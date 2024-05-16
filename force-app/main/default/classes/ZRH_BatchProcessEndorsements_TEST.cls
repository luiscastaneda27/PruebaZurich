/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 17/1/2024
Description  : Class test for class ZRH_BatchProcessEndorsements and ZRH_ProcessEndorsementsController
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          17/1/2024         Initial Version
********************************************************************************/
@isTest
public class ZRH_BatchProcessEndorsements_TEST {
    
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
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';
    private static final String SR_TARIFA_SCHOLARSHIP_NAME = 'ZRH_JSON_EscolaridadTarifa';
    private static final String SR_SALUD_PARAM_ASV_NAME = 'ZRH_JSON_SaludParamASV';
    private static final String SR_SALUD_PARAM_REPLACE_NAME = 'ZRH_JSON_SaludParamReplace';
    private static final String SR_SALUD_PARAM_CONDITION_NAME = 'ZRH_JSON_SaludParamCondition';
    private static final String SR_SALUD_PARAM_CONTAINS_NAME = 'ZRH_JSON_SaludParamContains';  
    private static final String NUMBER_FOLIO = '123123-0'; 
    public static final String LIFE_SCHOLARSHIP_PLAN= '501';
    public static final String ENDORSEMENT_TYPE= 'E-056';
    
    
    /**
    *  @Description: Test for the Method processEndorsements
    *  @Autor:       LEC, Deloitte
    *  @Date:        17/1/2024
    */
    @isTest 
    static void processEndorsements() {
        
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        StaticResource saludPG = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_PG_NAME);
        StaticResource saludTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        StaticResource escolTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SCHOLARSHIP_NAME);
        
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
        cgpOne.ZRH_Folio__c = NUMBER_FOLIO;
        cgpOne.ZRH_Periodo__c = 0;
        cgpOne.ZRH_Tarifa__c = saludTarifa.Body.toString();
        cgpOne.AccountId = testAccount.Id;
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
        
        ZRH_SincronizacionEndoso__c endoso = new ZRH_SincronizacionEndoso__c();
        endoso.ZRH_NombreObjeto__c = 'ContractGroupPlan';
        endoso.ZRH_Folio__c = NUMBER_FOLIO;
        endoso.ZRH_NombreCampo__c = 'ZRH_AtributosBMI__c';
        endoso.ZRH_Valor__c = 'Test';
        endoso.ZRH_TipoCampo__c = 'Campo Salesforce';
        endoso.ZRH_TipoEndoso__c = ENDORSEMENT_TYPE;
        endoso.ZRH_TipoObjeto__c = 'Principal'; // Principal, Cobertura 
        insert endoso;
        
        
        Test.startTest();
        Id batId = Database.executeBatch(new ZRH_BatchProcessEndorsements('Id != null'), 1);
        ZRH_ScheduleProcessEndorsements sc = new ZRH_ScheduleProcessEndorsements(); 
        sc.execute(null);
        System.assertEquals(sc != null, true, 'Working!');
        
        endoso = new ZRH_SincronizacionEndoso__c();
        endoso.ZRH_CampoCondicion__c = '';
        endoso.ZRH_CampoCondicionDos__c = '';
        endoso.ZRH_Folio__c = NUMBER_FOLIO;
        endoso.ZRH_NombreAtributo__c = 'Test';
        endoso.ZRH_NombreCampo__c = 'vlocity_ins__AttributeSelectedValues__c';
        endoso.ZRH_NombreObjeto__c = 'ContractGroupPlan';
        endoso.ZRH_TipoCampo__c = 'JSON'; //Campo Salesforce, JSON
        endoso.ZRH_TipoEndoso__c = '56';
        endoso.ZRH_TipoObjeto__c = 'Cobertura'; // Principal, Cobertura 
        endoso.ZRH_Valor__c = 'Test';
        endoso.ZRH_ValorCondicion__c = '600';
        endoso.ZRH_ValorCondicionDos__c = '';
        ZRH_ProcessEndorsementsController.processEndorsements(endoso);
        
        endoso.ZRH_CampoCondicion__c = 'ParentescoSalud';
        endoso.ZRH_ValorCondicion__c = 'Titular';
        endoso.ZRH_CampoCondicionDos__c = '';
        endoso.ZRH_Folio__c = NUMBER_FOLIO;
        endoso.ZRH_NombreAtributo__c = 'EdadSalidaS';
        endoso.ZRH_Valor__c = '1';
        endoso.ZRH_NombreCampo__c = 'ZRH_AtributosRequisitosAsegurabilidad__c';
        endoso.ZRH_NombreObjeto__c = 'ContractGroupPlan';
        endoso.ZRH_TipoCampo__c = 'JSON'; //Campo Salesforce, JSON
        endoso.ZRH_TipoEndoso__c = ENDORSEMENT_TYPE;
        endoso.ZRH_TipoObjeto__c = 'Principal'; // Principal, Cobertura 
        endoso.ZRH_ValorCondicionDos__c = '';
        ZRH_ProcessEndorsementsController.processEndorsements(endoso);
        
        endoso.ZRH_CampoCondicion__c = 'DescTarifaSalud';
        endoso.ZRH_ValorCondicion__c = 'EMPRESA';
        endoso.ZRH_CampoCondicionDos__c = '';
        endoso.ZRH_Folio__c = NUMBER_FOLIO;
        endoso.ZRH_NombreAtributo__c = 'TarifaSaludPP';
        endoso.ZRH_Valor__c = '1';
        endoso.ZRH_NombreCampo__c = 'ZRH_Tarifa__c';
        endoso.ZRH_NombreObjeto__c = 'ContractGroupPlan';
        endoso.ZRH_TipoCampo__c = 'JSON'; //Campo Salesforce, JSON
        endoso.ZRH_TipoEndoso__c = ENDORSEMENT_TYPE;
        endoso.ZRH_TipoObjeto__c = 'Principal'; // Principal, Cobertura 
        endoso.ZRH_ValorCondicionDos__c = '';
        ZRH_ProcessEndorsementsController.processEndorsements(endoso);
        
        testHealthProduct.ProductCode = LIFE_SCHOLARSHIP_PLAN;
        update testHealthProduct;
        
        
        cgpOne.ZRH_Tarifa__c = escolTarifa.Body.toString();
        update cgpOne;
        
        endoso.ZRH_CampoCondicion__c = 'DescripcionNivel';
        endoso.ZRH_ValorCondicion__c = 'SIN NIVEL ESCOLARIDAD';
        endoso.ZRH_CampoCondicionDos__c = 'CodigoCobertura';
        endoso.ZRH_ValorCondicionDos__c = '80';
        endoso.ZRH_Folio__c = NUMBER_FOLIO;
        endoso.ZRH_NombreAtributo__c = 'PrimaMensualEsc';
        endoso.ZRH_Valor__c = '1';
        endoso.ZRH_NombreCampo__c = 'ZRH_Tarifa__c';
        endoso.ZRH_NombreObjeto__c = 'ContractGroupPlan';
        endoso.ZRH_TipoCampo__c = 'JSON'; //Campo Salesforce, JSON
        endoso.ZRH_TipoEndoso__c = ENDORSEMENT_TYPE;
        endoso.ZRH_TipoObjeto__c = 'Principal'; // Principal, Cobertura
        ZRH_ProcessEndorsementsController.processEndorsements(endoso); 
        
        
        endoso.ZRH_CampoCondicion__c = '';
        endoso.ZRH_ValorCondicion__c = '';
        endoso.ZRH_CampoCondicionDos__c = '';
        endoso.ZRH_ValorCondicionDos__c = '';
        endoso.ZRH_Folio__c = NUMBER_FOLIO;
        endoso.ZRH_NombreAtributo__c = '';
        endoso.ZRH_Valor__c = '1';
        endoso.ZRH_NombreCampo__c = 'ZRH_AtributosAsistenciasSeleccionados__c';
        endoso.ZRH_NombreObjeto__c = 'Contract';
        endoso.ZRH_TipoCampo__c = 'Campo Salesforce'; //Campo Salesforce, JSON
        endoso.ZRH_TipoEndoso__c = ENDORSEMENT_TYPE;
        endoso.ZRH_TipoObjeto__c = 'Principal'; // Principal, Cobertura
        ZRH_ProcessEndorsementsController.processEndorsements(endoso); 
        
        
        endoso.ZRH_CampoCondicion__c = 'Campo';
        endoso.ZRH_ValorCondicion__c = 'C = Comisiones Pagadas';
        endoso.ZRH_CampoCondicionDos__c = 'Planes';
        endoso.ZRH_ValorCondicionDos__c = '600';
        endoso.ZRH_Folio__c = NUMBER_FOLIO;
        endoso.ZRH_NombreAtributo__c = 'Valor';
        endoso.ZRH_Valor__c = '1';
        endoso.ZRH_NombreCampo__c = 'ZRH_CuentasDEF__c';
        endoso.ZRH_NombreObjeto__c = 'Contract';
        endoso.ZRH_TipoCampo__c = 'JSON'; //Campo Salesforce, JSON
        endoso.ZRH_TipoEndoso__c = ENDORSEMENT_TYPE;
        endoso.ZRH_TipoObjeto__c = 'Principal'; // Principal, Cobertura
        ZRH_ProcessEndorsementsController.processEndorsements(endoso); 
        
        endoso.ZRH_CampoCondicion__c = 'Campo';
        endoso.ZRH_ValorCondicion__c = 'C = Comisiones Pagadas';
        endoso.ZRH_CampoCondicionDos__c = 'Planes';
        endoso.ZRH_ValorCondicionDos__c = '600';
        endoso.ZRH_Folio__c = NUMBER_FOLIO;
        endoso.ZRH_NombreAtributo__c = 'Valor';
        endoso.ZRH_Valor__c = 'false';
        endoso.ZRH_NombreCampo__c = 'vlocity_ins__Disclosure3__c';
        endoso.ZRH_NombreObjeto__c = 'Account';
        endoso.ZRH_TipoCampo__c = 'Campo Salesforce'; //Campo Salesforce, JSON
        endoso.ZRH_TipoEndoso__c = ENDORSEMENT_TYPE;
        endoso.ZRH_TipoObjeto__c = 'Principal'; // Principal, Cobertura
        ZRH_ProcessEndorsementsController.processEndorsements(endoso); 
        
        endoso.Id = null;
        endoso.ZRH_Estado__c = 'Error';
        insert endoso;
        ZRH_BatchProcessEndorsements.deleteRecords('ZRH_Estado__c = \'Error\'');
        Test.stopTest();
    }

}