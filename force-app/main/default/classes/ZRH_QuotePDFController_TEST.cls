/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 13/10/2023
Description  : Class test for class ZRH_QuotePDFController
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          13/10/2023        Initial Version
********************************************************************************/
@isTest
private class ZRH_QuotePDFController_TEST {

    private static final String SR_INPUT_NAME = 'ZRH_JSON_InputPDF';
    private static final String SR_ASV_VIDA_NAME = 'ZRH_JSON_VidaASV';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_ASV_COBERTURA_NAME = 'ZRH_JSON_CoberturaASV';
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';
    private static final String SR_TARIFA_VIDA_NAME = 'ZRH_JSON_VidaTarifa';
    private static final String SR_BODY_RESPONSE = 'ZRH_JSON_InputPDF';
    private static final String METHOD_NAME = 'executeGeneratePDF';
    private static final String INEXISTENT_METHOD_NAME = 'none';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
	private static final String INTEGRATION_ROUTE = 'ZRH_GeneracionPDF';
    private static final String SR_TARIFA_SCHOLARSHIP_NAME = 'ZRH_JSON_EscolaridadTarifa';
    private static final String LIFE_SCHOLARSHIP_RATE = 'TarifaEscolaridad';
    
    /**
    *  @Description: Test for the Method call
    *  @Autor:       Josue Aguilar, Deloitte
    *  @Date:        13/10/2023
    */
    @isTest 
    static void call() {
        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        
        List<String> endPoint = new List<String>();
        endPoint.add(service.ZRH_URLBase__c + path.ZRH_RutaURL__c);
        List<String> resBody = new List<String>();
        resBody.add(SR_BODY_RESPONSE);
        ZRH_UtilityHttpRequestMock_TEST.getMultimock(endPoint, resBody, 200);
        
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        StaticResource saludTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        StaticResource vidaTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_VIDA_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        Product2 testHealthCoverage = ZRH_DataFactory.createProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        PricebookEntry testPricebookEntryHealthCoverage = ZRH_DataFactory.createPricebookEntry(true, testHealthCoverage);
        Quote testParentQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testChildQuoteOne = ZRH_DataFactory.createChildQuote(true, testOpportunity, testParentQuote);
        Quote testChildQuoteTwo = ZRH_DataFactory.createChildQuote(true, testOpportunity, testParentQuote);
        QuoteLineItem testQuoteLineItemHealthOne = ZRH_DataFactory.createQuoteLineItem(true, testChildQuoteOne, testHealthProduct, testPricebookEntryHealth, saludASV.Body.toString());
        QuoteLineItem testQuoteLineItemLifeOne = ZRH_DataFactory.createQuoteLineItem(true, testChildQuoteTwo, testLifeProduct, testPricebookEntryLife, vidaASV.Body.toString());
        QuoteLineItem testQuoteLineItemHealthCoverage = ZRH_DataFactory.createQuoteLineItem(true, testChildQuoteOne, testHealthCoverage, testPricebookEntryHealthCoverage, coberturaASV.Body.toString());
        ZRH_Glosas__c testGlosaHealthOne = ZRH_DataFactory.createCoverageGloss(true, testQuoteLineItemHealthOne.Id);

        testQuoteLineItemHealthCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemHealthOne.Id;
        update testQuoteLineItemHealthCoverage;

        testQuoteLineItemHealthOne.ZRH_Tarifa__c = saludTarifa.Body.toString();
        update testQuoteLineItemHealthOne;

        testQuoteLineItemLifeOne.ZRH_Tarifa__c = vidaTarifa.Body.toString();
        update testQuoteLineItemLifeOne;
        
        StaticResource input = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_INPUT_NAME);

        Map<String,Object> inputMap = (Map<String,Object>)JSON.deserializeUntyped(input.Body.toString());
        Map<String, Object> inputEntry = (Map<String, Object>)inputMap.get('input');
        inputEntry.put('CotizacionId',testParentQuote.Id);
        inputEntry.put('AccountId',testAccount.Id);
        List<Object> planItems = (List<Object>)inputEntry.get('Planes');
        planItems.clear();
        planItems.add(new Map<String, Object>{
            'NombrePlan' => 'Salud',
            'CodigoPlan' => '600',
            'IdProductoCotizacion' => testQuoteLineItemHealthOne.Id,
            'RutContratante' => '12680728-7',
            'NombreContratante' => 'INSUMOS PRUEBA',
            'Vigencia' => '0 año'
        });
        planItems.add(new Map<String, Object>{
            'NombrePlan' => 'Vida',
            'CodigoPlan' => '500',
            'IdProductoCotizacion' => testQuoteLineItemLifeOne.Id,
            'RutContratante' => '12680728-7',
            'NombreContratante' => 'INSUMOS PRUEBA',
            'Vigencia' => '0 año'
        });

        Test.startTest();
        Object pdfResult = new ZRH_QuotePDFController().call(METHOD_NAME, inputMap);
        System.assertEquals(pdfResult != null, true, 'Working!');
        Test.stopTest();
    }

    /**
    *  @Description: Test for the Method call with inexistent method
    *  @Autor:       Josue Aguilar, Deloitte
    *  @Date:        13/10/2023
    */
    @isTest 
    static void callInexistentMethod() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testHealthCoverage = ZRH_DataFactory.createProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryHealthCoverage = ZRH_DataFactory.createPricebookEntry(true, testHealthCoverage);
        Quote testParentQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testChildQuoteOne = ZRH_DataFactory.createChildQuote(true, testOpportunity, testParentQuote);
        QuoteLineItem testQuoteLineItemHealthOne = ZRH_DataFactory.createQuoteLineItem(true, testChildQuoteOne, testHealthProduct, testPricebookEntryHealth, 'TEST');
        QuoteLineItem testQuoteLineItemHealthCoverage = ZRH_DataFactory.createQuoteLineItem(true, testChildQuoteOne, testHealthCoverage, testPricebookEntryHealthCoverage, 'TEST');
        ZRH_Glosas__c testGlosaHealthOne = ZRH_DataFactory.createCoverageGloss(true, testQuoteLineItemHealthOne.Id);

        testQuoteLineItemHealthCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemHealthOne.Id;
        update testQuoteLineItemHealthCoverage;
        
        StaticResource input = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_INPUT_NAME);

        Map<String,Object> inputMap = (Map<String,Object>)JSON.deserializeUntyped(input.body.toString());

        Test.startTest();
        Object pdfResult = new ZRH_QuotePDFController().call(INEXISTENT_METHOD_NAME, inputMap);
        StaticResource escolTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SCHOLARSHIP_NAME);
        Map<String,Object> obj = (Map<String,Object>)((Object) System.JSON.deserializeUntyped(escolTarifa.Body.toString()));
        ZRH_QuotePDFController.mapRatesScholarShip((List<Object>) obj.get(LIFE_SCHOLARSHIP_RATE));   
        System.assertEquals(pdfResult != null, true, 'Working!');
        Test.stopTest();
    }
}