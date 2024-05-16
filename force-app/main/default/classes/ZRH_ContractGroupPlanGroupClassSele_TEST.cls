/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/11/2023
Description  : Class test for class ContractGroupPlanGroupClassSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          27/11/2023        initial version
********************************************************************************/
@isTest
public class ZRH_ContractGroupPlanGroupClassSele_TEST {

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023  
    */
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_SALUD_PG_NAME = 'ZRH_JSON_SaludPG'; 
    private static final String SR_ASV_COBERTURA_NAME = 'ZRH_JSON_CoberturaASV';
        
    /**
    *  @Description: Test the for the selectByQuoteLineItem
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */
    @isTest 
    static void selectByContractGroupPlanTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testHealthCoverage = ZRH_DataFactory.createProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryHealthCoverage = ZRH_DataFactory.createPricebookEntry(true, testHealthCoverage);
        Quote parentQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote = ZRH_DataFactory.createChildQuote(true, testOpportunity, parentQuote);
        QuoteLineItem testQuoteLineItemHealthOne = ZRH_DataFactory.createQuoteLineItem(true, childQuote, testHealthProduct, testPricebookEntryHealth, saludASV.Body.toString());
                                             
        Test.startTest();
        List<ContractGroupPlanGroupClass> listRecord = new ZRH_ContractGroupPlanGroupClassSelector().selectByContractGroupPlan(testQuoteLineItemHealthOne.Id);
        System.assertEquals(listRecord != null, true, 'selectByQuoteLineItemTest failed');
        Test.stopTest();
    }

    /**
    *  @Description: Test the for the selectByContractGroupPlanIds
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        27/11/2023
    */
    @isTest 
    static void selectByContractGroupPlanIdsTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuoteOne.vlocity_ins_fsc__GroupCensusStdId__c = groupCensus.Id;
        testQuoteOne.ZRH_CotizacionHolding__c = holdingQuote.Id;
        insert testQuoteOne;

        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        testQuoteLineItemOne.ZRH_Folio__c = '12345-1';
        testQuoteLineItemOne.ZRH_Periodo__c = 1;
        insert testQuoteLineItemOne;
        QuoteLineItem testQuoteLineItemOneCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        testQuoteLineItemOneCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemOne.Id;
        insert testQuoteLineItemOneCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;

        Set<Id> cgpIds = new Set<Id>();
        cgpIds.add(cgpOne.Id);
                                             
        Test.startTest();
        List<ContractGroupPlanGroupClass> listRecord = new ZRH_ContractGroupPlanGroupClassSelector().selectByContractGroupPlanIds(cgpIds);
        System.assertEquals(listRecord != null, true);
        Test.stopTest();
    }
}