@isTest
public with sharing class API_Cotizacion_GLB_TEST {
    @TestSetup
    static void testSetup(){
        Account a = new Account(
            Name = 'TEST ACCOUNT',
            GLBP1_Rut__c = '65155524-8'
        );

        insert a;

        Opportunity o = new Opportunity(
            AccountId = a.Id,
            Name = 'Test Opp',
            StageName = 'Qualification',
            CloseDate = Date.today(),
            OwnerId = UserInfo.getUserId()
        );

        insert o;

        Product2 p = new Product2(Name = 'Test Product');
        insert p;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = p.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 30.00,
            IsActive = true
        );

        insert pbe;
    }

    @isTest
    public static void POST_API_TEST_FAIL_VOID_RELATIONSHIPS() {
        API_Cotizacion_GLB.API_POST_COTIZACION_WRAPPER mockData = new API_Cotizacion_GLB.API_POST_COTIZACION_WRAPPER();
        mockData.Cotizacion = new Quote(
            GLBP1_ID_Externo_Cotizacion__c = 'TEST01'
        );
        mockData.participantes= new List<GLBP1_Participante_de_cotizacion__c>();
        mockData.partidas = new List<QuoteLineItem>();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestURI = '/services/apexrest/cotizacion';  //Request URL

        req.httpMethod = 'POST';//HTTP Request Type

        RestContext.request = req;

        RestContext.response = res;

        Test.startTest();

        API_Cotizacion_GLB.createCotizacion(mockData);

        Test.stopTest();
    }

    @isTest
    public static void POST_API_TEST_FAIL_VOID_ID() {
        API_Cotizacion_GLB.API_POST_COTIZACION_WRAPPER mockData = new API_Cotizacion_GLB.API_POST_COTIZACION_WRAPPER();
        mockData.Cotizacion = new Quote(
            GLBP1_ID_Externo_Cotizacion__c = ''
        );
        mockData.participantes= new List<GLBP1_Participante_de_cotizacion__c>();
        mockData.partidas = new List<QuoteLineItem>();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestURI = '/services/apexrest/cotizacion';  //Request URL

        req.httpMethod = 'POST';//HTTP Request Type

        RestContext.request = req;

        RestContext.response = res;

        Test.startTest();

        API_Cotizacion_GLB.createCotizacion(mockData);

        Test.stopTest();
    }

    @isTest
    public static void POST_API_TEST_SUCCESS() {
        Opportunity o = [
            SELECT Id FROM Opportunity LIMIT 1
        ];

        PricebookEntry pbe = [
            SELECT Id FROM PricebookEntry LIMIT 1
        ];

        API_Cotizacion_GLB.API_POST_COTIZACION_WRAPPER mockData = new API_Cotizacion_GLB.API_POST_COTIZACION_WRAPPER();
        mockData.Cotizacion = new Quote(
            GLBP1_ID_Externo_Cotizacion__c = 'TEST01',
            Name = 'Test Cotizacion',
            OpportunityId = o.Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );
        mockData.participantes = new List<GLBP1_Participante_de_cotizacion__c>();
        mockData.participantes.add(new GLBP1_Participante_de_cotizacion__c(
            GLBP1_Cotizacion__r = new Quote(GLBP1_ID_Externo_Cotizacion__c = 'TEST01'),
            GLBP1_Participante__r = new Account(GLBP1_Rut__c = '65155524-8')
        ));
        mockData.partidas = new List<QuoteLineItem>();
        mockData.partidas.add(new QuoteLineItem(
            Quote = new Quote(GLBP1_ID_Externo_Cotizacion__c = 'TEST01'),
            UnitPrice = 10.00,
            Quantity = 1,
            PricebookEntryId = pbe.Id
        ));

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestURI = '/services/apexrest/cotizacion';  //Request URL

        req.httpMethod = 'POST';//HTTP Request Type

        RestContext.request = req;

        RestContext.response = res;

        Test.startTest();

        API_Cotizacion_GLB.createCotizacion(mockData);

        Test.stopTest();
    }
}