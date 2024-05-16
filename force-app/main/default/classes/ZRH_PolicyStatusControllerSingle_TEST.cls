/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 13/03/2024
Description  : Test class for ZRH_PolicyStatusControllerSingle, ensuring that policy 
               status retrieval and processing behave as expected.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Andrés Deus                 AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE             Description
1.0      AD             13/03/2024       Created Test Class
********************************************************************************/
@IsTest
private class ZRH_PolicyStatusControllerSingle_TEST {

    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_ConsultaEstadoPoliza';
    private static final String BODY_RESPONSE = '2';
    private static final String FOLIO_NUMBER = '373951';

    /**
    *  @Description: Sets up the mock response for HTTP callout
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    private static void setupMock() {
        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        String endPoint = service.ZRH_URLBase__c + path.ZRH_RutaURL__c;
        Test.setMock(HttpCalloutMock.class, new ZRH_UtilityHttpRequestMock_TEST(endPoint, 'application/json', 200, BODY_RESPONSE));
    }

    /**
    *  @Description: Tests the call method for its HTTP response and body content
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @IsTest
    private static void testCall() {
        setupMock();

        Test.startTest();
        HttpResponse res = ZRH_PolicyStatusControllerSingle.call(FOLIO_NUMBER);
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
        System.assertEquals(BODY_RESPONSE, res.getBody());
    }

    /**
    *  @Description: Tests the response method for correct data processing and output
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @IsTest
    private static void testResponse() {
        setupMock();

        List<String> inputVariables = new List<String>{FOLIO_NUMBER};

        Test.startTest();
        List<String> outputVariables = ZRH_PolicyStatusControllerSingle.response(inputVariables);
        Test.stopTest();

        System.assertEquals(1, outputVariables.size());
        System.assertEquals(BODY_RESPONSE, outputVariables[0]);
    }

    /**
    *  @Description: Tests the responseForJob method for correct data processing and single output
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @IsTest
    private static void testResponseForJob() {
        setupMock();

        List<String> inputVariables = new List<String>{FOLIO_NUMBER};

        Test.startTest();
        String result = ZRH_PolicyStatusControllerSingle.responseForJob(FOLIO_NUMBER);
        Test.stopTest();

        System.assertEquals(BODY_RESPONSE, result);
    }
}