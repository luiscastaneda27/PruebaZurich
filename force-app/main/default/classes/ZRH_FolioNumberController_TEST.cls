@isTest
private class ZRH_FolioNumberController_TEST {

    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_ConsultaFolio';

    /**
    *  @Description: Private helper method to set up and execute test logic
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    private static void executeTest(String staticResourceName, Integer expectedStatusCode, Boolean isSuccessTest) {
        StaticResource bodyResponse = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(staticResourceName);
        String expectedStatus = bodyResponse.Body.toString();
        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        String endPoint = service.ZRH_URLBase__c + path.ZRH_RutaURL__c;

        Test.setMock(HttpCalloutMock.class, new ZRH_UtilityHttpRequestMock_TEST(endPoint, 'application/json', expectedStatusCode, expectedStatus));

        Map<String, Object> result = new ZRH_FolioNumberController().response(5);

        System.assertEquals(expectedStatusCode, result.get('statusCode'), 'The status code should match the expected value.');

        if (isSuccessTest) {
            System.assertNotEquals(null, result.get('folioNumbers'), 'Folio numbers should be populated.');
        } else {
            List<String> folioNumbs = (List<String>)result.get('folioNumbers');
            System.assertEquals(0, folioNumbs.size(), 'No folio numbers should be populated on failure.');
        }
    }

    /**
    *  @Description: Test method to verify successful folio number generation
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @isTest 
    private static void testResponseSuccess() {
        executeTest('ZRH_JSON_FolioNumberSuccess', 201, true);
    }

    /**
    *  @Description: Test method to verify the handling of failed service calls
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @isTest 
    private static void testFailureSuccess() {
        executeTest('ZRH_JSON_FolioNumberFailure', 404, false);
    }
}