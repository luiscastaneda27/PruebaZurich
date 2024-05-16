@isTest
public class ZRH_GroupCensusMemberSelector_TEST {

    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';

    @isTest
    public static void selectGroupMembersByCensusIdsTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);

        List<GroupCensusMember> gcmList = new List<GroupCensusMember>();
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary1.ZRH_TipoMovimiento__c = 'Inclusión';
        primary1.ZRH_ClaveSincronizacion__c = '123';
        primary1.PolicyStartDate = Date.today();
        gcmList.add(primary1);
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary2.ZRH_TipoMovimiento__c = 'Inclusión';
        primary2.ZRH_ClaveSincronizacion__c = '1234';
        primary2.PolicyStartDate = Date.today();
        gcmList.add(primary2);
        GroupCensusMember primary3 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary3.ZRH_TipoMovimiento__c = 'Inclusión';
        primary3.ZRH_ClaveSincronizacion__c = '12345';
        primary3.PolicyStartDate = Date.today();
        gcmList.add(primary3);
        insert gcmList;

        Set<Id> gcmIds = new Set<Id>{primary1.Id, primary2.Id, primary3.Id};

        Test.startTest();
        Database.QueryLocator results = new ZRH_GroupCensusMemberSelector().selectGroupMembersByCensusIds(gcmIds);
        System.assertNotEquals(null, results, 'selectGroupMembersByCensusIds method failed to return expected results');
        Test.stopTest();
    }

    @isTest
    public static void selectDependantsFromPrimaryIdsTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);

        List<GroupCensusMember> gcmList = new List<GroupCensusMember>();
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary1.ZRH_TipoMovimiento__c = 'Inclusión';
        primary1.ZRH_ClaveSincronizacion__c = '123';
        primary1.PolicyStartDate = Date.today();
        gcmList.add(primary1);
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary2.ZRH_TipoMovimiento__c = 'Inclusión';
        primary2.ZRH_ClaveSincronizacion__c = '1234';
        primary2.PolicyStartDate = Date.today();
        gcmList.add(primary2);
        GroupCensusMember primary3 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary3.ZRH_TipoMovimiento__c = 'Inclusión';
        primary3.ZRH_ClaveSincronizacion__c = '12345';
        primary3.PolicyStartDate = Date.today();
        gcmList.add(primary3);
        insert gcmList;

        GroupCensusMember dep1 = ZRH_DataFactory.createGroupCensusMember(false, groupCensus, groupClass, primary1);
        dep1.ZRH_TipoMovimiento__c = 'Inclusión';
        dep1.ZRH_ClaveSincronizacion__c = '123456';
        dep1.PolicyStartDate = Date.today();
        insert dep1;

        Set<Id> primaryIds = new Set<Id>{primary1.Id, primary2.Id, primary3.Id};

        Test.startTest();
        List<GroupCensusMember> results = new ZRH_GroupCensusMemberSelector().selectDependantsFromPrimaryIds(primaryIds);
        System.assertEquals(1, results.size(), 'selectDependantsFromPrimaryIds method failed to return expected results');
        Test.stopTest();
    }

    @isTest
    public static void selectPrimaryMembersFromRutsAndCensusIdsTest() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);

        Account testAccount = ZRH_DataFactory.createAccount(true);
        GroupClass groupClass = ZRH_DataFactory.createGroupClass(true, testAccount);
        GroupCensus groupCensus = ZRH_DataFactory.createGroupCensus(true, testAccount);

        List<GroupCensusMember> gcmList = new List<GroupCensusMember>();
        GroupCensusMember primary1 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary1.ZRH_TipoMovimiento__c = 'Inclusión';
        primary1.ZRH_ClaveSincronizacion__c = '123';
        primary1.ZRH_Rut__c = '123';
        primary1.PolicyStartDate = Date.today();
        gcmList.add(primary1);
        GroupCensusMember primary2 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary2.ZRH_TipoMovimiento__c = 'Inclusión';
        primary2.ZRH_ClaveSincronizacion__c = '1234';
        primary2.PolicyStartDate = Date.today();
        gcmList.add(primary2);
        GroupCensusMember primary3 = ZRH_DataFactory.createPrimaryGroupCensusMember(false, groupCensus, groupClass);
        primary3.ZRH_TipoMovimiento__c = 'Inclusión';
        primary3.ZRH_ClaveSincronizacion__c = '12345';
        primary3.PolicyStartDate = Date.today();
        gcmList.add(primary3);
        insert gcmList;

        Set<String> memberRuts = new Set<String>{primary1.ZRH_Rut__c};
        Set<Id> censusIds = new Set<Id>{groupCensus.Id};

        Test.startTest();
        List<GroupCensusMember> results = new ZRH_GroupCensusMemberSelector().selectPrimaryMembersFromRutsAndCensusIds(memberRuts, censusIds);
        System.assertEquals(1, results.size(), 'selectPrimaryMembersFromRutsAndCensusIds method failed to return expected results');
        Test.stopTest();
    }
}