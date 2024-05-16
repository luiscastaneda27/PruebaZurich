@isTest
public class ZRH_insQuoteController_TEST {
    
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';

    @isTest
    private static void getQuoteLineItemGroupClassesTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);

        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuoteOne.ZRH_CotizacionHolding__c = holdingQuote.Id;
        insert testQuoteOne;
        
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        
        vlocity_ins__GroupClass__c gc = new vlocity_ins__GroupClass__c();
        gc.Name = 'test';
        gc.vlocity_ins__IsActive__c = true;
        gc.vlocity_ins__GroupId__c = testAccount.Id;
        insert gc;

        vlocity_ins__QuoteLineItemGroupClass__c qliGC = new vlocity_ins__QuoteLineItemGroupClass__c();
        qliGC.vlocity_ins__GroupClassId__c = gc.Id;
        qliGC.vlocity_ins__QuoteLineItemId__c = testQuoteLineItemOne.Id;
        qliGC.vlocity_ins__QuoteId__c = testQuoteOne.Id;
        insert qliGC;

        Test.startTest();
        
        List<vlocity_ins__QuoteLineItemGroupClass__c> qliGCs = ZRH_insQuoteController.getQuoteLineItemGroupClasses(testQuoteOne.Id);
        Test.stopTest();

        System.assertEquals(1, qliGCs.size(), 'getQuoteLineItemGroupClassesTest failed');
    }

    @isTest
    private static void getRootQuoteLineItemsTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);

        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuoteOne.ZRH_CotizacionHolding__c = holdingQuote.Id;
        insert testQuoteOne;
        
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());

        Test.startTest();        
        List<Id> rootIds = ZRH_insQuoteController.getRootQuoteLineItems(testQuoteOne.Id);
        Test.stopTest();

        System.assertEquals(1, rootIds.size(), 'getRootQuoteLineItemsTest failed');
    }

    @isTest
    private static void getRootIdToCoverageCountQuoteLineItemsTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);

        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuoteOne.ZRH_CotizacionHolding__c = holdingQuote.Id;
        insert testQuoteOne;
        
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());

        Test.startTest();        
        Map<Id, Integer> rootIdToCovCt = ZRH_insQuoteController.getRootIdToCoverageCountQuoteLineItems(testQuoteOne.Id);
        Test.stopTest();

        System.assertEquals(true, rootIdToCovCt.containsKey(testQuoteLineItemOne.Id), 'getRootIdToCoverageCountQuoteLineItemsTest no key');
        System.assertEquals(0, rootIdToCovCt.get(testQuoteLineItemOne.Id), 'getRootIdToCoverageCountQuoteLineItemsTest count mismatch');
    }
}