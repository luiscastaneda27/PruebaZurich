/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : Controller class to generate the JSON of the special conditions
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/09/2023		initial version
1.1      ATO			17/10/2023		Correction of the order of columns and row data
1.2      ATO			25/10/2023		Correction of the JSON structure of rates
1.3      ATO			25/10/2023		Correction of line breaks in the content of the glosses
1.4      ATO			25/10/2023		Correction of special glosses
********************************************************************************/
global without sharing class ZRH_ConditionedTables {

    /**
    *  @Description: Static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    private static final Set<String> PVR_SET_IDS_COVERAGE_RATE;
    private static final Set<String> PVR_SET_IDS_RATES;
    private static final Set<String> PVR_SET_IDS_ELIGIBILITY_REQUIREMENTS;
    private static final Set<String> PVR_SET_IDS_MEDICAL_REQUIREMENTS;
    private static final Set<String> PVR_SET_IDS_SURCHARGE;
    private static final Map<String, ZRH_ConfiguracionTraduccion__mdt> PVR_MAP_TRANSLATIONS;
    private static final String PVR_STR_TYPE;
    private static final String PVR_STR_CVRNAME;
    private static final String PVR_STR_GLSAPINAME;
    private static final String PVR_STR_FIELDAPINAME;
    private static final String PVR_STR_CODEGLOSS;
    private static final String PVR_STR_HASHTAG;
    private static final String PVR_STR_START_PARAGRAPH;
    private static final String PVR_STR_END_PARAGRAPH;
    private static final String PVR_STR_LINE_BREAK;
    private static final String PVR_STR_AGE;
    private static final Set<String> PVR_SET_IDS_LIFE;
	private static final Set<String> PVR_SET_IDS_LIFESCHOOLING;
	private static final Set<String> PVR_SET_IDS_FAMILYPROTECTION;
	private static final Set<String> PVR_SET_IDS_HEALTH;
	private static final Set<String> PVR_SET_IDS_PERSONALACCIDENTS;

    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    static {
        PVR_SET_IDS_COVERAGE_RATE = new Set<String>{'83.0', '84.0', '85.0', '86.0', '88.0'}; //Set the gloss IDs for the coverage table
        PVR_SET_IDS_RATES = new Set<String>{'141.0'}; // Set the gloss IDs for the rate table
        PVR_SET_IDS_ELIGIBILITY_REQUIREMENTS = new Set<String>{'153.0'}; // Set the gloss IDs for the Eligibility requirements table
        PVR_SET_IDS_MEDICAL_REQUIREMENTS = new Set<String>{'158.0'}; // Set the gloss IDs for the medical requirements table
        PVR_SET_IDS_SURCHARGE = new Set<String>{'143.0'}; // Set the gloss IDs for the Surcharge table
        PVR_MAP_TRANSLATIONS = setTranslations();
        PVR_STR_TYPE = 'Rates';
        PVR_STR_CVRNAME = 'Nombre Cobertura';
        PVR_STR_GLSAPINAME = 'ZRH_Glosas__c';
        PVR_STR_FIELDAPINAME = 'ZRH_TipoDeGlosa__c';
        PVR_STR_CODEGLOSS = 'G-003';
        PVR_STR_AGE = 'Edades';
        PVR_STR_HASHTAG = '###';
        PVR_STR_START_PARAGRAPH = '<p>';
        PVR_STR_END_PARAGRAPH = '</p>';
        PVR_STR_LINE_BREAK = ' \n';
        PVR_SET_IDS_LIFE = new Set<String>{'500'};
        PVR_SET_IDS_LIFESCHOOLING = new Set<String>{'501'};
        PVR_SET_IDS_FAMILYPROTECTION = new Set<String>{'502'};
        PVR_SET_IDS_HEALTH = new Set<String>{'600', '601', '602', '603', '604', '605', '606'};
        PVR_SET_IDS_PERSONALACCIDENTS = new Set<String>{'700'};
    }  
    
    private ZRH_StaticResourcesSelector staticResourceSelector;
    private ZRH_GlosasSelector glosasSelector;
    private ZRH_QuoteLineItemsSelector qliSelector;
    private static ZRH_ConfiguracionTraduccionesSelector translationsSelector;

    /**
    *  @Description: Mapping the JSON of glosses with their respective tables
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public ZRH_JSONGlossTables mapping(Set<ID> setIds) {
        
            Decimal count = 1.0;
            Integer location = 0;
        try {
            Map<String,String> mapPicklistValues = getPicklistValues(PVR_STR_GLSAPINAME, PVR_STR_FIELDAPINAME);
            ZRH_JSONGlossTables gloss = new ZRH_JSONGlossTables();
            gloss.CondicionadosParticulares = new List<ZRH_JSONGlossTables.CondicionadosParticulares>();
            Map<QuoteLineItem, List<GlossWrapper>> mapQliGloss = mapQueries(setIds);
            Map<Id, List<QuoteLineItem>> mapCvr = mapCoverage(setIds);
            for (QuoteLineItem qli : mapQliGloss.keySet()) {
                ZRH_JSONGlossTables.CondicionadosParticulares particularConditions = new ZRH_JSONGlossTables.CondicionadosParticulares();
                particularConditions.codigoPlan = toInt(qli.ZRH_CodigoProducto__c);
                particularConditions.condicionados = new List<ZRH_JSONGlossTables.Condicionados>();
                mapQliGloss.get(qli).sort();
                location = toInt((mapQliGloss.get(qli)).get((mapQliGloss.get(qli).size() - 1)).objGloss.ZRH_LocalizacionCondicionado__c);
                for (GlossWrapper gw : mapQliGloss.get(qli)) {
                    ZRH_Glosas__c g = gw.objGloss;
                    ZRH_JSONGlossTables.Condicionados obj = new ZRH_JSONGlossTables.Condicionados();
                    obj.titulo = g.ZRH_Titulo__c == null ? '' : g.ZRH_Titulo__c;
                    obj.tipo = g.ZRH_TipoDeGlosa__c != null ? mapPicklistValues.get(g.ZRH_TipoDeGlosa__c) : null;
                    obj.ordenCondc = g.ZRH_TipoDeGlosa__c == PVR_STR_CODEGLOSS ? (location + count++) : g.ZRH_LocalizacionCondicionado__c;
                    obj.contenido = ((g.ZRH_ContenidoGlosa__c.replaceAll(PVR_STR_START_PARAGRAPH, '').replaceAll(PVR_STR_END_PARAGRAPH, PVR_STR_HASHTAG)).stripHtmlTags()).replaceAll(PVR_STR_HASHTAG, PVR_STR_LINE_BREAK);
                    obj = mapTables(mapCvr, g, obj, qli);
                    particularConditions.condicionados.add(obj);
                }
                gloss.CondicionadosParticulares.add(particularConditions);
            }
            String Strgloss = JSON.serialize(gloss, true);
            return gloss;
        } catch (Exception e) {
            // Handle any exceptions
            System.debug(location +'----' + count);
            System.debug('Message: ' + e.getMessage());
            System.debug('Cause: ' + e.getCause());
            System.debug('LineNumber: ' + e.getLineNumber());            
            System.debug('StackTraceString: ' + e.getStackTraceString());
            System.debug('TypeName: ' + e.getTypeName());
        }
        
        return null;
    }

    /**
    *  @Description: Orchestrates the generation of tables for the glosses
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public ZRH_JSONGlossTables.Condicionados mapTables(Map<Id, List<QuoteLineItem>> mapCvr, ZRH_Glosas__c g, ZRH_JSONGlossTables.Condicionados obj, QuoteLineItem qli) {
        obj.tablasCondicionado  = new List<ZRH_JSONGlossTables.TablasCondicionado>();        
        ZRH_JSONGlossTables.TablasCondicionado conditioned = new ZRH_JSONGlossTables.TablasCondicionado();
        conditioned.ordenTabla = 1;
        //columns
        conditioned.columnas = new List<ZRH_JSONGlossTables.Columnas>();
        //rows
        conditioned.filas = new List<ZRH_JSONGlossTables.Filas>();
        if (PVR_SET_IDS_COVERAGE_RATE.contains(String.valueOf(g.ZRH_IDGlosa__c)) && !PVR_SET_IDS_LIFESCHOOLING.contains(qli.ZRH_CodigoProducto__c)) {
            obj.tablasCondicionado.add(mapCoverageRate(conditioned, mapCvr, g));
        } else if (PVR_SET_IDS_RATES.contains(String.valueOf(g.ZRH_IDGlosa__c))) {
            obj.tablasCondicionado.add(mapRates(conditioned, qli));
        } else if (PVR_SET_IDS_ELIGIBILITY_REQUIREMENTS.contains(String.valueOf(g.ZRH_IDGlosa__c)) && PVR_SET_IDS_PERSONALACCIDENTS.contains(qli.ZRH_CodigoProducto__c)) {
            obj.tablasCondicionado.add(mapEligibilityRequirements(conditioned, qli));
        } else if (PVR_SET_IDS_MEDICAL_REQUIREMENTS.contains(String.valueOf(g.ZRH_IDGlosa__c)) && !PVR_SET_IDS_PERSONALACCIDENTS.contains(qli.ZRH_CodigoProducto__c)) {
            obj.tablasCondicionado.add(mapMedicalRequirements(conditioned, qli));
        } else if (PVR_SET_IDS_SURCHARGE.contains(String.valueOf(g.ZRH_IDGlosa__c))) {
            obj.tablasCondicionado.add(mapSurcharge(conditioned, qli));
        }
        obj.cantidadTablas = obj.tablasCondicionado.size();
        return obj;
    }

    /**
    *  @Description: Generate the Coverage table
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public ZRH_JSONGlossTables.TablasCondicionado mapCoverageRate(ZRH_JSONGlossTables.TablasCondicionado conditioned, Map<Id, List<QuoteLineItem>> mapCvr, ZRH_Glosas__c g) {
        Integer countColumns = 0;
        for (QuoteLineItem cvr : orderAttributeCrv(mapCvr.get(g.ZRH_QuoteLineItem__c))) {
            ZRH_JSONGlossTables.Filas rows = new ZRH_JSONGlossTables.Filas();
            if (cvr.vlocity_ins__AttributeSelectedValues__c != null) {
                Map<String, Object> attrMap = (Map<String, Object>) JSON.deserializeUntyped(cvr.vlocity_ins__AttributeSelectedValues__c);
                if (countColumns == 0) {
                    ZRH_JSONGlossTables.Columnas columns = new ZRH_JSONGlossTables.Columnas();
                    columns.nombreColumna = PVR_STR_CVRNAME;
                    conditioned.columnas.add(columns);
                }
                rows.datos = new List<ZRH_JSONGlossTables.Datos>();
                ZRH_JSONGlossTables.Datos firstData = new ZRH_JSONGlossTables.Datos();
                firstData.dato = cvr.vlocity_ins__ProductName__c;
                rows.datos.add(firstData);
                for (String attr : attrMap.keySet()) {
                    countColumns++;
                    String order = PVR_MAP_TRANSLATIONS.containsKey(attr) ? toString(PVR_MAP_TRANSLATIONS.get(attr).ZRH_Orden__c) : null;
                    if (countColumns <= attrMap.keySet().size()) {
                        ZRH_JSONGlossTables.Columnas columns = new ZRH_JSONGlossTables.Columnas();
                        columns.nombreColumna = PVR_MAP_TRANSLATIONS.containsKey(attr) ? PVR_MAP_TRANSLATIONS.get(attr).ZRH_TraduccionFuncional__c : attr;
                        columns.orden = order;
                        conditioned.columnas.add(columns);
                    }
                    ZRH_JSONGlossTables.Datos data = new ZRH_JSONGlossTables.Datos();
                    data.dato = attrMap.get(attr) != null ? String.valueOf(attrMap.get(attr)) : '';
                    data.orden = order;
                    rows.datos.add(data);
                }
                rows.datos.sort();
                conditioned.filas.add(rows);
            }
        }
        conditioned.columnas.sort();
        conditioned.cantidadcolumnas = conditioned.columnas.size();
        conditioned.cantidadFilas = conditioned.filas.size();
        return conditioned;
    }

    /**
    *  @Description: Generate the Rates table
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public ZRH_JSONGlossTables.TablasCondicionado mapRates(ZRH_JSONGlossTables.TablasCondicionado conditioned, QuoteLineItem qli) {
        if (qli.ZRH_Tarifa__c  != null) {
            ZRH_JSONRates objRates = ZRH_JSONRates.parse(qli.ZRH_Tarifa__c);
            List<Object> items = (List<Object>) JSON.deserializeUntyped(getRateType(qli.ZRH_CodigoProducto__c, objRates));
            conditioned = conversionTotable(items, conditioned, PVR_STR_TYPE);
        }
        return conditioned;
    }

    /**
    *  @Description: Generate the Eligibility Requirements table
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public ZRH_JSONGlossTables.TablasCondicionado mapEligibilityRequirements(ZRH_JSONGlossTables.TablasCondicionado conditioned, QuoteLineItem qli) {
        if (qli.ZRH_AtributosRequisitosAsegurabilidad__c  != null) {
            List<Object> items;
            if (PVR_SET_IDS_LIFE.contains(qli.ZRH_CodigoProducto__c)) {
                List<ZRH_JSONEligibilityRequirements.Life> objRqm = (List<ZRH_JSONEligibilityRequirements.Life>)ZRH_JSONEligibilityRequirements.parseLife(qli.ZRH_AtributosRequisitosAsegurabilidad__c);
                items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objRqm, true));
            } else if (PVR_SET_IDS_LIFESCHOOLING.contains(qli.ZRH_CodigoProducto__c)) {
                List<ZRH_JSONEligibilityRequirements.LifeSchooling> objRqm = (List<ZRH_JSONEligibilityRequirements.LifeSchooling>)ZRH_JSONEligibilityRequirements.parseLifeSchooling(qli.ZRH_AtributosRequisitosAsegurabilidad__c);
                items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objRqm, true));
            } else if (PVR_SET_IDS_FAMILYPROTECTION.contains(qli.ZRH_CodigoProducto__c)) {
                List<ZRH_JSONEligibilityRequirements.FamilyProtection> objRqm = (List<ZRH_JSONEligibilityRequirements.FamilyProtection>)ZRH_JSONEligibilityRequirements.parseFamilyProtection(qli.ZRH_AtributosRequisitosAsegurabilidad__c);
                items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objRqm, true));
            } else if (PVR_SET_IDS_HEALTH.contains(qli.ZRH_CodigoProducto__c)) {
                List<ZRH_JSONEligibilityRequirements.Health> objRqm = (List<ZRH_JSONEligibilityRequirements.Health>)ZRH_JSONEligibilityRequirements.parseHealth(qli.ZRH_AtributosRequisitosAsegurabilidad__c);
                items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objRqm, true));
            } else if (PVR_SET_IDS_PERSONALACCIDENTS.contains(qli.ZRH_CodigoProducto__c)) {
                List<ZRH_JSONEligibilityRequirements.PersonalAccidents> objRqm = (List<ZRH_JSONEligibilityRequirements.PersonalAccidents>)ZRH_JSONEligibilityRequirements.parsePersonalAccidents(qli.ZRH_AtributosRequisitosAsegurabilidad__c);
                items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objRqm, true));
            }
            conditioned = conversionTotable(items, conditioned, null);
        }
        return conditioned;
    }

    /**
    *  @Description: Generate the Medical Requirements table
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public ZRH_JSONGlossTables.TablasCondicionado mapMedicalRequirements(ZRH_JSONGlossTables.TablasCondicionado conditioned, QuoteLineItem qli) {
        String str = qli.ZRH_AtributosReqMedicosSeleccionado__c;
        if (str  != null) {
            ZRH_JSONMedicalRequirements.columns objColumns = (ZRH_JSONMedicalRequirements.columns)ZRH_JSONMedicalRequirements.parseColumns(str);
            ZRH_JSONMedicalRequirements.FirstRow objFirstRow = (ZRH_JSONMedicalRequirements.FirstRow)ZRH_JSONMedicalRequirements.parseFirstRow(str);
            ZRH_JSONMedicalRequirements.SecondRow objSecondRow = (ZRH_JSONMedicalRequirements.SecondRow)ZRH_JSONMedicalRequirements.parseSecondRow(str);
            ZRH_JSONMedicalRequirements.ThirdRow objThirdRow = (ZRH_JSONMedicalRequirements.ThirdRow)ZRH_JSONMedicalRequirements.parseThirdRow(str);
            List<Object> items = new List<Object>();
            objColumns.Rango = PVR_STR_AGE;
            items.add((Object) JSON.deserializeUntyped(JSON.serialize(objColumns, true)));
            items.add((Object) JSON.deserializeUntyped(JSON.serialize(objFirstRow, true)));
            items.add((Object) JSON.deserializeUntyped(JSON.serialize(objSecondRow, true)));
            items.add((Object) JSON.deserializeUntyped(JSON.serialize(objThirdRow, true)));
            conditioned = conversionTotable(items, conditioned, null);
        }
        return conditioned;
    }

    /**
    *  @Description: Generate the Surcharge table
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public ZRH_JSONGlossTables.TablasCondicionado mapSurcharge(ZRH_JSONGlossTables.TablasCondicionado conditioned, QuoteLineItem qli) {
        String str = qli.Quote.ZRH_AtributosSobreprimasSeleccionados__c;
        if (str  != null) {
            List<ZRH_JSONSurcharge> objSurcharge = (List<ZRH_JSONSurcharge>)ZRH_JSONSurcharge.parse(str);
            List<Object> items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objSurcharge, true));
            conditioned = conversionTotable(items, conditioned, null);
        }
        return conditioned;
    }

    /**
    *  @Description: Convert a JSON to a table
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public ZRH_JSONGlossTables.TablasCondicionado conversionTotable(List<Object> items, ZRH_JSONGlossTables.TablasCondicionado conditioned, String type) {
        Map<Integer, Map<String, Object>> itemsMap = new Map<Integer, Map<String, Object>>();
        Integer countKey = 0;
        for (Object instance : items){
            itemsMap.put(countKey, (Map<String, Object>)instance);
            countKey++;
        }
        if (type == PVR_STR_TYPE) {
            itemsMap.remove(itemsMap.size() - 1);
        }
        countKey = 0;
        for (Integer ik : itemsMap.keySet()) {
            ZRH_JSONGlossTables.Filas rows = new ZRH_JSONGlossTables.Filas();
            rows.datos = new List<ZRH_JSONGlossTables.Datos>();
            Map<String, Object> valuesMap = itemsMap.get(ik);
            for (String vk : valuesMap.keySet()){
                countKey++;
                String order = PVR_MAP_TRANSLATIONS.containsKey(vk) ? toString(PVR_MAP_TRANSLATIONS.get(vk).ZRH_Orden__c) : null;
                if (countKey <= valuesMap.keySet().size()) {
                    ZRH_JSONGlossTables.Columnas columns = new ZRH_JSONGlossTables.Columnas();
                    columns.nombreColumna = PVR_MAP_TRANSLATIONS.containsKey(vk) ? PVR_MAP_TRANSLATIONS.get(vk).ZRH_TraduccionFuncional__c : vk;
                    columns.orden = order; 
                    conditioned.columnas.add(columns);
                }
                ZRH_JSONGlossTables.Datos data = new ZRH_JSONGlossTables.Datos();
                data.dato = String.valueOf(valuesMap.get(vk));
                data.orden = order;
                if (data.dato != '' && data.dato != null) {
                    rows.datos.add(data);
                }                
            }
            rows.datos.sort();
            conditioned.filas.add(rows);
        }
        conditioned.columnas.sort();
        conditioned.cantidadcolumnas = conditioned.columnas.size();
        conditioned.cantidadFilas = conditioned.filas.size();
        return conditioned;
    }

    /**
    *  @Description: Set a map of QuoteLineItems with list of glosses
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/09/2023
    */
    public Map<QuoteLineItem, List<GlossWrapper>> mapQueries(Set<ID> ids) {
        glosasSelector = new ZRH_GlosasSelector();
        qliSelector = new ZRH_QuoteLineItemsSelector();
        Map<Id,QuoteLineItem> qliQuery = qliSelector.selectProductsBySetIds(ids);
        List<ZRH_Glosas__c>  glossQuery = glosasSelector.selectBySetIds(null, qliQuery.keySet());
        Map<QuoteLineItem, List<GlossWrapper>> mapQliGloss = new Map<QuoteLineItem, List<GlossWrapper>>();
        Map<Id, List<GlossWrapper>> mapGloss = new Map<Id, List<GlossWrapper>>();
        for (ZRH_Glosas__c g : glossQuery) {
            List<GlossWrapper> glosslst = mapGloss.get(g.ZRH_QuoteLineItem__c);
            if (glosslst == null) {
                glosslst = new List<GlossWrapper>();
            }
            glosslst.add(new glossWrapper(g));
            mapGloss.put(g.ZRH_QuoteLineItem__c, glosslst);
        }
        for (QuoteLineItem qliEach: qliQuery.values()) {
            if (mapGloss.containsKey(qliEach.Id)) {
                mapQliGloss.put(qliEach, mapGloss.get(qliEach.Id));
            }
        }
        return mapQliGloss;
    }

    /**
    *  @Description: Sets a map of QuoteLineItems with their IDs
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/09/2023
    */
    public Map<Id, List<QuoteLineItem>> mapCoverage(Set<ID> ids) {
        qliSelector = new ZRH_QuoteLineItemsSelector();
        List<QuoteLineItem> cvrQuery = qliSelector.selectCoverageBySetIds(ids);
        Map<Id, List<QuoteLineItem>> mapCvr = new Map<Id, List<QuoteLineItem>>();
        for (QuoteLineItem cvr : cvrQuery) {
            List<QuoteLineItem> cvrLst = mapCvr.get(cvr.vlocity_ins__ParentItemId2__c);
            if (cvrLst == null) {
                cvrLst = new List<QuoteLineItem>();
            }
            if (cvr.vlocity_ins__ParentItemId2__c != null) {
                cvrLst.add(cvr);
                mapCvr.put(cvr.vlocity_ins__ParentItemId2__c, cvrLst);
            }            
        }
        return mapCvr;
    }

    /**
    *  @Description: Get picklist values
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/09/2023
    */
    public static Map<String,String> getPicklistValues(String sObjectType, String fieldApiName) {
        Map<String,String> options = new Map<String,String>();
        for (Schema.PicklistEntry pickListVal : getPickListEntry(sObjectType, fieldApiName)) {
            if (pickListVal.isActive()) {
                options.put(pickListVal.getValue(), pickListVal.getLabel());
            }
        }
        return options;
    }

    /**
    *  @Description: Gets the values ​​of a picklist depending on the object and the field
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/09/2023
    */
    private static List<Schema.PicklistEntry> getPickListEntry(String sObjectType, String fieldApiName) {
        // Globally desribe all the objects 
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();
        DescribeSObjectResult describeResult = globalDescribe.get(sObjectType).getDescribe();
        Map<String, Schema.SObjectField> describedFields = describeResult.fields.getMap();
        Schema.SObjectField field = describedFields.get(fieldApiName);
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        return ple;
    }

    /**
    *  @Description: Converts an object to a String
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/09/2021
    */
    private String toString(Object str){
        String res = str != Null ? String.valueOf(str) : null;
        return res;
    }

    /**
    *  @Description: Converts an object to an Integer
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/09/2021
    */
    private Integer toInt(Object str){
        Integer res = str != Null ? Integer.valueOf(str) : null;
        return res;
    }

    /**
    *  @Description: Set the map for the translation of the tables
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public static Map<String, ZRH_ConfiguracionTraduccion__mdt> setTranslations() {
        translationsSelector = new ZRH_ConfiguracionTraduccionesSelector();
        Map<String, ZRH_ConfiguracionTraduccion__mdt> trlMap =  new Map<String, ZRH_ConfiguracionTraduccion__mdt>();
        List<ZRH_ConfiguracionTraduccion__mdt> listTrl = translationsSelector.selectAll();
        for (ZRH_ConfiguracionTraduccion__mdt ct : listTrl){
            trlMap.put(ct.ZRH_Tag__c, ct);
        }
        return trlMap;
    }

    /**
    *  @Description: Gets the JSON of rates depending on the plan
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public String getRateType(String prodCode, ZRH_JSONRates objRates) {
        String obj = '';
        if (prodCode.isNumeric() && Integer.valueOf(prodCode) >= 500 && Integer.valueOf(prodCode) <= 502) {
            obj = JSON.serialize(objRates.TarifaVida, true);
        } else if (prodCode.isNumeric() && Integer.valueOf(prodCode) >= 600 && Integer.valueOf(prodCode) <= 606 ) {
            obj = JSON.serialize(objRates.TarifaSalud, true);
        }
        return obj;
    }
    
    /**
    *  @Description: Order coverage attributes
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/5/2024
    */
    public static List<QuoteLineItem> orderAttributeCrv(List<QuoteLineItem> cvrList){
        List<String> allAttributes = new List<String>();
        for (QuoteLineItem cvr : cvrList) {
            if (cvr.vlocity_ins__AttributeSelectedValues__c != null && ZRH_BatchSubmitPolicyProposalAS400.convertInt(cvr.ZRH_CodigoProducto__c) != null) {
                Map<String, Object> attrMap = (Map<String, Object>) JSON.deserializeUntyped(cvr.vlocity_ins__AttributeSelectedValues__c);
                for (String attr : attrMap.keySet()) {
                    if(!allAttributes.contains(attr) && attrMap.get(attr) != null){
                        allAttributes.add(attr);
                    }
                }
            }
        }
        
        for (Integer i = 0; i < cvrList.size(); i++) {
            if (cvrList[i].vlocity_ins__AttributeSelectedValues__c != null && ZRH_BatchSubmitPolicyProposalAS400.convertInt(cvrList[i].ZRH_CodigoProducto__c) != null) {
                Map<String, Object> attrMap = (Map<String, Object>) JSON.deserializeUntyped(cvrList[i].vlocity_ins__AttributeSelectedValues__c);
                Map<String, Object> attrMapOrd = new Map<String, Object>();
                for(String attr : allAttributes){
                    attrMapOrd.put(attr, attrMap.get(attr));
                }
                cvrList[i].vlocity_ins__AttributeSelectedValues__c = JSON.serialize(attrMapOrd);
            }
        }
        return cvrList;
    }

    /**
    *  @Description: Wrapper class for organizing glosses by plan
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        25/10/2023
    */   
    public class GlossWrapper implements comparable {
        public ZRH_Glosas__c objGloss;

        public glossWrapper (){
        }
		// Constructor        
		public glossWrapper(ZRH_Glosas__c gl) {
			this.objGloss = gl;
		}

        public Integer compareTo (Object compareTo) {
            glossWrapper glossW = (glossWrapper)compareTo;
            Integer returnValue = 0;
            if ((objGloss.ZRH_LocalizacionCondicionado__c  == null) && (glossW.objGloss.ZRH_LocalizacionCondicionado__c == null)) {
                // both wrappers have null Locations
                returnValue = 0;
            } else if ((objGloss.ZRH_LocalizacionCondicionado__c  == null) && (glossW.objGloss.ZRH_LocalizacionCondicionado__c != null)) {
                // nulls-first implementation
                returnValue = -1;
            } else if ((objGloss.ZRH_LocalizacionCondicionado__c  != null) && (glossW.objGloss.ZRH_LocalizacionCondicionado__c == null)) {
                // nulls-first implementation
                returnValue = 1;
            } else if (objGloss.ZRH_LocalizacionCondicionado__c > glossW.objGloss.ZRH_LocalizacionCondicionado__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (objGloss.ZRH_LocalizacionCondicionado__c < glossW.objGloss.ZRH_LocalizacionCondicionado__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            Return returnValue; 
        }
    }
    

}