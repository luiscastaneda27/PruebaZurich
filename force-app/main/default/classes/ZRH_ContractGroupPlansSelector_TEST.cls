/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/11/2023
Description  : Class test for class ZRH_ContractGroupPlansSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          27/11/2023        initial version
********************************************************************************/
@isTest
public class ZRH_ContractGroupPlansSelector_TEST {

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    private static final String QUERY_CONDITION = 'Id != null';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    
    /**
    *  @Description: Test the for the selectByDynamicCondition
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */
    @isTest 
    static void selectByDynamicConditionTest() {
        Test.startTest();
        Database.QueryLocator query = new ZRH_ContractGroupPlansSelector().selectByDynamicCondition(QUERY_CONDITION);
        new ZRH_ContractGroupPlansSelector().selectByRelatedQuotes(new Set<Id>());
        new ZRH_ContractGroupPlansSelector().selectParentPlansByContractIds(new Set<Id>());
        new ZRH_ContractGroupPlansSelector().selectPlansAndCoveragesByPolicyNumbers(new Set<String>());
        new ZRH_ContractGroupPlansSelector().selectByIdAndCoverages(UserInfo.getuserId(),new List<String>{'Name'});
        new ZRH_ContractGroupPlansSelector().selectByFolio(QUERY_CONDITION,new List<String>{'Name'});
        System.assertEquals(query != null, true, 'It´s Worked!');
        Test.stopTest();
    }

    /**
    *  @Description: Test the for the selectByRelatedQuotes
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        28/12/2023
    */
    @isTest
    static void selectByRelatedQuotesTest() {

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);

        Set<Id> mockQuoteIds = new Set<Id>{holdingQuote.Id};
        
        Test.startTest();
        List<ContractGroupPlan> results = new ZRH_ContractGroupPlansSelector().selectByRelatedQuotes(mockQuoteIds);
        System.assertEquals(0, results.size(), 'selectByRelatedQuotes method failed to return expected results');
        Test.stopTest();
    }

    /**
    *  @Description: Test the for the selectParentPlansByContractIds
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        28/12/2023
    */
    @isTest
    static void selectParentPlansByContractIdsTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);

        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuoteOne.vlocity_ins_fsc__GroupCensusStdId__c = groupCensus.Id;
        testQuoteOne.ZRH_CotizacionHolding__c = holdingQuote.Id;
        insert testQuoteOne;
        
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        testQuoteLineItemOne.ZRH_Folio__c = Math.random() + '1';
        insert testQuoteLineItemOne;
        QuoteLineItem testQuoteLineItemOneCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        testQuoteLineItemOneCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemOne.Id;
        insert testQuoteLineItemOneCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;

        Set<Id> mockContractIds = new Set<Id>{testContract.Id};
        
        Test.startTest();
        List<ContractGroupPlan> results = new ZRH_ContractGroupPlansSelector().selectParentPlansByContractIds(mockContractIds);
        System.assertEquals(1, results.size(), 'selectParentPlansByContractIds method failed to return expected parent plans');
        Test.stopTest();
    }

    /**
    *  @Description: Test the for the selectPlansAndCoveragesByPolicyNumbers
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        28/12/2023
    */
    @isTest
    static void selectPlansAndCoveragesByPolicyNumbersTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);

        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuoteOne.vlocity_ins_fsc__GroupCensusStdId__c = groupCensus.Id;
        testQuoteOne.ZRH_CotizacionHolding__c = holdingQuote.Id;
        insert testQuoteOne;
        
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        testQuoteLineItemOne.ZRH_Folio__c = Math.random() + '1';
        insert testQuoteLineItemOne;
        QuoteLineItem testQuoteLineItemOneCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        testQuoteLineItemOneCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemOne.Id;
        insert testQuoteLineItemOneCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;

        Set<String> mockPolicyNumbers = new Set<String>{cgpOne.ZRH_NumeroDePoliza__c};
        
        Test.startTest();
        List<ContractGroupPlan> results = new ZRH_ContractGroupPlansSelector().selectPlansAndCoveragesByPolicyNumbers(mockPolicyNumbers);
        System.assertEquals(2, results.size(), 'selectPlansAndCoveragesByPolicyNumbers method failed to return expected results');
        Test.stopTest();
    }

    /**
    *  @Description: Test the for the selectContractGroupPlanById
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        08/03/2024
    */
    @isTest
    static void selectContractGroupPlanByIdTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);

        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuoteOne.vlocity_ins_fsc__GroupCensusStdId__c = groupCensus.Id;
        testQuoteOne.ZRH_CotizacionHolding__c = holdingQuote.Id;
        insert testQuoteOne;
        
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        testQuoteLineItemOne.ZRH_Folio__c = Math.random() + '1';
        insert testQuoteLineItemOne;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        
        Test.startTest();
        List<ContractGroupPlan> results = new ZRH_ContractGroupPlansSelector().selectContractGroupPlanById(cgpOne.Id);
        System.assertEquals(1, results.size(), 'selectContractGroupPlanById method failed to return expected results');
        Test.stopTest();
    }

    /**
    *  @Description: Test the for the selectByEndorsementSentTrue
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        08/03/2024
    */
    @isTest
    static void selectPlansBySourceQuoteIdAndRecTypeDeveloperNameTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);

        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuoteOne.vlocity_ins_fsc__GroupCensusStdId__c = groupCensus.Id;
        testQuoteOne.ZRH_CotizacionHolding__c = holdingQuote.Id;
        insert testQuoteOne;
        
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        testQuoteLineItemOne.ZRH_Folio__c = Math.random() + '1';
        insert testQuoteLineItemOne;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        
        List<Id> quoteIds = new List<Id>();
        quoteIds.add(testQuoteOne.Id);

        Test.startTest();
        List<ContractGroupPlan> results = new ZRH_ContractGroupPlansSelector().selectPlansBySourceQuoteIdAndRecTypeDeveloperName(quoteIds, 'Product');
        System.assertEquals(1, results.size(), 'selectPlansBySourceQuoteIdAndRecTypeDeveloperName method failed to return expected results');
        Test.stopTest();
    }
}