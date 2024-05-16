/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 10/10/2023
Description  : Class test for class ZRH_ConditionedTables
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          10/10/2023        Initial Version
********************************************************************************/
@isTest
private class ZRH_ConditionedTables_TEST {

    private static final String OBJECT_GLOSAS = 'ZRH_Glosas__c';
    private static final String FIELD_TIPO_GLOSA = 'ZRH_TipoDeGlosa__c';
    private static final String OBJECT_QUOTE = 'Quote';
	private static final String SR_ASV_VIDA_NAME = 'ZRH_JSON_VidaASV';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_ASV_COBERTURA_NAME = 'ZRH_JSON_CoberturaASV';
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';
    private static final String SR_TARIFA_VIDA_NAME = 'ZRH_JSON_VidaTarifa';
    private static final String SR_REQ_MED_NAME = 'ZRH_JSON_RequisitosMedicos';
    private static final String SR_VIDA_REQ_ASEG_NAME = 'ZRH_JSON_VidaRA';
    
    /**
    *  @Description: Test for the Method mapping
    *  @Autor:       Josue Aguilar, Deloitte
    *  @Date:        10/10/2023
    */
    @isTest 
    static void mapping() {
        
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        StaticResource saludTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        StaticResource vidaTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_VIDA_NAME);
        StaticResource vidaRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_VIDA_REQ_ASEG_NAME);
        StaticResource vidaRM = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        Product2 testPersonalAccidentsProduct = ZRH_DataFactory.createPersonalAccidentsProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        PricebookEntry testPricebookEntryPersonalAccidents = ZRH_DataFactory.createPricebookEntry(true, testPersonalAccidentsProduct);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteTwo = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteThree = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteFour = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItemLifeOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, vidaASV.Body.toString());
        QuoteLineItem testQuoteLineItemLifeTwo = ZRH_DataFactory.createQuoteLineItem(true, testQuoteTwo, testPersonalAccidentsProduct, testPricebookEntryPersonalAccidents,  vidaASV.Body.toString());
        QuoteLineItem testQuoteLineItemLifeThree = ZRH_DataFactory.createQuoteLineItem(true, testQuoteThree, testLifeProduct, testPricebookEntryLife,  vidaASV.Body.toString());
        QuoteLineItem testQuoteLineItemHealthOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteFour, testHealthProduct, testPricebookEntryHealth,  saludASV.Body.toString());
        ZRH_Glosas__c testGlosaHealthOne = ZRH_DataFactory.createRateGloss(true, testQuoteLineItemHealthOne.Id);
        ZRH_Glosas__c testGlosaLifeOne = ZRH_DataFactory.createRateGloss(true, testQuoteLineItemLifeOne.Id);
        ZRH_Glosas__c testGlosaLifeTwo = ZRH_DataFactory.createRequirementGloss(true, testQuoteLineItemLifeTwo.Id);
        ZRH_Glosas__c testGlosaLifeThree = ZRH_DataFactory.createMedicalRequirementGloss(true, testQuoteLineItemLifeThree.Id);

        testQuoteLineItemHealthOne.ZRH_Tarifa__c = saludTarifa.Body.toString();
        testQuoteLineItemLifeOne.ZRH_Tarifa__c = vidaTarifa.Body.toString();
        testQuoteLineItemLifeTwo.ZRH_AtributosRequisitosAsegurabilidad__c = vidaRA.Body.toString();
        testQuoteLineItemLifeThree.ZRH_AtributosReqMedicosSeleccionado__c = vidaRM.Body.toString();
        

        update testQuoteLineItemHealthOne;
        update testQuoteLineItemLifeOne;
        update testQuoteLineItemLifeTwo;
        update testQuoteLineItemLifeThree;

        Set<ID> setIds = new Set<ID>();
        setIds.add(testQuoteOne.Id);
        setIds.add(testQuoteTwo.Id);
        setIds.add(testQuoteThree.Id);
        setIds.add(testQuoteFour.Id);
        
        Test.startTest();
        ZRH_JSONGlossTables glosas = new ZRH_ConditionedTables().mapping(setIds);
        System.assertEquals(glosas != null, true, 'Working!');
        Test.stopTest();
    }

    /**
    *  @Description: Test for the Method mapping with coverages
    *  @Autor:       Josue Aguilar, Deloitte
    *  @Date:        10/10/2023
    */
    @isTest 
    static void mappingCoverages() {
        
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testHealthCoverage = ZRH_DataFactory.createProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryHealthCoverage = ZRH_DataFactory.createPricebookEntry(true, testHealthCoverage);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItemHealthOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testHealthProduct, testPricebookEntryHealth, saludASV.Body.toString());
        QuoteLineItem testQuoteLineItemHealthCoverage = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testHealthCoverage, testPricebookEntryHealthCoverage, coberturaASV.Body.toString());
        ZRH_Glosas__c testGlosaHealthOne = ZRH_DataFactory.createCoverageGloss(true, testQuoteLineItemHealthOne.Id);

        testQuoteLineItemHealthCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemHealthOne.Id;

        update testQuoteLineItemHealthCoverage;

        Set<ID> setIds = new Set<ID>();
        setIds.add(testQuoteOne.Id);
        
        Test.startTest();
        ZRH_JSONGlossTables coverages = new ZRH_ConditionedTables().mapping(setIds);
        System.assertEquals(coverages != null, true, 'Working!');
        Test.stopTest();
    }

    /**
    *  @Description: Test for the Method getPicklistValues
    *  @Autor:       Josue Aguilar, Deloitte
    *  @Date:        10/10/2023
    */
    @isTest 
    static void getPicklistValues() {        
        Test.startTest();
        Map<String,String> picklistValues = ZRH_ConditionedTables.getPicklistValues(OBJECT_GLOSAS, FIELD_TIPO_GLOSA);
        System.assertEquals(picklistValues != null, true, 'Working!');
        Test.stopTest();
    }

    
}