/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Zurich
Created Date : 30/11/2023
Description  : Class test for class ZRH_UploadPDFController
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Edwin Rocha Quezada                 ERQ
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ERQ          30/11/2023        initial version
********************************************************************************/
@isTest
private class ZRH_UploadPDFControllerTest {
    /**
    *  @Description: Static variables
    *  @Autor:       ERQ, Zurich, edwin.rocha@mx.zurich.com
    *  @Date:        30/11/2023  
    */
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
	private static final String INTEGRATION_ROUTE = 'ZRH_SubirPDFCotizacion';
    private static final String SR_BODY_RESPONSE = 'ZRH_JSON_InputPDF';

    /**
    *  @Description: Method to execute Schedule Job
    *  @Autor:       ERQ, Zurich, edwin.rocha@mx.zurich.com
    *  @Date:        30/11/2023  
    */
	static void setupMethod() {
        // no record insert for tests
    }
    
    /**
    *  @Description: Method to execute test for uploadPDFQuote
    *  @Autor:       ERQ, Zurich, edwin.rocha@mx.zurich.com
    *  @Date:        30/11/2023  
    */
    @isTest
    static void testUploadPDFQuote() {
		ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        List<String> endPoint = new List<String>();
        endPoint.add(service.ZRH_URLBase__c + path.ZRH_RutaURL__c);
        List<String> resBody = new List<String>();
        resBody.add(SR_BODY_RESPONSE);
        ZRH_UtilityHttpRequestMock_TEST.getMultimock(endPoint, resBody, 200);
        Test.startTest();
        ZRH_UploadPDFController.uploadPDFQuote();
        Test.stopTest();    
    }
}