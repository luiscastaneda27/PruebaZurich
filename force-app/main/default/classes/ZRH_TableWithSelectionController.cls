/*********************************************************************************
Project      : Zurich Salesforce - Seguros colectivos
Created By   : Deloitte
Created Date : 11/05/2023
Description  : Class to query records from given SObject
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Mateo Long          			ML
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0       ML			11/05/2023		initial version
********************************************************************************/
global with sharing class ZRH_TableWithSelectionController implements vlocity_ins.VlocityOpenInterface{

    private static final String METHOD_NAME_QUERY_RECORDS;
    
    
    static{
        METHOD_NAME_QUERY_RECORDS = 'queryRecordsForTable';
    }
    

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
        List<sObject> listRecords;
        if (methodName == METHOD_NAME_QUERY_RECORDS){
            listRecords = queryRecordsForTable((String)inputMap.get('sObjectName'));
        }
        outputMap.put('listRecords', JSON.serialize(listRecords));
        return true;
    }

    public static List<sObject> queryRecordsForTable(String sObjectName) {
    
        return ZRH_QueryUtility.queryRecordsFromSObject(sObjectName);
    }
}