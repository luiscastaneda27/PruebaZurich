/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 5/10/2023
Description  : Class test for class ZRH_GlosasSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          5/10/2023        initial version
********************************************************************************/
@isTest
public class ZRH_MaestroGlosasSelector_TEST {
	
    @testSetup 
    static void setupMethod() {
        ZRH_DataFactory.createMasterGloss(true, 1.0);
    }
    
    
    /**
    *  @Description: Test the for the selectByRecordType
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        7/02/2022
    */
    @isTest 
    static void selectByPlanCode() {
        Test.startTest();
        List<ZRH_MaestroGlosas__c > result = new ZRH_MaestroGlosasSelector().selectByPlanCode(ZRH_DataFactory.PBC_KQRY_PRC);
        System.assertEquals(result.size() > 0, true, 'It´s Worked!');
        Test.stopTest();
    }
}