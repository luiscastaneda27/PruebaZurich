/**
 * @description       : 
 * @author            : Santiago Muñoz
 * @group             : 
 * @last modified on  : 04-20-2024
 * @last modified by  : Santiago Muñoz
**/
@isTest
public without sharing class WS_CreateCase_TEST {
    @testSetup
    private static void testSetup() {
        Account a = new Account(
            Name = 'TEST ACCOUNT',
            ZRH_Rut__c = '65155524-8'
        
        );
        insert a;
        
        insert new Contact(
            FirstName = 'FirstName',
            LastName = 'LastName',
            Email = 'test@test.test',
            Accountid = a.Id
        );
        

        Case aCase = new Case(
            Subject = 'Test Subject',
            AccountId = a.Id,
            SuppliedEmail = 'test@test.test',
            Description = 'Test Description'
        );

        insert aCase;
    }

    @isTest
    public static void createCase_TEST() {
        Case c = [
            SELECT Id FROM Case LIMIT 1
        ];

        List<Id> lId = new List<Id>();
        lId.add(c.Id);

        Test.setMock(HttpCalloutMock.class, new WS_CreateCase_Mock());

        Test.startTest();
        List<String> res = WS_CreateCase_GLB.serviceCallout(lId);
        Test.stopTest();

        System.assertEquals('Exito', res[0]);
    }
}