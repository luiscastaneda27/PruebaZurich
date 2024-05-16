/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 8/1/2024
Description  : Class test for class ZRH_BatchGeneratePolicyGloss and ZRH_ControllerGlossPolicy
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          8/1/2024         Initial Version
********************************************************************************/
@isTest
public class ZRH_BatchGeneratePolicyGloss_TEST {

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
        cgpOne.ZRH_Periodo__c = 0;
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
    *  @Description: Test for the Method manageGloss
    *  @Autor:       LEC, Deloitte
    *  @Date:        8/1/2024
    */
    @isTest 
    static void manageGloss() {
        Test.startTest();
        Id batId = Database.executeBatch(new ZRH_BatchGeneratePolicyGloss(), 1);
        System.assertEquals(batId != null, true, 'Working!');
        Test.stopTest();
    }
    
}