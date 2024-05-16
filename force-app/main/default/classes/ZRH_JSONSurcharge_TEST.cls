/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 20/11/2023
Description  : Class test for class ZRH_JsonSurchange
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Jean Nieto                         JN
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JN          20/11/2023        Initial Version
********************************************************************************/

@isTest
public class ZRH_JSONSurcharge_TEST {
    private static final String SR_Surcharge = 'ZRH_JSON_Surcharge';
    @isTest
    static void testDeserialize() {
        StaticResource surcharge= new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_Surcharge);
        String jsonString = surcharge.Body.toString();
        Test.startTest();
        List<ZRH_JSONSurcharge> resultSurcharge= ZRH_JSONSurcharge.parse(jsonString);
        for(ZRH_JSONSurcharge rs : resultSurcharge){
            System.assertEquals('Hijo/a', rs.parentesco);
            System.assertEquals('65', rs.edadSobre);
            System.assertEquals('20', rs.porcSobreprima);
        }
        Test.stopTest();
        
    }
}