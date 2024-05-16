/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 12/10/2023
Description  : Class test for class ZRH_JSONRates
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          12/10/2023        Initial Version
********************************************************************************/
@isTest
private class ZRH_JSONRates_TEST {
    
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';

     /**
    *  @Description: Test for the Method parse
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest 
    static void parse() {
        Test.startTest();
        StaticResource saludTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        ZRH_JSONRates obj = (ZRH_JSONRates)ZRH_JSONRates.parse(saludTarifa.Body.toString());
        System.assertEquals(obj != null, true, 'Working!');
        Test.stopTest();
    }
}