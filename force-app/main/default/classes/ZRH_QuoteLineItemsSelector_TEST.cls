/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 12/10/2023
Description  : Class test for class ZRH_QuoteLineItemsSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          12/10/2023        Initial Version
********************************************************************************/
@isTest
private class ZRH_QuoteLineItemsSelector_TEST {

    private static final String OBJECT_QUOTE = 'QuoteLineItem';
    private static final String ASV_QLI = 'Test';

    /**
    *  @Description: Test the Method selectProductsBySetIds
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest
    static void selectProductsBySetIds() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote testQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, testQuote, testProduct, testPricebookEntry, ASV_QLI);

        Set<Id> setIds = new Set<Id>();
        setIds.add(testQuote.Id);
        
        Test.startTest();
        Map<Id,QuoteLineItem> mapQli = new ZRH_QuoteLineItemsSelector().selectProductsBySetIds(setIds);
        System.assertEquals(mapQli.size() > 0, true, 'Working!');
        Test.stopTest();
    }

    /**
    *  @Description: Test the Method selectCoverageBySetIds
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest
    static void selectCoverageBySetIds() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote testQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, testQuote, testProduct, testPricebookEntry, ASV_QLI);

        Set<Id> setIds = new Set<Id>();
        setIds.add(testQuote.Id);
        
        Test.startTest();
        List<QuoteLineItem> lstQli = new ZRH_QuoteLineItemsSelector().selectCoverageBySetIds(setIds);
        System.assertEquals(lstQli.size() > 0, true, 'Working!');
        Test.stopTest();
    }
    
    /**
    *  @Description: Test for the Method selectByQuoteId
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest
    static void selectByQuoteId() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote testQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, testQuote, testProduct, testPricebookEntry, ASV_QLI);

        Set<Id> setIds = new Set<Id>();
        setIds.add(testQuote.Id);

        Test.startTest();
        List<QuoteLineItem> listQlis = new ZRH_QuoteLineItemsSelector().selectByQuoteId(setIds);
        System.assertEquals(listQlis.size() > 0, true, 'Working!');
        Test.stopTest();
    }
 
    /**
    *  @Description: Test for the Method selectChildAccountRootQLIsByParentQuoteId
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest
    static void selectChildAccountRootQLIsByParentQuoteId() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote testQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, testQuote, testProduct, testPricebookEntry, ASV_QLI);

        Test.startTest();
        Database.QueryLocator query = new ZRH_QuoteLineItemsSelector().selectChildAccountRootQLIsByParentQuoteId(testQuote.Id);
        System.assertEquals(query != null, true, 'Working!');
        Test.stopTest();

    }

    /**
    *  @Description: Test for the Method selectById
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        22/11/2023
    */
    @isTest
    static void selectChildRootQLIsByParentQuoteId() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        
        Quote testQuoteHolding = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuote = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuote.ZRH_CotizacionHolding__c = testQuoteHolding.Id;
        insert testQuote;
        
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(false, testQuote, testProduct, testPricebookEntry, ASV_QLI);
        testQuoteLineItem.ZRH_TipoTarifa__c = '1';
        insert testQuoteLineItem;

        Test.startTest();
        List<QuoteLineItem> lstQli = new ZRH_QuoteLineItemsSelector().selectChildRootQLIsByParentQuoteId(testQuoteHolding.Id);
        System.assertEquals(true, lstQli.size() > 0, 'Working!');   
        Test.stopTest();
    }

    /**
    *  @Description: Test for the Method selectById
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest
    static void selectById() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote testQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, testQuote, testProduct, testPricebookEntry, ASV_QLI);

        Test.startTest();
        List<QuoteLineItem> lstQli = new ZRH_QuoteLineItemsSelector().selectById(testQuote.Id);
        System.assertEquals(lstQli.size() > 0, true, 'Working!');
        Test.stopTest();
    }

    /**
    *  @Description: Test for the Method selectByIdAndCoverages
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest
    static void selectByIdAndCoverages() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testHealthCoverage = ZRH_DataFactory.createProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryHealthCoverage = ZRH_DataFactory.createPricebookEntry(true, testHealthCoverage);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItemHealthOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testHealthProduct, testPricebookEntryHealth, ASV_QLI);
        QuoteLineItem testQuoteLineItemHealthCoverage = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testHealthCoverage, testPricebookEntryHealthCoverage, ASV_QLI);
        ZRH_Glosas__c testGlosaHealthOne = ZRH_DataFactory.createCoverageGloss(true, testQuoteLineItemHealthOne.Id);

        testQuoteLineItemHealthCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemHealthOne.Id;

        update testQuoteLineItemHealthCoverage;

        Test.startTest();
        List<QuoteLineItem> lstQli = new ZRH_QuoteLineItemsSelector().selectByIdAndCoverages(testQuoteLineItemHealthOne.Id, ZRH_ControllerGloss.getFieldsObj(OBJECT_QUOTE));
        System.assertEquals(lstQli.size() > 0, true, 'Working!');
        Test.stopTest();
    }

    /**
    *  @Description: Test for the Method selectByIdsList
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest
    static void selectByIdsList() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote testQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, testQuote, testProduct, testPricebookEntry, ASV_QLI);

        List<String> lstIds = new List<String>();
        lstIds.add(testQuoteLineItem.Id);

        Test.startTest();
        List<QuoteLineItem> lstQli = new ZRH_QuoteLineItemsSelector().selectByIdsList(lstIds);
        System.assertEquals(lstQli.size() > 0, true, 'Working!');
        Test.stopTest();
    }

}