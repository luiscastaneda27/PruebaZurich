@isTest
private class ZRH_AsyncApexJobsSelector_TEST {

    @isTest
    private static void testAsyncApexJob() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote childQuote = ZRH_DataFactory.createQuote(true, testOpportunity);

        Test.startTest();
        ZRH_CalculateHoldingRatesBatch batch = new ZRH_CalculateHoldingRatesBatch();
        batch.quoteId = childQuote.Id;
        Id batchJobId = Database.executeBatch(batch);
        List<AsyncApexJob> job = new ZRH_AsyncApexJobsSelector().selectById(batchJobId);
        Test.stopTest();

        System.assertEquals(1, job.size());


    }
}