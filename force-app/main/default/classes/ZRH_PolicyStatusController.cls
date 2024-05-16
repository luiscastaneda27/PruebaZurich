/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 14/12/2023
Description  : Salesforce Controller for Policy Status.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Andres Deus                         AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JD             14/12/2023      Initial Version
********************************************************************************/

/**
 * @Description: This class provides methods to interact with the Policy Status functionality in Salesforce.
 * @Author: Andres Deus
 * @Date: 14/12/2023
 */
public with sharing class ZRH_PolicyStatusController {
    private static final String INTEGRATION_BASE;
    private static final String INTEGRATION_ROUTE;

    static {
        INTEGRATION_BASE = 'ZRH_SegurosColectivos';
        INTEGRATION_ROUTE = 'ZRH_ConsultaEstadoPoliza';
    }

    /**
     * @Description: Constructor for ZRH_PolicyStatusController class.
     */
    public ZRH_PolicyStatusController() {

    }

    /**
     * @Description: Calls the external service to get policy status based on the provided policy number.
     * @Author: Andres Deus
     * @Date: 14/12/2023
     * @param policyNumber - The policy number for which status needs to be retrieved.
     * @return HttpResponse - The HTTP response from the external service.
     */
    public static HttpResponse call(String policyNumber) {
        Map<String, String> pathParam = new Map<String, String>();
        Map<String, String> mapHeader = new Map<String, String>();
        Map<String, String> mapQuery = new Map<String, String>();
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        pathParam.put('numeroPoliza', policyNumber);
        setConf.put('header', mapHeader);
        setConf.put('path', pathParam);
        setConf.put('query', mapQuery);
        ZRH_RestConnection objClass = new ZRH_RestConnection(INTEGRATION_BASE, INTEGRATION_ROUTE, setConf);
        return objClass.callService(null);
    }

    /**
     * @Description: Invocable method to get policy status for a list of ContractGroupPlan records.
     * Enqueues a Queueable job for processing.
     * @Author: Andres Deus
     * @Date: 14/12/2023
     * @param contractGroupPlans - List of ContractGroupPlan records.
     * @return List<String> - List of output variables.
     */
    @InvocableMethod(label='Get Policy Status' description='Returns the status of a given policy in AS400')
    public static List<String> response(List<List<ContractGroupPlan>> contractGroupPlans) {
        List<String> outputVariables = new List<String>();
        Set<Id> contractGroupPlanIds = new Set<Id>();

        for (ContractGroupPlan contractGroupPlan : contractGroupPlans[0]) {
            contractGroupPlanIds.add(contractGroupPlan.Id);
        }

        // Enqueue the Queueable job
        ZRH_PolicyStatusQueueable queueableJob = new ZRH_PolicyStatusQueueable(contractGroupPlanIds, outputVariables);
        System.enqueueJob(queueableJob);

        return outputVariables;
    }
}