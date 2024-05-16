@isTest
public class ZRH_InsurancePolicySelector_TEST {

    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';

    @isTest
    public static void selectByPrimaryMembersAndPolicyNumbersTest() {
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

        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary1.ZRH_ClaveSincronizacion__c = '123456789';
        primary1.ZRH_TipoMovimiento__c = 'Inclusión';
        primary1.PolicyStartDate = Date.today();
        insert primary1;
        
        Account personAcc1 = ZRH_DataFactory.createPersonAccountWithRUT(true, primary1.ZRH_Rut__c);
        InsurancePolicy insurancePolicy = ZRH_DataFactory.createInsurancePolicy(true, personAcc1.Id, cgpOne.Id);
        InsurancePolicyParticipant ipp = ZRH_DataFactory.createPrimaryInsurancePolicyParticipant(true, insurancePolicy.Id, personAcc1.Id);
        InsurancePolicyCoverage ipc = ZRH_DataFactory.createInsurancePolicyCoverage(true, insurancePolicy.Id, testLifeProduct.Id);

        Set<String> mockPrimaryRuts = new Set<String>{personAcc1.ZRH_Rut__c};
        List<ContractGroupPlan> cgp = [SELECT ZRH_NumeroDePoliza__c FROM ContractGroupPlan WHERE Id = :cgpOne.Id];
        System.debug(cgp);
        Set<String> mockPolicyNumbers = new Set<String>{cgp[0].ZRH_NumeroDePoliza__c};

        Test.startTest();
        List<InsurancePolicy> results = new ZRH_InsurancePolicySelector().selectByPrimaryMembersAndPolicyNumbers(mockPrimaryRuts, mockPolicyNumbers);
        System.assertEquals(1, results.size(), 'selectByPrimaryMembersAndPolicyNumbers method failed to return expected results');
        Test.stopTest();
    }

    @isTest
    public static void selectByPrimaryMembersTest() {
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

        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary1.ZRH_ClaveSincronizacion__c = '123456789';
        primary1.ZRH_Rut__c = '123';
        primary1.ZRH_TipoMovimiento__c = 'Inclusión';
        primary1.PolicyStartDate = Date.today();
        insert primary1;

        Account personAcc1 = ZRH_DataFactory.createPersonAccountWithRUT(true, primary1.ZRH_Rut__c);
        InsurancePolicy insurancePolicy = ZRH_DataFactory.createInsurancePolicy(true, personAcc1.Id, cgpOne.Id);
        InsurancePolicyParticipant ipp = ZRH_DataFactory.createPrimaryInsurancePolicyParticipant(true, insurancePolicy.Id, personAcc1.Id);
        InsurancePolicyCoverage ipc = ZRH_DataFactory.createInsurancePolicyCoverage(true, insurancePolicy.Id, testLifeProduct.Id);

        Set<String> primaryRuts = new Set<String>{personAcc1.ZRH_Rut__c};
        Set<Id> quoteIds = new Set<Id>{testQuoteOne.Id};

        Test.startTest();
        List<InsurancePolicy> results = new ZRH_InsurancePolicySelector().selectByPrimaryMembers(primaryRuts, quoteIds);
        System.assertEquals(true, results.size() != null, 'selectByPrimaryMembers method failed to return expected results');
        Test.stopTest();
    }

    @isTest
    public static void selectByPrimaryMemberRutPolicyNumberAndQuoteIdsTest() {
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

        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary1.ZRH_ClaveSincronizacion__c = '123456789';
        primary1.ZRH_Rut__c = '123';
        primary1.ZRH_TipoMovimiento__c = 'Inclusión';
        primary1.PolicyStartDate = Date.today();
        insert primary1;

        Account personAcc1 = ZRH_DataFactory.createPersonAccountWithRUT(true, primary1.ZRH_Rut__c);
        InsurancePolicy insurancePolicy = ZRH_DataFactory.createInsurancePolicy(true, personAcc1.Id, cgpOne.Id);
        InsurancePolicyParticipant ipp = ZRH_DataFactory.createPrimaryInsurancePolicyParticipant(true, insurancePolicy.Id, personAcc1.Id);
        InsurancePolicyCoverage ipc = ZRH_DataFactory.createInsurancePolicyCoverage(true, insurancePolicy.Id, testLifeProduct.Id);

        Set<String> primaryRuts = new Set<String>{personAcc1.ZRH_Rut__c};
        List<ContractGroupPlan> cgp = [SELECT ZRH_NumeroDePolizaSinDV__c FROM ContractGroupPlan WHERE Id = :cgpOne.Id];
        Set<String> policyNumbers = new Set<String>{cgp[0].ZRH_NumeroDePolizaSinDV__c};
        Set<Id> quoteIds = new Set<Id>{testQuoteOne.Id};

        Test.startTest();
        List<InsurancePolicy> results = new ZRH_InsurancePolicySelector().selectByPrimaryMemberRutPolicyNumberAndQuoteIds(primaryRuts, policyNumbers, quoteIds);
        System.assertEquals(true, results.size() != null, 'selectByPrimaryMembers method failed to return expected results');
        Test.stopTest();
    }
}