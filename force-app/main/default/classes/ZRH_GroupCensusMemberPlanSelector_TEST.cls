@isTest
public class ZRH_GroupCensusMemberPlanSelector_TEST {

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

    private static Quote holdingQuote;

    @isTest
    public static void selectByGroupCensusMemberIdsTest() {
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
        
        List<GroupCensusMember> gcmList = new List<GroupCensusMember>();
        List<GroupCensusMember> gcmList1 = new List<GroupCensusMember>();

        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary1.ZRH_TipoMovimiento__c = 'Inclusión';
        primary1.ZRH_ClaveSincronizacion__c = '123';
        primary1.PolicyStartDate = Date.today();
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary2.ZRH_TipoMovimiento__c = 'Inclusión';
        primary2.ZRH_ClaveSincronizacion__c = '1234';
        primary2.PolicyStartDate = Date.today();

        gcmList.add(primary1);
        gcmList.add(primary2);
        insert gcmList;

        GroupCensusMember dep1Primary1 = ZRH_DataFactory.createGroupCensusMember(false, groupCensus, groupClass, primary1);
        dep1Primary1.ZRH_TipoMovimiento__c = 'Inclusión';
        dep1Primary1.ZRH_ClaveSincronizacion__c = '12345';
        dep1Primary1.PolicyStartDate = Date.today();
        GroupCensusMember dep1Primary2 = ZRH_DataFactory.createGroupCensusMember(false, groupCensus, groupClass, primary2);
        dep1Primary2.ZRH_TipoMovimiento__c = 'Inclusión';
        dep1Primary2.ZRH_ClaveSincronizacion__c = '123456';
        dep1Primary2.PolicyStartDate = Date.today();
        
        gcmList1.add(dep1Primary1);
        gcmList1.add(dep1Primary2);
        insert gcmList1;
        

        ContractGroupPlanGroupClass cgpgc = ZRH_DataFactory.createContractGroupPlanGroupClass(true, cgpOne, groupClass);
        
        GroupCensusMemberPlan primary1Plan1 = ZRH_DataFactory.createGroupCensusMemberPlan(true, primary1.Id, cgpOne.Id);
        GroupCensusMemberPlan primary2Plan1 = ZRH_DataFactory.createGroupCensusMemberPlan(true, primary2.Id, cgpOne.Id);
        GroupCensusMemberPlan dep1Plan1 = ZRH_DataFactory.createGroupCensusMemberPlan(true, dep1Primary1.Id, cgpOne.Id);
        GroupCensusMemberPlan dep2Plan1 = ZRH_DataFactory.createGroupCensusMemberPlan(true, dep1Primary2.Id, cgpOne.Id);

        Set<Id> gcmIds = new Set<Id>{primary1.Id, primary2.Id, dep1Primary1.Id, dep1Primary2.Id};

        Test.startTest();
        List<GroupCensusMemberPlan> results = new ZRH_GroupCensusMemberPlanSelector().selectByGroupCensusMemberIds(gcmIds);
        System.assertEquals(4, results.size(), 'selectByGroupCensusMemberIds method failed to return expected results');
        Test.stopTest();
    }
}