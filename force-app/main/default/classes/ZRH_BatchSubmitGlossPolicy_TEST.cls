/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 29/1/2024
Description  : Class test for class ZRH_BatchSubmitGlossPolicy
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          29/1/2024         Initial Version
********************************************************************************/
@isTest
public class ZRH_BatchSubmitGlossPolicy_TEST {

     /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        29/1/2024
    */
    private static final String OBJECT_GLOSAS = 'ZRH_Glosas__c';
    private static final String FIELD_TIPO_GLOSA = 'ZRH_TipoDeGlosa__c';
    private static final String OBJECT_QUOTE = 'Quote';
    private static final String OPERATOR_AND = 'AND'; 
    private static final String OPERATOR_OR = 'OR';
    private static final String CODE_GLOSS_STANDARD = 'G-001'; 
    private static final String CODE_GLOSS_CONDITIONAL = 'G-002';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_SALUD_PG_NAME = 'ZRH_JSON_SaludPG'; 
    private static final String SR_ASV_COBERTURA_NAME = 'ZRH_JSON_CoberturaASV';
    private static final String SR_SALUD_REQ_ASEG_NAME = 'ZRH_JSON_SaludRA';
    private static final String SR_SALUD_DEF_NAME = 'ZRH_JSON_SaludDEF';
    private static final String SR_SALUD_PARAM_ASV_NAME = 'ZRH_JSON_SaludParamASV';
    private static final String SR_SALUD_PARAM_REPLACE_NAME = 'ZRH_JSON_SaludParamReplace';
    private static final String SR_SALUD_PARAM_CONDITION_NAME = 'ZRH_JSON_SaludParamCondition';
    private static final String SR_SALUD_PARAM_CONTAINS_NAME = 'ZRH_JSON_SaludParamContains';  
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_EnvioGlosasPoliza';
    private static final String SR_BODY_RESPONSE = 'ZRH_JSON_InputPDF';
    private static final String FOLIO_NUMBER = '1234-0';  
    
    
    @testSetup 
    static void setupMethod() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        StaticResource saludPG = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_PG_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testHealthCoverage = ZRH_DataFactory.createProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryHealthCoverage = ZRH_DataFactory.createPricebookEntry(true, testHealthCoverage);
        Quote parentQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote = ZRH_DataFactory.createChildQuote(true, testOpportunity, parentQuote);
        QuoteLineItem testQuoteLineItemHealthOne = ZRH_DataFactory.createQuoteLineItem(true, childQuote, testHealthProduct, testPricebookEntryHealth, saludASV.Body.toString());
        QuoteLineItem testQuoteLineItemHealthCoverage = ZRH_DataFactory.createQuoteLineItem(true, childQuote, testHealthCoverage, testPricebookEntryHealthCoverage, coberturaASV.Body.toString());
        
