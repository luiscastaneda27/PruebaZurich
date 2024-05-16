/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 11/12/2023
Description  : Class test for class ZRH_ClonePlanController
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC         11/12/2023       initial version
********************************************************************************/
@isTest
public class ZRH_ClonePlanController_TEST {

    private static final String MAP_INPUT = 'input';
    private static final String MAP_OUTPUT = 'output';
    private static final String MAP_OPTIONS = 'options';
    private static final String TEXT_QUOTE_LINE_ITEM_ID = 'quoteLineItemId';
    private static final String TEXT_QUOTE_ID = 'quoteId';
    private static final String TEXT_RECORD_ID = 'QuoteLineItem';
    private static final String METHOD_NAME_CLON_PLAN = 'clonePlan';
    
     @testSetup 
    static void setupMethod() {
        
       
    }
    
    
    /**
    *  @Description: Test the for the class bathc ZRH_ClonePlanController
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        11/12/2023
    */
    @isTest 
    static void clonePlanControllerTest() {
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        Product2 testPersonalAccidentsProduct = ZRH_DataFactory.createPersonalAccidentsProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        PricebookEntry testPricebookEntryPersonalAccidents = ZRH_DataFactory.createPricebookEntry(true, testPersonalAccidentsProduct);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, '');
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testPersonalAccidentsProduct, testPricebookEntryPersonalAccidents,  '');
        
        testQuoteLineItemTwo.vlocity_ins__ParentItemId2__c = testQuoteLineItemOne.Id;
        update testQuoteLineItemTwo;
        
        ZRH_Glosas__c testGlosaHealthOne = ZRH_DataFactory.createRateGloss(true, testQuoteLineItemOne.Id);
        
        Map<String, Object> input = new  Map<String, Object>();
        input.put(TEXT_QUOTE_LINE_ITEM_ID, testQuoteLineItemOne.Id);
        input.put(TEXT_QUOTE_ID, testQuoteOne.Id);
        
        Map<String, Object> params = new Map<String, Object>();
        params.put(MAP_INPUT, input);
        params.put(MAP_OUTPUT, input);
        params.put(MAP_OPTIONS, input);
        
        Test.startTest();
        Object response = new ZRH_ClonePlanController().call(METHOD_NAME_CLON_PLAN, params);
        System.assertEquals(response, true, 'Working!');
        Test.stopTest();   
        
    }
}