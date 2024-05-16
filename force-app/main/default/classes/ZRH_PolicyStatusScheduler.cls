/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 14/12/2023
Description  : Salesforce Scheduler for automated tasks.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Andres Deus                         AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JD             14/12/2023      Initial Version
********************************************************************************/

global class ZRH_PolicyStatusScheduler implements Schedulable {
    /**
    *  @Description: This method contains the logic to be executed at the scheduled time.
    *  @Author: Andres Deus
    *  @Date: 14/12/2023
    */
    global void execute(SchedulableContext sc) {
        // Logic to be executed at the scheduled time
        System.debug('Scheduler executed: ' + DateTime.now());

        // Schedule the batch job
        String jobId = Database.executeBatch(new ZRH_PolicyStatusBatch(), 100); // 100 is the batch size

        System.debug('Batch job scheduled with jobId: ' + jobId);
    }

    /**
    *  @Description: This static method is used to schedule the scheduler job at a specified time using a cron expression.
    *  @Author: Andres Deus
    *  @Date: 14/12/2023
    */
    public static String scheduleJob() {
        // Schedule the job to run every day at Midnight
        String cronExp = '0 0 0 * * ? *';

        // Create an instance of the job
        ZRH_PolicyStatusScheduler policyStatusScheduler = new ZRH_PolicyStatusScheduler();

        // Schedule the job
        String jobId = System.schedule('Tarea Programada Estado de Pólizas', cronExp, policyStatusScheduler);

        return jobId;
    }

    /**
    *  @Description: This static method is used to unschedule the scheduler job based on the provided job ID.
    *  @Author: Andres Deus
    *  @Date: 14/12/2023
    */
    public static void unscheduleJob(String jobId) {
        // Cancel the job
        System.abortJob(jobId);
    }
}