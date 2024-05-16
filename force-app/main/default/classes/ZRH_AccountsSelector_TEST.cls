/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 5/10/2023
Description  : Class test for class ZRH_AccountsSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          5/10/2023        initial version
********************************************************************************/
@isTest
public class ZRH_AccountsSelector_TEST {

    
    private static final String OBJECT_ACCOUNT = 'Account';
    
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
        Account acc = ZRH_DataFactory.createAccount(true);
        
        Test.startTest();
        Account result = new ZRH_AccountsSelector().selectById(acc.Id, ZRH_ControllerGloss.getFieldsObj(OBJECT_ACCOUNT));
        System.assertEquals(result.Id == acc.Id, true, 'It´s Worked!');
        Test.stopTest();
    }
}