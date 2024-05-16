@isTest
public with sharing class ZRH_BotonCotizador_Controller_TEST {
    @testSetup
    private static void testSetup() {
        Account a = new Account(
            Name = 'TEST ACCOUNT',
            GLBP1_Rut__c = '65155524-8'
        );

        insert a;
        
        Opportunity o = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Qualification',
            CloseDate = Date.today()
        );

        insert o;
    }

    @isTest
    public static void retrieveToken_TEST() {
        Opportunity o = [
            SELECT Id FROM Opportunity LIMIT 1
        ];

        Test.setMock(HttpCalloutMock.class, new ZRH_BotonCotizador_MOCK());

        Test.startTest();
        String res = ZRH_BotonCotizador_Controller.retrieveToken(o.Id);
        Test.stopTest();

        System.assertEquals('testToken', res);
    }
}