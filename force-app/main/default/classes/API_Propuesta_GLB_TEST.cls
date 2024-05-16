@isTest
public with sharing class API_Propuesta_GLB_TEST {
    @TestSetup
    static void testSetup(){
        Account a = new Account(
            Name = 'TEST ACCOUNT',
            GLBP1_Rut__c = '65155524-8'
        );

        insert a;
    }

    @isTest
    public static void POST_API_TEST_FAIL_VOID_RELATIONSHIPS() {
        

        API_Propuesta_GLB.API_POST_PROPUESTA_WRAPPER mockData = new API_Propuesta_GLB.API_POST_PROPUESTA_WRAPPER();
        mockData.propuesta = new GLB_P1_Propuesta__c(
            GLB_P1_NumeroPropuesta__c = 'TEST01'
        );
        mockData.participantes= new List<GLB_P1_ParticipantePropuesta__c>();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestURI = '/services/apexrest/propuesta';  //Request URL

        req.httpMethod = 'POST';//HTTP Request Type

        RestContext.request = req;

        RestContext.response = res;

        Test.startTest();

        API_Propuesta_GLB.createPropuesta(mockData);

        Test.stopTest();
    }

    @isTest
    public static void POST_API_TEST_FAIL_VOID_ID() {
        

        API_Propuesta_GLB.API_POST_PROPUESTA_WRAPPER mockData = new API_Propuesta_GLB.API_POST_PROPUESTA_WRAPPER();
        mockData.propuesta = new GLB_P1_Propuesta__c(
            GLB_P1_NumeroPropuesta__c = ''
        );
        mockData.participantes = new List<GLB_P1_ParticipantePropuesta__c>();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestURI = '/services/apexrest/propuesta';  //Request URL

        req.httpMethod = 'POST';//HTTP Request Type

        RestContext.request = req;

        RestContext.response = res;

        Test.startTest();

        API_Propuesta_GLB.createPropuesta(mockData);

        Test.stopTest();
    }

    @isTest
    public static void POST_API_TEST_SUCCESS() {
        

        API_Propuesta_GLB.API_POST_PROPUESTA_WRAPPER mockData = new API_Propuesta_GLB.API_POST_PROPUESTA_WRAPPER();
        mockData.propuesta = new GLB_P1_Propuesta__c(
            GLB_P1_NumeroPropuesta__c = 'TEST01'
        );
        mockData.participantes = new List<GLB_P1_ParticipantePropuesta__c>();
        mockData.participantes.add(new GLB_P1_ParticipantePropuesta__c(
            GLB_P1_Propuesta__r = new GLB_P1_Propuesta__c(GLB_P1_NumeroPropuesta__c = 'TEST01')
        ));


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestURI = '/services/apexrest/propuesta';  //Request URL

        req.httpMethod = 'POST';//HTTP Request Type

        RestContext.request = req;

        RestContext.response = res;

        Test.startTest();

        API_Propuesta_GLB.createPropuesta(mockData);

        Test.stopTest();
    }
}