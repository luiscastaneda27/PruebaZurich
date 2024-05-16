public  class ZRH_CalculateHoldingRatesBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public String quoteId;
    private List<QuoteLineItem> toDeleteQlis = new List<QuoteLineItem>();
    private List<QuoteLineItem> toUpdateQlis = new List<QuoteLineItem>();
    
    public List<QuoteLineItem> start(Database.BatchableContext BC) {

        List<QuoteLineItem> qlis = new ZRH_QuoteLineItemsSelector().selectChildRootQLIsByParentQuoteId(quoteId);
        List<QuoteLineItem> parentQlis = new ZRH_QuoteLineItemsSelector().selectById(quoteId);

        Map<String, List<QuoteLineItem>> mapRateKeyPlans = new Map<String, List<QuoteLineItem>>();
        Set<String> keysToUpdate = new Set<String>();

        //Map rates to qlis
        for (QuoteLineItem qli : qlis) {
            String key = createKey(qli);
            if (!mapRateKeyPlans.containsKey(key)) {
                mapRateKeyPlans.put(key, new List<QuoteLineItem>{qli});
            } else {
            mapRateKeyPlans.get(key).add(qli);
            }
        }

        //Check which rates have been modified, as long as one qli from the rate was modfied, all need to be included in processing. 
        //Or if one of the plans was deleted, all restant ones need to be included in processing.
        for (QuoteLineItem qli : qlis) {
            String key = createKey(qli);
            if (keysToUpdate.contains(key)) {
                continue;
            }
            if (qli.ZRH_TarifaModificada__c == true && qli.ZRH_TipoTarifaPrevia__c != null) {
                
                //Add the key of the rate that the qli was changed to
                keysToUpdate.add(key);
                
                //Add the key for the rate that the qli was changed from
                String rateType = qli.ZRH_TipoTarifaPrevia__c;
                String productCode = qli.Product2.ProductCode;
                String productType = qli.Product2.vlocity_ins__Type__c;
                String fromKey = rateType + '-' + productCode + '-' + productType;
                keysToUpdate.add(fromKey);
                
            } else if (qli.ZRH_TarifaModificada__c == true) {
                keysToUpdate.add(key);
            }
        }

        //If no rate was modified but some plan of the same rate is deleted, we need to re calculate.
        for (QuoteLineItem qli : parentQlis) {
            String parentKey = createKey(qli);
            System.debug('numero anterior: ' + qli.ZRH_NumeroDePlanesEnContratantes__c);
            if (!mapRateKeyPlans.containsKey(parentKey) || qli.ZRH_NumeroDePlanesEnContratantes__c > mapRateKeyPlans.get(parentKey).size()) {
                keysToUpdate.add(parentKey);
            }
        }
        
        List<QuoteLineItem> qlisToUpdate = new List<QuoteLineItem>();
        //Add all the qlis that need to be updated, if only one has been updated, then all need to go through the processing
        for (String ratesKey : mapRateKeyPlans.keySet()) {
            if (keysToUpdate.contains(ratesKey)) {
                qlisToUpdate.addAll(mapRateKeyPlans.get(ratesKey));
            }
        }

        //Delete the rates that have suffered changes
        map<String, QuoteLineItem> mapRateKeyHoldingPlans = new map<String, QuoteLineItem>();
        Set<String> toDeleteKeys = new Set<String>();

        for (QuoteLineItem qli : parentQlis) {
            String parentKey = createKey(qli);
            //Holding plans that no longer exist || holding plans that have been modified will be deleted
            if (!mapRateKeyPlans.containsKey(parentKey) || keysToUpdate.contains(parentKey)) {
                toDeleteQlis.add(qli);        
                toDeleteKeys.add(parentKey);
            }
        }

        System.debug('qlis: ' + qlis);
        System.debug('keysToUpdate: ' + keysToUpdate);
        System.debug('toDeleteKeys: ' + toDeleteKeys);
        System.debug('qlisToUpdate: ' + qlisToUpdate);
        System.debug('num of qlisToUpdate: ' + qlisToUpdate.size());
        System.debug('toDeleteQlis: ' + toDeleteQlis);
        System.debug('num of toDeleteQlis: ' + toDeleteQlis.size());

        return qlisToUpdate;

    }
    
    public void execute(Database.BatchableContext BC, List<QuoteLineItem> scope) {
        
        Map<QuoteLineItem, List<String>> parentQliRatesToAdd = new Map<QuoteLineItem, List<String>>();
        Map<String, QuoteLineItem> keyParentQli = new Map<String, QuoteLineItem>();
        Map<QuoteLineItem, String> parentQliKey = new Map<QuoteLineItem, String>();
        List<QuoteLineItem> parentQuoteLineItems = new List<QuoteLineItem>();
        
        //Creates a Holding QLI for each different prod + ratetype that exists 
        for (QuoteLineItem qli : scope) {
            String key = createKey(qli);
            if (!keyParentQli.containsKey(key)) {
                QuoteLineItem newParentQli = createNewParentQLI(qli.Quote.ZRH_CotizacionHolding__c, qli.PricebookEntryId, qli.ZRH_TipoTarifa__c);
                keyParentQli.put(key, newParentQli);
                parentQliKey.put(newParentQli, key);
                parentQliRatesToAdd.put(newParentQli, new List<String>());
            }
            //Add the rate of the given qli to the list of rates to sum of the matching holding QLI 
            parentQliRatesToAdd.get(keyParentQli.get(key)).add(qli.ZRH_Tarifa__c);
        }
        //Go through Holding QLIs and decide which calculation to apply given the product being processed
        for (QuoteLineItem parentQli : parentQliRatesToAdd.keySet()) {
           
            List<String> childQliRates = parentQliRatesToAdd.get(parentQli);
            Integer numberOfChildRates = childQliRates.size();
           
            if (childQliRates.isEmpty()) {
                continue;
            }
            
            String key = parentQliKey.get(parentQli);
            List<String> parts = key.split('-');
            String rateType = parts[0];
            String productCode = parts[1];
            String productType = parts[2];
            if (productType == 'Vida' && productCode != '501') {
                String lifeRate = lifeRateCalculation(childQliRates, parentQli.ZRH_Tarifa__c);
                parentQli.ZRH_Tarifa__c = lifeRate;
                parentQli.ZRH_NumeroDePlanesEnContratantes__c = numberOfChildRates;
            }
            if (productCode == '501') {
                String scholarRate = scholarRateCalculation(childQliRates, parentQli.ZRH_Tarifa__c);
                parentQli.ZRH_Tarifa__c = scholarRate;
                parentQli.ZRH_NumeroDePlanesEnContratantes__c = numberOfChildRates;
            }
            if (productType == 'Salud') {
                String healthRate = healthRateCalculation(childQliRates, rateType, parentQli.ZRH_Tarifa__c);
                parentQli.ZRH_Tarifa__c = healthRate;
                parentQli.ZRH_NumeroDePlanesEnContratantes__c = numberOfChildRates;
            }
            parentQuoteLineItems.add(parentQli);  
        }
        upsert parentQuoteLineItems;

        for (QuoteLineItem qli : scope) {
            QuoteLineItem qliUpdt = new QuoteLineItem();
            qliUpdt.Id = qli.Id;
            qliUpdt.ZRH_TarifaModificada__c = false;
            qliUpdt.ZRH_TipoTarifaPrevia__c = null;
            toUpdateQlis.add(qliUpdt);
        }
    }

    public static String scholarRateCalculation(List<String> scholarRates, String actualRootRate) {
        if (actualRootRate != null) {
            scholarRates.add(actualRootRate);    
        }
        // Initialize a map to hold the summarized data
        Map<String, List<Decimal>> summaryMap = new Map<String, List<Decimal>>();
        // Loop through child JSONs to summarize data
        for (String childJson : scholarRates) {
            Map<String, Object> childRecords = (Map<String, Object>) JSON.deserializeUntyped(childJson);
            Object tarifaEscolaridadValue = childRecords.get('TarifaEscolaridad');
            List<Object> tarifaEscolaridad = new List<Object>();
            if (tarifaEscolaridadValue instanceof Map<String,Object>) {
                tarifaEscolaridad.add(tarifaEscolaridadValue);
            } else {
                tarifaEscolaridad = (List<Object>) tarifaEscolaridadValue;
            }
            for (Object tarifa : tarifaEscolaridad) {
                Map<String, Object> tar = (Map<String, Object>) tarifa;
                String codigoCobertura = (String) tar.get('CodigoCobertura');
                String nombreCobertura = (String) tar.get('NombreCobEsc');
                List<Object> niveles = (List<Object>) tar.get('Niveles');
                
                for (Object nivel : niveles) {
                    Map<String, Object> niv = (Map<String, Object>) nivel;
                    String codigoNivel = (String) niv.get('CodigoNivel');
                    if (codigoNivel == null) {
                        continue;
                    }
                    String descripcionNivel = (String) niv.get('DescripcionNivel');
                    Decimal nAseguradosEsc = niv.containsKey('NAseguradosEsc') ? (niv.get('NAseguradosEsc') != null ? (niv.get('NAseguradosEsc') instanceof String ? Decimal.valueOf((String)niv.get('NAseguradosEsc')) : (Decimal)niv.get('NAseguradosEsc')) : Decimal.valueOf(0)) : Decimal.valueOf(0);
                    Decimal capAsegEsc = niv.containsKey('CapAsegEsc') ? (niv.get('CapAsegEsc') != null ? (niv.get('CapAsegEsc') instanceof String ? Decimal.valueOf((String)niv.get('CapAsegEsc')) : (Decimal)niv.get('CapAsegEsc')) : Decimal.valueOf(0)) : Decimal.valueOf(0);
                    Decimal primaAnualEsc = niv.containsKey('PrimaAnualEsc') ? (niv.get('PrimaAnualEsc') != null ? (niv.get('PrimaAnualEsc') instanceof String ? Decimal.valueOf((String)niv.get('PrimaAnualEsc')) : (Decimal)niv.get('PrimaAnualEsc')) : Decimal.valueOf(0)) : Decimal.valueOf(0);
                    Decimal primaAnualVigenteEsc = niv.containsKey('PrimaAnualVigenteEsc') ? (niv.get('PrimaAnualVigenteEsc') != null ? (niv.get('PrimaAnualVigenteEsc') instanceof String ? Decimal.valueOf((String)niv.get('PrimaAnualVigenteEsc')) : (Decimal)niv.get('PrimaAnualVigenteEsc')) : Decimal.valueOf(0)) : Decimal.valueOf(0);
                    Decimal primaMensualEsc = niv.containsKey('PrimaMensualEsc') ? (niv.get('PrimaMensualEsc') != null ? (niv.get('PrimaMensualEsc') instanceof String ? Decimal.valueOf((String)niv.get('PrimaMensualEsc')) : (Decimal)niv.get('PrimaMensualEsc')) : Decimal.valueOf(0)) : Decimal.valueOf(0);
                    Decimal primaMensualVigenteEsc = niv.containsKey('PrimaMensualVigenteEsc') ? (niv.get('PrimaMensualVigenteEsc') != null ? (niv.get('PrimaMensualVigenteEsc') instanceof String ? Decimal.valueOf((String)niv.get('PrimaMensualVigenteEsc')) : (Decimal)niv.get('PrimaMensualVigenteEsc')) : Decimal.valueOf(0)) : Decimal.valueOf(0);                    
                    String key = codigoCobertura + '-' + codigoNivel + '-' + nombreCobertura + '-' + descripcionNivel;
                    if (!summaryMap.containsKey(key)) {
                        summaryMap.put(key, new List<Decimal>{0, 0, 0, 0, 0, 0});
                    }
                    List<Decimal> values = summaryMap.get(key);
                    values[0] += nAseguradosEsc;
                    values[1] += capAsegEsc;
                    values[2] += primaAnualEsc;
                    values[3] += primaAnualVigenteEsc;
                    values[4] += primaMensualEsc;
                    values[5] += primaMensualVigenteEsc;
                }
            }
            
        }
        // Create the resulting JSON structure
        List<Map<String, Object>> summarizedTarifaEscolaridad = new List<Map<String, Object>>();
        for (String key : summaryMap.keySet()) {
            String[] parts = key.split('-');
            String codigoCobertura = parts[0];
            String codigoNivel = parts[1];
            String nombreCobertura = parts[2];
            String descripcionNivel = parts[3];
            List<Decimal> values = summaryMap.get(key);
            Map<String, Object> nivel = new Map<String, Object>{'NAseguradosEsc' => values[0], 
                                                                'CapAsegEsc' => values[1],
                                                                'PrimaAnualEsc' => values[2],
                                                                'PrimaAnualVigenteEsc' => values[3],
                                                                'PrimaMensualEsc' => values[4],                                                    
                                                                'PrimaMensualVigenteEsc' => values[5],                                                    
                                                                'CodigoNivel' => codigoNivel,
                                                                'DescripcionNivel' => descripcionNivel};
            Map<String, Object> tarifa = new Map<String, Object>{'Niveles' => new List<Map<String, Object>>{nivel}, 'CodigoCobertura' => codigoCobertura, 'NombreCobEsc' => nombreCobertura};
            
            // Check if the summarizedTarifaEscolaridad already contains the same CodigoCobertura
            Boolean found = false;
            for (Map<String, Object> existingTarifa : summarizedTarifaEscolaridad) {
                if (existingTarifa.get('CodigoCobertura') == codigoCobertura) {
                    List<Map<String, Object>> existingNiveles = (List<Map<String, Object>>) existingTarifa.get('Niveles');
                    existingNiveles.addAll((List<Map<String, Object>>) tarifa.get('Niveles'));
                    found = true;
                    break;
                }
            }
            
            if (!found) {
                summarizedTarifaEscolaridad.add(tarifa);
            }
        }
        Map<String, Object> parentRecord = new Map<String, Object>{'IdTipoTarifa' => '4', 'TarifaEscolaridad' => summarizedTarifaEscolaridad};
        String parentJson = JSON.serialize(parentRecord);
        return parentJson;
    }

    public static String healthRateCalculation(List<String> healthRates, String tipoTarifa, String actualRootRate) {// Sample JSON data for child records
        if (actualRootRate != null) {
            healthRates.add(actualRootRate);    
        }
        // Initialize a map to hold the summarized data
        Map<String, Map<String, Decimal>> summaryMap = new Map<String, Map<String, Decimal>>();
        
        // Loop through child JSONs to summarize data
        for (String childJson : healthRates) {
            Map<String, Object> childRecord = (Map<String, Object>) JSON.deserializeUntyped(childJson);
        
            List<Object> tarifaSaludList = (List<Object>) childRecord.get('TarifaSalud');
            for (Object tarifaSaludObj : tarifaSaludList) {
                Map<String, Object> tarifaSalud = (Map<String, Object>) tarifaSaludObj;
                
                if (tarifaSalud.containsKey('CodigoSubtipoTarifa')) {
                    String codigoSubtipoTarifa = (String) tarifaSalud.get('CodigoSubtipoTarifa');
                    String descripcionSubtipoTarifa = (String) tarifaSalud.get('DescTarifaSalud');                    
                    Decimal edadInicio = tarifaSalud.containsKey('EdadInicio') && tarifaSalud.get('EdadInicio') != null ? (tarifaSalud.get('EdadInicio') instanceof String ? Decimal.valueOf((String)tarifaSalud.get('EdadInicio')) : (Decimal)tarifaSalud.get('EdadInicio')) : Decimal.valueOf(0);
                    Decimal edadTermino = tarifaSalud.containsKey('EdadTermino') && tarifaSalud.get('EdadTermino') != null ? (tarifaSalud.get('EdadTermino') instanceof String ? Decimal.valueOf((String)tarifaSalud.get('EdadTermino')) : (Decimal)tarifaSalud.get('EdadTermino')) : Decimal.valueOf(0);
                    Decimal tarifaSaludNT = tarifaSalud.containsKey('TarifaSaludNT') && tarifaSalud.get('TarifaSaludNT') != null ? (tarifaSalud.get('TarifaSaludNT') instanceof String ? Decimal.valueOf((String)tarifaSalud.get('TarifaSaludNT')) : (Decimal)tarifaSalud.get('TarifaSaludNT')) : Decimal.valueOf(0);
                    
                    String key = codigoSubtipoTarifa + '-' + descripcionSubtipoTarifa;
                    if (!summaryMap.containsKey(key)) {
                        summaryMap.put(key, new Map<String, Decimal>());
                    }
                    
                    Map<String, Decimal> values = summaryMap.get(key);
                    values.put('TarifaSaludNT', values.containsKey('TarifaSaludNT') ? values.get('TarifaSaludNT') + tarifaSaludNT : tarifaSaludNT);
                    values.put('EdadInicio', edadInicio);
                    values.put('EdadTermino', edadTermino);
                }
            }
        }
        
        // Create the resulting JSON structure
        List<Map<String, Object>> summarizedTarifaSalud = new List<Map<String, Object>>();
        for (String key : summaryMap.keySet()) {
            String[] parts = key.split('-');
            String codigoSubtipoTarifa = parts[0];
            String descripcionSubtipoTarifa = parts[1];
            Map<String, Decimal> values = summaryMap.get(key);
            Map<String, Object> tarifaSalud = new Map<String, Object>{
                'CodigoSubtipoTarifa' => codigoSubtipoTarifa,
                'DescTarifaSalud' => descripcionSubtipoTarifa,
                'EdadInicio' => values.get('EdadInicio'),
                'EdadTermino' => values.get('EdadTermino'),
                'TarifaSaludNT' => values.containsKey('TarifaSaludNT') ? values.get('TarifaSaludNT') : Decimal.valueOf(0)
            };
            summarizedTarifaSalud.add(tarifaSalud);
        }
        
        Map<String, Object> parentRecord = new Map<String, Object>{
            'IdTipoTarifa' => tipoTarifa,
            'TarifaSalud' => summarizedTarifaSalud
        };
        String parentJson = JSON.serialize(parentRecord);
        
        return parentJson;
    }

    public static String lifeRateCalculation(List<String> lifeRates, String actualRootRate) {
        if (actualRootRate != null) {
            lifeRates.add(actualRootRate);    
        }
        // Initialize a map to hold the summarized data
        Map<String, List<Decimal>> summaryMap = new Map<String, List<Decimal>>();
        // Loop through child JSONs to summarize data
        for (String childJson : lifeRates) {
            System.debug(childJson);
            Map<String, Object> childRecord = (Map<String, Object>) JSON.deserializeUntyped(childJson);
            List<Object> tarifaVidaList = (List<Object>) childRecord.get('TarifaVida');
            for (Object tarifaVidaObj : tarifaVidaList) {
                Map<String, Object> tarifaVida = (Map<String, Object>) tarifaVidaObj;
                
                String codigoCobertura = (String) tarifaVida.get('CodigoCobertura');
                String nombreCobertura = (String) tarifaVida.get('NombreCobertura');
                
                String key = codigoCobertura + '-' + nombreCobertura;
                if (!summaryMap.containsKey(key)) {
                    summaryMap.put(key, new List<Decimal>{0, 0, 0, 0, 0, 0});
                }
                
                List<Decimal> values = summaryMap.get(key);
                
                Decimal numeroAsegurados = tarifaVida.containsKey('NumeroAsegurados') ? (tarifaVida.get('NumeroAsegurados') != null ? (tarifaVida.get('NumeroAsegurados') instanceof String ? Decimal.valueOf((String)tarifaVida.get('NumeroAsegurados')) : (Decimal)tarifaVida.get('NumeroAsegurados')) : Decimal.valueOf(0)) : Decimal.valueOf(0);
                Decimal capitalAseguradoUF = tarifaVida.containsKey('CapitalAseguradoUF') ? (tarifaVida.get('CapitalAseguradoUF') != null ? (tarifaVida.get('CapitalAseguradoUF') instanceof String ? Decimal.valueOf((String)tarifaVida.get('CapitalAseguradoUF')) : (Decimal)tarifaVida.get('CapitalAseguradoUF')) : Decimal.valueOf(0)) : Decimal.valueOf(0);
                Decimal primaAnualUF = tarifaVida.containsKey('PrimaAnualUF') ? (tarifaVida.get('PrimaAnualUF') != null ? (tarifaVida.get('PrimaAnualUF') instanceof String ? Decimal.valueOf((String)tarifaVida.get('PrimaAnualUF')) : (Decimal)tarifaVida.get('PrimaAnualUF')) : Decimal.valueOf(0)) : Decimal.valueOf(0);
                Decimal primaAnualVigenteUF = tarifaVida.containsKey('PrimaAnualVigenteUF') ? (tarifaVida.get('PrimaAnualVigenteUF') != null ? (tarifaVida.get('PrimaAnualVigenteUF') instanceof String ? Decimal.valueOf((String)tarifaVida.get('PrimaAnualVigenteUF')) : (Decimal)tarifaVida.get('PrimaAnualVigenteUF')) : Decimal.valueOf(0)) : Decimal.valueOf(0);
                Decimal primaMensualUF = tarifaVida.containsKey('PrimaMensualUF') ? (tarifaVida.get('PrimaMensualUF') != null ? (tarifaVida.get('PrimaMensualUF') instanceof String ? Decimal.valueOf((String)tarifaVida.get('PrimaMensualUF')) : (Decimal)tarifaVida.get('PrimaMensualUF')) : Decimal.valueOf(0)) : Decimal.valueOf(0);
                Decimal primaMensualVigenteUF = tarifaVida.containsKey('PrimaMensualVigenteUF') ? (tarifaVida.get('PrimaMensualVigenteUF') != null ? (tarifaVida.get('PrimaMensualVigenteUF') instanceof String ? Decimal.valueOf((String)tarifaVida.get('PrimaMensualVigenteUF')) : (Decimal)tarifaVida.get('PrimaMensualVigenteUF')) : Decimal.valueOf(0)) : Decimal.valueOf(0);                
                
                values[0] += primaMensualUF;
                values[1] += primaMensualVigenteUF;
                values[2] += numeroAsegurados;
                values[3] += primaAnualUF;
                values[4] += primaAnualVigenteUF;
                values[5] += capitalAseguradoUF;
            }
        }
        // Create the resulting JSON structure
        List<Map<String, Object>> summarizedTarifaVida = new List<Map<String, Object>>();
        for (String key : summaryMap.keySet()) {
            String[] parts = key.split('-');
            String codigoCobertura = parts[0];
            String nombreCobertura = parts[1];
            List<Decimal> values = summaryMap.get(key);
            Map<String, Object> tarifaVida = new Map<String, Object>{
                'CodigoCobertura' => codigoCobertura,
                'NombreCobertura' => nombreCobertura,
                'PrimaMensualUF' => values[0],
                'PrimaMensualVigenteUF' => values[1],
                'NumeroAsegurados' => values[2],
                'PrimaAnualUF' => values[3],
                'PrimaAnualVigenteUF' => values[4],
                'CapitalAseguradoUF' => values[5]
            };
            summarizedTarifaVida.add(tarifaVida);
        }
        Map<String, Object> parentRecord = new Map<String, Object>{
            'IdTipoTarifa' => '6',
            'TarifaVida' => summarizedTarifaVida
        };
        String parentJson = JSON.serialize(parentRecord);
        return parentJson;
    }

    public static String createKey(QuoteLineItem qli) {
        String rateType = qli.ZRH_TipoTarifa__c;
        String productCode = qli.Product2.ProductCode;
        String productType = qli.Product2.vlocity_ins__Type__c;
        String key = rateType + '-' + productCode + '-' + productType;
        return key;
    }

    public static QuoteLineItem createNewParentQLI(String quoteId, String pbEntryId, String rateType) {
        QuoteLineItem newParentQli = new QuoteLineItem();
        newParentQli.QuoteId = quoteId;
        newParentQli.PricebookEntryId = pbEntryId;
        newParentQli.Quantity = 1;
        newParentQli.UnitPrice = 1;
        newParentQli.ZRH_TipoTarifa__c = RateType;
        return newParentQli;
    }

    public void finish(Database.BatchableContext BC) {

        AsyncApexJob a = new ZRH_AsyncApexJobsSelector().selectById(BC.getJobId())[0];

        if (a.NumberOfErrors == 0) {
            
            if (toDeleteQlis.size() > 0 ) {
                delete toDeleteQlis;
            }

            if (toUpdateQlis.size() > 0) {
                
                update toUpdateQlis;
            }
        } else {
            System.debug('errors: ' + a.ExtendedStatus);
        }

    }
}