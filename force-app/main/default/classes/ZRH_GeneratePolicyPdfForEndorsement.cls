/*********************************************************************************
Project      : Zurich Salesforce - Seguros colectivos
Created By   : Deloitte
Created Date : 16/02/2024
Description  : Class for Remote Action that generates policy pdfs for endorsements
History      :
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Andres Deus                   AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0       AD            16/02/2024            Created Class
********************************************************************************/
public without sharing class ZRH_GeneratePolicyPdfForEndorsement implements vlocity_ins.VlocityOpenInterface2, System.Callable {
 
    
 
    // Implementation of invokeMethod for vlocity_ins.VlocityOpenInterface2
    public Object invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName == 'generateCompletePdf') {
                generateCompletePdf(input, output, options);
            }else if (methodName == 'generateOnlyGlossPdf'){
                generateOnlyGlossPdf(input, output, options);
            }else if (methodName == 'generateOnlyPdf'){
                generateOnlyPdf(input, output, options);
            }
            else {
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
    *  @Description: calls batch to generate a complete pdf
    *  @Autor:       AD, Deloitte, adeusme@deloitte.com
    *  @Date:        16/02/2024 
    */
    public static void generateCompletePdf(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
 
        String folioNumber = (String) inputMap.get('Folio');
        
        String queryCondition = 'ZRH_Estado__c = \'Ingresado\' AND ZRH_Folio__c = \'' + folioNumber + '\'';
        
        Database.executeBatch(new ZRH_BatchProcessEndorsements(queryCondition), 1);
    } 
    
    /**
    *  @Description: calls batch to generate a PDF only with the new glosses
    *  @Autor:       AD, Deloitte, adeusme@deloitte.com
    *  @Date:        16/02/2024 
    */
    public static void generateOnlyGlossPdf(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
 
        Database.executeBatch(new ZRH_BatchSubmitGlossPolicy(), 1);
    } 
    
    /**
    *  @Description: calls batch to generate a PDF only with out the new glosses
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        6/03/2024 
    */
    public static void generateOnlyPdf(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
 
        String folioNumber = (String) inputMap.get('Folio');
        String queryCondition = 'ZRH_Folio__c = \'' + folioNumber + '\'';
        ContractGroupPlan p = DataBase.query(new ZRH_ContractGroupPlansSelector().selectByDynamicCondition(queryCondition).getQuery());
        Integer numberGloss = ZRH_ControllerGlossPolicy.manageGloss(p.Id);
        Database.executeBatch(new ZRH_BatchSubmitGlossPolicy(queryCondition), 1);
    } 

}