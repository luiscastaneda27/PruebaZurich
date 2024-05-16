/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 5/10/2023
Description  : Class test for class ZRH_QuotesSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          5/10/2023        initial version
2.0      JAA          12/10/2023
********************************************************************************/
@isTest
public class ZRH_QuotesSelector_TEST {

    private static final String OBJECT_QUOTE = 'Quote';
    
    /**
    *  @Description: Test the for the Method selectById
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        7/02/2022
    */
    @isTest 
    static void selectById() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
        
        Test.startTest();
        Quote result = new ZRH_QuotesSelector().selectById(childQuote1.Id, ZRH_ControllerGloss.getFieldsObj(OBJECT_QUOTE));
        System.assertEquals(result.Id == childQuote1.Id, true, 'It´s Worked!');
        Test.stopTest();
    }

    /**
    *  @Description: Test for the Method selectByQuoteHolding
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest 
    static void selectByQuoteHolding() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Quote parentQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote = ZRH_DataFactory.createChildQuote(true, testOpportunity, parentQuote);
        
        Test.startTest();
        List<Quote> result = new ZRH_QuotesSelector().selectByQuoteHolding(parentQuote.Id);
        System.assertEquals(result.size() > 0, true, 'Working!');
        Test.stopTest();
    }
}