/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 13/10/2023
Description  : Class test for class ZRH_ControllerGloss
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          13/10/2023        Initial Version
2.0      JAA          23/10/2023        Test Coverage Increase
********************************************************************************/
@isTest
private class ZRH_ControllerGloss_TEST {
    
    private static final String OBJECT_GLOSAS = 'ZRH_Glosas__c';
    private static final String FIELD_TIPO_GLOSA = 'ZRH_TipoDeGlosa__c';
    private static final String OBJECT_QUOTE = 'Quote';
    private static final String OPERATOR_AND = 'AND'; 
    private static final String OPERATOR_OR = 'OR';
    private static final String CODE_GLOSS_STANDARD = 'G-001'; 
    private static final String CODE_GLOSS_CONDITIONAL = 'G-002';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_ASV_COBERTURA_NAME = 'ZRH_JSON_CoberturaASV';
    private static final String SR_SALUD_REQ_ASEG_NAME = 'ZRH_JSON_SaludRA';
    private static final String SR_SALUD_DEF_NAME = 'ZRH_JSON_SaludDEF';
    private static final String SR_SALUD_PARAM_ASV_NAME = 'ZRH_JSON_SaludParamASV';
    private static final String SR_SALUD_PARAM_REPLACE_NAME = 'ZRH_JSON_SaludParamReplace';
    private static final String SR_SALUD_PARAM_CONDITION_NAME = 'ZRH_JSON_SaludParamCondition';
    private static final String SR_SALUD_PARAM_CONTAINS_NAME = 'ZRH_JSON_SaludParamContains';    
    
    /**
    *  @Description: Test for the Method getGlossNumberForPlan
    *  @Autor:       Josue Aguilar, Deloitte
    *  @Date:        13/10/2023
    */
    @isTest 
    static void getGlossNumberForPlan() {
        
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        
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
        ZRH_Glosas__c testGlosaHealthOne = ZRH_DataFactory.createCoverageGloss(true, testQuoteLineItemHealthOne.Id);

        testQuoteLineItemHealthCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemHealthOne.Id;
        
        update testQuoteLineItemHealthCoverage;
        
        Test.startTest();
        Integer gloss = ZRH_ControllerGloss.getGlossNumberForPlan(testQuoteLineItemHealthOne.Id);
        System.assertEquals(gloss != null, true, 'Working!');
        Test.stopTest();
    }
    
    /**
    *  @Description: Test for the Method manageGloss
    *  @Autor:       Josue Aguilar, Deloitte
    *  @Date:        13/10/2023
    */
    @isTest 
    static void manageGloss() {
        
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        
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
        ZRH_MaestroGlosas__c masterGlossOne = ZRH_DataFactory.createMasterGloss(true, 1.0);
        ZRH_MaestroGlosas__c masterGlossTwo = ZRH_DataFactory.createMasterGloss(true, 2.0);
        ZRH_MaestroGlosas__c masterGlossThree = ZRH_DataFactory.createMasterGloss(true, 3.0);
        ZRH_MaestroGlosas__c masterGlossFour = ZRH_DataFactory.createMasterGloss(true, 4.0);
        ZRH_Glosas__c testGlosaHealthOne = ZRH_DataFactory.createRateGloss(true, testQuoteLineItemHealthOne.Id);
        ZRH_Glosas__c testGlosaHealthTwo = ZRH_DataFactory.createCoverageGloss(true, testQuoteLineItemHealthOne.Id);
        ZRH_Glosas__c testGlosaHealthThree = ZRH_DataFactory.createGloss(true, testQuoteLineItemHealthOne.Id);

        StaticResource saludDEF = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_DEF_NAME);
        parentQuote.ZRH_CuentasDEF__c = saludDEF.Body.toString();
        update parentQuote;
        
        childQuote.ZRH_Holding__c = testAccount.Id;
        update childQuote;
        
        StaticResource saludRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_REQ_ASEG_NAME);
        testQuoteLineItemHealthOne.ZRH_AtributosRequisitosAsegurabilidad__c = saludRA.Body.toString();
        update testQuoteLineItemHealthOne;
        
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

        
        Test.startTest();
        Integer gloss = ZRH_ControllerGloss.manageGloss(testQuoteLineItemHealthOne.Id);
        System.assertEquals(gloss != null, true, 'Working!');
        Test.stopTest();
    }
}