        Contract testContract = ZRH_DataFactory.createContract(true, parentQuote, testAccount);
        Contract testContractChild = ZRH_DataFactory.createContract(true, childQuote, testAccount);
        testContractChild.ZRH_ContratoHolding__c = testContract.Id;
        
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContractChild, testQuoteLineItemHealthOne);
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContractChild, testQuoteLineItemHealthCoverage);
        
        cgpOne.vlocity_ins_fsc__AttributeSelectedValues__c = testQuoteLineItemHealthOne.vlocity_ins__AttributeSelectedValues__c;
        
        
        cgpTwo.ContractGroupParentPlanId  = cgpone.Id;
        cgpTwo.vlocity_ins_fsc__AttributeSelectedValues__c = testQuoteLineItemHealthCoverage.vlocity_ins__AttributeSelectedValues__c;
        cgpOne.ZRH_Folio__c = FOLIO_NUMBER;
        cgpOne.ZRH_EnvioGlosaPendiente__c = true;
        update cgpOne;
        update cgpTwo;
        update testContractChild;
        
        ZRH_MaestroGlosas__c masterGlossOne = ZRH_DataFactory.createMasterGloss(true, 1.0);
        ZRH_MaestroGlosas__c masterGlossTwo = ZRH_DataFactory.createMasterGloss(true, 2.0);
        ZRH_MaestroGlosas__c masterGlossThree = ZRH_DataFactory.createMasterGloss(true, 3.0);
        ZRH_MaestroGlosas__c masterGlossFour = ZRH_DataFactory.createMasterGloss(true, 4.0);
        ZRH_MaestroGlosas__c masterGlossFive = ZRH_DataFactory.createMasterGloss(true, 154.0);
        
        ZRH_Glosas__c testGlosaHealthOne = ZRH_DataFactory.createRateGloss(true, testQuoteLineItemHealthOne.Id);
        ZRH_Glosas__c testGlosaHealthTwo = ZRH_DataFactory.createCoverageGloss(true, testQuoteLineItemHealthOne.Id);
        ZRH_Glosas__c testGlosaHealthThree = ZRH_DataFactory.createGloss(true, testQuoteLineItemHealthOne.Id);
        
        StaticResource saludDEF = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_DEF_NAME);
        parentQuote.ZRH_CuentasDEF__c = saludDEF.Body.toString();
        testContract.ZRH_CuentasDEF__c = saludDEF.Body.toString();
        update parentQuote;
        update testContract;
        
        childQuote.ZRH_Holding__c = testAccount.Id;
        testContractChild.ZRH_Holding__c = testAccount.Id;
        update childQuote;
        update testContractChild;
        
        StaticResource saludRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_REQ_ASEG_NAME);
        testQuoteLineItemHealthOne.ZRH_AtributosRequisitosAsegurabilidad__c = saludRA.Body.toString();
        cgpOne.ZRH_AtributosRequisitosAsegurabilidad__c = saludRA.Body.toString();
        cgpOne.ZRH_EndosoEnviado__c = true;
        update testQuoteLineItemHealthOne;
        update cgpOne;
        
        testQuoteLineItemHealthCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemHealthOne.Id;
        update testQuoteLineItemHealthCoverage;    
        
        StaticResource saludParamASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_PARAM_ASV_NAME);
        masterGlossOne.ZRH_Parametros__c = saludParamASV.Body.toString();
        masterGlossOne.ZRH_TipoDeGlosa__c = CODE_GLOSS_STANDARD;
        update masterGlossOne;
        
        StaticResource saludParamCondition = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_PARAM_CONDITION_NAME);
        masterGlossTwo.ZRH_Parametros__c = saludParamCondition.Body.toString();
        masterGlossTwo.ZRH_LogicaCondiciones__c = OPERATOR_AND;
        masterGlossTwo.ZRH_TipoDeGlosa__c = CODE_GLOSS_CONDITIONAL;
        update masterGlossTwo;
        
        StaticResource saludParamReplace = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_PARAM_REPLACE_NAME);
        masterGlossThree.ZRH_Parametros__c = saludParamReplace.Body.toString();
        masterGlossThree.ZRH_LogicaCondiciones__c = OPERATOR_OR;
        masterGlossThree.ZRH_TipoDeGlosa__c = CODE_GLOSS_CONDITIONAL;
        update masterGlossThree;
        
        StaticResource saludParamContains = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_PARAM_CONTAINS_NAME);
        masterGlossFour.ZRH_Parametros__c = saludParamContains.Body.toString();
        masterGlossFour.ZRH_LogicaCondiciones__c = OPERATOR_OR;
        masterGlossFour.ZRH_TipoDeGlosa__c = CODE_GLOSS_CONDITIONAL;
        update masterGlossFour;
        masterGlossFive.ZRH_Parametros__c = saludPG.Body.toString();
        masterGlossFive.ZRH_LogicaCondiciones__c = OPERATOR_AND;
        masterGlossFive.ZRH_TipoDeGlosa__c = CODE_GLOSS_CONDITIONAL;
        update masterGlossFive;
    }
    
    /**
    *  @Description: Test for the Method ZRH_BatchSubmitGlossPolicy
    *  @Autor:       LEC, Deloitte
    *  @Date:        24/1/2024
    */
    @isTest 
    static void ZRH_BatchSubmitGlossPolicy() {
        
        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        
        List<String> endPoint = new List<String>();
        endPoint.add(service.ZRH_URLBase__c + path.ZRH_RutaURL__c + '/' + FOLIO_NUMBER.split('-')[0]);
        List<String> resBody = new List<String>();
        resBody.add(SR_BODY_RESPONSE);
        ZRH_UtilityHttpRequestMock_TEST.getMultimock(endPoint, resBody, 200);
        
        Test.startTest();
        generateData();
        Id batId = Database.executeBatch(new ZRH_BatchSubmitGlossPolicy(), 1);
        batId = Database.executeBatch(new ZRH_BatchSubmitGlossPolicy('ZRH_EnvioGlosaPendiente__c = true'), 1);
        System.assertEquals(batId != null, true, 'Working!');
        Test.stopTest();
    }
    
     /**
    *  @Description: generate data
    *  @Autor:       LEC, Deloitte
    *  @Date:        24/1/2024
    */
    public static void generateData(){
        String valueCero = '0';
        ZRH_BatchSubmitGlossPolicy.Datos d = new ZRH_BatchSubmitGlossPolicy.Datos();
        d.dato = valueCero;
        
        ZRH_BatchSubmitGlossPolicy.Filas f = new ZRH_BatchSubmitGlossPolicy.Filas();
        f.Datos = new List<ZRH_BatchSubmitGlossPolicy.Datos>();
        
        ZRH_BatchSubmitGlossPolicy.Columnas c = new ZRH_BatchSubmitGlossPolicy.Columnas();
        c.nombre = valueCero;
        
        ZRH_BatchSubmitGlossPolicy.TablasA t = new ZRH_BatchSubmitGlossPolicy.TablasA();
        t.Columnas = new  List<ZRH_BatchSubmitGlossPolicy.Columnas>();
        t.FilaTabla = new List<ZRH_BatchSubmitGlossPolicy.Filas>();
        t.NombreTabla = valueCero;
        t.TituloTabla = valueCero;
        
        ZRH_BatchSubmitGlossPolicy.SubTitulosA s = new ZRH_BatchSubmitGlossPolicy.SubTitulosA();
        s.Contenido = valueCero;
        s.Nombre = valueCero;
        s.Tablas = new List<ZRH_BatchSubmitGlossPolicy.TablasA>();
        
        ZRH_BatchSubmitGlossPolicy.Articulos a = new ZRH_BatchSubmitGlossPolicy.Articulos();
        a.Nombre = valueCero;
        a.OrdenCondc = Decimal.valueOf(valueCero);
        a.SubTitulos = new List<ZRH_BatchSubmitGlossPolicy.SubTitulosA>();
        a.Titulo = valueCero;
        
        ZRH_BatchSubmitGlossPolicy.CondicionadoParticular cp = new ZRH_BatchSubmitGlossPolicy.CondicionadoParticular();
        cp.Articulos = new List<ZRH_BatchSubmitGlossPolicy.Articulos>();
        cp.Anexos = new List<ZRH_BatchSubmitGlossPolicy.Anexos>(); 
        
        ZRH_BatchSubmitGlossPolicy.Anexos anx = new ZRH_BatchSubmitGlossPolicy.Anexos();
        anx.Nombre = valueCero;
        anx.Titulo = valueCero;
        anx.SubTitulos = new List<ZRH_BatchSubmitGlossPolicy.SubTitulosA>();
        
        ZRH_BatchSubmitGlossPolicy.Tablas tb = new ZRH_BatchSubmitGlossPolicy.Tablas();
        tb.Columnas = new List<ZRH_BatchSubmitGlossPolicy.Columnas>();
        tb.Filas = new List<ZRH_BatchSubmitGlossPolicy.Filas>();
        tb.NombreTabla = valueCero;
        tb.TituloTabla = valueCero;
        
        ZRH_BatchSubmitGlossPolicy.TablasAntecedentesGrls grs = new ZRH_BatchSubmitGlossPolicy.TablasAntecedentesGrls();
        grs.Tablas = new List<ZRH_BatchSubmitGlossPolicy.Tablas>();
        
        ZRH_BatchSubmitGlossPolicy.PlocyGloss plz = new ZRH_BatchSubmitGlossPolicy.PlocyGloss();
        plz.CondicionadoParticular = cp;
        plz.TablasAntecedentesGrls = grs;
        plz.ContractId = valueCero;
        plz.Origen = valueCero;
        plz.Ambiente = valueCero;
        plz.CodigoSistema = valueCero;
        plz.DvPoliza = Integer.valueOf(valueCero);
        plz.Periodo = Integer.valueOf(valueCero);
        plz.Poliza = Integer.valueOf(valueCero);
    }
}