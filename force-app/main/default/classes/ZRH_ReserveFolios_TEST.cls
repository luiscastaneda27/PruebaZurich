@isTest
public class ZRH_ReserveFolios_TEST {
    
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';

    @isTest
    private static void reserveFoliosTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
            ZRH_ReserveFolios helper = new ZRH_ReserveFolios();
            Map<String, Object> args = new Map<String, Object>();
            args.put('input', new Map<String, Object>{'numeroDeFoliosAReservar' => 5});
            args.put('output', new Map<String, Object>());
            args.put('options', new Map<String, Object>());
            
            Object result = helper.call('reserveFolios', args);
        Test.stopTest();
            
        Map<String, Object> outputMap = (Map<String,Object>)args.get('output');
        List<String> listFolios = (List<String>)outputMap.get('listaFolios');
        System.assertEquals(5, listFolios.size());
    }

    @isTest
    private static void matchFoliosWithPlansTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuoteOne.ZRH_CotizacionHolding__c = holdingQuote.Id;
        insert testQuoteOne;

        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());

        Test.startTest();
        
            List<Object> listaFolios = new List<Object>();
            listaFolios.add('12345');
        
            List<Object> listaPlanes = new List<Object>();
            listaPlanes.add((Object)testQuoteLineItemOne.Id);

            ZRH_ReserveFolios helper = new ZRH_ReserveFolios();
            Map<String, Object> args = new Map<String, Object>();
            args.put('input', new Map<String, Object>{'listaFolios' => listaFolios, 'listaPlanes' => listaPlanes});
            args.put('output', new Map<String, Object>());
            args.put('options', new Map<String, Object>());
            
            Object result = helper.call('matchFoliosWithPlans', args);

        Test.stopTest();
            
        QuoteLineItem updatedQli = [SELECT Id FROM QuoteLineItem WHERE ZRH_Folio__c = :(String)listaFolios[0] LIMIT 1];
        System.assertNotEquals(null, updatedQli);
    }

    // Mock class to generate fake HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201); 
            String responseBody = '{' +
            '"statusCode": 201,' +
            '"folioInicial": 12345,' + 
            '"folioFinal": 12349' + 
            '}';
            res.setBody(responseBody);
            return res;
        }
    }
}