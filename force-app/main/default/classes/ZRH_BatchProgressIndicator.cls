public class ZRH_BatchProgressIndicator {

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = new ZRH_AsyncApexJobsSelector().selectById(jobID)[0];
        return jobInfo;
    }

}