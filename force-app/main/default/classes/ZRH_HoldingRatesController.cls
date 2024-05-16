public with sharing class ZRH_HoldingRatesController {

    @AuraEnabled
    public static Id startBatch(Id quoteId) {      
        ZRH_CalculateHoldingRatesBatch batch = new ZRH_CalculateHoldingRatesBatch();
        batch.quoteId = quoteId;
        Id batchJobId = Database.executeBatch(batch);
        return batchJobId;
    }

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = new ZRH_AsyncApexJobsSelector().selectById(jobID)[0];
        return jobInfo;
    }
}