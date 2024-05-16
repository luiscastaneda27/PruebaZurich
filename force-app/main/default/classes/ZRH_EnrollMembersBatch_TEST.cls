/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 21/12/2023
Description  : Test Batch class to enroll members to policies
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Mateo Long.                         ML
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ML			21/12/2023		initial version
********************************************************************************/
@isTest
public class ZRH_EnrollMembersBatch_TEST {

    /**
    *  @Description: Static variables
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        19/12/2023  
    */
    private static final String SR_ASV_VIDA_NAME = 'ZRH_JSON_VidaASV';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_ASV_COBERTURA_NAME = 'ZRH_JSON_CoberturaASV';
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';
    private static final String SR_TARIFA_VIDA_NAME = 'ZRH_JSON_VidaTarifa';
    private static final String SR_REQ_MED_NAME = 'ZRH_JSON_RequisitosMedicos';
    private static final String SR_VIDA_REQ_ASEG_NAME = 'ZRH_JSON_VidaRA';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_EnvioPropuestaPoliza';
    private static final String SR_BODY_RESPONSE = 'ZRH_JSON_InputPDF';
    private static final String SR_FOLIO_NUMBER_ONE = '1245-1';
    private static final String SR_FOLIO_NUMBER_TWO = '1245-2';
    private static final String SR_FOLIO_NUMBER_THREE = '1245-3';
    private static final String PERSON_ACCOUNT_DEVELOPER_NAME = 'PersonAccount';

    private static Quote holdingQuote;

