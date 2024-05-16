/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 14/12/2023
Description  : Batch class for updating policy status in ContractGroupPlan records.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Andres Deus                         AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JD             14/12/2023      Initial Version
********************************************************************************/

global class ZRH_PolicyStatusBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    /**
    *  @Description: Start method to provide the scope of records to process in the batch.
    *                Queries Contract Group Plans with status different from 8 and ZRH_Folio__c is not null.
    *  @Author: Andres Deus
    *  @Date: 14/12/2023
    *  @param bc Database.BatchableContext The batchable context.
    *  @return Database.QueryLocator The query locator for the records to process.
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, ZRH_Folio__c, ZRH_Estado__c FROM ContractGroupPlan ' +
            'WHERE ZRH_Estado__c != \'8\' AND ZRH_Estado__c != \'2\' AND ZRH_Folio__c != null'
        );
    }

    /**
    *  @Description: Execute method to process the records in the batch.
    *                Calls the external API using the ZRH_Folio__c value to get the policy status.
    *                Updates the status in the ContractGroupPlan records.
    *  @Author: Andres Deus
    *  @Date: 14/12/2023
    *  @param bc Database.BatchableContext The batchable context.
    *  @param scope List<ContractGroupPlan> The scope of records to process.
    */
    global void execute(Database.BatchableContext bc, List<ContractGroupPlan> scope) {
        System.debug(scope);
        List<ContractGroupPlan> recordsToUpdate = new List<ContractGroupPlan>();

        for (ContractGroupPlan record : scope) {

            // Remove dash and everything after it from ZRH_Folio__c
            String folioWithoutDash = record.ZRH_Folio__c.substringBefore('-');
            System.debug(folioWithoutDash);

            // Call the external API using the ZRH_Folio__c value
            String status = ZRH_PolicyStatusControllerSingle.responseForJob(folioWithoutDash);

            System.debug('RecordId: ' + record.Id + ' Estado: ' + status);

            // Update the status in the record
            record.ZRH_Estado__c = status;
            recordsToUpdate.add(record);
        }

        // Update the records
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }

    /**
    *  @Description: Finish method to execute any post-processing logic if needed.
    *  @Author: Andres Deus
    *  @Date: 14/12/2023
    *  @param bc Database.BatchableContext The batchable context.
    */
    global void finish(Database.BatchableContext bc) {
        // Execute any post-processing logic if needed
    }
}