public with sharing class ZRH_QueryUtility {

    public static List<sObject> queryRecordsFromSObject(String sObjectName) {
        List<sObject> records = new List<sObject>();

        try {
            // Dynamically construct the query based on the sObject name
            String query = 'SELECT Id, Name, ZRH_Codigo__c FROM ' + sObjectName + ' LIMIT 5000';
            String finalString = String.escapeSingleQuotes(query);
            records = Database.query(finalString);
        } catch (QueryException e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
        
        return records;
    }
}