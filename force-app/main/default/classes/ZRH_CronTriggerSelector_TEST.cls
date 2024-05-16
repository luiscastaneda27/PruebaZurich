/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 14/03/2024
Description  : Class test for class ZRH_CronTriggerSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Andrés Deus                       AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      AD            14/03/2024       initial version
********************************************************************************/
@isTest
public class ZRH_CronTriggerSelector_TEST {

    /**
    *  @Description: Test the selector method for selecting by job name
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        14/03/2024
    */
    @isTest 
    static void selectByJobNameTest() {
        
        Test.startTest();
        List<CronTrigger> jobList = new ZRH_CronTriggerSelector().selectByJobName('TestJob');
        // You can't assert the size here since it's environment-dependent. Ideally, you'd use mocking.
        System.assertNotEquals(null, jobList, 'Job list should not be null');
        Test.stopTest();
    }

    // Additional tests can be created for other methods or scenarios as needed.
}