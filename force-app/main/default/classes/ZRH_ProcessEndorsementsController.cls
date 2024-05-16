/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 9/1/2024
Description  : Class for Process Endorsements
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          9/1/2024       initial version
********************************************************************************/
public without sharing class ZRH_ProcessEndorsementsController {

    
    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        9/1/2024
    */
    private static final String OBJECT_CGP = 'ContractGroupPlan';
    private static final String OBJECT_CONTRACT = 'Contract';
    private static final String OBJECT_ACCOUNT = 'Account';
    private static final String OBJECT_TYPE = 'Cobertura';
    private static final String FIELD_TYPE = 'Campo Salesforce';
    private static final String FIELD_CGP = 'vlocity_ins_fsc__AttributeSelectedValues__c';
    private static final String FIELD_QLI = 'vlocity_ins__AttributeSelectedValues__c';
    private static final String FIELD_ELIGIBILITY_REQUIREMENTS = 'ZRH_AtributosRequisitosAsegurabilidad__c';
    private static final String LIFE_RATE = 'TarifaVida';
    private static final String LIFE_SCHOLARSHIP_RATE = 'TarifaEscolaridad';
    private static final String HEALTH_RATE = 'TarifaSalud';
    private static final String TEXT_LEVEL_SCHOLARSHIP = 'Niveles';
    private static final String FIELD_RATE = 'ZRH_Tarifa__c';
    private static final String FIELD_DEF = 'ZRH_CuentasDEF__c';
    private static final String LIFE_SCHOLARSHIP_PLAN= '501';
    private static final String PLANS_TEXT = 'Planes';
    private static final String FIELDS_DEF = 'CamposDEF';
    private static final Set<String> HEALTH_PLANS_LIST = ZRH_QuotePDFController.setHealthPlanCodes();
    private static final Set<String> LIFE_PLANS_LIST = ZRH_QuotePDFController.setLifePlanCodes();
    private static final String DATA_TYPE_DATE = 'DATE';
    private static final String DATA_TYPE_DATE_TIME = 'DATETIME';
    private static final String DATA_TYPE_DATE_BOOLEAN = 'BOOLEAN';
    private static final List<String> LIST_DATA_TYPE_DATE_DOUBLE = new  List<String>{'DOUBLE','PERCENT','CURRENCY'};
    
    
    public static String processEndorsements(ZRH_SincronizacionEndoso__c endoso){
        String folio = endoso.ZRH_Folio__c.split('-')[0];
        Integer periodo = Integer.valueOf(endoso.ZRH_Folio__c.split('-')[1]);
        String condition = 'ZRH_Folio__c like \'%'+folio+'%\' And ZRH_Periodo__c = ' + periodo;
        ContractGroupPlan policy = new ZRH_ContractGroupPlansSelector().selectByFolio(condition, ZRH_ControllerGlossPolicy.getFieldsObj(OBJECT_CGP))[0];
        endoso.ZRH_NombreCampo__c = endoso.ZRH_NombreCampo__c == FIELD_QLI ? FIELD_CGP : endoso.ZRH_NombreCampo__c;
        String cgpId;
        if(endoso.ZRH_NombreObjeto__c == OBJECT_CGP){
            ContractGroupPlan policyObj = policy; 
            
            // validamos si es cobertura
            if(endoso.ZRH_TipoObjeto__c == OBJECT_TYPE){
                for(ContractGroupPlan item: policy.ChildContractGroupPlans){
                    if(item.ZRH_CodigoProducto__c == endoso.ZRH_ValorCondicion__c){
                        policyObj = item; 
                    }
                }
            }
            // validamos si el campo a actualizar es campo de salesforce
            if(endoso.ZRH_TipoCampo__c == FIELD_TYPE){
                updateField(policyObj, endoso);
                cgpId = policy.Id;
            }else{
                if(endoso.ZRH_CampoCondicion__c == null || endoso.ZRH_TipoObjeto__c == OBJECT_TYPE){
                    updateFieldJSON(policyObj, endoso);
                    cgpId = policy.Id;
                }else if(endoso.ZRH_NombreCampo__c == FIELD_ELIGIBILITY_REQUIREMENTS){
                    cgpId = mapEligibilityRequirements(policyObj, endoso);
                }else if(endoso.ZRH_NombreCampo__c == FIELD_RATE){
                    cgpId = mapRates(policyObj, endoso);
                }
            }
            
        }else if(endoso.ZRH_NombreObjeto__c == OBJECT_CONTRACT){
            Contract contractObj = new ZRH_ContractsSelector().selectById(policy.ContractId, ZRH_ControllerGlossPolicy.getFieldsObj(OBJECT_CONTRACT));
            if(endoso.ZRH_TipoCampo__c == FIELD_TYPE){
                updateField(contractObj, endoso);
                cgpId = policy.Id;
            }else{
                if(endoso.ZRH_NombreCampo__c == FIELD_DEF){
                    Contract contractObjHol = new ZRH_ContractsSelector().selectById(contractObj.ZRH_ContratoHolding__c, ZRH_ControllerGlossPolicy.getFieldsObj(OBJECT_CONTRACT));
                    cgpId = mapDef(contractObjHol, endoso, policy.Id);
                }
            }
        }else if(endoso.ZRH_NombreObjeto__c == OBJECT_ACCOUNT){
            updateField(new Account(Id = policy.AccountId), endoso);
            cgpId = policy.Id;
        }
        update new ContractGroupPlan(Id = policy.Id, ZRH_EndosoEnviado__c = true);
        return cgpId;
    }
    
    
    public static void updateField(SObject objUpdate, ZRH_SincronizacionEndoso__c endoso){
        try{
            objUpdate.put(endoso.ZRH_NombreCampo__c, endoso.ZRH_Valor__c);
        }catch(exception ex){
            assignValueField(objUpdate, endoso);
        }
        update objUpdate;
    }
    
    public static void assignValueField(Sobject so, ZRH_SincronizacionEndoso__c item){
        Map<String, String> mapFielf = ZRH_ClonePlanController.getFieldsObjMap(item.ZRH_NombreObjeto__c);
        if(LIST_DATA_TYPE_DATE_DOUBLE.contains(mapFielf.get(item.ZRH_NombreCampo__c))){
            so.put(item.ZRH_NombreCampo__c, Double.valueOf(item.ZRH_Valor__c));
        }else if(mapFielf.get(item.ZRH_NombreCampo__c) == DATA_TYPE_DATE){
            so.put(item.ZRH_NombreCampo__c, Date.valueOf(item.ZRH_Valor__c));
        }else if(mapFielf.get(item.ZRH_NombreCampo__c) == DATA_TYPE_DATE_TIME){
            so.put(item.ZRH_NombreCampo__c, Date.valueOf(item.ZRH_Valor__c));
        }else if(mapFielf.get(item.ZRH_NombreCampo__c) == DATA_TYPE_DATE_BOOLEAN){
            so.put(item.ZRH_NombreCampo__c, Boolean.valueOf(item.ZRH_Valor__c));
        }
    }
    
    public static void updateFieldJSON (SObject obj, ZRH_SincronizacionEndoso__c endoso){
        Object objSON = (Object) System.JSON.deserializeUntyped((String)obj.get(endoso.ZRH_NombreCampo__c));
        Map<String,Object> data = (Map<String,Object>)objSON;
        data.put(endoso.ZRH_NombreAtributo__c, endoso.ZRH_Valor__c);
        obj.put(endoso.ZRH_NombreCampo__c, JSON.serialize(data));
        update obj;
    }
    
    public static String mapEligibilityRequirements(ContractGroupPlan obj, ZRH_SincronizacionEndoso__c endoso){
        List<Object> listRecord = (List<Object>) System.JSON.deserializeUntyped(obj.ZRH_AtributosRequisitosAsegurabilidad__c);
        String cgpId;
        for(Object item : listRecord){
            Map<String,Object> data = (Map<String,Object>)item;
            System.debug(data.get(endoso.ZRH_CampoCondicion__c) + endoso.ZRH_ValorCondicion__c);
            if(data.get(endoso.ZRH_CampoCondicion__c) == endoso.ZRH_ValorCondicion__c){
                data.put(endoso.ZRH_NombreAtributo__c, endoso.ZRH_Valor__c);
                cgpId = obj.Id;
            }
        }
        obj.put(endoso.ZRH_NombreCampo__c, JSON.serialize(listRecord));
        update obj;
        return cgpId;
    }
    
    public static String mapRates(ContractGroupPlan obj, ZRH_SincronizacionEndoso__c endoso){
        Map<String,Object> objecParent =  (Map<String,Object>) System.JSON.deserializeUntyped(obj.ZRH_Tarifa__c);
        List<Object> listRecord = new List<Object>();
        String cgpId;
        if(obj.ZRH_CodigoProducto__c == LIFE_SCHOLARSHIP_PLAN){
            listRecord = (List<Object>) objecParent.get(LIFE_SCHOLARSHIP_RATE);
            for(Object item : listRecord){
                Map<String,Object> data = (Map<String,Object>)item;
                if(data.get(endoso.ZRH_CampoCondicionDos__c) == endoso.ZRH_ValorCondicionDos__c){
                    for(Object level: (List<Object>) data.get(TEXT_LEVEL_SCHOLARSHIP)){
                        Map<String,Object> dataLevel = (Map<String,Object>)level;
                        if(dataLevel.get(endoso.ZRH_CampoCondicion__c) == endoso.ZRH_ValorCondicion__c){
                            dataLevel.put(endoso.ZRH_NombreAtributo__c, Decimal.valueOf(endoso.ZRH_Valor__c));
                            cgpId = obj.Id;
                        }
                    }
                }
            }
        }else{
            String nameList = HEALTH_PLANS_LIST.contains(obj.ZRH_CodigoProducto__c) ? HEALTH_RATE : LIFE_RATE;
            listRecord = (List<Object>) objecParent.get(nameList);
            for(Object item : listRecord){
                Map<String,Object> data = (Map<String,Object>)item;
                if(data.get(endoso.ZRH_CampoCondicion__c) == endoso.ZRH_ValorCondicion__c){
                    data.put(endoso.ZRH_NombreAtributo__c, Decimal.valueOf(endoso.ZRH_Valor__c));
                    cgpId = obj.Id;
                }
            }
        }
        obj.put(endoso.ZRH_NombreCampo__c, JSON.serialize(objecParent));
        update obj;
        return cgpId;
    }
    
    /**
    *  @Description: map the def data in the Endorsements.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        15/1/2023
    */ 
    public static String mapDef(Contract obj, ZRH_SincronizacionEndoso__c endoso, String cgpId){
        List<Object> defList = (List<Object>) System.JSON.deserializeUntyped(obj.ZRH_CuentasDEF__c);
        String cgpIdResponse;
        for(Object def : defList){
            Map<String,Object> objectDef = (Map<String,Object>)def;
            for(Object plan : (List<Object>) objectDef.get(PLANS_TEXT)){
                if(String.isNotBlank(endoso.ZRH_ValorCondicionDos__c) && endoso.ZRH_ValorCondicionDos__c.contains((String)plan)){
                    for(Object camposdef : (List<Object>) objectDef.get(FIELDS_DEF)){
                        Map<String,Object> objectCampoDef = (Map<String,Object>)camposdef;
                        if(objectCampoDef.get(endoso.ZRH_CampoCondicion__c) == endoso.ZRH_ValorCondicion__c){
                            objectCampoDef.put(endoso.ZRH_NombreAtributo__c, endoso.ZRH_Valor__c);
                            cgpIdResponse = cgpId;
                        }
                    }
                }
            }
        }
        obj.put(endoso.ZRH_NombreCampo__c, JSON.serialize(defList));
        update obj;
        return cgpIdResponse;
    }
    
}