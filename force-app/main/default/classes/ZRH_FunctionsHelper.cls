/*******************************************************************************************************
* Project: ZURICH - Salesforce
* Created By: Deloitte
* Created Date: 06/09/2023
* Description: Utility class for functions in Vlocity
* ----------------------------------- ACRONYM OF AUTHORS -----------------------------------------------
* AUTHOR                               ACRONYM
* Jair Anton Atuncar                   JANTON
* ------------------------------------------------------------------------------------------------------
* VERSION          AUTHOR          DATE                Description
* 1.0              JANTON          06/09/2023          initial version
*******************************************************************************************************/
global class ZRH_FunctionsHelper implements Callable {
    
    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        7/11/2023  
    */
    public static final String GLOSS_HONDING = 'GlosaHonding';
    public static final String GLOSS_CONTRACTOR = 'GlosaContratante';
    public static final String OBJECT_QUOTE = 'Quote';
    public static final String TEXT_RECORD = 'recordId';
    public static final String COVERAGE_CODE = 'CodigoCobertura';
    
    /*
@Description: Initial method
@Author: JANTON, Deloitte, jantona@deloitte.com
@Date: 06/09/2023
*/
    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    /*
@Description: invoke method from return initial method
@Author: JANTON, Deloitte, jantona@deloitte.com
@Date: 06/09/2023
*/
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        if(methodName == 'replace'){
            List<Object> arguments = (List<Object>) inputs.get('arguments');
            output.put('result', replace(arguments));
        }
        if(methodName == 'filterPlans'){
            filterPlans(inputs, output);
        }
        if(methodName == 'sortLifeRates'){
            List<Object> arguments = (List<Object>) inputs.get('arguments');
            output.put('result', sortLifeRates(arguments));
        }
        if(methodName == GLOSS_HONDING){
            String recordId = (String)inputs.get(TEXT_RECORD);
            createdJSONHolding(recordId);
        }
        if(methodName == GLOSS_CONTRACTOR){
            String recordId = (String)inputs.get(TEXT_RECORD);
            ZRH_ControllerGloss.saveJsonCalloutPDF(recordId);
        }
        return true;
    }
    
    /*
    @Description: Function helper
    @Author: JANTON, Deloitte, jantona@deloitte.com
    @Date: 06/09/2023
    */
    private String replace(List<Object> arguments){
        String result = '';
        try {
            String str = String.valueOf(arguments[0]);
            String target = String.valueOf(arguments[1]);
            String replacement = String.valueOf(arguments[2]);
            result = str.replaceAll(target, replacement);
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        return result;
    }

    
    /*
    @Description: Function helper to sort life rates
    @Author: ML, Deloitte, mlongg@deloitte.com
    @Date: 16/02/2024
    */
    private List<Object> sortLifeRates(List<Object> arguments){
        
        List<Object> result = new List<Object>();
        List<Map<String, Object>> rates = (List<Map<String, Object>>)arguments; 
        Map<Integer,Object> mapCodeToRate = new Map<Integer,Object>();
        Integer numbOfRates = rates.size();
        List<Integer> rateCodes = new List<Integer>();

        for (Object rate : rates) {
            Map<String,Object> rateObj = (Map<String,Object>)rate;
            String codigoCoberturaStr = (String) rateObj.get(COVERAGE_CODE);
            Integer codigoCoberturaInt = Integer.valueOf(codigoCoberturaStr);
            rateObj.put(COVERAGE_CODE, codigoCoberturaInt);
            mapCodeToRate.put((Integer)rateObj.get(COVERAGE_CODE), rateObj);
            rateCodes.add((Integer)rateObj.get(COVERAGE_CODE));
        }

        rateCodes.sort();

        for (Integer code : rateCodes) {
            Object rate = mapCodeToRate.get(code);
            Map<String,Object> rateObj = (Map<String,Object>)rate;
            String codigoCoberturaStr = rateObj.get(COVERAGE_CODE).toString();
            rateObj.put(COVERAGE_CODE, codigoCoberturaStr);
            result.add(rateObj);
        }

        System.debug('result: ' + result);
        return result;
    }
    
    /*
    @Description: Function helper
    @Author: ADEUS, Deloitte, adeusms@deloitte.com
    @Date: 02/10/2023
    */
    private void filterPlans(Map<String,Object> inputMap, Map<String,Object> outputMap){
        try {
            List<Map<String, Object>> filteredPlans = new List<Map<String, Object>>();
            
            String selectedPlans = String.valueOf(inputMap.get('PlanesSeleccionados'));
            
            List<String> selectedPlansList = selectedPlans.split(';');
            system.debug('esto son lo planes existentes'+ inputMap.get('PlanesExistentes'));
            List<String> usedPlans = new List<String>();
            if(inputMap.get('PlanesExistentes')!=''){
                List<Map<String, Object>> existingPlans = (List<Map<String, Object>>) inputMap.get('PlanesExistentes');
                system.debug('existingPlans'+existingPlans);
                
                for(Map<String,Object> existingPlan : existingPlans){
                    
                    String codigo = String.valueOf(existingPlan.get('Codigo'));
                    
                    if(selectedPlans.contains(codigo)){
                        filteredPlans.add(existingPlan);
                        
                        if(!usedPlans.contains(codigo)){
                            usedPlans.add(codigo);
                        }
                    }
                }
                
                
                
                
                if(usedPlans.size() < selectedPlansList.size()){
                    String notUsedPlans = '';
                    
                    for(String selectedPlan : selectedPlansList){
                        if(!usedPlans.contains(selectedPlan)){
                            notUsedPlans += selectedPlan;
                            notUsedPlans += ' ';
                        }
                    }
                    
                    outputMap.put('planError', true);
                    outputMap.put('planErrorMessage', 'No es posible crear la glosa, no tiene plan ' + notUsedPlans + 'configurado para el grupo de negocio o contratante');
                }
            }else{
                String notUsedPlansVacio = '';
                for(String selectedPlanVacio : selectedPlansList){
                    notUsedPlansVacio += selectedPlanVacio;
                    notUsedPlansVAcio += ' ';
                    
                }
                
                outputMap.put('planError', true);
                outputMap.put('planErrorMessage', 'No es posible crear la glosa, no tiene plan ' + notUsedPlansVAcio + 'configurado para el grupo de negocio o contratante'); 
            }
            
            outputMap.put('result', filteredPlans);
            
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
    }
    
    /*
    @Description: Browse all contracted quotes
    @Author: LEC, Deloitte, lcastanedad@deloitte.com
    @Date: 07/11/2023
    */
    public static void createdJSONHolding(String recordId){
        Quote quoteObj = new ZRH_QuotesSelector().selectById(recordId, ZRH_ControllerGloss.getFieldsObj(OBJECT_QUOTE));
        for(Quote item: new ZRH_QuotesSelector().selectByQuoteHolding(quoteObj.ZRH_CotizacionHolding__c)){
            ZRH_ControllerGloss.saveJsonCalloutPDF(item.Id);
        }
    }
}