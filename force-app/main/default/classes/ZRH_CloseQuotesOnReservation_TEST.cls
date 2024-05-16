/*********************************************************************************
 Project      : Zurich Salesforce - Seguros colectivos
 Created By   : Deloitte
 Created Date : 15/11/2023
 Description  : Test Class for Remote Action that closes quotes on reservation
 History      :
 --------------------------ACRONYM OF AUTHORS-------------------------------------
 AUTHOR                      ACRONYM
 Mateo Long                    ML
 ---------------------------------------------------------------------------------
 VERSION  AUTHOR         DATE            Description
 1.0      ML            15/11/2023            Created Class
 ********************************************************************************/
@isTest
private class ZRH_CloseQuotesOnReservation_TEST {
    /*
        @Description: execute and validate closing of quotes
        @Author: ML, Deloitte, mlongg@deloitte.com
        @Date: 15/11/2023
    */
    @isTest static void testCloseQuotes() {
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteTwo = ZRH_DataFactory.createQuote(true, testOpportunity);
        List<Quote> testQuotes = new List<Quote>();
        testQuotes.add(testQuoteOne);
        testQuotes.add(testQuoteTwo);

        // Prepare input for closeQuotes method
        List<Object> quotesToClose = new List<Object>();
        for (Quote q : testQuotes) {
            Map<String, Object> quoteMap = new Map<String, Object>{
                'Id' => q.Id,
                'EstadoCotizacion' => 'E-10',
                'SubEstado' => 'SE-05'
            };
            quotesToClose.add(quoteMap);
        }

        Map<String, Object> inputMap = new Map<String, Object>{
            'listQuotesToClose' => quotesToClose
        };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Call method
        Test.startTest();
        ZRH_CloseQuotesOnReservation helper = new ZRH_CloseQuotesOnReservation();
        Map<String, Object> args = new Map<String, Object>();
        args.put('input', inputMap);
        args.put('output', outputMap);
        args.put('options', options);
        helper.call('closeQuotes', args);
        Test.stopTest();

        // Asserts
        List<Quote> updatedQuotes = [SELECT Id, Status, ZRH_SubEstado__c FROM Quote WHERE Id IN :testQuotes];
        for (Quote q : updatedQuotes) {
            System.assertEquals('E-10', q.Status);
            System.assertEquals('SE-05', q.ZRH_SubEstado__c);
        }
    }
    /*
        @Description: execute and validate error
        @Author: ML, Deloitte, mlongg@deloitte.com
        @Date: 15/11/2023
    */
    @isTest static void testCloseQuotesWrongMethodName() {
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteTwo = ZRH_DataFactory.createQuote(true, testOpportunity);
        List<Quote> testQuotes = new List<Quote>();
        testQuotes.add(testQuoteOne);
        testQuotes.add(testQuoteTwo);

        // Prepare input for closeQuotes method
        List<Object> quotesToClose = new List<Object>();
        for (Quote q : testQuotes) {
            Map<String, Object> quoteMap = new Map<String, Object>{
                'Id' => q.Id,
                'EstadoCotizacion' => 'E-10',
                'SubEstado' => 'SE-05'
            };
            quotesToClose.add(quoteMap);
        }

        Map<String, Object> inputMap = new Map<String, Object>{
            'listQuotesToClose' => quotesToClose
        };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Call method
        Test.startTest();
        ZRH_CloseQuotesOnReservation helper = new ZRH_CloseQuotesOnReservation();
        Map<String, Object> args = new Map<String, Object>();
        args.put('input', inputMap);
        args.put('output', outputMap);
        args.put('options', options);
        helper.call('closeQuotesWrong', args);
        Test.stopTest();

        // Asserts
        List<Quote> updatedQuotes = [SELECT Id, Status, ZRH_SubEstado__c FROM Quote WHERE Id IN :testQuotes AND Status = 'E-10' AND ZRH_SubEstado__c = 'SE-05'];
        System.assertEquals(true, updatedQuotes.size() == 0);
    }
}