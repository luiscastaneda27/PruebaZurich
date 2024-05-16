/*********************************************************************************
Project      : Zurich Salesforce - Seguros colectivos
Created By   : Deloitte
Created Date : 11/05/2023
Description  :  Test Class to query records from given SObject
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Mateo Long          			ML
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0       ML			11/05/2023		initial version
********************************************************************************/
@isTest
private class ZRH_TableWithSelectionController_Test {

    @isTest static void assertEquals_ObjectWithAllFields_ReturnsRecords() {

        ZRH_Convenio__c conv = ZRH_DataFactory.createConvenio(true);
        
        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('sObjectName', 'ZRH_Convenio__c');
        Boolean convs = new ZRH_TableWithSelectionController().invokeMethod('queryRecordsForTable', inputMap, outputMap, null);
        Test.stopTest();


        Object response = outputMap.get('listRecords');
        System.assertNotEquals('[]',response);
    }

    @isTest static void assertEquals_ObjectWithMissingFields_ThrowException() {

        ZRH_Convenio__c conv = ZRH_DataFactory.createConvenio(true);

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('sObjectName', 'Account');
        Boolean convs = new ZRH_TableWithSelectionController().invokeMethod('queryRecordsForTable', inputMap, outputMap, null);
        Test.stopTest();

        Object response = outputMap.get('listRecords');
        System.assertEquals('[]', response);
    }
}