/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 25/10/2023
Description  : Class test for class ZRH_ContentDocumentLinkTrigger
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          25/10/2023        Initial Version
********************************************************************************/
@IsTest
public class ZRH_ContentDocumentLinkTrigger_TEST {

    @isTest
    static void updateFlagPDF() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        ContentVersion testContentVersion = ZRH_DataFactory.createContentVersion(true);
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:testContentVersion.Id].ContentDocumentId;
        Quote testParentQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testChildQuoteOne = ZRH_DataFactory.createChildQuote(true, testOpportunity, testParentQuote);
        QuoteLineItem testQuoteLineItemHealthOne = ZRH_DataFactory.createQuoteLineItem(true, testChildQuoteOne, testHealthProduct, testPricebookEntryHealth, 'TEST');
        
        Test.startTest();
        ContentDocumentLink testContentDocumentLink = ZRH_DataFactory.createContentDocumentLink(true, testParentQuote.Id, contentDocumentId);
        System.assertEquals(testParentQuote.ZRH_PDFCreado__c = true , true, 'Working!');
        Test.stopTest();
    }
}