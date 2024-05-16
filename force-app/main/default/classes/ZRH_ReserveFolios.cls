/*********************************************************************************
 Project      : Zurich Salesforce - Seguros colectivos
 Created By   : Deloitte
 Created Date : 24/10/2023
 Description  : Class for Remote Action that reserves folios for policies
 History      :
 --------------------------ACRONYM OF AUTHORS-------------------------------------
 AUTHOR                      ACRONYM
 Mateo Long                    ML
 ---------------------------------------------------------------------------------
 VERSION  AUTHOR         DATE            Description
 1.0      ML            24/10/2023            Created Class
 ********************************************************************************/
global without sharing class ZRH_ReserveFolios implements vlocity_ins.VlocityOpenInterface2, System.Callable {

    /**
    *  @Description: Static variables
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        24/10/2023  
    */
    private static final String NUMBER_OF_FOLIOS_TO_RESERVE = 'numeroDeFoliosAReservar';
    private static final String LIST_FOLIOS = 'listaFolios';
    private static final String LIST_PLANS = 'listaPlanes';
    private static final Integer MAX_SUPPORTED_VALUE = 100;
    private static final Integer MAX_RETRY = 3;
    private static final String STATUS_CODE = 'statusServicio';


    // Implementation of invokeMethod for vlocity_ins.VlocityOpenInterface2
    global Object invokeMethod(String methodName, Map<String, Object> input,
                               Map<String, Object> output, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName == 'reserveFolios') {
                reserveFolios(input, output, options);
            } else if ((methodName == 'matchFoliosWithPlans')) {
                matchFoliosWithPlans(input, output, options);
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
    *  @Description: gets folios and saves them in the quote line items
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        24/10/2023  
    */
    global static void reserveFolios(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){

        Integer totalNumberToReserve = (Integer) inputMap.get(NUMBER_OF_FOLIOS_TO_RESERVE);    
        Integer pendingFoliosToReserve = totalNumberToReserve;
        Integer numberToReserve;
        Integer maxNumberOfFolios = MAX_SUPPORTED_VALUE;
        List<String> folios = new List<String>();
        Integer lastStatusCode;
        
        for (Integer i = 0; i < totalNumberToReserve; i += MAX_SUPPORTED_VALUE) {
            
            Boolean hasSucceeded = false;

            if (pendingFoliosToReserve > maxNumberOfFolios) {
                numberToReserve = maxNumberOfFolios;
            } else {
                numberToReserve = pendingFoliosToReserve;
            }
            
            for (Integer retry = 0; retry < MAX_RETRY; retry++) {
                
                ZRH_FolioNumberController controller = new ZRH_FolioNumberController();
                Map<String,Object> foliosResponse = controller.response(numberToReserve);
                List<String> listFolios = (List<String>) foliosResponse.get('folioNumbers');
                Integer statusCode = (Integer) foliosResponse.get('statusCode');
                lastStatusCode = statusCode;
                
                System.debug('folioNumbers: ' + listFolios);
                System.debug('statusCode: ' + statusCode);
                
                folios.addAll(listFolios);
                
                if (statusCode == 201 && listFolios.size() == numberToReserve) {
                    hasSucceeded = true;
                    break;
                }
            }
            if (!hasSucceeded) {
                outputMap.put(STATUS_CODE, lastStatusCode);
                break;
            }
            pendingFoliosToReserve -= numberToReserve;
        }
        
        if (folios.size() == totalNumberToReserve) {
            outputMap.put(LIST_FOLIOS, folios);   
            outputMap.put(STATUS_CODE, lastStatusCode);
        }

    }

    global static void matchFoliosWithPlans(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        List<Object> folios = (List<Object>) inputMap.get(LIST_FOLIOS);
        List<Object> plans = (List<Object>) inputMap.get(LIST_PLANS);
    
        List<QuoteLineItem> qlisList = new List<QuoteLineItem>();
        
        Integer pos = 0;
        for (Object plan : plans) {
    
            QuoteLineItem qlItem = new QuoteLineItem();
            qlItem.Id = (Id)plan;
            qlItem.ZRH_Folio__c = (String)folios[pos];
    
            qlisList.add(qlItem);
            pos += 1;
        }
    
        update qlisList;
        outputMap.put('listaPlanesFolios', qlisList);
    }
}