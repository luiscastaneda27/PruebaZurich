@isTest
private class ZRH_HoldingRatesController_TEST {

    @isTest
    static void testStartBatch() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Quote testQuote = ZRH_DataFactory.createQuote(true, testOpportunity);

        Test.startTest();
        Id batchJobId = ZRH_HoldingRatesController.startBatch(testQuote.Id);
        Test.stopTest();

        System.assert(batchJobId != null);
    }

    @isTest
    static void testGetBatchJobStatus() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Quote testQuote = ZRH_DataFactory.createQuote(true, testOpportunity);

        Id batchJobId = ZRH_HoldingRatesController.startBatch(testQuote.Id);
        
        Test.startTest();
        AsyncApexJob jobInfo = ZRH_HoldingRatesController.getBatchJobStatus(batchJobId);
        Test.stopTest();
        
        System.assert(jobInfo != null);
        
    }
}