/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 17/11/2023
Description  : Batch class to send policy proposal
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			17/11/2023		initial version
********************************************************************************/
global without sharing class ZRH_BatchSubmitPolicyProposalAS400 implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    private static final String FLAG_STATUS = '3';
    private static final String STATUS_POLICY_SUCCESS = '3';
    private static final String STATUS_POLICY_ERROR = '5';
    private static final String NAME_CUSTOM_NOTIFICATION = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_EnvioPropuestaPoliza';
    private static final String INTEGRATION_ROUTE_RENOVATION = 'ZRH_EnvioPropuestaPolizaRenovacion';
    private static final String NOTIFICATION_TITLE = 'Envió de pólizas';
    private static final String NOTIFICATION_TEXT = 'Se enviaron # propuestas de pólizas del grupo de negocio ';
    private static final String NOTIFICATION_TITLE_ERROR = 'Error en envió de pólizas';
    private static final String NOTIFICATION_TEXT_ERROR = 'Se producido un error al enviar la póliza ';
    private static final String STR_HEADER = 'header';
    private static final String STR_PATH = 'path';
    private static final String POLICY_NUMBER = 'numberPolicy';
    private static final String STR_HEADER_KEY = 'Content-Type';
    private static final String STR_HEADER_VALUE = 'application/json';
    private static final String STR_CODE_PRODUCT = '603';
    private static final String STR_CODE_PRODUCT_DENTAL = '605';
    private static final String STR_VALUE_YES = 'Si';
    private static final String STR_LEAD_COINSURED = 'L';
    private static final String STR_PARTICIPANT_COINSURED = 'P';
    private static final String SPLIT_TEXT = '-';
    private String queryCondition;
    private static final Set<String> DEDUCTIBLE_TYPE = new Set<String>{'Por Grupo Familiar - Diferenciado', 'Por Asegurado y Grupo Familiar - Diferenciado'};
    private static final Set<String> CAPITAL_TYPE_LIST = new Set<String>{'Mixto', 'Porcentaje', 'Valor'};
    private static final Set<Integer> STATUS_CODE_SUCCESSS = new Set<Integer>{200, 201};
    
    private static final String LIFE_SCHOLARSHIP_RATE = 'TarifaEscolaridad';
    private static final String TEXT_LEVEL_SCHOLARSHIP = 'Niveles';
    private static final String CODE_COVERAGE = 'CodigoCobertura';
    private static final String TEXT_COVERAGE_NAME_SCHOLARSHIP = 'NombreCobEsc';
    
    /**
    *  @Description: Constructor method of the class
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    global ZRH_BatchSubmitPolicyProposalAS400(String condition){
        this.queryCondition = condition;
    }
    
    /**
    *  @Description: Start Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        return new ZRH_ContractGroupPlansSelector().selectByDynamicCondition(queryCondition);
    }
    
    /**
    *  @Description: Execute Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        ContractGroupPlan objPol = (ContractGroupPlan) scope?.get(0);
        try{
            objPol = convertAttrb(objPol);
            Map<String, String> mapConstans = getMapConstans();
            Map<String, String>  mapEquivalences = getMapEquivalence();
            Map<String, ContractGroupPlanGroupClass> mapRoles = new Map<String, ContractGroupPlanGroupClass>();
            String systemCode = 'CodigoSistema';
            String deductibleApplies = 'InstanciaAplicaDeducible';
            String policyOrigen = 'PolizaOrigen';
            String generationType = 'TipoGeneracion';
            String plazoPresentacion = 'PlazoPresentacion';
            String isRen = 'EsRenovacion';
            String emiPolicy = 'EmisorPoliza';
            String intermedType = 'TipoIntermediario';
            ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
            
            List<String> listFolio = String.isNotBlank(objPol.ZRH_Folio__c) ? objPol.ZRH_Folio__c.split(SPLIT_TEXT) : new List<String>();
            for(ContractGroupPlanGroupClass item: new ZRH_ContractGroupPlanGroupClassSelector().selectByContractGroupPlan(objPol.Id)){
                mapRoles.put(objPol.Id, item);   
            }
        	objPol.vlocity_ins_fsc__AttributeSelectedValues__c = objPol.vlocity_ins_fsc__AttributeSelectedValues__c.replace('""', '0');
            AttributeSelectedValues attr = (AttributeSelectedValues) JSON.deserialize(objPol.vlocity_ins_fsc__AttributeSelectedValues__c, AttributeSelectedValues.class); 
            ZRH_JSONPolicyProposal.Policy poliza = new ZRH_JSONPolicyProposal.Policy();
            
            poliza.Ambiente = service.ZRH_Ambiente__c;
            poliza.PorcAumCapitalEval = attr.PorcVarAceptCapital != null ? attr.PorcVarAceptCapital.setScale(2) : 0;
            
            poliza.Ape = convertInt(attr.IndicAPEPrimAnual);
            poliza.Cad = new List<String>();
            if(String.isNotBlank(attr.Cad) || String.isNotBlank(attr.VidaCad)){
                poliza.Cad.add(String.isNotBlank(attr.Cad) ? attr.Cad : attr.VidaCad);
            }
            if(attr.LiderPorc != null){
                poliza.coaseguro = new List<ZRH_JSONPolicyProposal.Coaseguro>();
                ZRH_JSONPolicyProposal.Coaseguro coa = new ZRH_JSONPolicyProposal.Coaseguro();
                coa.CodigoCoaseguro = attr.CodLider;
                coa.TipoCoaseguro = STR_LEAD_COINSURED;
                coa.PorcentajeParticipacion = getIntNotNull(convertInt(attr.LiderPorc));
                poliza.coaseguro.add(coa);
                coa = new ZRH_JSONPolicyProposal.Coaseguro();
                coa.CodigoCoaseguro = attr.CodPart;
                coa.TipoCoaseguro = STR_PARTICIPANT_COINSURED;
                coa.PorcentajeParticipacion = getIntNotNull(convertInt(attr.PartPorc));
                poliza.coaseguro.add(coa);
            }
            poliza.coberturas = new List<ZRH_JSONPolicyProposal.Coberturas>();
            poliza.CodigoPlan = convertInt(objPol.ZRH_CodigoProducto__c);
            poliza.CodigoSistema = mapConstans.get(systemCode);
            poliza.CodigoRol = 1;
            poliza.CotizacionId = objPol.Contract.SourceQuoteId;
            poliza.DescripcionSolicitud = objPol.Contract.Account.Name;
            poliza.Poliza = convertInt(listFolio?.get(0));
            poliza.DvPoliza = convertInt(listFolio?.get(1));
            poliza.IndicadorGMM = getIntNotNull(convertInt(attr.IndicadorGMM));
            poliza.InstanciaAplicaDeducible = mapConstans.get(deductibleApplies);
            poliza.NombreContratante = objPol.Contract.Account.Name;
            poliza.NombrePlan = mapRoles.containsKey(objPol.Id) ? mapRoles.get(objPol.Id).GroupClass.Name : null;
            poliza.NumeroCotizacion = objPol.Contract.SourceQuote.QuoteNumber;
            poliza.NumeroDiasCarencia = getIntNotNull(attr.PerCarenciaDias); 
            poliza.NumeroMaximoDeducibleFamiliar = 0;
            poliza.NumeroSolicitud = convertInt(objPol.Contract.SourceQuote.QuoteNumber);
            poliza.PolizaOrigen =  mapConstans.get(policyOrigen);
            poliza.PorcentajeArancelUco = getIntNotNull(convertInt(attr.ArancelUCO));
            poliza.RutContratante = objPol.Contract.Account.ZRH_Rut__c;
            poliza.NombreContratanteLegal = attr.ContratLegal;
            poliza.RutContratanteLegal = attr.Rut;
            poliza.TipoGeneracion = mapConstans.get(generationType);
            poliza.GeneraFactura = compareValueYes(attr.GeneraFactura, mapEquivalences);
            poliza.TipoFacturacion = attr.TipoFacturacion;
            
            poliza.GrupoNegocio = new ZRH_JSONPolicyProposal.GrupoNegocio();
            poliza.GrupoNegocio.codigoGrupo = convertInt(objPol.Contract.ZRH_Holding__r.ZRH_CodigoGrupoNegocio__c);
            poliza.GrupoNegocio.NombreGrupo = objPol.Contract.ZRH_Holding__r.Name;
            
            poliza.vigenciaInicial = convertInt(objPol.Contract.StartDate);
            poliza.vigenciaFinal = convertInt(objPol.Contract.vlocity_ins__EnrollmentEndDate__c);
            poliza.FechaAceptacionContrato = convertInt(attr.FechaAceptContrato);
            poliza.MonedaPoliza = 91;
            poliza.PlazoPresentacion = mapConstans.get(plazoPresentacion);
            poliza.MonedaPagoSiniestros = attr.MonedaPago;
            poliza.FrecuienciaDePagos = attr.FrecPago != null ? attr.FrecPago.subString(0, 1) : mapEquivalences.get(STR_VALUE_YES);
            poliza.TipoCobranza = mapEquivalences.containsKey(attr.TipoCobranza) ? mapEquivalences.get(attr.TipoCobranza) : 'V';
            poliza.DiaCorteCobranza = attr.DiaCorteCobranza;
            poliza.DiaCobranza = attr.DiaCobranza;
            poliza.RutAsistenteComercial = objPol.Contract.SourceQuote.Opportunity.Owner.ZRH_Rut__c; 
            poliza.Insitu = compareValueYes(attr.EjecutivoInsitu, mapEquivalences);
            poliza.TienePortabilidad = compareValueYes(attr.TienePortabilidad, mapEquivalences);
            poliza.Pyme = compareValueYes(attr.Pyme, mapEquivalences);
            poliza.SegmentoCliente = attr.SegmentoCliente == '01' ? '1' : '2';
            poliza.EsContributaria = compareValueYes(attr.Cont, mapEquivalences);
            poliza.ContribucionEmpresa = getIntNotNull(convertInt(attr.PorcContEmpresa));
            poliza.FactorStoploss = getIntNotNull(convertInt(attr.FactorStopLoss));
            poliza.EsRenovacion = objPol.ZRH_EsRenovacion__c ? 'S' : 'N';
            poliza.EmisorPoliza  = mapConstans.get(emiPolicy);
            poliza.Pol = attr.POL;
            poliza.Iram = getIntNotNull(attr.IndicIRAM);
            if(objPol.ZRH_CodigoProducto__c == '601' && poliza.Iram == 0){
                poliza.Iram = 1;
            }
            poliza.Periodo = convertInt(objPol.ZRH_Periodo__c);
            poliza.GroupCensusId = objPol.Contract.SourceQuote.vlocity_ins_fsc__GroupCensusStdId__c;
            poliza.GroupClassId = mapRoles.containsKey(objPol.Id) ? mapRoles.get(objPol.Id).GroupClassId : null;
            
            poliza.TopesGrupoCoberturas = new ZRH_JSONPolicyProposal.TopesGrupoCoberturas();
            poliza.TopesGrupoCoberturas.GrupoCobertura = new List<ZRH_JSONPolicyProposal.GrupoCobertura>();
            
            poliza.TopesTotales = new ZRH_JSONPolicyProposal.TopesTotales();
            poliza.TopesTotales.DeduciblePorTramos = new List<ZRH_JSONPolicyProposal.DeduciblePorTramos>();
            poliza.TopesTotales.AtributosAgrupacion = new List<ZRH_JSONPolicyProposal.AtributosAgrupacion>();
            
            Map<String, List<ContractGroupPlan>> mapGroupPlan = new Map<String, List<ContractGroupPlan>>();
            //add covegares
            addCoverage(poliza, attr, objPol, mapEquivalences);
            
            //add coverage caps
            addCoverageCap(poliza, objPol, mapRoles);
            
            poliza.Asegurabilidad = new List<ZRH_JSONPolicyProposal.Asegurabilidad>();
            if(String.isNotBlank(objPol.ZRH_AtributosRequisitosAsegurabilidad__c)){
                //add asegurabilidad
                addAsegurabilidad(poliza, objPol.ZRH_AtributosRequisitosAsegurabilidad__c, objPol.ZRH_CodigoProducto__c);
            }
            
            poliza.Intermediarios = new List<ZRH_JSONPolicyProposal.Intermediarios>();
            ZRH_JSONPolicyProposal.Intermediarios intrm = new ZRH_JSONPolicyProposal.Intermediarios();
            intrm.Comision = objPol.Contract.ZRH_ComisionCorredor__c != null ? objPol.Contract.ZRH_ComisionCorredor__c.setScale(2) : 0;
            intrm.RutIntermediario = objPol.Contract.vlocity_ins__AgencyBrokerageId__r.ZRH_Rut__c;
            intrm.TipoIntermediario = mapConstans.get(intermedType); 
            poliza.Intermediarios.add(intrm);
            
            poliza.UnidadEquivalenteAsegurada = new ZRH_JSONPolicyProposal.UnidadEquivalenteAsegurada();
            poliza.UnidadEquivalenteAsegurada.UnidadEquivalenteAsegurada = mapEquivalences.containsKey(attr.TipoCapital) ? mapEquivalences.get(attr.TipoCapital) : 'RT';
            poliza.UnidadEquivalenteAsegurada.NumeroRentas = getIntNotNull(attr.CantidadNumeroRentas);
            poliza.UnidadEquivalenteAsegurada.ValorCapital = getIntNotNull(convertInt(attr.CantidadUF));
            
            
            poliza.Tarifa = new ZRH_JSONPolicyProposal.Tarifa();
            poliza.Tarifa.TarifaSalud = new List<ZRH_JSONPolicyProposal.TarifaSalud>();
            poliza.Tarifa.Escolaridad = new List<ZRH_JSONPolicyProposal.Escolaridad>();
            poliza.Tarifa.TarifaNumeroTipoIntegrante = new List<ZRH_JSONPolicyProposal.TarifaNumeroTipoIntegrante>();
            if(String.isNotBlank(objPol.ZRH_Tarifa__c)){
                ZRH_JSONRates objRates = ZRH_JSONRates.parse(objPol.ZRH_Tarifa__c);
                poliza.Tarifa.IdTipoTarifa = objRates.IdTipoTarifa;
                for(ZRH_JSONRates.TarifaSalud elem: objRates.TarifaSalud){
                    ZRH_JSONPolicyProposal.TarifaSalud objSal = new ZRH_JSONPolicyProposal.TarifaSalud();
                    ZRH_JSONPolicyProposal.TarifaNumeroTipoIntegrante objDeb = new ZRH_JSONPolicyProposal.TarifaNumeroTipoIntegrante();
                    
                    objSal.CodigoSubtipoTarifa = elem.CodigoSubtipoTarifa;
                    objSal.ValorTipoSubTipo = elem.TarifaSaludPV;
                    objSal.ValorTarifaDental = objPol.ZRH_CodigoProducto__c == '605' || objPol.ZRH_CodigoProducto__c == '606' ? elem.TarifaSaludPP : 0;
                    objSal.ValorTarifaSalud = objPol.ZRH_CodigoProducto__c != '605' && objPol.ZRH_CodigoProducto__c != '606' ? elem.TarifaSaludPP : 0;
                    
                    objDeb.CodigoSubtipoTarifa = elem.CodigoSubtipoTarifa;
                    objDeb.Edad = elem.EdadInicio;
                    objDeb.ValorTipoTarifaPoliza = elem.CodigoSubtipoTarifa;
                    objDeb.Valtrs = elem.TarifaSaludNT;
                    objDeb.ValtrD = objSal.ValorTarifaDental;
                    if(elem.CodigoSubtipoTarifa != null && (objSal.ValorTarifaSalud > 0 || objSal.ValorTarifaDental > 0)){
                        if(objRates.IdTipoTarifa == '1' || objRates.IdTipoTarifa == '2' || objRates.IdTipoTarifa == '3'){
                            poliza.Tarifa.TarifaSalud.add(objSal);                            
                        }else if(objRates.IdTipoTarifa == '7' || objRates.IdTipoTarifa == '9'){
                             poliza.Tarifa.TarifaNumeroTipoIntegrante.add(objDeb);
                        }
                    }
                }
                if(objPol.ZRH_CodigoProducto__c == '501'){
                     Map<String,Object> objT = (Map<String,Object>)((Object)System.JSON.deserializeUntyped(objPol.ZRH_Tarifa__c));
                    mapRatesScholarShip(poliza, (List<Object>)objT.get(LIFE_SCHOLARSHIP_RATE));
                }else{
                    for(ZRH_JSONRates.TarifaVida elem: objRates.TarifaVida){
                        ZRH_JSONPolicyProposal.Escolaridad objVida = new ZRH_JSONPolicyProposal.Escolaridad();
                        objVida.CodigoCobertura = getIntNotNull(elem.CodigoCobertura);
                        objVida.Tasa = elem.TasaMensual;
                        //objVida.CodigoNivel = elem.
                        objVida.ValorCapital = getIntNotNull(convertInt(elem.CapitalAseguradoUF));
                        poliza.Tarifa.Escolaridad.add(objVida);
                    }
                }
            }
            String productCode = objPol.ZRH_CodigoProducto__c;
            System.debug(productCode);
            if(ZRH_JSONPolicyProposal.PVR_SET_IDS_LIFE.contains(productCode) || ZRH_JSONPolicyProposal.PVR_SET_IDS_FAMILYPROTECTION.contains(productCode) || ZRH_JSONPolicyProposal.PVR_SET_IDS_PERSONALACCIDENTS.contains(productCode)){
                poliza.Tarifa.Escolaridad = new List<ZRH_JSONPolicyProposal.Escolaridad>();
                poliza.Tarifa.TarifaSalud = new List<ZRH_JSONPolicyProposal.TarifaSalud>();
            }
            Boolean planLife = ZRH_JSONPolicyProposal.PVR_SET_IDS_LIFE.contains(productCode) || ZRH_JSONPolicyProposal.PVR_SET_IDS_FAMILYPROTECTION.contains(productCode) || ZRH_JSONPolicyProposal.PVR_SET_IDS_PERSONALACCIDENTS.contains(productCode);
            Boolean planLifeSchooling =  ZRH_JSONPolicyProposal.PVR_SET_IDS_LIFESCHOOLING.contains(productCode);
            Boolean planHealth = ZRH_JSONPolicyProposal.PVR_SET_IDS_HEALTH.contains(productCode);
            
            ZRH_JSONPolicyProposal.PolicyLife polizaLife = (ZRH_JSONPolicyProposal.PolicyLife) JSON.deserialize(JSON.serialize(poliza), ZRH_JSONPolicyProposal.PolicyLife.class);
            ZRH_JSONPolicyProposal.PolicyLifeSchooling polizaLifeSch = (ZRH_JSONPolicyProposal.PolicyLifeSchooling) JSON.deserialize(JSON.serialize(poliza), ZRH_JSONPolicyProposal.PolicyLifeSchooling.class);
            ZRH_JSONPolicyProposal.PolicyHealth polizaHealth = (ZRH_JSONPolicyProposal.PolicyHealth) JSON.deserialize(JSON.serialize(poliza), ZRH_JSONPolicyProposal.PolicyHealth.class);
            
            String requestBody =  planLife ? JSON.serialize(polizaLife) :
            planLifeSchooling ? JSON.serialize(polizaLifeSch) :
            planHealth ? JSON.serialize(polizaHealth) : 
            JSON.serialize(poliza);
            //System.debug('Body Clase: '+requestBody);
            String route = objPol.ZRH_EsRenovacion__c ? INTEGRATION_ROUTE_RENOVATION : INTEGRATION_ROUTE;
            HttpResponse res = call(requestBody, listFolio?.get(0), route);
            if(STATUS_CODE_SUCCESSS.contains(res.getStatusCode())){
                objPol.ZRH_Estado__c  = STATUS_POLICY_SUCCESS;
                objPol.ZRH_PropuestaPolizaEnviada__c = true;
                objPol.ZRH_MensajeRespuestaPropuestaPoliza__c  = null;
                updateContract(objPol);
            }else{
                sendNotification(NOTIFICATION_TITLE_ERROR, res.getBody(), objPol.Id, objPol.contract.OwnerId);
                objPol.ZRH_PropuestaPolizaEnviada__c = false;
                objPol.ZRH_MensajeRespuestaPropuestaPoliza__c  = res.getBody() != null && res.getBody().length() > 255 ? res.getBody().subString(0, 255) :  res.getBody();
            }
        }catch(exception ex){
            objPol.ZRH_PropuestaPolizaEnviada__c = false;
            objPol.ZRH_MensajeRespuestaPropuestaPoliza__c  = 'Error: '+ex.getMessage() + ', Línea: '+ex.getLineNumber();
        }
        update objPol;
    }
    
    /**
    *  @Description: Finish Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    global void finish(Database.BatchableContext bc){
        System.debug('=== BatchUpdateContactBlocked.finish ===');       
    }
    
    /**
    *  @Description: Generate the Rates SCHOLARSHIP  table
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024 
    */    
    public static void mapRatesScholarShip(ZRH_JSONPolicyProposal.Policy poliza, List<Object> ratesList) {
        for(Object taf: ratesList){
            Map<String,Object> tafMap = (Map<String,Object>)taf;
            Map<String,Object> resp = (Map<String,Object>)((Object)System.JSON.deserializeUntyped('{}'));
            if(tafMap.get(CODE_COVERAGE) != null){
                for (Object o : (List<Object>)tafMap.get(TEXT_LEVEL_SCHOLARSHIP)) {
                    ZRH_JSONPolicyProposal.Escolaridad objVida = new ZRH_JSONPolicyProposal.Escolaridad();
                    Map<String,Object> dataNivel = (Map<String,Object>)o;
                    Escolridad esc = (Escolridad)System.JSON.deserialize(JSON.serialize(dataNivel), Escolridad.class);
                    
                    objVida.CodigoCobertura = Integer.valueOf((String)tafMap.get(CODE_COVERAGE));
                    objVida.Tasa = String.isNotBlank(esc.TasaAnualEsc) ? Decimal.valueOf(esc.TasaAnualEsc) : 0;
                    objVida.CodigoNivel = esc.CodigoNivel;
                    objVida.ValorCapital = String.isNotBlank(esc.CapAsegEsc) ? Decimal.valueOf(esc.CapAsegEsc) : 0;
                    
                    if(objVida.CodigoNivel != null){
                        objVida.CodigoNivel = mapNivelEscolaridad(objVida.CodigoNivel);
                        poliza.Tarifa.Escolaridad.add(objVida);
                    }
                }
            }
        }
    }
    
    
    /**
    *  @Description: map level Rates SCHOLARSHIP Ship
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024  
    */
    public static String mapNivelEscolaridad(String nivel){
        if(nivel == '0'){
            return '1';
        }else if(nivel == 'PK'){
             return '8';
        }else if(nivel == 'KI'){
             return '9';
        }else if(nivel == '1B'){
             return '10';
        }else if(nivel == '2B'){
             return '11';
        }else if(nivel == '3B'){
             return '12';
        }else if(nivel == '4B'){
             return '13';
        }else if(nivel == '5B'){
             return '14';
        }else if(nivel == '6B'){
             return '15';
        }else if(nivel == '7B'){
             return '16';
        }else if(nivel == '8B'){
             return '17';
        }else if(nivel == '1M'){
             return '18';
        }else if(nivel == '2M'){
             return '19';
        }else if(nivel == '3M'){
             return '20';
        }else if(nivel == '4M'){
             return '21';
        }else if(nivel == '1S'){
             return '22';
        }else if(nivel == '2S'){
             return '23';
        }else if(nivel == '3S'){
             return '24';
        }else if(nivel == '4S'){
             return '25';
        }else if(nivel == '5S'){
             return '26';
        }else if(nivel == '1Z'){
             return '28';
        }else if(nivel == '2Z'){
             return '29';
        }else if(nivel == '3Z'){
             return '30';
        }else if(nivel == '4Z'){
             return '31';
        }else if(nivel == '5Z'){
             return '32';
        }else if(nivel == '6Z'){
             return '33';
        }else if(nivel == '17'){
             return '40';
        }else if(nivel == '27'){
             return '41';
        }else if(nivel == '37'){
             return '42';
        }else if(nivel == '47'){
             return '43';
        }else if(nivel == '57'){
             return '44';
        }else if(nivel == '67'){
             return '45';
        }else if(nivel == '77'){
             return '46';
        }else if(nivel == '1P'){
             return '47';
        }else if(nivel == '2P'){
             return '48';
        }else if(nivel == '3P'){
             return '49';
        }else if(nivel == '4P'){
             return '50';
        }else if(nivel == '5P'){
             return '51';
        }else if(nivel == '6P'){
             return '52';
        }
        return nivel;
    }
    
    
    /**
    *  @Description: Service Call
    *  @Author:      Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        20/10/2023  
    */
    private HttpResponse call(String body, String numberPolicy, String route) {
        Map<String, String> mapParam = new Map<String, String>();
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        mapParam.put(POLICY_NUMBER, numberPolicy);
        setConf.put(STR_PATH, mapParam);
        mapParam = new Map<String, String>();
        mapParam.put(STR_HEADER_KEY, STR_HEADER_VALUE);
        setConf.put(STR_HEADER, mapParam);
        ZRH_RestConnection objClass = new ZRH_RestConnection(INTEGRATION_BASE, route, setConf);
        return objClass.callService(body);
    }
    
    /**
    *  @Description: Send notification
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static void sendNotification(String title, String description, String recordId, String userId){
        CustomNotificationType notificacion = [Select Id from CustomNotificationType where DeveloperName = :NAME_CUSTOM_NOTIFICATION]; 
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(title);
        notification.setBody(description);
        notification.setNotificationTypeId(notificacion.Id);
        notification.setTargetId( recordId ); 
        notification.send(new Set<String> { userId }); 
    }
    
    public static ContractGroupPlan convertAttrb(ContractGroupPlan cgpObj){  
        for(ContractGroupPlan item: cgpObj.ChildContractGroupPlans){
            String att = item.vlocity_ins_fsc__AttributeSelectedValues__c;
            if(att != null){
                item.vlocity_ins_fsc__AttributeSelectedValues__c = att.replace('GrupoFam', 'GrpFam'); 
            }
        }
        return cgpObj;
    }
  
    
    /**
    *  @Description: Convert Date field to Integer
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static Integer convertInt(Date dateConvert){
        try{
            String valueCero = '0';
            String dateString = String.valueOf(dateConvert.year());
            dateString +=  String.valueOf(dateConvert.month()).leftPad(2, valueCero);
            dateString += String.valueOf(dateConvert.day()).leftPad(2, valueCero);
            return Integer.valueOf(dateString);
        }catch(exception ex){
            return null;
        }
    }
    
    /**
    *  @Description: Convert String field to Integer
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static Integer convertInt(String numberString){
        try{
            return Integer.valueOf(numberString);
        }catch(exception ex){
            return null;
        }
    }
    
    /**
    *  @Description: Convert String field to Decimal
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static Decimal convertDec(String numberString){
        try{
            return Decimal.valueOf(numberString);
        }catch(exception ex){
            return 0.0;
        }
    }
    
    /**
    *  @Description: Convert String field to Decimal
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static Decimal getDecNotNull(Decimal value){
         return value != null ? value : 0;
    }
    
    /**
    *  @Description: Convert Decimal field to Integer
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static Integer convertInt(Decimal numberDecimal){
        try{
            return Integer.valueOf(numberDecimal);
        }catch(exception ex){
            return null;
        }
    }
    
    /**
    *  @Description: Add the policy sections
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public List<ZRH_JSONPolicyProposal.DeduciblePorTramos> addSections(Integer idDeductible, AttributeSelectedValues attrSec){
        List<ZRH_JSONPolicyProposal.DeduciblePorTramos> deductiblesList = new List<ZRH_JSONPolicyProposal.DeduciblePorTramos>();
        ZRH_JSONPolicyProposal.DeduciblePorTramos deductible = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
       
        if(attrSec.Asegurado != null){
            deductible.TramoDeDucible = idDeductible;
            deductible.SubTramo = 1;
            deductible.ValorDeducibleTramo = attrSec.Asegurado;  
            deductiblesList.add(deductible);  
        }
        if(attrSec.EmpUnaCrg != null){
            deductible = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
            deductible.TramoDeDucible = idDeductible;
            deductible.SubTramo = 2;
            deductible.ValorDeducibleTramo = attrSec.EmpUnaCrg;  
            deductiblesList.add(deductible);  
        }
        if(attrSec.EmpDosCrgs != null){
            deductible = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
            deductible.TramoDeDucible = idDeductible;
            deductible.SubTramo = 3;
            deductible.ValorDeducibleTramo = attrSec.EmpDosCrgs;  
            deductiblesList.add(deductible);  
        }
        if(attrSec.EmpDosMasCrgs != null){
            deductible = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
            deductible.TramoDeDucible = idDeductible;
            deductible.SubTramo = 4;
            deductible.ValorDeducibleTramo = attrSec.EmpDosMasCrgs;  
            deductiblesList.add(deductible);  
        }
        if(attrSec.EmpTresMasCrgs != null){
            deductible = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
            deductible.TramoDeDucible = idDeductible;
            deductible.SubTramo = 5;
            deductible.ValorDeducibleTramo = attrSec.EmpTresMasCrgs;  
            deductiblesList.add(deductible);  
        }
        if(attrSec.EmpTresCrgs != null){
            deductible = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
            deductible.TramoDeDucible = idDeductible;
            deductible.SubTramo = 6;
            deductible.ValorDeducibleTramo = attrSec.EmpTresCrgs;  
            deductiblesList.add(deductible);  
        }
        if(attrSec.EmpCuatroMasCrgs != null){
            deductible = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
            deductible.TramoDeDucible = idDeductible;
            deductible.SubTramo = 7;
            deductible.ValorDeducibleTramo = attrSec.EmpCuatroMasCrgs;  
            deductiblesList.add(deductible);  
        }
        if(attrSec.EmpCuatroCrgs != null){
            deductible = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
            deductible.TramoDeDucible = idDeductible;
            deductible.SubTramo = 8;
            deductible.ValorDeducibleTramo = attrSec.EmpCuatroCrgs;  
            deductiblesList.add(deductible);  
        }
        if(attrSec.EmpCincoMasCrgs != null){
            deductible = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
            deductible.TramoDeDucible = idDeductible;
            deductible.SubTramo = 9;
            deductible.ValorDeducibleTramo = attrSec.EmpCincoMasCrgs;   
            deductiblesList.add(deductible);  
        }
        if(attrSec.NumMaxDedGrpFam != null){
            deductible = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
            deductible.TramoDeDucible = idDeductible;
            deductible.SubTramo = 10;
            deductible.ValorDeducibleTramo = attrSec.NumMaxDedGrpFam;   
            deductiblesList.add(deductible);  
        }        
        return deductiblesList;
    }
    
    
    /**
    *  @Description: Add Insurability Requirements
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public void addAsegurabilidad(ZRH_JSONPolicyProposal.Policy poliza, String attrReqAse, String productCode){
        String coverageCode = '1';
        Object desObj = JSON.deserializeUntyped(attrReqAse);
        List<Object> desList;
        if (desObj instanceof List<Object>) {
            desList = (List<Object>)desObj;            
        } else if (desObj instanceof Map<String, Object>) {
            desList = new List<Object>();
            desList.Add((Object)desObj);
        }
        for(Object objAse : desList){
            ZRH_JSONPolicyProposal.Asegurabilidad reqAse= new ZRH_JSONPolicyProposal.Asegurabilidad();
            if(ZRH_JSONPolicyProposal.PVR_SET_IDS_LIFE.contains(productCode)){
                ZRH_JSONEligibilityRequirements.Life objAseg = (ZRH_JSONEligibilityRequirements.Life)JSON.deserialize(JSON.serialize(objAse), ZRH_JSONEligibilityRequirements.Life.class);
                reqAse.EdadIngreso = objAseg.EdadMinimaIngreso;
                reqAse.EdadSalida = objAseg.EdadSalida;
                reqAse.EdadDPS = objAseg.EdadDPS;
                reqAse.LimiteSolicitudDPS = getIntNotNull(objAseg.DPSCapitalIgualMayor);
                reqAse.EdadTope = objAseg.CodigoCobertura == coverageCode ? objAseg.EdadSalida : 0;
                reqAse.TipoRelacion = 'T';
                for(ZRH_JSONPolicyProposal.Coberturas c: poliza.Coberturas){
                    if(c.CodigoCobertura == Integer.valueOf(objAseg.CodigoCobertura)){
                         c.EdadTopeDeLaCobertura = objAseg.EdadSalida;
                    }
                }
            }else if(ZRH_JSONPolicyProposal.PVR_SET_IDS_LIFESCHOOLING.contains(productCode) || ZRH_JSONPolicyProposal.PVR_SET_IDS_FAMILYPROTECTION.contains(productCode) || ZRH_JSONPolicyProposal.PVR_SET_IDS_PERSONALACCIDENTS.contains(productCode)){
                ZRH_JSONEligibilityRequirements.LifeSchooling objAseg = (ZRH_JSONEligibilityRequirements.LifeSchooling)JSON.deserialize(JSON.serialize(objAse), ZRH_JSONEligibilityRequirements.LifeSchooling.class);
                objAseg.Parentesco = convertRelationship(objAseg.Parentesco);
                
                reqAse.TipoRelacion = objAseg.Parentesco != null ? objAseg.Parentesco.subString(0, 1) : null;
                reqAse.EdadIngreso = objAseg.EdadMinimaIngresoP;
                reqAse.EdadSalida = objAseg.EdadSalidaP;
                reqAse.EdadDPS = objAseg.EdadDPSP;
                reqAse.LimiteSolicitudDPS = getIntNotNull(objAseg.DPSCapitalIgualMayorP);
                reqAse.EdadTope = objAseg.EdadTopeIngresoP;
                
            }else if(ZRH_JSONPolicyProposal.PVR_SET_IDS_HEALTH.contains(productCode)){
                ZRH_JSONEligibilityRequirements.Health objAseg = (ZRH_JSONEligibilityRequirements.Health) JSON.deserialize(JSON.serialize(objAse), ZRH_JSONEligibilityRequirements.Health.class);
                objAseg.ParentescoSalud  = convertRelationship(objAseg.ParentescoSalud);
                
                reqAse.TipoRelacion = objAseg.ParentescoSalud != null ? objAseg.ParentescoSalud.subString(0, 1) : null;
                reqAse.EdadIngreso = objAseg.EdadMinimaIngresoS;
                reqAse.EdadSalida = objAseg.EdadSalidaS;
                reqAse.EdadTope = objAseg.EdadTopeIngresoS;
                reqAse.LimiteSolicitudDPS = 0;
                reqAse.EdadDPS = 0;
            }   
            if(reqAse.EdadTope > 0){
                poliza.Asegurabilidad.add(reqAse);                
            }

        }
    }
    
    
    /**
    *  @Description: Convert Relationship for value AS400
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/1/2024  
    */
    public static String convertRelationship(String parent){
        parent = parent == 'Hijastro (a)' ? 'I' : parent;
        parent = parent == 'Hijos Duplos' ? 'J' : parent;
        parent = parent == 'Conviviente Civil' ? 'W' : parent;
        return parent;
    }
    
    /**
    *  @Description: Add coverage of policy
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public void  addCoverage(ZRH_JSONPolicyProposal.Policy poliza, AttributeSelectedValues attr, ContractGroupPlan objPol, Map<String, String> mapValue){
        Map<Integer, ZRH_JSONPolicyProposal.GrupoCobertura> mapGrupo = new  Map<Integer, ZRH_JSONPolicyProposal.GrupoCobertura>();
        List<String> nivelesList = new List<String>();
        Integer valueZero = 0;
        for(ContractGroupPlan  covPol: objPol.ChildContractGroupPlans){
            if(String.isBlank(covPol.vlocity_ins_fsc__AttributeSelectedValues__c)){
                continue;
            }
            covPol.vlocity_ins_fsc__AttributeSelectedValues__c = covPol.vlocity_ins_fsc__AttributeSelectedValues__c.replace('""', '0');
            ZRH_JSONPolicyProposal.Coberturas c = new ZRH_JSONPolicyProposal.Coberturas();
            AttributeSelectedValues attrC = (AttributeSelectedValues) JSON.deserialize(covPol.vlocity_ins_fsc__AttributeSelectedValues__c, AttributeSelectedValues.class);
            if(String.isNotBlank(attrC.Cad) || String.isNotBlank(attrC.VidaCad)){
                poliza.Cad.add(String.isNotBlank(attrC.Cad) ? attrC.Cad : attrC.VidaCad);
            }
            String nivelManejoTopes = attrc.TopeMaxAnualAseg != null ? 'A' : attrc.TopeMaxAnualGrpFam != null ? 'G' : attrc.TopeMaxAnualPol != null ? 'P' : 'A';
            Decimal topeMaximoAnual = attrc.TopeMaxAnualAseg != null ? attrc.TopeMaxAnualAseg : attrc.TopeMaxAnualGrpFam != null ? attrc.TopeMaxAnualGrpFam : attrc.TopeMaxAnualPol != null ? attrc.TopeMaxAnualPol : 0;
            
            c.CodigoCobertura = convertInt(covPol.ZRH_CodigoProducto__c);
            c.CodigoGrupoCoberturas =  covPol.ZRH_GrupoDeCobertura__c != null ? convertInt(covPol.ZRH_GrupoDeCobertura__c) : 1;
            c.NivelManejoTopes = nivelManejoTopes;
            c.PorcentajeReembolso = getIntNotNull(attrc.PorcReemBonoAseg);
            c.NumeroPrestacionesAnual = getIntNotNull(attrc.NumMaxPrestAnualsAseg);
            c.NumeroPrestacionesPorEvento = getIntNotNull(attrc.NumMaxPrestEventoAseg);
            c.ValorMaxPrestacion = getIntNotNull(attrc.TopeMaxPrestAseg); //Problem
            c.TopeMaximoAnual = getIntNotNull(topeMaximoAnual);
            c.TopeMaximoPorEvento = getIntNotNull(attrc.TopeMaxEventoAseg);//Problem
            c.ValorDeducibleAnual = getIntNotNull(attrc.NumMaxPrestAnualsAseg);
            c.ValorDeduciblePorEvento = getIntNotNull(attrc.NumMaxPrestEventoAseg);
            c.ValorDeduciblePorPrestacion = getIntNotNull(attrc.ValorDeduciblePorPrestacion);
            c.PorcentajeLibreEleccionPorPrestacion = getIntNotNull(attrc.PorcReemLibEleccAseg);
            c.PorcentajeSinPrevisionPorPrestacion = getIntNotNull(attrc.PorcReemSinPrevAseg);
            c.IndicadorCoberturaSuplementaria = compareValueYes(attrc.IndCoberturaSupAseg, mapValue);
            c.ValorLimiteDeReembolso = getIntNotNull(attrc.ValLimReemSupAseg);
            c.NumeroLimiteDePrestacionesPorReembolsoSuplementario = getIntNotNull(attrc.NumPrestSupAseg);
            c.PorcentajeReembolsoSuplementario = getIntNotNull(attrc.PorcReemSupAseg);
            c.MontoMaximoReembolso = getIntNotNull(attrc.TopeMaxReemSupAseg);
            c.IndicadorAplicaPorPrestacion = compareValueYes(attrc.IndCoberturaSupAseg, mapValue);
            c.TipoDeCapitalPorcentajeValor = getTypeCapitalAS400(attrc.TipoDeCapital);
            c.PorcentajeDeCapital = getIntNotNull(attrc.PorcDelCapital);
            c.ValorDeCapital = getIntNotNull(attrc.MontoCapitalUF);
            c.TasaParaLaPrima = attrc.TasaSFPXMil != null ? attrc.TasaSFPXMil : 0;
            c.EdadTopeDeLaCobertura = getIntNotNull(attrc.EdadTopeDeLaCobertura);
            if(convertInt(covPol.ZRH_CodigoProducto__c) != null){
                poliza.coberturas.add(c);
                if(attrc.TopeMaxAnualAseg != null && attrc.TopeMaxAnualGrpFam != null){
                    String covJSON = JSON.serialize(c);
                    ZRH_JSONPolicyProposal.Coberturas covClo = (ZRH_JSONPolicyProposal.Coberturas) JSON.deserialize(covJSON, ZRH_JSONPolicyProposal.Coberturas.class);
                    covClo.NivelManejoTopes = 'G';
                    covClo.TopeMaximoAnual = attrc.TopeMaxAnualGrpFam;
                    covClo.ValorMaxPrestacion = getIntNotNull(attrc.TopeMaxPrestGrpFam); 
                    covClo.TopeMaximoPorEvento = getIntNotNull(attrc.TopeMaxEventoGrpFam);                    
                    poliza.NumeroMaximoDeducibleFamiliar = 1;
                    poliza.coberturas.add(covClo);
                } 
                if(attrc.TopeMaxAnualPol != null && (attrc.TopeMaxAnualAseg != null || attrc.TopeMaxAnualGrpFam != null)){
                    String covJSON = JSON.serialize(c);
                    ZRH_JSONPolicyProposal.Coberturas covClo = (ZRH_JSONPolicyProposal.Coberturas) JSON.deserialize(covJSON, ZRH_JSONPolicyProposal.Coberturas.class);
                    covClo.NivelManejoTopes = 'P';
                    covClo.TopeMaximoAnual = attrc.TopeMaxAnualPol;
                    covClo.NumeroPrestacionesAnual = 1;
                    poliza.coberturas.add(covClo);
                }
            }
            
            ZRH_JSONPolicyProposal.GrupoCobertura coverageGroup = new ZRH_JSONPolicyProposal.GrupoCobertura();
            coverageGroup.CodigoGrupoCoberturas = covPol.ZRH_GrupoDeCobertura__c != null ? convertInt(covPol.ZRH_GrupoDeCobertura__c) : 1;
            coverageGroup.DeduciblePorTramos = new List<ZRH_JSONPolicyProposal.DeduciblePorTramos>();
            coverageGroup.AtributosAgrupacion = new List<ZRH_JSONPolicyProposal.AtributosAgrupacion>();
            
            ZRH_JSONPolicyProposal.AtributosAgrupacion dedAgr = new ZRH_JSONPolicyProposal.AtributosAgrupacion();
            ZRH_JSONPolicyProposal.DeduciblePorTramos dedTra = new ZRH_JSONPolicyProposal.DeduciblePorTramos();
            if(DEDUCTIBLE_TYPE.contains(attr.TipoDeducible)){
                coverageGroup.DeduciblePorTramos = addSections(convertInt(objPol.ZRH_TipoTarifa__c), attrC);
            }else if(attr.TipoDeducible == 'Por Grupo Familiar' && convertInt(covPol.ZRH_CodigoProducto__c) == null && attrc.NumMaxDedGrpFam != null){
                dedAgr.NivelManejoTopes = 'G';
                dedAgr.NumeroPrestacionesAnual = valueZero;
                dedAgr.TopeMaximoPorEvento = valueZero;
                dedAgr.ValorDeducibleAnual = attrc.NumMaxDedGrpFam;
                dedAgr.ValorDeduciblePorEvento = valueZero;
                dedAgr.TopeMaximoAnual  = valueZero;
                poliza.NumeroMaximoDeducibleFamiliar = 1;
                coverageGroup.AtributosAgrupacion.add(dedAgr);
            }
            
            ZRH_JSONPolicyProposal.GrupoCobertura grupo = new ZRH_JSONPolicyProposal.GrupoCobertura();
            grupo.DeduciblePorTramos = new List<ZRH_JSONPolicyProposal.DeduciblePorTramos>();
            grupo.AtributosAgrupacion = new List<ZRH_JSONPolicyProposal.AtributosAgrupacion>();
            if(mapGrupo.containsKey(coverageGroup.CodigoGrupoCoberturas)){
                grupo = mapGrupo.get(coverageGroup.CodigoGrupoCoberturas);
            }else{
                grupo.CodigoGrupoCoberturas = coverageGroup.CodigoGrupoCoberturas;
            }
            if(coverageGroup.DeduciblePorTramos.size() > 0){
                grupo.DeduciblePorTramos.addAll(coverageGroup.DeduciblePorTramos);
            }
            if(coverageGroup.AtributosAgrupacion.size() > 0){
                grupo.AtributosAgrupacion.addAll(coverageGroup.AtributosAgrupacion);
            }
            if(mapGrupo.containsKey(coverageGroup.CodigoGrupoCoberturas)){
                mapGrupo.put(grupo.CodigoGrupoCoberturas, grupo);
                for(integer i = 0; i < poliza.TopesGrupoCoberturas.GrupoCobertura.size(); i++){
                    if(poliza.TopesGrupoCoberturas.GrupoCobertura[i].CodigoGrupoCoberturas == grupo.CodigoGrupoCoberturas){
                        poliza.TopesGrupoCoberturas.GrupoCobertura[i] = grupo;
                    }
                }
             }else{
                 poliza.TopesGrupoCoberturas.GrupoCobertura.add(grupo);
                 mapGrupo.put(grupo.CodigoGrupoCoberturas, grupo);
             }
        }
    }
    
    /**
    *  @Description: map coverage of caps
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public void addCoverageCap(ZRH_JSONPolicyProposal.Policy poliza, ContractGroupPlan objPol, Map<String, ContractGroupPlanGroupClass> mapRoles){
        String objApiName = 'Product2';
        String fieldApiName = 'ZRH_GrupoDeCobertura__c';
        String topeMaximoAnual = 'TMA';
        String nameRol = String.isNotBlank(poliza.GroupClassId) ? mapRoles.get(objPol.Id).GroupClass.Name : null;
        if(String.isNotBlank(objPol.ZRH_AtributosTopes__c)){
            ZRH_JSONTopes obj = ZRH_JSONTopes.parse(objPol.ZRH_AtributosTopes__c);
            ZRH_JSONPolicyProposal.AtributosAgrupacion dedAgr = new ZRH_JSONPolicyProposal.AtributosAgrupacion();
            Map<String, ZRH_JSONPolicyProposal.AtributosAgrupacion> mapAg = new Map<String, ZRH_JSONPolicyProposal.AtributosAgrupacion>();
           
            SObjectType objectType = Schema.getGlobalDescribe().get(objApiName);
            for(Schema.PicklistEntry entry : objectType.getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPickListValues())  {
                ZRH_JSONPolicyProposal.GrupoCobertura coverageGroup = new ZRH_JSONPolicyProposal.GrupoCobertura();
                coverageGroup.DeduciblePorTramos = new List<ZRH_JSONPolicyProposal.DeduciblePorTramos>();
                coverageGroup.AtributosAgrupacion = new List<ZRH_JSONPolicyProposal.AtributosAgrupacion>();
                coverageGroup.CodigoGrupoCoberturas = convertInt(entry.getValue());
                mapAg = new Map<String, ZRH_JSONPolicyProposal.AtributosAgrupacion>();
                
                Integer posi = -1;
                for(integer i = 0; i < poliza.TopesGrupoCoberturas.GrupoCobertura.size(); i++){
                    if(poliza.TopesGrupoCoberturas.GrupoCobertura[i].CodigoGrupoCoberturas == coverageGroup.CodigoGrupoCoberturas){
                        coverageGroup = poliza.TopesGrupoCoberturas.GrupoCobertura[i];
                        posi = i;
                    }
                }
                
                for(ZRH_JSONTopes.TopesGrupoCobertura item: obj.TopesGrupoCobertura){
                    
                    if(nameRol == item.RolLabel && item.GrupoCobertura == entry.getValue()){
                        dedAgr = mapAg.containsKey(item.Agrupacion) ? mapAg.get(item.Agrupacion) : new ZRH_JSONPolicyProposal.AtributosAgrupacion();
                        dedAgr.NivelManejoTopes = item.Agrupacion;
                        dedAgr.NumeroPrestacionesAnual = item.Tope == topeMaximoAnual ? convertInt(item.NroPrestAnuales) : getIntNotNull(dedAgr.NumeroPrestacionesAnual);
                        dedAgr.TopeMaximoAnual = item.Tope == topeMaximoAnual ? convertDec(item.Valor) : getDecNotNull(dedAgr.TopeMaximoAnual) ;
                        dedAgr.TopeMaximoPorEvento = item.Tope != topeMaximoAnual ? convertDec(item.Valor) : getDecNotNull(dedAgr.TopeMaximoPorEvento) ;
                        dedAgr.ValorDeducibleAnual = item.Tope == topeMaximoAnual ? convertDec(item.ValorDeducible) : getDecNotNull(dedAgr.ValorDeducibleAnual) ;
                        dedAgr.ValorDeduciblePorEvento = item.Tope != topeMaximoAnual ? convertDec(item.ValorDeducible) : getDecNotNull(dedAgr.ValorDeduciblePorEvento);
                        if(mapAg.containsKey(item.Agrupacion)){
                            for(Integer i = 0; i < coverageGroup.AtributosAgrupacion.size(); i++){
                                if(coverageGroup.AtributosAgrupacion[i].NivelManejoTopes == dedAgr.NivelManejoTopes){
                                    coverageGroup.AtributosAgrupacion[i] = dedAgr;
                                }
                            }
                        }else{
                            coverageGroup.AtributosAgrupacion.add(dedAgr);   
                        }
                        mapAg.put(item.Agrupacion, dedAgr);
                    }
                }
                if(coverageGroup.AtributosAgrupacion.size() > 0){
                    if(posi > -1){
                        poliza.TopesGrupoCoberturas.GrupoCobertura[posi] = coverageGroup;
                    }else{
                        poliza.TopesGrupoCoberturas.GrupoCobertura.add(coverageGroup);
                    }
                }
            }
            
            mapAg = new Map<String, ZRH_JSONPolicyProposal.AtributosAgrupacion>();
            for(ZRH_JSONTopes.TopesPoliza item: obj.TopesPoliza){
                dedAgr = mapAg.containsKey(item.Agrupacion) ? mapAg.get(item.Agrupacion) : new ZRH_JSONPolicyProposal.AtributosAgrupacion();
                dedAgr.NivelManejoTopes = item.Agrupacion;
                dedAgr.NumeroPrestacionesAnual = 0;
                dedAgr.TopeMaximoAnual = item.Tope == topeMaximoAnual ? convertDec(item.Valor) : getDecNotNull(dedAgr.TopeMaximoAnual) ;
                dedAgr.TopeMaximoPorEvento = item.Tope != topeMaximoAnual ? convertDec(item.Valor) : getDecNotNull(dedAgr.TopeMaximoPorEvento) ;
                dedAgr.ValorDeducibleAnual = item.Tope == topeMaximoAnual ? convertDec(item.ValorDeducible) : getDecNotNull(dedAgr.ValorDeducibleAnual);
                dedAgr.ValorDeduciblePorEvento = item.Tope != topeMaximoAnual ? convertDec(item.ValorDeducible) : getDecNotNull(dedAgr.ValorDeduciblePorEvento);
                if(mapAg.containsKey(item.Agrupacion)){
                    for(Integer i = 0; i < poliza.TopesTotales.AtributosAgrupacion.size(); i++){
                        if(poliza.TopesTotales.AtributosAgrupacion[i].NivelManejoTopes == dedAgr.NivelManejoTopes){
                            poliza.TopesTotales.AtributosAgrupacion[i] = dedAgr;
                        }
                    }
                }else{
                    poliza.TopesTotales.AtributosAgrupacion.add(dedAgr);   
                }
                mapAg.put(item.Agrupacion, dedAgr);
            }
            
            for(ZRH_JSONTopes.TopesAdicional item: obj.TopesAdicional){
                if(item.Alternativa == 'Si' && nameRol == item.RolLabel){
                    poliza.Cobertura = convertInt(item.Tope);
                    poliza.ValorTopeAnual = convertDec(item.Valor);
                }
            }
        }
        
    }
    
    /**
    *  @Description: update status Contract
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public void  updateContract(ContractGroupPlan cgp){
         String flagStatus = FLAG_STATUS;
        Contract c = new ZRH_ContractsSelector().selectByIds(cgp.ContractId)?.get(0);
        
        for(ContractGroupPlan objPol : c.ContractGroupPlans){
            if(objPol.ZRH_Estado__c != FLAG_STATUS && objPol.Id != cgp.Id){
                flagStatus = c.Status;
            }
        }
        if(flagStatus != c.Status){
            c.Status = flagStatus;
            DataBase.update (c, false);
            String description = NOTIFICATION_TEXT + ' ' +  c.Account.ZRH_CodigoGrupoNegocio__c + ' ' + c.Account.Name;
            description = description.replace('#', String.valueOf(c.ContractGroupPlans.size()));
            sendNotification(NOTIFICATION_TITLE, description, c.Id, c.OwnerId);
        }
    }
    
    /**
    *  @Description: get map of Constant
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static Map<String, String>  getMapConstans(){
        Map<String, String> mapConstans = new Map<String, String>();
        ZRH_RutaIntegracion__mdt route = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        for(ZRH_DiccionarioConstantes__mdt item: ZRH_DiccionarioConstantes__mdt.getAll().values()){
            if(route.Id == item.ZRH_Servicio__c ){
                mapConstans.put(item.ZRH_Constante__c, item.ZRH_Valor__c);
            }
        }
        return mapConstans;
    }
    
    /**
    *  @Description: get map of Equivalence Dictionary
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static Map<String, String>  getMapEquivalence(){
        Map<String, String> mapReturn = new Map<String, String>();
        ZRH_RutaIntegracion__mdt route = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        for(ZRH_DiccionarioEquivalencias__mdt item: ZRH_DiccionarioEquivalencias__mdt.getAll().values()){
            if(route.Id == item.ZRH_Servicio__c ){
                mapReturn.put(item.ZRH_ValorSalesforce__c, item.ZRH_ValorAS400__c);
            }
        }
        return mapReturn;
    }
    
    /**
    *  @Description: get number not null
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static Integer  getIntNotNull(Integer value){
       return value != null ? value : 0;
    }
    
    /**
    *  @Description: get number not null
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static Decimal  getIntNotNull(Decimal value){
       return value != null ? value.setScale(2) : 0;
    }
    
    /**
    *  @Description: Compare value Yes
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static String compareValueYes(String value, Map<String, String> mapValue){
        String valueReturn = 'N';
        if(String.isNotBlank(value) && mapValue.containsKey(value)){
            valueReturn = mapValue.get(value);
        }
       return valueReturn;
    }
    
    /**
    *  @Description: get code Type of Capital for AS400
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static String getTypeCapitalAS400(String value){
        value = String.isNotBlank(value) && CAPITAL_TYPE_LIST.contains(value) ? value.subString(0, 1) : 'V';
        return value;
    }

    /**
    *  @Description: class AttributeSelectedValues
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public class AttributeSelectedValues{
        public String Cad { get; set; }
        public String VidaCAD { get; set; }
        public String IndicAPEPrimAnual { get; set; }
        public Integer CodLider { get; set; }
        public Integer CodPart { get; set; }
        public Integer PerCarenciaDias { get; set; }
        public String TipoCobranza { get; set; }
        public String TipoCapital { get; set; }
        public Date FechaAceptContrato { get; set; }
        public Decimal NumMaxDedGrpFam { get; set; }
        public Integer MonedaPago { get; set; }
        public String FrecPago { get; set; }
        public Integer DiaCorteCobranza { get; set; }
        public Integer DiaCobranza { get; set; }
        public String EjecutivoInsitu { get; set; }
        public String TienePortabilidad { get; set; }
        public String Pyme { get; set; }
        public String SegmentoCliente { get; set; }
        public String Cont { get; set; }
        public Decimal PorcContEmpresa { get; set; }
        public Decimal FactorStopLoss { get; set; }
        public String POL { get; set; }
        public Integer IndicIRAM { get; set; }
        public Decimal PorcReemBonoAseg { get; set; }
        public Decimal TopeMaxPrestAseg { get; set; }
        public Decimal TopeMaxPrestGrpFam { get; set; }
        public Decimal TopeMaxAnualAseg { get; set; }
        public Decimal TopeMaxEventoAseg { get; set; }
        public Decimal TopeMaxEventoGrpFam { get; set; }
        public Decimal ValLimReemSupAseg { get; set; }
        public Decimal PorcDelCapital { get; set; }
        public Decimal MontoCapitalUF { get; set; }
        public String Coasegurador { get; set; }
        public String ContratLegal { get; set; }
        public String Rut { get; set; }
        public Decimal PartPorc { get; set; }
        public Decimal LiderPorc { get; set; }
        public Integer CantidadNumeroRentas { get; set; }
        public Decimal CantidadUF { get; set; }
        public Integer DAnualBenefAnioPol { get; set; }
        public Decimal NumMaxPrestEventoAseg { get; set; }
        public Decimal NumMaxPrestAnualsAseg { get; set; }
        public Decimal TopeMaxReemSupAseg { get; set; }
        public Decimal TopeMaxAnualGrpFam{ get; set; }
        public Decimal TopeMaxAnualPol{ get; set; } 
        public Decimal PorcReemSupAseg { get; set; }
        public String TipoDeducible { get; set; }
        public Decimal PorcReemLibEleccAseg{ get; set; }
        public Decimal PorcReemSinPrevAseg{ get; set; }
        public Decimal NumPrestSupAseg{ get; set; }
        public Integer ValorDeduciblePorPrestacion{ get; set; }
        public String IndCoberturaSupAseg{ get; set; }
        public String TipoDeCapital{ get; set; }
        public Integer TasaMilSFPago{ get; set; } 
        public Integer EdadTopeDeLaCobertura{ get; set; }
        public Decimal Asegurado{ get; set; }
        public Decimal EmpUnaCrg{ get; set; }
        public Decimal EmpDosCrgs{ get; set; }
        public Decimal EmpDosMasCrgs{ get; set; }
        public Decimal EmpTresMasCrgs{ get; set; }
        public Decimal EmpTresCrgs{ get; set; }
        public Decimal EmpCuatroMasCrgs{ get; set; }
        public Decimal EmpCuatroCrgs{ get; set; }
        public Decimal EmpCincoMasCrgs{ get; set; }
        public String GeneraFactura { get; set; }
        public String TipoFacturacion { get; set; }
        public Decimal PorcVarAceptCapital { get; set; }
        public String IndicadorGMM { get; set; }
        public Decimal ArancelUCO { get; set; }
        public Decimal TasaSFPXMil { get; set; }
        
    }
    
    
    public class Escolridad{
        public String CodigoNivel;
        public String CapAsegEsc;
        public String TasaAnualEsc;
    }
}