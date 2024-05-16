/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 10/10/2023
Description  : Class test for class ZRH_ConfiguracionTraduccionesSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          10/10/2023        Initial Version
********************************************************************************/
@isTest
public class ZRH_ConfiguracionTraduccionSelector_TEST {
    
    /**
    *  @Description: Test for the Method selectAll
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        10/10/2023
    */
    @isTest
    static void testSelectAll() {
        Test.startTest();
        List<ZRH_ConfiguracionTraduccion__mdt> translationList = new ZRH_ConfiguracionTraduccionesSelector().selectAll();
        System.assertEquals(translationList != null , true, 'Working!');
        Test.stopTest();
    }
}