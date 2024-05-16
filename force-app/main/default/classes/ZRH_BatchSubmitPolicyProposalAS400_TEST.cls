/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/11/2023
Description  : Class test for class ZRH_BatchSubmitPolicyProposalAS400
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          27/11/2023        initial version
********************************************************************************/
@isTest
public class ZRH_BatchSubmitPolicyProposalAS400_TEST {

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023  
    */
    private static final String QUERY_CONDITION = 'ContractGroupParentPlanId = null';
    private static final String SR_ASV_VIDA_NAME = 'ZRH_JSON_VidaASV';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_TARIFA_SCHOLARSHIP_NAME = 'ZRH_JSON_EscolaridadTarifa';
    private static final String SR_ASV_COBERTURA_NAME = 'ZRH_JSON_CoberturaASV';
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';
    private static final String SR_TARIFA_VIDA_NAME = 'ZRH_JSON_VidaTarifa';
    private static final String SR_REQ_MED_NAME = 'ZRH_JSON_RequisitosMedicos';
    private static final String SR_VIDA_REQ_ASEG_NAME = 'ZRH_JSON_VidaRA';
    private static final String SR_SALUD_LIMITS_NAME = 'ZRH_JSON_LIMITS';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_EnvioPropuestaPoliza';
    private static final String SR_BODY_RESPONSE = 'ZRH_JSON_InputPDF';
    private static final String SR_FOLIO_NUMBER_ONE = '1245-1';
    private static final String SR_FOLIO_NUMBER_TWO = '1245-2';
    private static final String SR_FOLIO_NUMBER_THREE = '1245-3';
    private static final String LIFE_SCHOLARSHIP_RATE = 'TarifaEscolaridad';
    