    @testSetup
    private static void setupTestData() {
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        StaticResource saludTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        StaticResource vidaTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_VIDA_NAME);
        StaticResource vidaRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_VIDA_REQ_ASEG_NAME);
        StaticResource vidaRM = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        Product2 testPersonalAccidentsProduct = ZRH_DataFactory.createPersonalAccidentsProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        PricebookEntry testPricebookEntryPersonalAccidents = ZRH_DataFactory.createPricebookEntry(true, testPersonalAccidentsProduct);
        
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(false, testOpportunity);
        testQuoteOne.vlocity_ins_fsc__GroupCensusStdId__c = groupCensus.Id;
        testQuoteOne.ZRH_CotizacionHolding__c = holdingQuote.Id;
        insert testQuoteOne;
        
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        
        QuoteLineItem testQuoteLineItemOneCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        testQuoteLineItemOneCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemOne.Id;
        insert testQuoteLineItemOneCoverage;

        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testPersonalAccidentsProduct, testPricebookEntryPersonalAccidents,  vidaASV.Body.toString());
        QuoteLineItem testQuoteLineItemThree = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        QuoteLineItem testQuoteLineItemFour = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testPersonalAccidentsProduct, testPricebookEntryPersonalAccidents,  vidaASV.Body.toString());

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);

        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpThree = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemThree);
        ContractGroupPlan cgpFour = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemFour);
    }

    // -------- ---------- ---------
    // -------- ENROLLMENTS --------
    // -------- ---------- ---------
    @isTest
    private static void enrollOnlyPrimaryMembers() {
        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwo.ZRH_Folio__c = '12346-1';
        testQuoteLineItemTwo.ZRH_Periodo__c = 1;
        insert testQuoteLineItemTwo;
        QuoteLineItem testQuoteLineItemTwoCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwoCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemTwo.Id;
        insert testQuoteLineItemTwoCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpTwoCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemTwoCoverage);
        cgpTwoCoverage.ContractGroupParentPlanId = cgpTwo.Id;
        insert cgpTwoCoverage;
        
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        primary1.PhoneNumber = '12345678';
        insert primary1;
        
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary2.ZRH_Rut__c = '1234';
        primary2.ZRH_Poliza__c = '12346-1';
        primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12346-1' + '1234';
        insert primary2;

        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy];
        //System.assertEquals(2, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant];
        //System.assertEquals(2, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<InsurancePolicyCoverage> insPolCov = [SELECT Id FROM InsurancePolicyCoverage];
        //System.assertEquals(2, insPolCov.size(), 'InsurancePolicyCoverage not matching');
        List<Account> personAccs = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :PERSON_ACCOUNT_DEVELOPER_NAME];
        //System.assertEquals(1, personAccs.size(), 'Account not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_InclusionRealizada__c = true];
        //System.assertEquals(2, gcms.size(), 'GroupCensusMember not matching');
    }
    
    @isTest
    private static void enrollPrimaryMembersWithDependants() {
        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwo.ZRH_Folio__c = '12346-1';
        testQuoteLineItemTwo.ZRH_Periodo__c = 1;
        insert testQuoteLineItemTwo;
        QuoteLineItem testQuoteLineItemTwoCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwoCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemTwo.Id;
        insert testQuoteLineItemTwoCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpTwoCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemTwoCoverage);
        cgpTwoCoverage.ContractGroupParentPlanId = cgpTwo.Id;
        insert cgpTwoCoverage;
        
        // primary with policy 12345-1
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        insert primary1;
        
        // primary with policy 12346-1
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary2.ZRH_Rut__c = '1234';
        primary2.ZRH_Poliza__c = '12346-1';
        primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12346-1' + '1234';
        insert primary2;
        
        // dependant tied to primary with policy 12345-1
        GroupCensusMember dep1Primary1 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary1, 'Inclusión');
        dep1Primary1.ZRH_Rut__c = '12345';
        dep1Primary1.ZRH_Poliza__c = '12345-1';
        dep1Primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '12345';
        insert dep1Primary1;

        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy];
        //System.assertEquals(2, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant];
        //System.assertEquals(3, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<InsurancePolicyCoverage> insPolCov = [SELECT Id FROM InsurancePolicyCoverage];
        //System.assertEquals(2, insPolCov.size(), 'InsurancePolicyCoverage not matching');
        List<Account> personAccs = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :PERSON_ACCOUNT_DEVELOPER_NAME];
        //System.assertEquals(2, personAccs.size(), 'Account not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_InclusionRealizada__c = true];
        //System.assertEquals(3, gcms.size(), 'GroupCensusMember not matching');
    }

    @isTest
    private static void enrollPrimaryMembersWithSameDependants() {

        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwo.ZRH_Folio__c = '12346-1';
        testQuoteLineItemTwo.ZRH_Periodo__c = 1;
        insert testQuoteLineItemTwo;
        QuoteLineItem testQuoteLineItemTwoCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwoCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemTwo.Id;
        insert testQuoteLineItemTwoCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpTwoCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemTwoCoverage);
        cgpTwoCoverage.ContractGroupParentPlanId = cgpTwo.Id;
        insert cgpTwoCoverage;
        
        // primary 1 with policy 12345-1
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        insert primary1;
        
        // primary 2 with policy 12345-1
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary2.ZRH_Rut__c = '12345';
        primary2.ZRH_Poliza__c = '12345-1';
        primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '12345';
        insert primary2;
        
        // dependant tied to primary 1
        GroupCensusMember dep1Primary1 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary1, 'Inclusión');
        dep1Primary1.ZRH_Rut__c = '123456';
        dep1Primary1.ZRH_Poliza__c = '12345-1';
        dep1Primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '12345' + '123456';
        insert dep1Primary1;

        // dependant tied to primary 2
        GroupCensusMember dep1Primary2 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary2, 'Inclusión');
        dep1Primary2.ZRH_Rut__c = '123456';
        dep1Primary2.ZRH_Poliza__c = '12345-1';
        dep1Primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234' + '123456';
        insert dep1Primary2;

        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy];
        //System.assertEquals(2, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant];
        //System.assertEquals(4, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<InsurancePolicyCoverage> insPolCov = [SELECT Id FROM InsurancePolicyCoverage];
        //System.assertEquals(2, insPolCov.size(), 'InsurancePolicyCoverage not matching');
        List<Account> personAccs = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :PERSON_ACCOUNT_DEVELOPER_NAME];
        //System.assertEquals(3, personAccs.size(), 'Account not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_InclusionRealizada__c = true];
        //System.assertEquals(4, gcms.size(), 'GroupCensusMember not matching');
    }
    @isTest
    private static void enrollMemberAsPrimaryAndDependant() {

        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwo.ZRH_Folio__c = '12346-1';
        testQuoteLineItemTwo.ZRH_Periodo__c = 1;
        insert testQuoteLineItemTwo;
        QuoteLineItem testQuoteLineItemTwoCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwoCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemTwo.Id;
        insert testQuoteLineItemTwoCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpTwoCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemTwoCoverage);
        cgpTwoCoverage.ContractGroupParentPlanId = cgpTwo.Id;
        insert cgpTwoCoverage;
        
        // primary 1 with policy 12345-1
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        insert primary1;

        // primary 1 with policy 12345-1
        GroupCensusMember primary12 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary12.ZRH_Rut__c = '1234';
        primary12.ZRH_Poliza__c = '12346-1';
        primary12.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12346-1' + '1234';
        insert primary12;
        
        // primary 2 with policy 12345-1
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary2.ZRH_Rut__c = '12345';
        primary2.ZRH_Poliza__c = '12345-1';
        primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '12345';
        insert primary2;
        
        // dependant 2 tied to primary 1
        GroupCensusMember dep2Primary1 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary1, 'Inclusión');
        dep2Primary1.ZRH_Rut__c = '12345';
        dep2Primary1.ZRH_Poliza__c = '12346-1';
        dep2Primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12346-1' + '1234' + '12345';
        insert dep2Primary1;

        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy];
        //System.assertEquals(3, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant];
        //System.assertEquals(4, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<InsurancePolicyCoverage> insPolCov = [SELECT Id FROM InsurancePolicyCoverage];
        //System.assertEquals(3, insPolCov.size(), 'InsurancePolicyCoverage not matching');
        List<Account> personAccs = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :PERSON_ACCOUNT_DEVELOPER_NAME];
        //System.assertEquals(2, personAccs.size(), 'Account not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_InclusionRealizada__c = true];
        //System.assertEquals(4, gcms.size(), 'GroupCensusMember not matching');
    }
    /*@isTest
    private static void enrollDependantsWithAlreadyEnrolledPrimaryMembers() {

        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        
        //Already existing primary
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        primary1.ZRH_InclusionRealizada__c = true;
        insert primary1;
        Account personAcc = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '1234', RecordTypeId = paRecTypeId);
        insert personAcc;
        InsurancePolicy ip = new InsurancePolicy(Name = '1', NameInsuredId = personAcc.Id, ContractGroupPlanId = cgpOne.Id, Status = 'Activa', PolicyType = 'Vida');
        insert ip;
        InsurancePolicyCoverage ipc = new InsurancePolicyCoverage(InsurancePolicyId = ip.Id);
        insert ipc;
        InsurancePolicyParticipant ipp = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc.Id,
        Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp;
        
        //Enroll a dependant of that primary 
        GroupCensusMember dep1Primary1 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary1, 'Inclusión');
        dep1Primary1.ZRH_Rut__c = '12345';
        dep1Primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234' + '12345' ;
        dep1Primary1.PolicyStartDate = Date.today() + 1;
        insert dep1Primary1;

        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy];
        //System.assertEquals(1, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant];
        //System.assertEquals(2, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<Account> personAccs = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :PERSON_ACCOUNT_DEVELOPER_NAME];
        //System.assertEquals(2, personAccs.size(), 'Account not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_InclusionRealizada__c = true];
        //System.assertEquals(2, gcms.size(), 'GroupCensusMember not matching');
    }*/
    @isTest
    private static void enrollPrimaryMemberWithIncorrectPolicyNumber() {

        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwo.ZRH_Folio__c = '12346-1';
        testQuoteLineItemTwo.ZRH_Periodo__c = 1;
        insert testQuoteLineItemTwo;
        QuoteLineItem testQuoteLineItemTwoCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwoCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemTwo.Id;
        insert testQuoteLineItemTwoCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpTwoCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemTwoCoverage);
        cgpTwoCoverage.ContractGroupParentPlanId = cgpTwo.Id;
        insert cgpTwoCoverage;
        
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345asasdasdas-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        insert primary1;
        
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary2.ZRH_Rut__c = '1234';
        primary2.ZRH_Poliza__c = '12346-asdasasd1';
        primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12346-1' + '1234';
        insert primary2;

        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy];
        //System.assertEquals(0, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant];
        //System.assertEquals(0, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<InsurancePolicyCoverage> insPolCov = [SELECT Id FROM InsurancePolicyCoverage];
        //System.assertEquals(0, insPolCov.size(), 'InsurancePolicyCoverage not matching');
        List<Account> personAccs = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :PERSON_ACCOUNT_DEVELOPER_NAME];
        //System.assertEquals(1, personAccs.size(), 'Account not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_InclusionRealizada__c = true];
        //System.assertEquals(2, gcms.size(), 'GroupCensusMember not matching');
    }
    @isTest
    private static void enrollPrimaryMemberAlreadyEnrolled() {

        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        
        //Already existing primary
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        primary1.ZRH_InclusionRealizada__c = true;
        insert primary1;
        Account personAcc = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '1234', RecordTypeId = paRecTypeId);
        insert personAcc;
        InsurancePolicy ip = new InsurancePolicy(Name = '1', NameInsuredId = personAcc.Id, ContractGroupPlanId = cgpOne.Id, Status = 'Activa', PolicyType = 'Vida');
        insert ip;
        InsurancePolicyCoverage ipc = new InsurancePolicyCoverage(InsurancePolicyId = ip.Id);
        insert ipc;
        InsurancePolicyParticipant ipp = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc.Id,
        Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp;                

        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy];
        //System.assertEquals(1, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant];
        //System.assertEquals(1, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<Account> personAccs = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :PERSON_ACCOUNT_DEVELOPER_NAME];
        //System.assertEquals(1, personAccs.size(), 'Account not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_InclusionRealizada__c = true];
        //System.assertEquals(1, gcms.size(), 'GroupCensusMember not matching');
    }
    @isTest
    private static void enrollDependantToCorrectPrimaryMember() {Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwo.ZRH_Folio__c = '12346-1';
        testQuoteLineItemTwo.ZRH_Periodo__c = 1;
        insert testQuoteLineItemTwo;
        QuoteLineItem testQuoteLineItemTwoCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwoCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemTwo.Id;
        insert testQuoteLineItemTwoCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpTwoCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemTwoCoverage);
        cgpTwoCoverage.ContractGroupParentPlanId = cgpTwo.Id;
        insert cgpTwoCoverage;
        
        // primary 1 with policy 12345-1
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        insert primary1;
        
        // primary 1 with policy 12346-1
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary2.ZRH_Rut__c = '1234';
        primary2.ZRH_Poliza__c = '12346-1';
        primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12346-1' + '1234';
        insert primary2;
        
        // dependant tied to primary 1
        GroupCensusMember dep1Primary1 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary1, 'Inclusión');
        dep1Primary1.ZRH_Rut__c = '123456';
        dep1Primary1.ZRH_Poliza__c = '12345-1';
        dep1Primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234' + '123456';
        insert dep1Primary1;

        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy];
        //System.assertEquals(2, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant];
        //System.assertEquals(3, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<InsurancePolicyCoverage> insPolCov = [SELECT Id FROM InsurancePolicyCoverage];
        //System.assertEquals(2, insPolCov.size(), 'InsurancePolicyCoverage not matching');
        List<Account> personAccs = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :PERSON_ACCOUNT_DEVELOPER_NAME];
        //System.assertEquals(2, personAccs.size(), 'Account not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_InclusionRealizada__c = true];
        //System.assertEquals(3, gcms.size(), 'GroupCensusMember not matching');
    }

    @isTest
    private static void enrollPrimaryMembersWithPhoneNumbers() {
        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwo.ZRH_Folio__c = '12346-1';
        testQuoteLineItemTwo.ZRH_Periodo__c = 1;
        insert testQuoteLineItemTwo;
        QuoteLineItem testQuoteLineItemTwoCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwoCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemTwo.Id;
        insert testQuoteLineItemTwoCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpTwoCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemTwoCoverage);
        cgpTwoCoverage.ContractGroupParentPlanId = cgpTwo.Id;
        insert cgpTwoCoverage;
        
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        // 8 digit
        primary1.PhoneNumber = '12345678';
        insert primary1;
        
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary2.ZRH_Rut__c = '12345';
        primary2.ZRH_Poliza__c = '12345-1';
        primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '12345';
        // 9 digit
        primary2.PhoneNumber = '123456789';
        insert primary2;
        
        GroupCensusMember primary3 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary3.ZRH_Rut__c = '123456';
        primary3.ZRH_Poliza__c = '12345-1';
        primary3.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '123456';
        // 11 digit
        primary3.PhoneNumber = '12345678901';
        insert primary3;
        
        GroupCensusMember primary4 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary4.ZRH_Rut__c = '1234567';
        primary4.ZRH_Poliza__c = '12345-1';
        primary4.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234567';
        // 12 digit
        primary4.PhoneNumber = '123456789012';
        insert primary4;
        
        GroupCensusMember primary5 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary5.ZRH_Rut__c = '12345678';
        primary5.ZRH_Poliza__c = '12345-1';
        primary5.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '12345678';
        // 10 digit
        primary5.PhoneNumber = '1234567890';
        insert primary5;

        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy];
        //System.assertEquals(5, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant];
        //System.assertEquals(5, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<InsurancePolicyCoverage> insPolCov = [SELECT Id FROM InsurancePolicyCoverage];
        //System.assertEquals(5, insPolCov.size(), 'InsurancePolicyCoverage not matching');
        List<Account> personAccs = [SELECT Id, PersonMobilePhone FROM Account WHERE RecordType.DeveloperName = :PERSON_ACCOUNT_DEVELOPER_NAME];
        //System.assertEquals(5, personAccs.size(), 'Account not matching');
        for (Account pa : personAccs) {
            if (pa.PersonMobilePhone != null) {
                //System.assertEquals(12, pa.PersonMobilePhone.length());
            }
        }
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_InclusionRealizada__c = true];
        //System.assertEquals(5, gcms.size(), 'GroupCensusMember not matching');
        
    }
        
    // -------- ---------- --------
    // -------- EXCLUSIONS --------
    // -------- ---------- --------
    @isTest
    private static void excludePrimaryMember() {
        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        //Already existing members
        Account personAcc = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '1234', RecordTypeId = paRecTypeId);
        insert personAcc;
        InsurancePolicy ip = new InsurancePolicy(Name = '1', NameInsuredId = personAcc.Id, ContractGroupPlanId = cgpOne.Id, Status = 'Activa');
        insert ip;
        InsurancePolicyCoverage ipc = new InsurancePolicyCoverage(InsurancePolicyId = ip.Id);
        insert ipc;
        InsurancePolicyParticipant ipp = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc.Id,
                                                                      Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp;
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_InclusionRealizada__c = true;
        insert primary1;

        // Exclude primary and dep
        primary1.ZRH_TipoMovimiento__c = 'Exclusión';
        primary1.ZRH_FechaExclusion__c = Date.today() + 100;
        update primary1;
        
        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy WHERE Status = 'Cancelada'];
        //System.assertEquals(1, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant WHERE IsActiveParticipant = false];
        //System.assertEquals(1, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_ExclusionRealizada__c = true];
        //System.assertEquals(1, gcms.size(), 'GroupCensusMember not matching');
    }
    @isTest
    private static void excludePrimaryMemberAndDependants() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        //Already existing members
        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        Account personAcc = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '1234', RecordTypeId = paRecTypeId);
        insert personAcc;
        Account personAcc1 = new Account(FirstName = 'Test', LastName = '2', ZRH_Rut__c = '12345', RecordTypeId = paRecTypeId);
        insert personAcc1;
        InsurancePolicy ip = new InsurancePolicy(Name = '1', NameInsuredId = personAcc.Id, ContractGroupPlanId = cgpOne.Id, Status = 'Activa');
        insert ip;
        InsurancePolicyCoverage ipc = new InsurancePolicyCoverage(InsurancePolicyId = ip.Id);
        insert ipc;
        InsurancePolicyParticipant ipp = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc.Id,
                                                                      Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp;
        InsurancePolicyParticipant ipp1 = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc.Id,
                                                                         RelatedParticipantAccountId = personAcc1.Id, Role = 'Otro', IsActiveParticipant = true);
        insert ipp1;
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        primary1.ZRH_InclusionRealizada__c = true;
        insert primary1;
        GroupCensusMember dep1Primary1 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary1, 'Inclusión');
        dep1Primary1.ZRH_Rut__c = '12345';
        dep1Primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234' + '12345';
        dep1Primary1.ZRH_InclusionRealizada__c = true;
        insert dep1Primary1;

        // Exclude primary and dep
        primary1.ZRH_TipoMovimiento__c = 'Exclusión';
        primary1.ZRH_FechaExclusion__c = Date.today() + 100;
        update primary1;
        dep1Primary1.ZRH_TipoMovimiento__c = 'Exclusión';
        dep1Primary1.ZRH_FechaExclusion__c = Date.today() + 100;
        update dep1Primary1;
        
        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy WHERE Status = 'Cancelada'];
        //System.assertEquals(1, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant WHERE IsActiveParticipant = false];
        //System.assertEquals(2, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_ExclusionRealizada__c = true];
        //System.assertEquals(2, gcms.size(), 'GroupCensusMember not matching');
    }
    @isTest
    private static void excludePrimaryAndDependantsOfOnePolicy() {
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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

        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwo.ZRH_Folio__c = '12346';
        testQuoteLineItemTwo.ZRH_Periodo__c = 1;
        insert testQuoteLineItemTwo;
        QuoteLineItem testQuoteLineItemTwoCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwoCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemTwo.Id;
        insert testQuoteLineItemTwoCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpTwoCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemTwoCoverage);
        cgpTwoCoverage.ContractGroupParentPlanId = cgpTwo.Id;
        insert cgpTwoCoverage;

        //Already existing members
        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        Account personAcc = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '1234', RecordTypeId = paRecTypeId);
        insert personAcc;
        // ip 1
        InsurancePolicy ip = new InsurancePolicy(Name = '1', NameInsuredId = personAcc.Id, ContractGroupPlanId = cgpOne.Id, Status = 'Activa');
        insert ip;
        InsurancePolicyCoverage ipc = new InsurancePolicyCoverage(InsurancePolicyId = ip.Id);
        insert ipc;
        InsurancePolicyParticipant ipp = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc.Id,
                                                                      Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp;
        // ip 2
        InsurancePolicy ip1 = new InsurancePolicy(Name = '1', NameInsuredId = personAcc.Id, ContractGroupPlanId = cgpTwo.Id, Status = 'Activa');
        insert ip1;
        InsurancePolicyCoverage ipc1 = new InsurancePolicyCoverage(InsurancePolicyId = ip1.Id);
        insert ipc1;
        InsurancePolicyParticipant ipp2 = new InsurancePolicyParticipant(InsurancePolicyId = ip1.Id, PrimaryParticipantAccountId = personAcc.Id,
                                                                      Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp2;        
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        primary1.ZRH_InclusionRealizada__c = true;
        insert primary1;
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary2.ZRH_Rut__c = '1234';
        primary2.ZRH_Poliza__c = '12346-1';
        primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12346-1' + '1234';
        primary2.ZRH_InclusionRealizada__c = true;
        insert primary2;

        // Exclude primary and dep
        primary1.ZRH_TipoMovimiento__c = 'Exclusión';
        primary1.ZRH_FechaExclusion__c = Date.today() + 100;
        update primary1;
        
        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy WHERE Status = 'Cancelada'];
        //System.assertEquals(1, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant WHERE IsActiveParticipant = false];
        //System.assertEquals(1, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_ExclusionRealizada__c = true];
        //System.assertEquals(1, gcms.size(), 'GroupCensusMember not matching');    
    }
    @isTest
    private static void excludeOnlyDependantMember() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        //Already existing members
        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        Account personAcc = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '1234', RecordTypeId = paRecTypeId);
        insert personAcc;
        Account personAcc1 = new Account(FirstName = 'Test', LastName = '2', ZRH_Rut__c = '12345', RecordTypeId = paRecTypeId);
        insert personAcc1;

        InsurancePolicy ip = new InsurancePolicy(Name = '1', NameInsuredId = personAcc.Id, ContractGroupPlanId = cgpOne.Id, Status = 'Activa');
        insert ip;
        InsurancePolicyCoverage ipc = new InsurancePolicyCoverage(InsurancePolicyId = ip.Id);
        insert ipc;
        InsurancePolicyParticipant ipp = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc.Id,
                                                                      Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp;
        InsurancePolicyParticipant ipp1 = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc.Id,
                                                                         RelatedParticipantAccountId = personAcc1.Id, Role = 'Otro', IsActiveParticipant = true);
        insert ipp1;
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        primary1.ZRH_InclusionRealizada__c = true;
        insert primary1;
        GroupCensusMember dep1Primary1 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary1, 'Inclusión');
        dep1Primary1.ZRH_Rut__c = '12345';
        dep1Primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234' + '12345';
        dep1Primary1.ZRH_InclusionRealizada__c = true;
        insert dep1Primary1;

        // Exclude primary and dep
        dep1Primary1.ZRH_TipoMovimiento__c = 'Exclusión';
        dep1Primary1.ZRH_FechaExclusion__c = Date.today() + 100;
        update dep1Primary1;
        
        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy WHERE Status = 'Cancelada'];
        //System.assertEquals(0, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant WHERE IsActiveParticipant = false];
        //System.assertEquals(1, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_ExclusionRealizada__c = true];
        //System.assertEquals(1, gcms.size(), 'GroupCensusMember not matching');
    }
    @isTest
    private static void excludeOnlyOnceDependantMemberThatBelongsTwiceToThePolicy() {

        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwo.ZRH_Folio__c = '12346-1';
        testQuoteLineItemTwo.ZRH_Periodo__c = 1;
        insert testQuoteLineItemTwo;
        QuoteLineItem testQuoteLineItemTwoCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwoCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemTwo.Id;
        insert testQuoteLineItemTwoCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpTwoCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemTwoCoverage);
        cgpTwoCoverage.ContractGroupParentPlanId = cgpTwo.Id;
        insert cgpTwoCoverage;

        //Already existing members
        // primary 1
        Account personAcc1 = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '1234', RecordTypeId = paRecTypeId);
        insert personAcc1;
        // primary 2
        Account personAcc2 = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '12345', RecordTypeId = paRecTypeId);
        insert personAcc2;
        // dep
        Account personAcc3 = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '123456', RecordTypeId = paRecTypeId);
        insert personAcc3;
        // ip 1
        InsurancePolicy ip = new InsurancePolicy(Name = '1', NameInsuredId = personAcc1.Id, ContractGroupPlanId = cgpOne.Id, Status = 'Activa');
        insert ip;
        InsurancePolicyCoverage ipc = new InsurancePolicyCoverage(InsurancePolicyId = ip.Id);
        insert ipc;
        InsurancePolicyParticipant ipp = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc1.Id,
                                                                      Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp;
        InsurancePolicyParticipant ipp1 = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc1.Id,
                                                                         RelatedParticipantAccountId = personAcc3.Id, Role = 'Otro', IsActiveParticipant = true);
        insert ipp1;
        
        // ip 2
        InsurancePolicy ip1 = new InsurancePolicy(Name = '1', NameInsuredId = personAcc2.Id, ContractGroupPlanId = cgpOne.Id, Status = 'Activa');
        insert ip1;
        InsurancePolicyCoverage ipc1 = new InsurancePolicyCoverage(InsurancePolicyId = ip1.Id);
        insert ipc1;
        InsurancePolicyParticipant ipp2 = new InsurancePolicyParticipant(InsurancePolicyId = ip1.Id, PrimaryParticipantAccountId = personAcc2.Id,
                                                                      Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp2;        
        InsurancePolicyParticipant ipp3 = new InsurancePolicyParticipant(InsurancePolicyId = ip1.Id, PrimaryParticipantAccountId = personAcc2.Id,
                                                                         RelatedParticipantAccountId = personAcc3.Id, Role = 'Otro', IsActiveParticipant = true);
        insert ipp3;
        // primary 1
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        primary1.ZRH_InclusionRealizada__c = true;
        insert primary1;

        // primary 2
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary2.ZRH_Rut__c = '12345';
        primary2.ZRH_Poliza__c = '12346-1';
        primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12346-1' + '12345';
        primary2.ZRH_InclusionRealizada__c = true;
        insert primary2;

        // dep tied to primary 1
        GroupCensusMember dep1Primary1 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary1, 'Inclusión');
        dep1Primary1.ZRH_Rut__c = '123456';
        dep1Primary1.ZRH_Poliza__c = '12345-1';
        dep1Primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234' + '123456';
        dep1Primary1.ZRH_InclusionRealizada__c = true;
        // dep tied to primary 2
        insert dep1Primary1;
        GroupCensusMember dep1Primary2 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary2, 'Inclusión');
        dep1Primary2.ZRH_Rut__c = '123456';
        dep1Primary2.ZRH_Poliza__c = '12345-1';
        dep1Primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '12345' + '123456';
        dep1Primary2.ZRH_InclusionRealizada__c = true;
        insert dep1Primary2;

        //exclude dep tied to primary 2
        dep1Primary2.ZRH_TipoMovimiento__c = 'Exclusión';
        dep1Primary2.ZRH_FechaExclusion__c = Date.today();
        update dep1Primary2;

        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicy> insPolicies = [SELECT Id FROM InsurancePolicy WHERE Status = 'Cancelada'];
        //System.assertEquals(0, insPolicies.size(), 'InsurancePolicy not matching');
        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant WHERE IsActiveParticipant = false];
        //System.assertEquals(1, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<GroupCensusMember> gcms = [SELECT Id FROM GroupCensusMember WHERE ZRH_ExclusionRealizada__c = true];
        //System.assertEquals(1, gcms.size(), 'GroupCensusMember not matching');
    }
    
    // -------- ------------- --------
    // -------- MODIFICATIONS --------
    // -------- ------------- --------
    @isTest
    private static void modifyMembers() {
        Id paRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);

        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
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
        
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwo.ZRH_Folio__c = '12346-1';
        testQuoteLineItemTwo.ZRH_Periodo__c = 1;
        insert testQuoteLineItemTwo;
        QuoteLineItem testQuoteLineItemTwoCoverage = ZRH_DataFactory.createQuoteLineItem(false, testQuoteOne, testHealthProduct, testPricebookEntryHealth, vidaASV.Body.toString());
        testQuoteLineItemTwoCoverage.vlocity_ins__ParentItemId2__c = testQuoteLineItemTwo.Id;
        insert testQuoteLineItemTwoCoverage;

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);

        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpOneCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemOneCoverage);
        cgpOneCoverage.ContractGroupParentPlanId = cgpOne.Id;
        insert cgpOneCoverage;
        
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ContractGroupPlan cgpTwoCoverage = ZRH_DataFactory.createContractGroupPlan(false, testContract, testQuoteLineItemTwoCoverage);
        cgpTwoCoverage.ContractGroupParentPlanId = cgpTwo.Id;
        insert cgpTwoCoverage;

        //Already existing members
        // primary 1
        Account personAcc1 = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '1234', RecordTypeId = paRecTypeId);
        insert personAcc1;
        // primary 2
        Account personAcc2 = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '12345', RecordTypeId = paRecTypeId);
        insert personAcc2;
        // dep
        Account personAcc3 = new Account(FirstName = 'Test', LastName = '1', ZRH_Rut__c = '123456', RecordTypeId = paRecTypeId);
        insert personAcc3;
        // ip 1
        InsurancePolicy ip = new InsurancePolicy(Name = '1', NameInsuredId = personAcc1.Id, ContractGroupPlanId = cgpOne.Id, Status = 'Activa');
        insert ip;
        InsurancePolicyCoverage ipc = new InsurancePolicyCoverage(InsurancePolicyId = ip.Id);
        insert ipc;
        InsurancePolicyParticipant ipp = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc1.Id,
                                                                      Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp;
        InsurancePolicyParticipant ipp1 = new InsurancePolicyParticipant(InsurancePolicyId = ip.Id, PrimaryParticipantAccountId = personAcc1.Id,
                                                                         RelatedParticipantAccountId = personAcc3.Id, Role = 'Otro', IsActiveParticipant = true);
        insert ipp1;
        
        // ip 2
        InsurancePolicy ip1 = new InsurancePolicy(Name = '1', NameInsuredId = personAcc2.Id, ContractGroupPlanId = cgpOne.Id, Status = 'Activa');
        insert ip1;
        InsurancePolicyCoverage ipc1 = new InsurancePolicyCoverage(InsurancePolicyId = ip1.Id);
        insert ipc1;
        InsurancePolicyParticipant ipp2 = new InsurancePolicyParticipant(InsurancePolicyId = ip1.Id, PrimaryParticipantAccountId = personAcc2.Id,
                                                                      Role = 'Titular de la póliza', IsActiveParticipant = true);
        insert ipp2;        
        InsurancePolicyParticipant ipp3 = new InsurancePolicyParticipant(InsurancePolicyId = ip1.Id, PrimaryParticipantAccountId = personAcc2.Id,
                                                                         RelatedParticipantAccountId = personAcc3.Id, Role = 'Otro', IsActiveParticipant = true);
        insert ipp3;

        // primary 1
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary1.ZRH_Rut__c = '1234';
        primary1.ZRH_Poliza__c = '12345-1';
        primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234';
        primary1.ZRH_InclusionRealizada__c = true;
        insert primary1;

        // primary 2
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMemberWithMovement(false, groupCensus, groupClass, 'Inclusión');
        primary2.ZRH_Rut__c = '12345';
        primary2.ZRH_Poliza__c = '12345-1';
        primary2.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '12345';
        primary2.ZRH_InclusionRealizada__c = true;
        insert primary2;

        // dep tied to primary 1
        GroupCensusMember dep1Primary1 = ZRH_DataFactory.createGroupCensusMemberWithMovement(false, groupCensus, groupClass, primary1, 'Inclusión');
        dep1Primary1.ZRH_Rut__c = '123456';
        dep1Primary1.ZRH_Poliza__c = '12345-1';
        dep1Primary1.ZRH_ClaveSincronizacion__c = groupCensus.Id + '12345-1' + '1234' + '123456';
        dep1Primary1.ZRH_InclusionRealizada__c = true;
        insert dep1Primary1;

        // Modify primary 1
        primary1.ZRH_TipoMovimiento__c = 'Modificación';
        primary1.ZRH_Banco__c = '1';
        primary1.Email = 'a@test.com';
        update primary1;

        // Modify primary 2
        primary2.ZRH_TipoMovimiento__c = 'Modificación';
        primary2.ZRH_Banco__c = '1';
        primary2.Email = 'a@test.com';
        update primary2;

        // Modify dep
        dep1Primary1.ZRH_TipoMovimiento__c = 'Modificación';
        dep1Primary1.ZRH_Banco__c = '1';
        dep1Primary1.Email = 'a@test.com';
        update dep1Primary1;
        
        Test.startTest();
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<InsurancePolicyParticipant> insPolPart = [SELECT Id FROM InsurancePolicyParticipant WHERE ZRH_Banco__c = '1'];
        //System.assertEquals(3, insPolPart.size(), 'InsurancePolicyParticipant not matching');
        List<Account> personAccs = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :PERSON_ACCOUNT_DEVELOPER_NAME AND PersonEmail = 'a@test.com'];
        //System.assertEquals(3, personAccs.size(), 'Account not matching');
    }
}