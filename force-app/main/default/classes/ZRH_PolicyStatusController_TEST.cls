/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 13/03/2024
Description  : Test class for ZRH_PolicyStatusController, ensuring that the controller
               correctly interacts with policy status data and services.
********************************************************************************/
@IsTest
private class ZRH_PolicyStatusController_TEST {

    private static final String QUERY_CONDITION = 'ContractGroupParentPlanId = null';
    private static final String SR_ASV_VIDA_NAME = 'ZRH_JSON_VidaASV';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_ASV_COBERTURA_NAME = 'ZRH_JSON_CoberturaASV';
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';
    private static final String SR_TARIFA_VIDA_NAME = 'ZRH_JSON_VidaTarifa';
    private static final String SR_VIDA_REQ_ASEG_NAME = 'ZRH_JSON_VidaRA';
    private static final String SR_SALUD_LIMITS_NAME = 'ZRH_JSON_LIMITS';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_ConsultaEstadoPoliza';
    private static final String BODY_RESPONSE = '2';
    private static final String FOLIO_NUMBER = '373951';

    /**
    *  @Description: Setup method to prepare data for test scenarios
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @testSetup 
    static void setupMethod() {
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        StaticResource saludTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        StaticResource vidaTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_VIDA_NAME);
        StaticResource vidaRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_VIDA_REQ_ASEG_NAME);
        StaticResource saludLimits = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_LIMITS_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        
        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        
        cgpOne.ZRH_Tarifa__c = saludTarifa.Body.toString();
        cgpOne.ZRH_AtributosTopes__c = saludLimits.Body.toString();
        cgpOne.ZRH_Folio__c = FOLIO_NUMBER;
        cgpOne.ZRH_AtributosRequisitosAsegurabilidad__c = vidaRA.Body.toString();
        
        update cgpOne;
    }

    /**
    *  @Description: Test method to verify the call method's functionality and response handling
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @IsTest
    static void testCallMethod() {
        setupMock();
        Test.startTest();
        HttpResponse response = ZRH_PolicyStatusController.call(FOLIO_NUMBER);
        Test.stopTest();

        // Assert that the response is not null
        System.assertNotEquals(null, response, 'Response should not be null');

        // Assert the status code of the response
        System.assertEquals(200, response.getStatusCode(), 'Status code should be 200');

        // Assert the response body
        System.assertEquals(BODY_RESPONSE, response.getBody(), 'Response body should match the mock response');
    }

    /**
    *  @Description: Test method to verify the response method's functionality in processing and outputting data
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @IsTest
    static void testResponseMethod() {
        setupMock();
        String condition = 'ZRH_Folio__c = \'' + FOLIO_NUMBER + '\'';
        List<ContractGroupPlan> mockPlans = new ZRH_ContractGroupPlansSelector().selectByFolio(condition, new List<String>{'Name'});

        Test.startTest();
        List<String> output = ZRH_PolicyStatusController.response(new List<List<ContractGroupPlan>>{mockPlans});
        Test.stopTest();

        // Assert that the output is not null
        System.assertNotEquals(null, output, 'Output should not be null');
    }

    /**
    *  @Description: Utility method to setup mock HTTP response
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    private static void setupMock() {
        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        String endPoint = service.ZRH_URLBase__c + path.ZRH_RutaURL__c;
        Test.setMock(HttpCalloutMock.class, new ZRH_UtilityHttpRequestMock_TEST(endPoint, 'application/json', 200, BODY_RESPONSE));
    }
}