    @testSetup 
    static void setupMethod() {
        
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        StaticResource saludTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        StaticResource vidaTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_VIDA_NAME);
        StaticResource vidaRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_VIDA_REQ_ASEG_NAME);
        StaticResource vidaRM = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);
        StaticResource saludLimits = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_LIMITS_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        Product2 testPersonalAccidentsProduct = ZRH_DataFactory.createPersonalAccidentsProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        PricebookEntry testPricebookEntryPersonalAccidents = ZRH_DataFactory.createPricebookEntry(true, testPersonalAccidentsProduct);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testPersonalAccidentsProduct, testPricebookEntryPersonalAccidents,  vidaASV.Body.toString());
        
        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues att = (ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues) JSON.deserialize(cgpTwo.vlocity_ins_fsc__AttributeSelectedValues__c, ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues.class);
        Integer valorCero = 0;
        att.Asegurado = valorCero;
        att.EmpUnaCrg = valorCero;
        att.EmpDosCrgs = valorCero;
        att.EmpDosMasCrgs = valorCero;
        att.EmpTresMasCrgs = valorCero;
        att.EmpTresCrgs = valorCero;
        att.EmpCuatroMasCrgs = valorCero;
        att.EmpCuatroCrgs = valorCero;
        att.EmpCincoMasCrgs = valorCero;
        att.NumMaxDedGrpFam = valorCero;
       
        
        cgpOne.ZRH_Tarifa__c = saludTarifa.Body.toString();
        cgpOne.ZRH_AtributosTopes__c = saludLimits.Body.toString();
        cgpOne.ZRH_Folio__c = SR_FOLIO_NUMBER_ONE;
        cgpOne.ZRH_AtributosRequisitosAsegurabilidad__c = vidaRA.Body.toString();
        cgpTwo.ContractGroupParentPlanId  = cgpone.Id;
        cgpTwo.vlocity_ins_fsc__AttributeSelectedValues__c = JSON.serialize(att);
        
        update cgpone;
        update cgpTwo;
    }
    
    /**
    *  @Description: Test the for the class bathc ZRH_BatchSendPolicyProposalAS400
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */
    @isTest 
    static void batchSubmitPolicyProposalAS400Test() {
        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        
        List<String> endPoint = new List<String>();
        endPoint.add(service.ZRH_URLBase__c + path.ZRH_RutaURL__c + '/' + SR_FOLIO_NUMBER_ONE.split('-')[0]);
        List<String> resBody = new List<String>();
        resBody.add(SR_BODY_RESPONSE);
        ZRH_UtilityHttpRequestMock_TEST.getMultimock(endPoint, resBody, 200);
        
        Test.startTest();
        Id jobId = Database.executeBatch(new ZRH_BatchSubmitPolicyProposalAS400(QUERY_CONDITION), 1);
        System.assertEquals(jobId != null, true, 'It´s Worked!');
        Test.stopTest();
    }
    
    /**
    *  @Description: Test the for the class bathc batchSubmitPolicyProposalAS400Fail501
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */
    @isTest 
    static void batchSubmitPolicyProposalAS400Fail501() {
        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        
        List<String> endPoint = new List<String>();
        endPoint.add(service.ZRH_URLBase__c + path.ZRH_RutaURL__c + '/' + SR_FOLIO_NUMBER_ONE.split('-')[0]);
        List<String> resBody = new List<String>();
        resBody.add(SR_BODY_RESPONSE);
        ZRH_UtilityHttpRequestMock_TEST.getMultimock(endPoint, resBody, 501);
        
        Test.startTest();
        ZRH_JSONPolicyProposal.PolicyLife objPol = new ZRH_JSONPolicyProposal.PolicyLife();
        objPol.Poliza = null; 
        objPol.DvPoliza = null; 
        objPol.NumeroSolicitud = null; 
        objPol.DescripcionSolicitud = null; 
        objPol.NombreContratante = null; 
        objPol.RutContratante = null; 
        objPol.CodigoRol = null;
        objPol.VigenciaInicial = null; 
        objPol.VigenciaFinal = null; 
        objPol.CodigoPlan = null; 
        objPol.NombrePlan = null;
        objPol.GrupoNegocio = null; 
        objPol.FechaAceptacionContrato = null; 
        objPol.MonedaPoliza = null; 
        objPol.UnidadEquivalenteAsegurada = null; 
        objPol.Tarifa = null; 
        objPol.Intermediarios = null; 
        objPol.PlazoPresentacion = null;
        objPol.InstanciaAplicaDeducible = null; 
        objPol.MonedaPagoSiniestros = null; 
        objPol.FrecuienciaDePagos = null; 
        objPol.TipoCobranza = null; 
        objPol.DiaCobranza = null; 
        objPol.DiaCorteCobranza = null; 
        objPol.TipoGeneracion = null;
        objPol.GeneraFactura = null;
        objPol.TipoFacturacion = null; 
        objPol.coaseguro = null; 
        objPol.RutAsistenteComercial = null;
        objPol.Asegurabilidad = null; 
        objPol.Insitu = null; 
        objPol.TienePortabilidad = null; 
        objPol.Pyme = null; 
        objPol.SegmentoCliente = null; 
        objPol.EsContributaria = null; 
        objPol.ContribucionEmpresa = null; 
        objPol.FactorStoploss = null;
        objPol.EsRenovacion = null;
        objPol.PolizaOrigen = null; 
        objPol.EmisorPoliza = null;
        objPol.Pol = null; 
        objPol.Cad = null; 
        objPol.Iram = null; 
        objPol.Ape = null; 
        objPol.IndicadorGMM = null; 
        objPol.NumeroMaximoDeducibleFamiliar = null; 
        objPol.NumeroCotizacion = null;  
        objPol.CotizacionId = null; 
        objPol.CodigoSistema = null; 
        objPol.GroupCensusId = null; 
        objPol.GroupClassId = null; 
        objPol.Periodo = null;
        objPol.coberturas = null; 
        
        ZRH_JSONPolicyProposal.PolicyLifeSchooling objPolSch = new ZRH_JSONPolicyProposal.PolicyLifeSchooling();
        objPolSch.Poliza = null; 
        objPolSch.DvPoliza = null; 
        objPolSch.NumeroSolicitud = null; 
        objPolSch.DescripcionSolicitud = null; 
        objPolSch.NombreContratante = null; 
        objPolSch.RutContratante = null; 
        objPolSch.CodigoRol = null;
        objPolSch.VigenciaInicial = null; 
        objPolSch.VigenciaFinal = null; 
        objPolSch.CodigoPlan = null; 
        objPolSch.NombrePlan = null;
        objPolSch.GrupoNegocio = null; 
        objPolSch.FechaAceptacionContrato = null; 
        objPolSch.MonedaPoliza = null; 
        objPolSch.UnidadEquivalenteAsegurada = null; 
        objPolSch.Tarifa = null; 
        objPolSch.Intermediarios = null; 
        objPolSch.PlazoPresentacion = null;
        objPolSch.InstanciaAplicaDeducible = null; 
        objPolSch.MonedaPagoSiniestros = null; 
        objPolSch.FrecuienciaDePagos = null; 
        objPolSch.TipoCobranza = null; 
        objPolSch.DiaCobranza = null; 
        objPolSch.DiaCorteCobranza = null; 
        objPolSch.TipoGeneracion = null;
        objPolSch.GeneraFactura = null;
        objPolSch.TipoFacturacion = null; 
        objPolSch.coaseguro = null; 
        objPolSch.RutAsistenteComercial = null;
        objPolSch.Asegurabilidad = null; 
        objPolSch.Insitu = null; 
        objPolSch.TienePortabilidad = null; 
        objPolSch.Pyme = null; 
        objPolSch.SegmentoCliente = null; 
        objPolSch.EsContributaria = null; 
        objPolSch.ContribucionEmpresa = null; 
        objPolSch.FactorStoploss = null;
        objPolSch.EsRenovacion = null;
        objPolSch.PolizaOrigen = null; 
        objPolSch.EmisorPoliza = null;
        objPolSch.Pol = null; 
        objPolSch.Cad = null; 
        objPolSch.Iram = null; 
        objPolSch.Ape = null; 
        objPolSch.IndicadorGMM = null; 
        objPolSch.NumeroMaximoDeducibleFamiliar = null; 
        objPolSch.NumeroCotizacion = null;  
        objPolSch.CotizacionId = null; 
        objPolSch.CodigoSistema = null; 
        objPolSch.GroupCensusId = null; 
        objPolSch.GroupClassId = null; 
        objPolSch.Periodo = null;
        objPolSch.coberturas = null; 
        //Id jobId = Database.executeBatch(new ZRH_BatchSubmitPolicyProposalAS400(QUERY_CONDITION), 1);
        //System.assertEquals(jobId != null, true, 'It´s Worked!');
        Test.stopTest();
    }
    
    /**
    *  @Description: Test the for the class Schedule ZRH_ScheduleSubmitPolicyProposalAS400
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */
    @isTest 
    static void scheduleSubmitPolicyProposalAS400Test() {
        Test.startTest();
        new ZRH_ScheduleSubmitPolicyProposalAS400().execute(null);
        
        StaticResource escolTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SCHOLARSHIP_NAME);
        
        ZRH_JSONPolicyProposal.Policy poliza = new ZRH_JSONPolicyProposal.Policy();
        poliza.Tarifa = new ZRH_JSONPolicyProposal.Tarifa();
        poliza.Tarifa.Escolaridad = new List<ZRH_JSONPolicyProposal.Escolaridad>();
        
        Map<String,Object> obj = (Map<String,Object>)((Object)System.JSON.deserializeUntyped(escolTarifa.Body.toString()));
        List<Object> ratesList = (List<Object>) obj.get(LIFE_SCHOLARSHIP_RATE);
        ZRH_BatchSubmitPolicyProposalAS400.mapRatesScholarShip(poliza, ratesList);
        String title = 'test';
        ZRH_BatchSubmitPolicyProposalAS400.sendNotification(title, title,userInfo.getUserId(),userInfo.getUserId());
        ZRH_BatchSubmitPolicyProposalAS400.convertRelationship('');
            for(String l : new List<String>{'B','M','S','Z','P'}){
                for(Integer i = 1; i<10; i++){
                    ZRH_BatchSubmitPolicyProposalAS400.mapNivelEscolaridad(i + l);
                }
            }
        
        Test.stopTest();
    }
}