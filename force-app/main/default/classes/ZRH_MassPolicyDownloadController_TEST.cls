/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 20/12/2023
Description  : Class test for class ZRH_MassPolicyDownloadController
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          20/12/2023        initial version
********************************************************************************/
@isTest
public class ZRH_MassPolicyDownloadController_TEST {

     /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        20/12/2023  
    */
    private static final String MAP_INPUT = 'input';
    private static final String MAP_OUTPUT = 'output';
    private static final String MAP_OPTIONS = 'options';
    private static final String METHOD_NAME = 'getAccounts';
    private static final String NAME_RESPONSE = 'responseApexClass';
    private static final String NAME_ACCOUNT = 'accountId';
    private static final String NAME_QUERY = 'query';
    private static final String NAME_QUERY_FILES = 'Select Id FROM ContentDocumentLink where LinkedEntityId in :contractList';
    
     @testSetup 
    static void setupMethod() {
        // no record insert for tests
    }
    
    /**
    *  @Description: Test for the Method getAccounts
    *  @Autor:       Luis Castañeda, Deloitte
    *  @Date:        7/11/2023
    */
    @isTest 
    static void massPolicyDownloadControllerTest() {
        Account testAccountHol = ZRH_DataFactory.createAccount(true);
        Account testAccount = ZRH_DataFactory.createAccount(true);
        testAccount.ParentId = testAccountHol.Id;
        update testAccount;
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
        
        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> params = new Map<String, Object>();
        
        inputMap.put(NAME_ACCOUNT, testAccount.Id);
        inputMap.put(NAME_QUERY, NAME_QUERY_FILES);
        params.put(MAP_INPUT, inputMap);
        params.put(MAP_OUTPUT, outputMap);
        params.put(MAP_OPTIONS, options);
        Test.startTest();
        ZRH_MassPolicyDownloadController obj = new ZRH_MassPolicyDownloadController();
        obj.call(METHOD_NAME, params);
        inputMap.put(NAME_ACCOUNT, testAccountHol.Id);
        Object response = obj.call(METHOD_NAME, params);
        System.assertEquals(response != null, true, 'Working!');
        Test.stopTest();
    }
}