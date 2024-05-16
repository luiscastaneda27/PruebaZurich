/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 12/10/2023
Description  : Class test for class ZRH_JSONGlossTables
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          12/10/2023        Initial Version
********************************************************************************/
@isTest
private class ZRH_JSONGlossTables_TEST {

    private static final String ASV_QLI = 'Test';

    /**
    *  @Description: Test for the Method parse
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest 
    static void parse() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteTwo = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItemLifeOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, ASV_QLI);
        QuoteLineItem testQuoteLineItemLifeTwo = ZRH_DataFactory.createQuoteLineItem(true, testQuoteTwo, testLifeProduct, testPricebookEntryLife, ASV_QLI);
        ZRH_Glosas__c testGlosaLifeOne = ZRH_DataFactory.createGloss(true, testQuoteLineItemLifeOne.Id);
        ZRH_Glosas__c testGlosaLifeTwo = ZRH_DataFactory.createGloss(true, testQuoteLineItemLifeTwo.Id);

        Set<ID> setIds = new Set<ID>();
        setIds.add(testQuoteOne.Id);
        setIds.add(testQuoteTwo.Id);
        
        Test.startTest();
        ZRH_JSONGlossTables gloss = new ZRH_ConditionedTables().mapping(setIds);
        String strGloss = JSON.serialize(gloss, true);
        ZRH_JSONGlossTables obj = (ZRH_JSONGlossTables)ZRH_JSONGlossTables.parse(strGloss);
        System.assertEquals(obj != null, true, 'Working!');
        Test.stopTest();
    }
}