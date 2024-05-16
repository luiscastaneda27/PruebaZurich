/*********************************************************************************
 Project      : Zurich Salesforce - Seguros colectivos
 Created By   : Deloitte
 Created Date : 19/12/2023
 Description  : Class for Remote Action that enroll members into policies
 History      :
 --------------------------ACRONYM OF AUTHORS-------------------------------------
 AUTHOR                      ACRONYM
 Mateo Long                    ML
 ---------------------------------------------------------------------------------
 VERSION  AUTHOR         DATE            Description
 1.0      ML            19/12/2023            Created Class
 ********************************************************************************/
public without sharing class ZRH_EnrollMembers implements vlocity_ins.VlocityOpenInterface2, System.Callable {

    /**
    *  @Description: Static variables
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        19/12/2023  
    */
    private static final String HOLDING_QUOTE = 'IdCotizacionHolding';

    // Implementation of invokeMethod for vlocity_ins.VlocityOpenInterface2
    public Object invokeMethod(String methodName, Map<String, Object> input,
                               Map<String, Object> output, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName == 'enrollMembers') {
                enrollMembers(input, output, options);
            } else {
                output.put('error', 'Method not found: ' + methodName);
                result = false;
            }
        } catch (Exception e) {
            output.put('error', e.getMessage());
            System.debug('Error in invokeMethod: ' + e.getMessage());
            result = false;
        }
        return result;
    }

    // Implementation of call method for System.Callable
    public Object call(String methodName, Map<String, Object> params) {
        Map<String, Object> input = (Map<String, Object>) params.get('input');
        Map<String, Object> output = (Map<String, Object>) params.get('output');
        Map<String, Object> options = (Map<String, Object>) params.get('options');
        return invokeMethod(methodName, input, output, options);
    }
    

    /**
    *  @Description: calls batch to process quotes and create contracts
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        19/12/2023  
    */
    public static void enrollMembers(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){

        Id holdingQuoteId = (Id) inputMap.get(HOLDING_QUOTE);        
        
        ZRH_EnrollMembersBatch batch = new ZRH_EnrollMembersBatch();
        batch.holdingQuoteId = holdingQuoteId;
        Id batchJobId = Database.executeBatch(batch, 100);

        List<Id> ids = new List<Id>();
        ids.add(holdingQuoteId);
        List<Contract> contracts = new ZRH_ContractsSelector().selectContractsBySourceQuoteIds(new List<Id>(ids));
        Contract holdingContract = contracts[0];
        holdingContract.ZRH_IdJobInscripcionMiembros__c = batchJobId;
        update holdingContract;

        outputMap.put('batchJobId', batchJobId);
    }    
}