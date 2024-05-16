@isTest
public with sharing class WS_UploadAttachment_TEST {
    @testSetup
    private static void testSetup() {
        Account a = new Account(
            Name = 'TEST ACCOUNT',
            ZRH_Rut__c = '65155524-8'
        );

        insert a;

        Case aCase = new Case(
            Subject = 'Test Subject',
            AccountId = a.Id,
            Description = 'Test Description'
        );

        insert aCase;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.csv',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                        FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = aCase.Id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
    }

    @isTest
    public static void createCase_TEST() {
        Case c = [
            SELECT Id FROM Case LIMIT 1
        ];

        List<Id> lId = new List<Id>();
        lId.add(c.Id);

        Test.setMock(HttpCalloutMock.class, new WS_UploadAttachment_Mock());

        Test.startTest();
        List<String> res = WS_UploadAttachment_GLB.serviceCallout(lId);
        Test.stopTest();

        System.assertEquals('DONE', res[0]);
    }
}