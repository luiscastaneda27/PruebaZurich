/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 1/12/2023
Description  : class for clon plan
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			1/12/2023		initial version
********************************************************************************/
global without sharing class ZRH_ClonePlanController implements vlocity_ins.VlocityOpenInterface2{

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        1/12/2023 
    */
    private static final String MAP_INPUT = 'input';
    private static final String MAP_OUTPUT = 'output';
    private static final String MAP_OPTIONS = 'options';
    private static final String TEXT_QUOTE_LINE_ITEM_ID = 'quoteLineItemId';
    private static final String TEXT_QUOTE_ID = 'quoteId';
    private static final String TEXT_QUOTE_LINE_ITEM = 'QuoteLineItem';
    private static final String METHOD_NAME_CLON_PLAN = 'clonePlan';
    
    global Object invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        if (METHOD_NAME_CLON_PLAN == methodName) {
            clonPlan(input);
        }
        return true;
    }
    
    // Implementation of call method for System.Callable
    global Object call(String methodName, Map<String, Object> params) {
        Map<String, Object> input = (Map<String, Object>) params.get(MAP_INPUT);
        Map<String, Object> output = (Map<String, Object>) params.get(MAP_OUTPUT);
        Map<String, Object> options = (Map<String, Object>) params.get(MAP_OPTIONS);
        return invokeMethod(methodName, input, output, options);
    }
    
    public static void clonPlan(Map<String, Object> input){
        String quoteLineItemId = (String) input.get(TEXT_QUOTE_LINE_ITEM_ID);
        String quoteId = (String) input.get(TEXT_QUOTE_ID);
        List<String> fieldList = getFieldsObj(TEXT_QUOTE_LINE_ITEM);
        fieldList.add('Quote.Name');
        fieldList.add('Quote.Account.Name');
        List<ZRH_Glosas__c> listGloss = new ZRH_GlosasSelector().selectByQliIdOnly(quotelineItemId);
        List<vlocity_ins__QuoteLineItemGroupClass__c> rollList = new ZRH_QuoteLineItemGroupClassSelector().selectByQuoteLineItems(quotelineItemId);
        List<QuoteLineitem> qliList = new ZRH_QuoteLineItemsSelector().selectByIdAndCoverages(quotelineItemId, fieldList);
        QuoteLineitem plan = qliList?.get(0).clone(true);
        QuoteLineitem planold = qliList?.get(0).clone(true);
        qliList?.remove(0);
        plan.Id = null;
        plan.ZRH_Folio__c = null;
        plan.QuoteId = quoteId;
        insert plan;
        
        Map<Id, QuoteLineitem> mapCvr = mapCoverages(plan, qliList);
        insert mapCvr.values();
        
        listGloss = mapGloss(plan, listGloss);
        insert listGloss;
        
        rollList = mapRoles(plan, rollList);
        insert rollList;
        
        plan = new ZRH_QuoteLineItemsSelector().selectByIdAndCoverages(plan.Id, fieldList)[0];
        
        plan = replaceCvr(plan, mapCvr);
        plan.ZRH_ClonePlan__c = 'Este Plan ' + plan.LineNumber + ' fue clonado de la cotización ' + planold.Quote.Name + ' y ' + planold.Quote.Account.Name;
        update plan;
    }
    
    /**
    *  @Description: map coverages.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        1/12/2023
    */
    public static Map<Id, QuoteLineitem> mapCoverages(QuoteLineitem plan, List<QuoteLineitem> qliList){
        Map<Id, QuoteLineitem> mapCvr = new Map<Id, QuoteLineitem>();
        for(QuoteLineitem cvr : qliList){
            QuoteLineitem item = cvr.clone(true);
            item.Id = null;
            item.QuoteId = plan.QuoteId;
            item.vlocity_ins__SubParentItemId__c = plan.Id;
            item.vlocity_ins__ParentItemId__c = plan.Id;
            item.vlocity_ins__ParentItemId2__c = plan.Id;
            item.ZRH_Folio__c = null;
            mapCvr.put(cvr.Id, item);
        }
        return mapCvr;
    }
    
    /**
    *  @Description: map gloss.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        1/12/2023
    */
    public static List<ZRH_Glosas__c> mapGloss(QuoteLineitem plan, List<ZRH_Glosas__c> glossList){
        for(ZRH_Glosas__c g : glossList){
            g.ZRH_Quote__c = plan.QuoteId;
            g.ZRH_QuoteLineItem__c = plan.Id;
            g.Id = null;
        }
        return glossList;
    }
    
    /**
    *  @Description: Map rolles.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        1/12/2023
    */
    public static List<vlocity_ins__QuoteLineItemGroupClass__c> mapRoles(QuoteLineitem plan, List<vlocity_ins__QuoteLineItemGroupClass__c> listRoll){
        List<vlocity_ins__QuoteLineItemGroupClass__c> listRecords = new List<vlocity_ins__QuoteLineItemGroupClass__c>();
        Integer i = 0;
        for(vlocity_ins__QuoteLineItemGroupClass__c r : listRoll){
            listRecords.add(new vlocity_ins__QuoteLineItemGroupClass__c(vlocity_ins__GroupClassId__c  = r.vlocity_ins__GroupClassId__c, vlocity_ins__QuoteLineItemId__c = plan.Id, vlocity_ins__QuoteId__c = plan.QuoteId,  Name = i + ' ' + Plan.Id));
            i++;
        }
        return listRecords;
    }
    
    /**
    *  @Description: replace coverages.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        1/12/2023
    */
    public static QuoteLineitem replaceCvr(QuoteLineItem plan,  Map<Id, QuoteLineitem> mapCvr){
        Map<String, String> mapFields = getFieldsObjMap(String.valueof(QuoteLineitem.sObjectType));
        for(String field: mapFields.keySet()){
            if(plan.get(field) != null && mapFields.get(field) == 'TEXTAREA'){
                String value = String.valueOf(plan.get(field));
                for(Id qli: mapCvr.keySet()){
                    String cvrId = mapCvr.get(qli).Id;
                    value = value.replace(qli, cvrId);
                }
                plan.put(field, value); 
            }      
        }        
        return plan;
    }
    
    /**
    *  @Description: Gets all fields of an object.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        1/12/2023
    */
    public static List<String> getFieldsObj(String objectName){
        List<String> fieldList = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldList.add(dfield.getName());
        }
        return fieldList;
    }
    
    /**
    *  @Description: Gets all fields and type of an object.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        1/12/2023
    */
    public static Map<String, String> getFieldsObjMap(String objectName){
        Map<String, String> mapFields = new Map<String, String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            mapFields.put(dfield.getName(), String.valueOf(dfield.getType()));
        }
        return mapFields;
    }
}