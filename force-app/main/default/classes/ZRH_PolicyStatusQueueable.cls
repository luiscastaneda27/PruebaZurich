/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 14/12/2023
Description  : Queueable job for Policy Status updates in Salesforce.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Andres Deus                         AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JD             14/12/2023      Initial Version
********************************************************************************/

/**
 * @Description: This Queueable class performs asynchronous processing to update policy status.
 * @Author: Andres Deus
 * @Date: 14/12/2023
 */
public with sharing class ZRH_PolicyStatusQueueable implements Queueable {
    private Set<Id> contractGroupPlanIds;
    private List<String> outputVariables;

    /**
     * @Description: Constructor for ZRH_PolicyStatusQueueable class.
     * @param contractGroupPlanIds - Set of ContractGroupPlan record Ids to be processed.
     * @param outputVariables - List to store output messages.
     */
    public ZRH_PolicyStatusQueueable(Set<Id> contractGroupPlanIds, List<String> outputVariables) {
        this.contractGroupPlanIds = contractGroupPlanIds;
        this.outputVariables = outputVariables;
    }

    /**
     * @Description: Executes the Queueable job to update policy status based on external callout.
     * @Author: Andres Deus
     * @Date: 14/12/2023
     * @param context - QueueableContext instance.
     */
    public void execute(QueueableContext context) {
        System.debug('Executing the QUEUEABLE JOB');
        ZRH_PolicyStatusQueueable.makeCallout(contractGroupPlanIds, outputVariables);
    }

    /**
     * @Description: Invocable method to make callouts to an external service for policy status updates.
     * Updates Salesforce records based on the callout response.
     * @Author: Andres Deus
     * @Date: 14/12/2023
     * @param contractGroupPlanIds - Set of ContractGroupPlan record Ids.
     * @param outputVariables - List to store output messages.
     */
    @future(callout=true)
    public static void makeCallout(Set<Id> contractGroupPlanIds, List<String> outputVariables) {
        List<ContractGroupPlan> contractGroupPlans = [SELECT Id, ZRH_Estado__c, ZRH_ConsultaEstadoPolizaManual__c, ContractId, ZRH_Folio__c FROM ContractGroupPlan WHERE Id IN :contractGroupPlanIds AND ZRH_Folio__c != null];
        Contract contract = [SELECT Id, ZRH_ConsultaEstadoPolizaManual__c FROM Contract WHERE Id = :contractGroupPlans.get(0).ContractId];
        Boolean contractHasBeenUpdated = false;

        for (ContractGroupPlan contractGroupPlan : contractGroupPlans) {
            
            String policyNumber = contractGroupPlan.ZRH_Folio__c.remove('.');
            String transformedPolicyNumber = policyNumber.substringBefore('-');
            HttpResponse res = ZRH_PolicyStatusController.call(transformedPolicyNumber);
            String status = res.getBody().remove('"');
            Integer numberOfCalls = 1;
            
            
            //3 tries to do the callout
            while (!status.isNumeric() && numberOfCalls < 3) {
                res = ZRH_PolicyStatusController.call(transformedPolicyNumber);
                status = res.getBody().remove('"');
                numberOfCalls++;
            }

            //Field Updates
            if (status.isNumeric()) {
                contractGroupPlan.ZRH_Estado__c = status;
                contractGroupPlan.ZRH_ConsultaEstadoPolizaManual__c = false;
            } else {
                contractGroupPlan.ZRH_ConsultaEstadoPolizaManual__c = true;
                if (!contractHasBeenUpdated) {
                    contract.ZRH_ConsultaEstadoPolizaManual__c = true;
                    contractHasBeenUpdated = true;
                }
            }   
        }

        // Record Updates
        update contractGroupPlans;
        if (contractHasBeenUpdated) {
            update contract;
        }
    }
}