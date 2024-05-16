/*********************************************************************************
 Project      : Zurich Salesforce - Seguros colectivos
 Created By   : Deloitte
 Created Date : 30/10/2023
 Description  : Class for Remote Action that reserves folios for policies
 History      :
 --------------------------ACRONYM OF AUTHORS-------------------------------------
 AUTHOR                      ACRONYM
 Mateo Long                    ML
 ---------------------------------------------------------------------------------
 VERSION  AUTHOR         DATE            Description
 1.0      ML            30/10/2023            Created Class
 ********************************************************************************/
global without sharing class ZRH_CreateContracts implements vlocity_ins.VlocityOpenInterface2, System.Callable {

    /**
    *  @Description: Static variables
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        30/10/2023  
    */
    private static final String CHILD_QUOTES = 'CotizacionesContratantes';
    private static final String HOLDING_QUOTE = 'IdCotizacionHolding';

    // Implementation of invokeMethod for vlocity_ins.VlocityOpenInterface2
    global Object invokeMethod(String methodName, Map<String, Object> input,
                               Map<String, Object> output, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName == 'createContracts') {
                createContracts(input, output, options);
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
    global Object call(String methodName, Map<String, Object> params) {
        Map<String, Object> input = (Map<String, Object>) params.get('input');
        Map<String, Object> output = (Map<String, Object>) params.get('output');
        Map<String, Object> options = (Map<String, Object>) params.get('options');
        return invokeMethod(methodName, input, output, options);
    }
    

    /**
    *  @Description: calls batch to process quotes and create contracts
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        30/10/2023  
    */
    global static void createContracts(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){

        Id holdingQuoteId = (Id) inputMap.get(HOLDING_QUOTE);        
        List<Object> objs = (List<Object>) inputMap.get(CHILD_QUOTES);        
        List<Id> quoteIds = new List<Id>();

        for (Object obj : objs) {
            Id id = (Id) obj;
            quoteIds.add(id);
        }

        Id batchJobId = Database.executeBatch(new ZRH_CreateContractsFromQuotesBatch(quoteIds), 5);

        List<String> quoteFields = new List<String>{'Id', 'ZRH_IdJobCreacionPolizas__c'};
        Quote holdingQuote = new ZRH_QuotesSelector().selectById(holdingQuoteId, quoteFields);
        holdingQuote.ZRH_IdJobCreacionPolizas__c = batchJobId;
        update holdingQuote;

        outputMap.put('batchJobId', batchJobId);
        outputMap.put('holdingQuote', holdingQuote);
    }    
}