/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 5/10/2023
Description  : Class test for class ZRH_GlosasSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
Josue Alejandro Aguilar             JAA 
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          5/10/2023        initial version
2.0      JAA         11/10/2023
********************************************************************************/
@isTest
public class ZRH_GlosasSelector_TEST {

    private static final String NAME_GLOSA = 'Glosa Test';
    
    /**
    *  @Description: Test the for the Method selectByQLIIdAndGlossType
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        7/02/2022
    */
    @isTest 
    static void selectByQuoteLineItemId() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, childQuote1, testProduct, testPricebookEntry, JSON.serialize(testAccount));
        ZRH_Glosas__c gloss = ZRH_DataFactory.createGloss(true, testQuoteLineItem.Id);
        
        Test.startTest();
        List<ZRH_Glosas__c> result = new ZRH_GlosasSelector().selectByQLIIdAndGlossType(gloss.ZRH_QuoteLineItem__c);
        System.assertEquals(result.size() > 0, true, 'It´s Worked!');
        Test.stopTest();
    }

    /**
    *  @Description: Test for the Method selectByStaticResourceNameWithLimit
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        11/10/2023
    */
    @isTest 
    static void selectByStaticResourceNameWithLimit() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, childQuote1, testProduct, testPricebookEntry, JSON.serialize(testAccount));
        ZRH_Glosas__c gloss = ZRH_DataFactory.createGloss(true, testQuoteLineItem.Id);

        gloss=[SELECT Id, Name FROM ZRH_Glosas__c WHERE Id = : gloss.id];
        
        Test.startTest();
        ZRH_Glosas__c result = new ZRH_GlosasSelector().selectByStaticResourceNameWithLimit(gloss.name);
        System.assertEquals(result != null, true, 'Working!');
        Test.stopTest();
    }

    /**
    *  @Description: Test for the Method selectBySetIds
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        11/10/2023
    */
    @isTest 
    static void selectBySetIds() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, childQuote1, testProduct, testPricebookEntry, JSON.serialize(testAccount));
        ZRH_Glosas__c gloss = ZRH_DataFactory.createGloss(true, testQuoteLineItem.Id);
        
        Set<Id> setIds = new Set<Id>();
        setIds.add(testQuoteLineItem.Id);
        
        Test.startTest();
        List<ZRH_Glosas__c> result = new ZRH_GlosasSelector().selectBySetIds(null, setIds);
        System.assertEquals(result.size() > 0, true, 'Working!');
        Test.stopTest();
    }

    /**
    *  @Description: Test for the Method selectByQLIId
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        11/10/2023
    */
    @isTest 
    static void selectByQLIId() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, childQuote1, testProduct, testPricebookEntry, JSON.serialize(testAccount));
        ZRH_Glosas__c gloss = ZRH_DataFactory.createGloss(true, testQuoteLineItem.Id);
        
        Set<Id> setIds = new Set<Id>();
        setIds.add(testQuoteLineItem.Id);
        
        Test.startTest();
        List<ZRH_Glosas__c> result = new ZRH_GlosasSelector().selectByQLIId(setIds);
        System.assertEquals(result.size() > 0, true, 'Working!');
        Test.stopTest();
    }

}