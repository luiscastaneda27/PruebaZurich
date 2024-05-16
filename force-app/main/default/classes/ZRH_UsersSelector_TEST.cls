/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 5/10/2023
Description  : Class test for class ZRH_UsersSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          5/10/2023        initial version
********************************************************************************/
@isTest
public class ZRH_UsersSelector_TEST {

    @testSetup 
    static void setupMethod() {
        // no record insert for tests
    }
    
    /**
    *  @Description: Test the for the Method selectById
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        7/02/2022
    */
    @isTest 
    static void selectById() {
        Test.startTest();
        User result = new ZRH_UsersSelector().selectById(UserInfo.getUserId());
        System.assertEquals(result.Id == UserInfo.getUserId(), true, 'It´s Worked!');
        Test.stopTest();
    }
}