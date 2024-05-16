/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 13/03/2024
Description  : Test class for ZRH_PolicyStatusScheduler, ensuring that the scheduler 
               for policy status updates functions correctly, including job scheduling,
               unscheduling, and execution.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Andrés Deus                 AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE             Description
1.0      AD             13/03/2024       Created Test Class
********************************************************************************/
@isTest
private class ZRH_PolicyStatusScheduler_TEST {

    /**
    *  @Description: Test method to verify that the scheduler job is properly scheduled
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @isTest
    static void testScheduler() {
        ZRH_CronTriggerSelector selector = new ZRH_CronTriggerSelector();
        
        // Check if job is already scheduled
        List<CronTrigger> existingJobs = selector.selectByJobName('Tarea Programada Estado de Pólizas');
        
        if (existingJobs.size() > 0) {
            String jobId = existingJobs[0].Id;
            unscheduleJob(jobId);
        }

        // Schedule the job
        String jobId = ZRH_PolicyStatusScheduler.scheduleJob();

        // Assert that the job is scheduled
        List<CronTrigger> scheduledJobs = selector.selectByJobName('Tarea Programada Estado de Pólizas');
        System.assertNotEquals(0, scheduledJobs.size(), 'Job should be scheduled');
    }

    /**
    *  @Description: Test method to verify that the scheduler job is properly unscheduled
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @isTest
    static void testUnscheduler() {
        ZRH_CronTriggerSelector selector = new ZRH_CronTriggerSelector();

        // Check if job is already scheduled
        List<CronTrigger> existingJobs = selector.selectByJobName('Tarea Programada Estado de Pólizas');
        if (existingJobs.isEmpty()) {
            // If job is not scheduled, schedule it first
            ZRH_PolicyStatusScheduler.scheduleJob();
        }

        // Get the job Id
        List<CronTrigger> scheduledJobs = selector.selectByJobName('Tarea Programada Estado de Pólizas');
        String jobId = scheduledJobs[0].Id;

        // Unschedule the job
        unscheduleJob(jobId);

        // Assert that the job is unscheduled
        List<CronTrigger> unscheduledJobs = selector.selectByJobName('Tarea Programada Estado de Pólizas');
        System.assertEquals(0, unscheduledJobs.size(), 'Job should be unscheduled');
    }

    /**
    *  @Description: Test method to verify the execution of the scheduler job
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @isTest
    static void testExecute() {
        // Create test data if needed
        // Insert Test Data

        Test.startTest();
        ZRH_PolicyStatusScheduler scheduler = new ZRH_PolicyStatusScheduler();
        scheduler.execute(null);
        Test.stopTest();
        
    }

    /**
    *  @Description: Helper method to unschedule a job
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    private static void unscheduleJob(String jobId) {
        Test.startTest();
        ZRH_PolicyStatusScheduler.unscheduleJob(jobId);
        Test.stopTest();

        // It's uncommon to assert in a helper method, but if you wish to do so:
        ZRH_CronTriggerSelector selector = new ZRH_CronTriggerSelector();
        List<CronTrigger> jobsAfterUnschedule = selector.selectByJobName('Tarea Programada Estado de Pólizas');
        System.assertEquals(0, jobsAfterUnschedule.size(), 'The job should be unscheduled');
    }
}