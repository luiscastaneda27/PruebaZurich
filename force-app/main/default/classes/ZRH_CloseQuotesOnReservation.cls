/*********************************************************************************
 Project      : Zurich Salesforce - Seguros colectivos
 Created By   : Deloitte
 Created Date : 15/11/2023
 Description  : Class for Remote Action that closes quotes on reservation
 History      :
 --------------------------ACRONYM OF AUTHORS-------------------------------------
 AUTHOR                      ACRONYM
 Mateo Long                    ML
 ---------------------------------------------------------------------------------
 VERSION  AUTHOR         DATE            Description
 1.0      ML            15/11/2023            Created Class
 ********************************************************************************/
global without sharing class ZRH_CloseQuotesOnReservation implements vlocity_ins.VlocityOpenInterface2, System.Callable {

    /**
    *  @Description: Static variables
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        15/11/2023  
    */
    private static final String LIST_QUOTES_TO_CLOSE = 'listQuotesToClose';
    private static final String ID = 'Id';
    private static final String STATUS = 'EstadoCotizacion';
    private static final String SUB_STATUS = 'SubEstado';

    // Implementation of invokeMethod for vlocity_ins.VlocityOpenInterface2
    global Object invokeMethod(String methodName, Map<String, Object> input,
                               Map<String, Object> output, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName == 'closeQuotes') {
                closeQuotes(input, output, options);
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
    
    global static void closeQuotes(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){

        List<Object> quotesToClose = (List<Object>) inputMap.get(LIST_QUOTES_TO_CLOSE);    
        List<Quote> quotesToUpdate = new List<Quote>();
        
        Integer pos = 0;
        for (Object quote : quotesToClose) {
            Map<String,Object> q = (Map<String,Object>)quote;

            Quote quoteToUpdt = new Quote();
            quoteToUpdt.Id = (Id)q.get(ID);
            quoteToUpdt.Status = (String)q.get(STATUS);
            quoteToUpdt.ZRH_SubEstado__c = (String)q.get(SUB_STATUS);
    
            quotesToUpdate.add(quoteToUpdt);
            pos += 1;
        }
    
        update quotesToUpdate;
        outputMap.put('cotizacionesActualizadas', quotesToUpdate);
    }
}