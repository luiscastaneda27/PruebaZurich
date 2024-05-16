/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 14/12/2023
Description  : Controller class for retrieving the status of a policy in AS400.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Andres Deus                         AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      AD             14/12/2023      Initial Version
********************************************************************************/

public with sharing class ZRH_PolicyStatusControllerSingle {
    
    /**
    *  @Description: Static variables
    *  @Autor:       Andres Deus
    *  @Date:        14/12/2023
    */
    private static final String INTEGRATION_BASE;
    private static final String INTEGRATION_ROUTE;

    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Andres Deus
    *  @Date:        14/12/2023
    */
    static {
        INTEGRATION_BASE = 'ZRH_SegurosColectivos';
        INTEGRATION_ROUTE = 'ZRH_ConsultaEstadoPoliza';
    }

    /**
    *  @Description: Invokes a REST service to retrieve the status of a policy.
    *  @param policyNumber The policy number for which status is requested.
    *  @return HttpResponse The HTTP response from the REST service.
    *  @Author: Andres Deus
    *  @Date: 14/12/2023
    */
    @TestVisible
    private static HttpResponse call(String policyNumber) {
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
    *  @Description: Invocable method to get the policy status for a single policy.
    *  @param inputVariables List containing the policy number.
    *  @return List<String> List containing the policy status.
    *  @Author: Andres Deus
    *  @Date: 14/12/2023
    */
    @InvocableMethod(label='Get Policy Status Single' description='Returns the status of a given policy in AS400')
    public static List<String> response(List<String> inputVariables) {
        List<String> outputVariables = new List<String>();
        String transformedPolicyNumber = inputVariables.get(0).substringBefore('-');
        HttpResponse res = call(transformedPolicyNumber);
        outputVariables.add(res.getBody().remove('"'));
        return outputVariables;
    }

    /**
    *  @Description: Retrieves the policy status for a job.
    *  @param policyNumber The policy number for which status is requested.
    *  @return String The policy status.
    *  @Author: Andres Deus
    *  @Date: 14/12/2023
    */
    public static String responseForJob(String policyNumber) {
        String transformedPolicyNumber = policyNumber.substringBefore('-');
        HttpResponse res = call(transformedPolicyNumber);
        return res.getBody().remove('"');
    }
}