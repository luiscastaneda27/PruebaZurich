/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 15/09/2023
Description  : Controller Class for PDF
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Luis Enrique Castañeda      LEC
Abdon Tejos O			    ATO
Josue Alejandro Aguilar     JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      LEC         15/09/2023		   	    Created Class
2.0      ATO         27/09/2023		   	    
3.0      JAA         20/10/2023		   	    Change from callout to Rest Connection
4.0      JAA         25/01/2024             Life Scolarship Rates & Net Total
********************************************************************************/
global without sharing class ZRH_QuotePDFController implements vlocity_ins.VlocityOpenInterface2, System.Callable {

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        15/09/2023  
    */
    private static final String QUOTE_ID = 'CotizacionId';
    private static final String QUOTE_LINE_ITEM_ID = 'IdProductoCotizacion';
    private static final String PLAN_TEXT = 'Planes';
    private static final String PLAN_QUOTES_DETAILS = 'PlanCotizacionDetalles';
    private static final String PLAN_QUOTES_DETAILS_CURRENT = 'RenovacionPlanVigenteDetalles';
    private static final String ZERO_VALUE = '0';
    private static final String LIFE_SCHOLARSHIP_PLAN= '501';
    private static final String ANNUAL_PREMIUM_UF = 'PrimaAnualUF';
    private static final String ANNUAL_PREMIUM_UF_CURRENT= 'PrimaAnualVigenteUF';
    private static final String ANNUAL_PREMIUM_SCHOLARSHIP = 'PrimaAnualEsc';
    private static final String ANNUAL_PREMIUM_SCHOLARSHIP_CURRENT = 'PrimaAnualVigenteEsc';
    private static final String ANNUALL_PREMIUM_UF = 'PrimaAnuallUF';
    private static final String TEXT_COVERAGE_NAME = 'NombreCobertura';
    private static final String TEXT_COVERAGE_NAME_SCHOLARSHIP = 'NombreCobEsc';
    private static final String TEXT_DESCRIPTION_LEVEL = 'DescripcionNivel';
    private static final String SECURED_DISTRIBUTION_TEXT = 'DistribucionAsegurado';
    private static final String MONTHLY_PREMIUM_UF = 'PrimaMensualUF';
    private static final String MONTHLY_PREMIUM_UF_CURRENT = 'PrimaMensualVigenteUF';
    private static final String MONTHLY_PREMIUM_SCHOLARSHIP = 'PrimaMensualEsc';
    private static final String MONTHLY_PREMIUM_SCHOLARSHIP_CURRENT = 'PrimaMensualVigenteEsc';
    private static final String MONTHLY_RATE = 'TasaMensual';
    private static final String MONTHLY_RATE_CURRENT = 'TasaMensualVigente';
    private static final String ANNUAL_RATE_SCHOLARSHIP = 'TasaAnualEsc'; 
    private static final String ANNUAL_RATE_SCHOLARSHIP_CURRENT = 'TasaAnualVigenteEsc';
    private static final String ANNUAL_RATE = 'TasaAnual'; 
    private static final String ANNUAL_RATE_CURRENT = 'TasaAnualVigente';
    private static final String MONTHLY_RATE_SCHOLARSHIP = 'TasaMensualEsc';
    private static final String MONTHLY_RATE_SCHOLARSHIP_CURRENT = 'TasaMensualVigenteEsc';
    private static final String INSURANCE_CAPITAL = 'CapitalAseguradoUF';
    private static final String NUMBER_INSURED = 'NumeroAsegurados';
    private static final String NUMBER_INSURED_SCHOLARSHIP ='NAseguradosEsc';
    private static final String CODE_COVERAGE = 'CodigoCobertura';
    private static final String NUMBER_OF_INSURED = 'CantidadAsegurados';
    private static final String INSURED_CAPITAL = 'CapitalAseguradoUF';
    private static final String INSURED_CAPITAL_SCHOLARSHIP ='CapAsegEsc';
    private static final String MONTHLY_NET_PREMIUM = 'PrimaNetaMensualUF';
    private static final String TEXT_CODE_PLAN = 'CodigoPlan';
    private static final String TEXT_CODE_LEVEL = 'CodigoNivel';
    private static final String INDIVIDUAL_PREMIUM = 'PrimaIndividual';
    private static final String PP_HEALTH_RATE = 'TarifaSaludPP';
    private static final String PV_HEALTH_RATE = 'TarifaSaludPV';
    private static final String NT_HEALTH_RATE = 'TarifaSaludNT';
    private static final String DISC_HEALTH_RATE = 'DescTarifaSalud';
    private static final String LIFE_RATE = 'TarifaVida';
    private static final String LIFE_SCHOLARSHIP_RATE = 'TarifaEscolaridad';
    private static final String HEALTH_RATE = 'TarifaSalud';
    private static final String PARTICULAR_CONDITIONS = 'CondicionadosParticulares';
    private static final String ENVIRONMENT = 'Ambiente';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
	private static final String INTEGRATION_ROUTE = 'ZRH_GeneracionPDF';
    private static final String LEVEL_SCHOLARSHIP_LIST = 'Escolaridad'; 
    private static final String TEXT_LEVEL_SCHOLARSHIP = 'Niveles';
    private static final String TEXT_NET_TOTAL_PLAN = 'TotalNeto';
    private static final String TEXT_NET_TOTAL_PLAN_CURRENT = 'RenovacionPlanVigenteTotalNeto';
    private static final String TEXT_GROSS_TOTAL_PLAN = 'TotalBruto';
    private static final String TEXT_GROSS_TOTAL_PLAN_CURRENT = 'RenovacionPlanVigenteTotalBruto';
    private static final String TEXT_IVA = 'Iva';
    private static final String TEXT_IVA_CURRENT = 'RenovacionPlanVigenteIva';
    
    private static final Decimal VALUE_IVA = Decimal.valueOf(Label.ZRH_ValorIVA);
    private static final String TEXT_TOTAL_RATES = 'TOTAL';
    private static final Set<String> HEALTH_PLANS_LIST;
    private static final Set<String> LIFE_PLANS_LIST;
    private static final String QUOTE_TYPE = 'TipoCotizacion';
    private static final Set<String> COVERAGE_WITHOUT_IVA;
    
    
    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    static {
        HEALTH_PLANS_LIST = setHealthPlanCodes();
        LIFE_PLANS_LIST = setLifePlanCodes();
        COVERAGE_WITHOUT_IVA = new Set<String>{'1','3'};
    }  

    
    // Default constructor
    public ZRH_QuotePDFController() {
        // The default constructor can be left empty if there's no specific initialization needed.
    }

    /**
    *  @Description: Method to handle the remote action call to generate PDF
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        20/10/2023
    */
    private void executeGeneratePDF(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        try {

            input = orderCoverages(input, output);
            String body = JSON.serialize(input);
            system.debug('Body: '+ body);
            // Call Service
            HttpResponse res = call(body);

            Map<String, Object> response = new Map<String, Object>{
            'errorCode' => res.getStatusCode(),
            'error' => res.getStatus(),
            'responseBody' => res.getBody()
        	};
            
            output.put('response', response);

        } catch (Exception e) {
            input = orderCoverages(input, output);
            String body = JSON.serialize(input);
            system.debug('este es el body'+ body);
            // Handle any exceptions
            output.put('error', e.getMessage());
            System.debug('Error in executeGeneratePDF: ' + e.getMessage() + ' --- '+e.getLineNumber());
        }
    }

    // Implementation of invokeMethod for vlocity_ins.VlocityOpenInterface2
    global Object invokeMethod(String methodName, Map<String, Object> input,
                               Map<String, Object> output, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName == 'executeGeneratePDF') {
                executeGeneratePDF(input, output, options);
            } else {
                output.put('error', 'Method not found: ' + methodName);
                result = false;
            }
        } catch (Exception e) {
            output.put('error', e.getMessage());
            System.debug('input desde invokeMethod: ' + input);
            System.debug('Error in invokeMethod: ' + e.getMessage() + ': Línea: '+e.getLineNumber());
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
    
    public static Map<String,Object> orderCoverages(Map<String,Object> input, Map<String,Object> output){
        input = validateListPlans(input);
        String jsonString = JSON.serialize(input);
        Set<ID> setIdsQuote = new Set<ID>();
        Map<String,Object> data = (Map<String,Object>)((Object)System.JSON.deserializeUntyped(jsonString));
        List<ZRH_JSONGlossTables.CondicionadosParticulares> glossList = new List<ZRH_JSONGlossTables.CondicionadosParticulares>();
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        
        String quoteId = (String)data.get(QUOTE_ID);
        Boolean flagServ = false;
        String renov = 'N';
        Boolean isCurrent = false;
        for(Quote item: new ZRH_QuotesSelector().selectByQuoteHolding(quoteId)){
            isCurrent = item.ZRH_CotizacionHolding__r.ZRH_RenovacionFlag__c;
            renov = isCurrent ? 'R' : renov;
            
            setIdsQuote.add(item.Id);
            flagServ = String.isBlank(item.ZRH_AtributosCondicionadosParticulares__c) ? true : flagServ;
            if(String.isNotBlank(item.ZRH_AtributosCondicionadosParticulares__c)){
                List<ZRH_JSONGlossTables.CondicionadosParticulares> glossforQuote = (List<ZRH_JSONGlossTables.CondicionadosParticulares>) JSON.deserialize(item.ZRH_AtributosCondicionadosParticulares__c, List<ZRH_JSONGlossTables.CondicionadosParticulares>.class);
                for(ZRH_JSONGlossTables.CondicionadosParticulares cp: glossforQuote){
                    glossList.add(cp);
                }
            }
        }
        if(flagServ){
            glossList = new ZRH_ConditionedTables().mapping(setIdsQuote).CondicionadosParticulares;
        }
        data.put(PARTICULAR_CONDITIONS, glossList);
        data.put(ENVIRONMENT, service.ZRH_Ambiente__c);
        data.put(QUOTE_TYPE, renov);
        List<String> qliIdsList = new List<String>();
        for(Object p: (List<Object>)data.get(PLAN_TEXT)){
            Map<String,Object> plan = (Map<String,Object>)p;
            qliIdsList.add((String)plan.get(QUOTE_LINE_ITEM_ID));
        }
        Map<Id, QuoteLineItem> mapQLI = new Map<Id, QuoteLineItem>(new ZRH_QuoteLineItemsSelector().selectByIdsList(qliIdsList));
        
        for(Object p: (List<Object>)data.get(PLAN_TEXT)){
            Map<String,Object> plan = (Map<String,Object>)p;
            String IdProductoCotizacion = (String)plan.get(QUOTE_LINE_ITEM_ID);
            String jsonTarifa = mapQLI.containsKey(IdProductoCotizacion) ? mapQLI.get(IdProductoCotizacion).ZRH_Tarifa__c : null;
            if(String.IsNotBlank(jsonTarifa)){
                List<Object> listObj = new List<Object>();
                List<Object> listObjCurrent = new List<Object>();
                String planCode = (String)plan.get(TEXT_CODE_PLAN);
                Map<String,Object> objT = (Map<String,Object>)((Object)System.JSON.deserializeUntyped(jsonTarifa));
                if(HEALTH_PLANS_LIST.contains(planCode)){
                    for(Object taf: (List<Object>)objT.get(HEALTH_RATE)){
                        Map<String,Object> tafMap = (Map<String,Object>)taf;
                        Map<String,Object> resp = (Map<String,Object>)((Object)System.JSON.deserializeUntyped('{}'));
                        Map<String,Object> respCurrent = (Map<String,Object>)((Object)System.JSON.deserializeUntyped('{}'));
                        if(tafMap.get(NT_HEALTH_RATE) != null && tafMap.get(DISC_HEALTH_RATE) != TEXT_TOTAL_RATES){
                            resp.put(SECURED_DISTRIBUTION_TEXT, tafMap.get(DISC_HEALTH_RATE) != null ? tafMap.get(DISC_HEALTH_RATE) : ZERO_VALUE);                            
                            respCurrent.put(SECURED_DISTRIBUTION_TEXT, tafMap.get(DISC_HEALTH_RATE) != null ? tafMap.get(DISC_HEALTH_RATE) : ZERO_VALUE);
                            
                            resp.put(NUMBER_OF_INSURED, tafMap.get(NT_HEALTH_RATE) != null ? tafMap.get(NT_HEALTH_RATE) : ZERO_VALUE);
                            respCurrent.put(NUMBER_OF_INSURED, tafMap.get(NT_HEALTH_RATE) != null ? tafMap.get(NT_HEALTH_RATE) : ZERO_VALUE);
                            
                            resp.put(INDIVIDUAL_PREMIUM, tafMap.get(PP_HEALTH_RATE) != null ? tafMap.get(PP_HEALTH_RATE): ZERO_VALUE);
                            respCurrent.put(INDIVIDUAL_PREMIUM, tafMap.get(PV_HEALTH_RATE) != null ? tafMap.get(PV_HEALTH_RATE): ZERO_VALUE);
                            Decimal valuePP = 0;
                            Decimal valuePV = 0;
                            try{
                                valuePP = (Integer) tafMap.get(NT_HEALTH_RATE) * (tafMap.get(PP_HEALTH_RATE) != null ? (Decimal) tafMap.get(PP_HEALTH_RATE) : 0 );
                            }catch(exception e){
                                valuePP = (Integer) tafMap.get(NT_HEALTH_RATE) * (tafMap.get(PP_HEALTH_RATE) != null ? (Integer) tafMap.get(PP_HEALTH_RATE) : 0 );
                            }
                            try{
                                valuePV = (Integer) tafMap.get(NT_HEALTH_RATE) * (tafMap.get(PV_HEALTH_RATE) != null ? (Decimal) tafMap.get(PV_HEALTH_RATE) : 0 );
                            }catch(exception e){
                                valuePV = (Integer) tafMap.get(NT_HEALTH_RATE) * (tafMap.get(PV_HEALTH_RATE) != null ? (Integer) tafMap.get(PV_HEALTH_RATE) : 0 );
                            }
                            resp.put(MONTHLY_NET_PREMIUM, valuePP);
                            respCurrent.put(MONTHLY_NET_PREMIUM, valuePV);
                            
                            listObj.add(resp);
                            listObjCurrent.add(respCurrent);
                        }
                        if(tafMap.get(DISC_HEALTH_RATE) == TEXT_TOTAL_RATES){
                            Decimal totalN = (Decimal)tafMap.get(PP_HEALTH_RATE);
                            Decimal iva = totalN * VALUE_IVA;
                            Decimal totalB = totalN + iva;
                            plan.put(TEXT_NET_TOTAL_PLAN, totalN);
                            plan.put(TEXT_GROSS_TOTAL_PLAN, totalB);
                            plan.put(TEXT_IVA, iva);
                            
                            totalN = (Decimal)tafMap.get(PV_HEALTH_RATE);
                            iva = totalN * VALUE_IVA;
                            totalB = totalN + iva;
                            plan.put(TEXT_NET_TOTAL_PLAN_CURRENT, totalN);
                            plan.put(TEXT_GROSS_TOTAL_PLAN_CURRENT, totalB);
                            plan.put(TEXT_IVA_CURRENT, iva);
                        }
                    }
                        
                }else if(LIFE_PLANS_LIST.contains(planCode)){
                    Decimal sinIva = 0;
                    Decimal sinIvaVig = 0;
                    for(Object taf: (List<Object>)objT.get(LIFE_RATE)){
                        Map<String,Object> tafMap = (Map<String,Object>)taf;
                        Map<String,Object> resp = (Map<String,Object>)((Object)System.JSON.deserializeUntyped('{}')); 
                        Map<String,Object> respCurrent = (Map<String,Object>)((Object)System.JSON.deserializeUntyped('{}')); 
                        if(/*tafMap.get(NUMBER_INSURED) != null &&*/ tafMap.get(TEXT_COVERAGE_NAME) != TEXT_TOTAL_RATES){
                            resp.put(TEXT_COVERAGE_NAME, tafMap.get(TEXT_COVERAGE_NAME));
                            respCurrent.put(TEXT_COVERAGE_NAME, tafMap.get(TEXT_COVERAGE_NAME));
                            
                            //resp.put(NUMBER_INSURED, tafMap.get(NUMBER_INSURED) != null ? tafMap.get(NUMBER_INSURED): ZERO_VALUE);
                            resp.put(NUMBER_OF_INSURED, tafMap.get(NUMBER_INSURED) != null ? tafMap.get(NUMBER_INSURED): ZERO_VALUE);
                            respCurrent.put(NUMBER_OF_INSURED, tafMap.get(NUMBER_INSURED) != null ? tafMap.get(NUMBER_INSURED): ZERO_VALUE);
                                
                            resp.put(INSURANCE_CAPITAL, tafMap.get(INSURED_CAPITAL) != null ? tafMap.get(INSURED_CAPITAL): ZERO_VALUE);
                            respCurrent.put(INSURANCE_CAPITAL, tafMap.get(INSURED_CAPITAL) != null ? tafMap.get(INSURED_CAPITAL): ZERO_VALUE);
                            
                            resp.put(MONTHLY_RATE, tafMap.get(MONTHLY_RATE) != null ? tafMap.get(MONTHLY_RATE): ZERO_VALUE);
                            respCurrent.put(MONTHLY_RATE, tafMap.get(MONTHLY_RATE_CURRENT) != null ? tafMap.get(MONTHLY_RATE_CURRENT): ZERO_VALUE);
                            
                            //resp.put(MONTHLY_PREMIUM_UF, tafMap.get(MONTHLY_PREMIUM_UF) != null ? tafMap.get(MONTHLY_PREMIUM_UF): ZERO_VALUE);
                            resp.put(MONTHLY_NET_PREMIUM, tafMap.get(MONTHLY_PREMIUM_UF) != null ? tafMap.get(MONTHLY_PREMIUM_UF): ZERO_VALUE);
                            respCurrent.put(MONTHLY_NET_PREMIUM, tafMap.get(MONTHLY_PREMIUM_UF_CURRENT) != null ? tafMap.get(MONTHLY_PREMIUM_UF_CURRENT): ZERO_VALUE);
                                
                            //resp.put(ANNUAL_PREMIUM_UF, tafMap.get(ANNUAL_PREMIUM_UF) != null ?tafMap.get(ANNUAL_PREMIUM_UF) : ZERO_VALUE);
                            resp.put(ANNUALL_PREMIUM_UF, tafMap.get(ANNUAL_PREMIUM_UF) != null ?tafMap.get(ANNUAL_PREMIUM_UF) : ZERO_VALUE);
                            respCurrent.put(ANNUALL_PREMIUM_UF, tafMap.get(ANNUAL_PREMIUM_UF_CURRENT) != null ?tafMap.get(ANNUAL_PREMIUM_UF_CURRENT) : ZERO_VALUE);
                            
                            resp.put(ANNUAL_RATE, tafMap.get(ANNUAL_RATE) != null ?tafMap.get(ANNUAL_RATE) : ZERO_VALUE);
                            respCurrent.put(ANNUAL_RATE, tafMap.get(ANNUAL_RATE_CURRENT) != null ?tafMap.get(ANNUAL_RATE_CURRENT) : ZERO_VALUE);
                            
                            listObj.add(resp);
                            listObjCurrent.add(respCurrent);
                            sinIva += COVERAGE_WITHOUT_IVA.contains((String)tafMap.get(CODE_COVERAGE)) ? (Decimal) resp.get(MONTHLY_NET_PREMIUM) : 0;
                            sinIvaVig += COVERAGE_WITHOUT_IVA.contains((String)tafMap.get(CODE_COVERAGE)) ? (Decimal) respCurrent.get(MONTHLY_NET_PREMIUM) : 0;
                        }
                        if(tafMap.get(TEXT_COVERAGE_NAME) == TEXT_TOTAL_RATES){
                            Decimal totalN = (Decimal)tafMap.get(MONTHLY_PREMIUM_UF);
                            Decimal iva = (totalN - sinIva) * VALUE_IVA;
                            Decimal totalB = totalN + iva;
                            plan.put(TEXT_NET_TOTAL_PLAN, totalN);
                            plan.put(TEXT_GROSS_TOTAL_PLAN, totalB);
                            plan.put(TEXT_IVA, iva);
                            
                            totalN = (Decimal)tafMap.get(MONTHLY_PREMIUM_UF_CURRENT);
                            iva = (totalN - sinIvaVig) * VALUE_IVA;
                            totalB = totalN + iva;
                            plan.put(TEXT_NET_TOTAL_PLAN_CURRENT, totalN);
                            plan.put(TEXT_GROSS_TOTAL_PLAN_CURRENT, totalB);
                            plan.put(TEXT_IVA_CURRENT, iva);
                        }
                    }
                }
                else if(planCode == LIFE_SCHOLARSHIP_PLAN){
                    objWrapper response = mapRatesScholarShip((List<Object>)objT.get(LIFE_SCHOLARSHIP_RATE));
                    listObj = response.listObj;
                    listObjCurrent = response.listObjCurrent;
                    plan.put(TEXT_NET_TOTAL_PLAN, response.TotalNeto);
                    plan.put(TEXT_GROSS_TOTAL_PLAN, response.TotalBruto);
                    plan.put(TEXT_IVA, response.iva);
                    
                    plan.put(TEXT_NET_TOTAL_PLAN_CURRENT, response.RenovacionPlanVigenteTotalNeto);
                    plan.put(TEXT_GROSS_TOTAL_PLAN_CURRENT, response.RenovacionPlanVigenteTotalBruto);
                    plan.put(TEXT_IVA_CURRENT, response.RenovacionPlanVigenteiva);
                }
                plan.put(PLAN_QUOTES_DETAILS, listObj);
                if(isCurrent){
                    plan.put(PLAN_QUOTES_DETAILS_CURRENT, listObjCurrent) ;
                }else{
                    plan.put(PLAN_QUOTES_DETAILS_CURRENT, null);
                    plan.put(TEXT_NET_TOTAL_PLAN_CURRENT, 0);
                    plan.put(TEXT_GROSS_TOTAL_PLAN_CURRENT, 0);
                    plan.put(TEXT_IVA_CURRENT, 0);
                }
            }else {
                plan.put(PLAN_QUOTES_DETAILS, new List<Object>());
            }
            
        }
        return data;
    }

    /**
    *  @Description: Generate the Rates SCHOLARSHIP  table
    *  @Autor:       Josue Aguilar, jaguilars@deloitte.com
    *  @Date:        4/1/2024
    */    
    public static objWrapper mapRatesScholarShip(List<Object> ratesList) {
        objWrapper response = new objWrapper();
        List<Object> listObj = new List<Object>();
        List<Object> listObjLevel = new List<Object>();
        
        List<Object> listObjCurrent = new List<Object>();
        List<Object> listObjLevelCurrent = new List<Object>();
        String numAse = 'EscNumAsegurados';
        String capAse = 'EscCapitalAseguradoUF';
        String nivEscol = 'EscNivelEscolaridad';
        String tasaAnuEsc = 'EscTasaAnual';
        String tasaMens = 'EscTasaMensual';
        String primaAnu = 'EscPrimaAnuallUF';
        String primaMens = 'EscPrimaNetaMensualUF';
        String capiAse = 'CapitalAseguradosUF';
        String tasaAnu = 'TasaAnual';
        String primaAnuUf = 'PrimaAnuallAF';
        
        Decimal totalN = 0;
        Decimal iva = 0;
        Decimal totalB = 0;
        Decimal sinIva = 0;
        Decimal totalNVig = 0;
        Decimal ivaVig = 0;
        Decimal totalBVig = 0;
        Decimal sinIvaVig = 0;
        
        for(Object taf: ratesList){
            Map<String,Object> tafMap = (Map<String,Object>)taf;
            
            Map<String,Object> resp = (Map<String,Object>)((Object)System.JSON.deserializeUntyped('{}'));
            Map<String,Object> respCurrent = (Map<String,Object>)((Object)System.JSON.deserializeUntyped('{}'));
            
            if(tafMap.get(CODE_COVERAGE) != null){
                resp.put(CODE_COVERAGE, tafMap.get(CODE_COVERAGE));
                resp.put(TEXT_COVERAGE_NAME, tafMap.get(TEXT_COVERAGE_NAME_SCHOLARSHIP));
                respCurrent.put(CODE_COVERAGE, tafMap.get(CODE_COVERAGE));
                respCurrent.put(TEXT_COVERAGE_NAME, tafMap.get(TEXT_COVERAGE_NAME_SCHOLARSHIP));
                Decimal CantidadAsegurados = 0;
                Decimal CapitalAseguradosUF = 0;
                Decimal TasaMensual = 0;
                Decimal PrimaNetaMensualUF = 0;
                Decimal TasaAnual = 0;
                Decimal PrimaAnuallAF = 0;
                
                //Decimal CantidadAseguradosCurr = 0;
                Decimal CapitalAseguradosUFCurr = 0;
                Decimal TasaMensualCurr = 0;
                Decimal PrimaNetaMensualUFCurr = 0;
                Decimal TasaAnualCurr = 0;
                Decimal PrimaAnuallAFCurr = 0;
                //system.debug('CODE COVERAGE:' + tafMap.get(CODE_COVERAGE));
                listObjLevel = new List<Object>();
                for (Object o : (List<Object>)tafMap.get(TEXT_LEVEL_SCHOLARSHIP)) {
                    Map<String,Object> dataNivel = (Map<String,Object>)o;
                    Map<String,Object> respLevel = (Map<String,Object>)(Object)System.JSON.deserializeUntyped('{}');
                    Map<String,Object> respLevelCurrent = (Map<String,Object>)(Object)System.JSON.deserializeUntyped('{}');
                    if(dataNivel.get(TEXT_DESCRIPTION_LEVEL) != TEXT_TOTAL_RATES){
                        System.debug(JSON.serialize(dataNivel));
                        respLevel.put(numAse, dataNivel.get(NUMBER_INSURED_SCHOLARSHIP) != null ? dataNivel.get(NUMBER_INSURED_SCHOLARSHIP) : ZERO_VALUE);
                        respLevelCurrent.put(numAse, dataNivel.get(NUMBER_INSURED_SCHOLARSHIP) != null ? dataNivel.get(NUMBER_INSURED_SCHOLARSHIP) : ZERO_VALUE);
                        CantidadAsegurados += convertToDecimal(dataNivel.get(NUMBER_INSURED_SCHOLARSHIP));// != null ? (Decimal) dataNivel.get(NUMBER_INSURED_SCHOLARSHIP) : 0;
                        
                        respLevel.put(capAse, dataNivel.get(INSURED_CAPITAL_SCHOLARSHIP)!= null ? dataNivel.get(INSURED_CAPITAL_SCHOLARSHIP): ZERO_VALUE);
                        respLevelCurrent.put(capAse, dataNivel.get(INSURED_CAPITAL_SCHOLARSHIP)!= null ? dataNivel.get(INSURED_CAPITAL_SCHOLARSHIP): ZERO_VALUE);
                        CapitalAseguradosUF += convertToDecimal(dataNivel.get(INSURED_CAPITAL_SCHOLARSHIP));// dataNivel.get(INSURED_CAPITAL_SCHOLARSHIP) != null ? (Decimal) dataNivel.get(INSURED_CAPITAL_SCHOLARSHIP) : 0;
                        
                        respLevel.put(nivEscol,dataNivel.get(TEXT_DESCRIPTION_LEVEL));
                        respLevelCurrent.put(nivEscol,dataNivel.get(TEXT_DESCRIPTION_LEVEL));
                        
                        respLevel.put(tasaAnuEsc, dataNivel.get(ANNUAL_PREMIUM_SCHOLARSHIP)!= null ? dataNivel.get(ANNUAL_PREMIUM_SCHOLARSHIP): ZERO_VALUE);
                        respLevelCurrent.put(tasaAnuEsc, dataNivel.get(ANNUAL_PREMIUM_SCHOLARSHIP_CURRENT)!= null ? dataNivel.get(ANNUAL_PREMIUM_SCHOLARSHIP_CURRENT): ZERO_VALUE);
                        TasaAnual += convertToDecimal(dataNivel.get(ANNUAL_PREMIUM_SCHOLARSHIP));
                        TasaAnualCurr += convertToDecimal(respLevelCurrent.get(tasaAnuEsc));
                        
                        respLevel.put(tasaMens, dataNivel.get(MONTHLY_PREMIUM_SCHOLARSHIP)!= null ? dataNivel.get(MONTHLY_PREMIUM_SCHOLARSHIP): ZERO_VALUE);
                        respLevelCurrent.put(tasaMens, dataNivel.get(MONTHLY_PREMIUM_SCHOLARSHIP_CURRENT)!= null ? dataNivel.get(MONTHLY_PREMIUM_SCHOLARSHIP_CURRENT): ZERO_VALUE);
                        TasaMensual += convertToDecimal(dataNivel.get(MONTHLY_PREMIUM_SCHOLARSHIP));
                        TasaMensualCurr += convertToDecimal(respLevelCurrent.get(tasaMens));
                        
                        respLevel.put(primaAnu, dataNivel.get(ANNUAL_RATE_SCHOLARSHIP)!= null ? dataNivel.get(ANNUAL_RATE_SCHOLARSHIP): ZERO_VALUE);
                        respLevelCurrent.put(primaAnu, dataNivel.get(ANNUAL_RATE_SCHOLARSHIP_CURRENT)!= null ? dataNivel.get(ANNUAL_RATE_SCHOLARSHIP_CURRENT): ZERO_VALUE);
                        PrimaAnuallAF += convertToDecimal(dataNivel.get(ANNUAL_RATE_SCHOLARSHIP));
                        PrimaAnuallAFCurr += convertToDecimal(respLevelCurrent.get(primaAnu));
                        
                        respLevel.put(primaMens, dataNivel.get(MONTHLY_RATE_SCHOLARSHIP)!= null ? dataNivel.get(MONTHLY_RATE_SCHOLARSHIP): ZERO_VALUE);
                        respLevelCurrent.put(primaMens, dataNivel.get(MONTHLY_RATE_SCHOLARSHIP_CURRENT) != null ? dataNivel.get(MONTHLY_RATE_SCHOLARSHIP_CURRENT): ZERO_VALUE);
                        PrimaNetaMensualUF += convertToDecimal(dataNivel.get(MONTHLY_RATE_SCHOLARSHIP));
                        System.debug(respLevelCurrent.get(primaMens));
                        PrimaNetaMensualUFCurr += convertToDecimal(respLevelCurrent.get(primaMens));
                        
                        sinIva += COVERAGE_WITHOUT_IVA.contains((String)tafMap.get(CODE_COVERAGE)) ? convertToDecimal(respLevel.get(tasaMens)) : 0;
                     sinIvaVig += COVERAGE_WITHOUT_IVA.contains((String)tafMap.get(CODE_COVERAGE)) ? convertToDecimal(respLevelCurrent.get(tasaMens)) : 0;
                        
                        listObjLevel.add(respLevel);
                        listObjLevelCurrent.add(respLevelCurrent);
                    }else{
                        totalN += (Decimal)dataNivel.get(MONTHLY_PREMIUM_SCHOLARSHIP);
                        iva += (totalN - sinIva) * VALUE_IVA;
                        totalB += totalN + iva;
                        sinIva = 0;
                        
                        totalNVig += dataNivel.get(MONTHLY_PREMIUM_SCHOLARSHIP_CURRENT) != null ? convertToDecimal(dataNivel.get(MONTHLY_PREMIUM_SCHOLARSHIP_CURRENT)) : 0;
                        ivaVig += (totalNVig - sinIvaVig) * VALUE_IVA;
                        totalBVig += totalNVig + ivaVig;
                        sinIvaVig = 0;
                    }
                }
                
                resp.put(NUMBER_OF_INSURED, CantidadAsegurados);
                resp.put(capiAse, CapitalAseguradosUF);
                resp.put(MONTHLY_RATE, TasaMensual);
                resp.put(MONTHLY_NET_PREMIUM, PrimaNetaMensualUF);
                resp.put(tasaAnu, TasaAnual);
                resp.put(primaAnuUf, PrimaAnuallAF);
                resp.put(LEVEL_SCHOLARSHIP_LIST,listObjLevel);
                listObj.add(resp);
                
                respCurrent.put(NUMBER_OF_INSURED, CantidadAsegurados);
                respCurrent.put(capiAse, CapitalAseguradosUF);
                respCurrent.put(MONTHLY_RATE, TasaMensualCurr);
                respCurrent.put(MONTHLY_NET_PREMIUM, PrimaNetaMensualUFCurr);
                respCurrent.put(tasaAnu, TasaAnualCurr);
                respCurrent.put(primaAnuUf, PrimaAnuallAFCurr);
                respCurrent.put(LEVEL_SCHOLARSHIP_LIST,listObjLevelCurrent);
                listObjCurrent.add(respCurrent);
            }
        }
        response.listObj = listObj;
        response.listObjCurrent = listObjCurrent;
        response.TotalBruto = totalB;
        response.TotalNeto = totalN;
        response.Iva = iva;
        response.RenovacionPlanVigenteTotalBruto = totalBVig;
        response.RenovacionPlanVigenteTotalNeto = totalNVig;
        response.RenovacionPlanVigenteIva = ivaVig;
        
        
        return response;
    }
    
    public static Map<String,Object> validateListPlans(Map<String,Object> input){
        List<Object> planList = new List<Object>();
        try{
            planList = (List<Object>)input.get(PLAN_TEXT);
        }catch(Exception e){
            planList.add((Object)input.get(PLAN_TEXT));
        }
        input.put(PLAN_TEXT, planList);
        return input;
    }
    
    /**
    *  @Description: Service Call
    *  @Author:      Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        20/10/2023  
    */
    private HttpResponse call(String body) {
        ZRH_RestConnection objClass = new ZRH_RestConnection(INTEGRATION_BASE, INTEGRATION_ROUTE);
        return objClass.callService(body);
    }
    
    /**
    *  @Description: Filling of the static target variable
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public static Set<String> setHealthPlanCodes() {
        return new Set<String>{'600','601','602','603','604','605','606'};
    }
    
    /**
    *  @Description: Filling of the static target variable
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public static Set<String> setLifePlanCodes() {
        return new Set<String>{'500','502','700'};
    }
    
    /**
    *  @Description: Convert ti Decimal
    *  @Author:      Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        2/1/2024  
    */
    public static Decimal convertToDecimal(Object obj){
        Decimal response = 0.0;
        try{
            return (Decimal) obj;
        }catch(exception ex){
            try{
                return Decimal.valueOf((String) obj);
            }catch(exception e){
                return response;
            }
        }
    }
    
    public class objWrapper{
        public List<Object> listObj;
        public List<Object> listObjCurrent;
        public Decimal TotalBruto;
        public Decimal TotalNeto;
        public Decimal Iva;
        public Decimal RenovacionPlanVigenteTotalBruto;
        public Decimal RenovacionPlanVigenteTotalNeto;
        public Decimal RenovacionPlanVigenteIva;
    }
}