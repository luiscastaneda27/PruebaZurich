/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 13/03/2024
Description  : Test class for ZRH_JSONFolioNumber
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Andrés Deus                 AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      AD             13/03/2024       Created Test Class
********************************************************************************/
@IsTest
private class ZRH_JSONFolioNumber_TEST {

    private static final String SR_BODY_REQUEST = 'ZRH_JSON_FolioNumberRequest';
    private static final String SR_BODY_RESPONSE = 'ZRH_JSON_FolioNumberResponse';

    /**
    *  @Description: Test method to verify the parsing of JSON request into a Request object
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @IsTest
    static void testParseRequest() {
        String jsonRequest = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_BODY_REQUEST).Body.toString();
        
        // Call the method to test
        ZRH_JSONFolioNumber.Request requestObj = ZRH_JSONFolioNumber.parseRequest(jsonRequest);
        
        // Verify the results
        System.assertEquals('TestSource', requestObj.origen, 'The origen does not match');
        System.assertEquals(5, requestObj.cantidad, 'The cantidad does not match');
    }

    /**
    *  @Description: Test method to verify the parsing of JSON response into a Response object
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @IsTest
    static void testParseResponse() {
        String jsonResponse = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_BODY_RESPONSE).Body.toString();
        
        // Call the method to test
        ZRH_JSONFolioNumber.Response responseObj = ZRH_JSONFolioNumber.parseResponse(jsonResponse);
        
        // Verify the results
        System.assertEquals(1, responseObj.id, 'The id does not match');
        System.assertEquals(100, responseObj.folioInicial, 'The folioInicial does not match');
        System.assertEquals(105, responseObj.folioFinal, 'The folioFinal does not match');
    }
}