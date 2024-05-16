/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 8/1/2024
Description  : Class test for class ZRH_SincronizacionEndososSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          8/1/2024        initial version
********************************************************************************/
@isTest
public class ZRH_SincronizacionEndososSelector_TEST {

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024 
    */
    private static final String QUERY_CONDITION = 'Id != null';
    
    
    /**
    *  @Description: Test the for the selectByDynamicCondition
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024
    */
    @isTest 
    static void selectByDynamicConditionTest() {
        Test.startTest();
        Database.QueryLocator query = new ZRH_SincronizacionEndososSelector().selectByDynamicCondition(QUERY_CONDITION);
        System.assertEquals(query != null, true, 'It´s Worked!');
        Test.stopTest();
    }
}