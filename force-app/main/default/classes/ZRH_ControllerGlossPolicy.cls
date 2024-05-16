/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 5/1/2024
Description  : Class for add gloss of policy
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          5/1/2024       initial version
********************************************************************************/
public without sharing class ZRH_ControllerGlossPolicy {

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        5/1/2024  
    */
    private static final String TYPE_OPERATION = 'typeOperation';
    private static final String TYPE_OBJECT = 'typeObject';
    private static final String FIELD = 'field';
    private static final String ATRIBUTE = 'atribute';
    private static final String VALUE = 'value';
    private static final String SOURCE_OBJECT = 'sourceObject';
    private static final String FIELD_JSON = 'fieldJSON';
    private static final String TYPE_CONDITION = 'typeCondition'; 
    private static final String GLOSS_EXCEPTIONAL = 'glosaExcepcional';
    private static final String GLOSS_EXCEPTIONAL_GRACE_PERIOD = 'PeriodoDeGracia';
    private static final String CONDITION = 'condition'; 
    private static final String REPLACE = 'replace';
    private static final String OPERATOR_AND = 'AND'; 
    private static final String OPERATOR_OR = 'OR';
    private static final String CODE_GLOSS_STANDARD = 'G-001'; 
    private static final String CODE_GLOSS_CONDITIONAL = 'G-002';
    private static final String GLOSS_EXCEPTIONAL_COVERAGE = 'Cobertura';
    private static final String GLOSS_EXCEPTIONAL_DEF = 'DEF';
    private static final String GLOSS_EXCEPTIONAL_CAD = 'CAD';
    private static final String GLOSS_EXCEPTIONAL_REQASE = 'ReqAse';
    private static final String OBJECT_CGP = 'ContractGroupPlan';
    private static final String OBJECT_QLI = 'QuoteLineItem';
    private static final String FIELD_CGP = 'vlocity_ins_fsc__AttributeSelectedValues__c';
    private static final String FIELD_QLI = 'vlocity_ins__AttributeSelectedValues__c';
    private static final String FIELD_FOLIO = 'ZRH_Folio__c';
    private static final String POUND_SIGN_DELETE = '####';
    private static final String POUND_SIGN_INSERT = '###';
    private static final String BUSINESS_CODE = '<Código Grupo de Negocio>';
    private static final String OBJECT_ACCOUNT = 'Account';
    private static final String OBJECT_ACCOUNT_HOLDING = 'AccountHolding';
    private static final String OBJECT_CONTRACT = 'Contract';
    private static final String OBJECT_QUOTE = 'Quote';
    private static final String OBJECT_USER = 'User';
    private static final String OBJECT_CONTRACT_HOLDING = 'ContractHolding';
    private static final String OBJECT_QUOTE_HOLDING = 'QuoteHolding';
    private static final String TEXT_CONTAINS = 'contains';
    private static final String FIELD_OBJECT_DEF = 'ZRH_CuentasDEF__c';
    private static final String HEALTH_RELATIONSHIP = 'ParentescoSalud';
    private static final String REPLACE_RESQ_ASEG = '%ReqAse%';
    private static final String LIFE_CAD = 'VidaCAD';
    private static final String REPLACE_COVERAGE = '%coberturas%';
    private static final String REPLACE_CAD = '%CAD%';
    private static final String REPLACE_INVALIDEZ = '%InvalidesPermanente%';
    private static final String PLAN_CODE_80 = '80';
    private static final String PLAN_CODE_82 = '82';
    private static final String TEXT_REPLACE_INVALIDEZ = 'o INVALIDEZ PERMANENTE ';
    private static final String PERCENTAGE = '%';
    private static final String FIELD_TEXT = 'Campo';
    private static final String VALUE_TEXT = 'Valor';
    private static final String PLANS_TEXT = 'Planes';
    private static final String FIELDS_DEF = 'CamposDEF';
    private static final String STRING_EMPTY = '';
    private static final String VALUE_CERO = '0'; 
    private static final String NOTIFICATION_TITLE = 'Activación de Glosas';
    private static final String MENSAGE_NOTIFICACION = '¡Atención! Se han actualizado las glosas de la póliza con el Folio ZRH_Folio__c - GN <Código Grupo de Negocio>. La cantidad actual de glosas asociadas a la Póliza es ahora: ###, en comparación con la cantidad previa de glosas asociadas a la Póliza, que era: ####.';
    private static final String NAME_CUSTOM_NOTIFICATION = 'ZRH_SegurosColectivos';
    private static final String MINIMUM_AGE_ADMISSION = 'EdadMinimaIngresoS';
    private static final String TEXT_TITLE = 'Titular';
    private static final String GLOSS_EXCEPTIONAL_PHARMACY  = 'Farmacia';
    private static final String TRIPLE_VALUE_ZERO = '.000';
    private static final String ATTRIBUTE_DEDUCTIBLE_LEVEL_TWO = 'NivelDeducible2';
    private static final String FIELD_CONDITION = 'fieldCondition';
    private static final String VALUE_CONDITION = 'valueCondition';
    private static final String FIELD_PRODUCT_CODE = 'ZRH_CodigoProducto__c';
    
    /**
    *  @Description: Delete and activate the new glosses to the plan.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/09/2023
	*/   
    public static Integer manageGloss(String cgpId){
        
        //List<ContractGroupPlan> cgpList = new ZRH_ContractGroupPlansSelector().selectByIdAndCoverages(cgpId, getFieldsObj(OBJECT_CGP));
        List<ContractGroupPlan> cgpList = new List<ContractGroupPlan>();
        cgpList.add(new ContractGroupPlan(Id = cgpId));
        for(ContractGroupPlan item: new ZRH_ContractGroupPlansSelector().selectByIdAndCoverages(cgpId, getFieldsObj(OBJECT_CGP))){
            if(item.id == cgpId){
                String att = item.vlocity_ins_fsc__AttributeSelectedValues__c;
                Map<String, Object>  attr = (map<String, Object>) JSON.deserializeUntyped(att);
                if(attr.get(ATTRIBUTE_DEDUCTIBLE_LEVEL_TWO) != null){
                    attr.put(ATTRIBUTE_DEDUCTIBLE_LEVEL_TWO.subString(0, ATTRIBUTE_DEDUCTIBLE_LEVEL_TWO.length() - 1), attr.get(ATTRIBUTE_DEDUCTIBLE_LEVEL_TWO));
                    item.vlocity_ins_fsc__AttributeSelectedValues__c = JSON.serialize(attr);
                }
                cgpList[0] = item; 
            }else{
                cgpList.add(item);
            }
        }
        ContractGroupPlan policy = cgpList?.get(0);
        
        String recordId = policy.QuoteLineItemId;
        List<ZRH_Glosas__c> glossInsert = new List<ZRH_Glosas__c>();
        List<ZRH_Glosas__c> glossDelete = new ZRH_GlosasSelector().selectByQLIIdAndGlossType(recordId);
        
        
        List<ZRH_MaestroGlosas__c > glossList = new ZRH_MaestroGlosasSelector().selectByPlanCode(policy.ZRH_CodigoProducto__c);
        
        Contract contractObj = new ZRH_ContractsSelector().selectById(policy.ContractId, getFieldsObj(OBJECT_CONTRACT));
        Contract contractObhHold = new ZRH_ContractsSelector().selectById(contractObj.ZRH_ContratoHolding__c, getFieldsObj(OBJECT_CONTRACT));
        
        Account accObj = new ZRH_AccountsSelector().selectById(contractObj.AccountId, getFieldsObj(OBJECT_ACCOUNT));
        Account accObjHonding = new ZRH_AccountsSelector().selectById(contractObj.ZRH_Holding__c, getFieldsObj(OBJECT_ACCOUNT));
        
        User user1 = new ZRH_UsersSelector().selectById(contractObj.OwnerId);
        
        
        Map<String, Sobject> mapObject = new Map<String, Sobject>();
        mapObject.put(OBJECT_CONTRACT, contractObj);
        mapObject.put(OBJECT_CONTRACT_HOLDING, contractObhHold);
        mapObject.put(OBJECT_ACCOUNT, accObj);
        mapObject.put(OBJECT_ACCOUNT_HOLDING, accObjHonding);
        mapObject.put(OBJECT_USER, user1);
        List<String> glossListAdd = new List<String>();
        
        for(ContractGroupPlan cgp: cgpList){
            for(ZRH_MaestroGlosas__c g : glossList){
                try{
                    List<Object> conditionList = new List<Object>();
                    List<Object> replaceList = new List<Object>();
                    g.ZRH_ContenidoGlosa__c = String.isBlank(g.ZRH_ContenidoGlosa__c) ? STRING_EMPTY : g.ZRH_ContenidoGlosa__c;
                    String parametros = String.isNotBlank(g.ZRH_Parametros__c) ? g.ZRH_Parametros__c : JSON.serialize(new List<Object>());
                    parametros = parametros.replace(FIELD_QLI, FIELD_CGP);
                    parametros = parametros.replace(OBJECT_QLI, OBJECT_CGP);
                    parametros = parametros.replace(OBJECT_QUOTE, OBJECT_CONTRACT);
                    parametros = parametros.replace(OBJECT_QUOTE_HOLDING, OBJECT_CONTRACT_HOLDING);
                    if((g.ZRH_TipoDeGlosa__c == CODE_GLOSS_STANDARD && cgp.ContractGroupParentPlanId != null) || glossListAdd.contains(g.Id) ||
                       (cgp.ContractGroupParentPlanId != null && !parametros.contains(OBJECT_CGP)) ){
                           continue;
                       }
                    for(Object gson : (List<Object>) System.JSON.deserializeUntyped(parametros)){
                        Map<String,Object> data = (Map<String,Object>)gson;
                        if(data.get(TYPE_OPERATION) == CONDITION){
                            conditionList.add(gson);
                        }else if(data.get(TYPE_OPERATION) == REPLACE){
                            replaceList.add(gson);
                        }
                    }
                    mapObject.put(OBJECT_CGP, cgp);
                    Integer numValidation = validationsGloss(conditionList, mapObject);
                    if(g.ZRH_TipoDeGlosa__c == CODE_GLOSS_STANDARD || 
                       (g.ZRH_TipoDeGlosa__c == CODE_GLOSS_CONDITIONAL && g.ZRH_LogicaCondiciones__c == OPERATOR_AND && numValidation == conditionList.size() && numValidation > 0) ||
                       (g.ZRH_TipoDeGlosa__c == CODE_GLOSS_CONDITIONAL && g.ZRH_LogicaCondiciones__c == OPERATOR_OR && numValidation > 0)
                      ){
                          ZRH_Glosas__c gloss = new ZRH_Glosas__c ();
                          gloss.Name = g.Name;
                          gloss.ZRH_IDGlosa__c = g.ZRH_IDGlosa__c;
                          gloss.ZRH_TipoDeGlosa__c = g.ZRH_TipoDeGlosa__c;
                          String cont = replaceGloss(replaceList, mapObject, g.ZRH_ContenidoGlosa__c, policy.ZRH_CodigoProducto__c, cgpList);
                          while(String.isNotBlank(cont) && cont.contains(TRIPLE_VALUE_ZERO)){
                              cont = cont.replace(TRIPLE_VALUE_ZERO, TRIPLE_VALUE_ZERO.subString(0, TRIPLE_VALUE_ZERO.length() - 1));
                          }
                          gloss.ZRH_ContenidoGlosa__c = cont;
                          gloss.ZRH_Validaciones__c = g.ZRH_Validaciones__c;
                          gloss.ZRH_Parametros__c = g.ZRH_Parametros__c;
                          gloss.ZRH_LocalizacionCondicionado__c = g.ZRH_LocalizacionCondicionado__c;
                          gloss.ZRH_Plan__c = g.ZRH_Plan__c;
                          gloss.ZRH_Activo__c = true;
                          gloss.ZRH_DestinoTipoPDF__c = g.ZRH_DestinoTipoPDF__c;
                          gloss.ZRH_NumeroArticulo__c = g.ZRH_NumeroArticulo__c;
                          gloss.ZRH_NombreArticulo__c = g.ZRH_NombreArticulo__c;
                          gloss.ZRH_Quote__c = contractObj.SourceQuoteId;
                          gloss.ZRH_Contrato__c = contractObj.Id;
                          gloss.ZRH_QuoteLineItem__c = policy.QuoteLineItemId;
                          gloss.ZRH_PlanDelContrato__c = policy.Id;
                          gloss.ZRH_InformacionDinamica__c = replaceList.size() > 0;
                          gloss.ZRH_ContieneTabla__c = g.ZRH_ContieneTabla__c; 
                          gloss.ZRH_Titulo__c = g.ZRH_Titulo__c;
                          glossListAdd.add(g.Id);
                          glossInsert.add(gloss);
                      }
                }catch(Exception ex){
                    System.debug('Id: '+g.Id);
                    System.debug('Metodo principal: '+ex.getMessage() + ' ---- '+ex.getLineNumber());
                }
            }
        }
        insert glossInsert;
        delete glossDelete;
        
        policy.ZRH_Folio__c = policy.ZRH_Folio__c == null ? '' : policy.ZRH_Folio__c;
        accObjHonding.ZRH_CodigoGrupoNegocio__c = accObjHonding.ZRH_CodigoGrupoNegocio__c == null ? '' : accObjHonding.ZRH_CodigoGrupoNegocio__c;
        String mensaje = MENSAGE_NOTIFICACION.replace(POUND_SIGN_DELETE, glossDelete.size() + '');
        mensaje = mensaje.replace(POUND_SIGN_INSERT, glossInsert.size() + '');
        mensaje = mensaje.replace(FIELD_FOLIO, policy.ZRH_Folio__c);
        mensaje = mensaje.replace(BUSINESS_CODE, accObjHonding.ZRH_CodigoGrupoNegocio__c);
        sendNotification(NOTIFICATION_TITLE, mensaje, policy.Id, contractObj.OwnerId);
        System.debug('mensaje: '+mensaje);
        return glossInsert.size();
    }
    
    
    /**
    *  @Description: Validates if the plan meets the condition.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/09/2023
    */  
    public static Integer validationsGloss(List<Object> conditionList, Map<String, Sobject> mapObject){
        Integer numValidation = 0;
        for(Object gson : conditionList){
            Map<String,Object> dataGlosa = (Map<String,Object>)gson;
            String valueObject;
            Sobject objectData = mapObject.get((String) dataGlosa.get(SOURCE_OBJECT));
            if(dataGlosa.get(TYPE_OBJECT) == ATRIBUTE){
                String deserializeJson =  (String) objectData.get((String)dataGlosa.get(FIELD_JSON)); 
                deserializeJson = String.isNotBlank(deserializeJson) ? deserializeJson : '{}';
                Map<String,Object> data;
                
                if(dataGlosa.get(FIELD_CONDITION) != null){
                    for(Object obj: (List<Object>) System.JSON.deserializeUntyped(deserializeJson)){
                        data = (Map<String,Object>)obj;
                        if(data.get((String)dataGlosa.get(FIELD_CONDITION)) == dataGlosa.get(VALUE_CONDITION)){
                            valueObject = String.valueOf(data.get((String) dataGlosa.get(FIELD)));
                        }
                    }
                }else{
                    Object obj = (Object) System.JSON.deserializeUntyped(deserializeJson);
                    data = (Map<String,Object>)obj;
                    valueObject = String.valueOf(data.get((String) dataGlosa.get(FIELD)));
                }
                
            }else if (dataGlosa.get(TYPE_OBJECT) == FIELD){
                valueObject = String.valueOf(objectData.get((String)dataGlosa.get(FIELD)));
            }
            String valueGloss = String.valueof(dataGlosa.get(VALUE));
            if(dataGlosa.get(GLOSS_EXCEPTIONAL) == GLOSS_EXCEPTIONAL_DEF){
                valueGloss = (String) mapObject.get(OBJECT_CGP).get(FIELD_PRODUCT_CODE);
            }
            
            if(dataGlosa.get(TYPE_CONDITION) == '=' && valueObject == valueGloss){
                numValidation ++;
            }else if(dataGlosa.get(TYPE_CONDITION) == '<>' && valueObject != valueGloss){
                numValidation ++;
            }else if(dataGlosa.get(TYPE_CONDITION) == '>' && valueObject > valueGloss){
                numValidation ++;
            }else if(dataGlosa.get(TYPE_CONDITION) == '<' && valueObject < valueGloss){
                numValidation ++;
            }else if(dataGlosa.get(TYPE_CONDITION) == TEXT_CONTAINS && String.isNotBlank(valueObject) && valueObject.contains(valueGloss)){
                numValidation ++;
            }else if(dataGlosa.get(GLOSS_EXCEPTIONAL) == GLOSS_EXCEPTIONAL_REQASE && objectData.get((String)dataGlosa.get(FIELD)) != null){
                Object desObj = JSON.deserializeUntyped((String)objectData.get((String)dataGlosa.get(FIELD)));
                List<Object> desList;
                if (desObj instanceof List<Object>) {
                    desList = (List<Object>)desObj;            
                } else if (desObj instanceof Map<String, Object>) {
                    desList = new List<Object>();
                    desList.Add((Object)desObj);
                }
                for(Object item :desList){
                    Map<String,Object> data = (Map<String,Object>)item;
                    if(data.get(MINIMUM_AGE_ADMISSION) != null && data.get(HEALTH_RELATIONSHIP) != TEXT_TITLE){
                        numValidation = 1;   
                    }
                }
                
            }
        }
        return numValidation;
    }
    
    /**
    *  @Description: Replace the plan data in the gloss.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/09/2023
    */ 
    public static String replaceGloss(List<Object> replaceList, Map<String, Sobject> mapObject, String glossText, String codePlan, List<ContractGroupPlan> qliList){
        for(Object gson : replaceList){
            Map<String,Object> dataGlosa = (Map<String,Object>)gson;
            String valueObject;
            Sobject objectData = mapObject.get((String) dataGlosa.get(SOURCE_OBJECT));
            if(dataGlosa.get(GLOSS_EXCEPTIONAL) != null){
                if(dataGlosa.get(GLOSS_EXCEPTIONAL) == GLOSS_EXCEPTIONAL_DEF){
                    glossText = replaceDef((String)mapObject.get(OBJECT_CONTRACT_HOLDING).get(FIELD_OBJECT_DEF), glossText, codePlan);
                    
                }else if(dataGlosa.get(GLOSS_EXCEPTIONAL) == GLOSS_EXCEPTIONAL_GRACE_PERIOD){
                    String deserializeJson =  (String) objectData.get((String)dataGlosa.get(FIELD_JSON)) ; 
                    Object obj = (Object) System.JSON.deserializeUntyped(deserializeJson);
                    Map<String,Object> data = (Map<String,Object>)obj;
                    valueObject = String.ValueOf(data.get((String) dataGlosa.get(FIELD)));
                    valueObject = String.ValueOf(Integer.ValueOf(valueObject)*30);
                    glossText = glossText.replace((String)dataGlosa.get(VALUE), valueObject != null ? valueObject : STRING_EMPTY); 
                    
                }else if(dataGlosa.get(GLOSS_EXCEPTIONAL) == GLOSS_EXCEPTIONAL_REQASE){
                    Object desObj = JSON.deserializeUntyped(qliList?.get(0).ZRH_AtributosRequisitosAsegurabilidad__c);
                    List<Object> desList;
                    if (desObj instanceof List<Object>) {
                        desList = (List<Object>)desObj;            
                    } else if (desObj instanceof Map<String, Object>) {
                        desList = new List<Object>();
                        desList.Add((Object)desObj);
                    }
                    String reqAs = STRING_EMPTY;
                    for(Object item :desList){
                        Map<String,Object> data = (Map<String,Object>)item;
                        if(data.get(MINIMUM_AGE_ADMISSION) != null && data.get(HEALTH_RELATIONSHIP) != TEXT_TITLE){
                            reqAs += ( reqAs != STRING_EMPTY ? ',' : STRING_EMPTY ) + data.get(HEALTH_RELATIONSHIP);   
                        }
                    }
                    glossText = glossText.replace(REPLACE_RESQ_ASEG, reqAs);
                }else if(dataGlosa.get(GLOSS_EXCEPTIONAL) == GLOSS_EXCEPTIONAL_PHARMACY){
                    String valueReplace = STRING_EMPTY;
                    Object obj = (Object) System.JSON.deserializeUntyped((String) objectData.get((String)dataGlosa.get(FIELD_JSON)));
                    Map<String,Object> data = (Map<String,Object>)obj;
                    System.debug(JSON.serialize(data));
                    String ConvenioFarmacias = (String) data.get((String)dataGlosa.get(FIELD));
                    for(String f: ConvenioFarmacias.split(';') ){
                        valueReplace += GLOSS_EXCEPTIONAL_PHARMACY + ' ' + f + ', ';
                    }
                    glossText = glossText.replace((String)dataGlosa.get(VALUE), valueReplace.subString(0, valueReplace.length() - 2));
                }else{
                    String valueReplace = STRING_EMPTY;
                    String cad = STRING_EMPTY;
                    String inval = STRING_EMPTY;
                    for(Integer i = 1; i<qliList.size(); i++){
                        inval = qliList[i].ZRH_CodigoProducto__c == PLAN_CODE_80 || qliList[i].ZRH_CodigoProducto__c == PLAN_CODE_82 ? qliList[i].Name : inval;
                        if(dataGlosa.get(GLOSS_EXCEPTIONAL) == GLOSS_EXCEPTIONAL_COVERAGE){
                            valueReplace += ( valueReplace != STRING_EMPTY ? ', ' : STRING_EMPTY ) + qliList[i].vlocity_ins_fsc__Product2Id__r.Name;
                        }else if(dataGlosa.get(GLOSS_EXCEPTIONAL) == GLOSS_EXCEPTIONAL_CAD){
                            Object obj = (Object) System.JSON.deserializeUntyped(qliList[i].vlocity_ins_fsc__AttributeSelectedValues__c);
                            Map<String,Object> data = (Map<String,Object>)obj;
                            if(data.get(LIFE_CAD) != null){
                                cad += (cad != STRING_EMPTY ? ', ' : STRING_EMPTY ) + data.get(LIFE_CAD);
                            }
                        }
                    }
                    
                    glossText = glossText.replace(REPLACE_COVERAGE, valueReplace);
                    glossText = glossText.replace(REPLACE_CAD, cad);
                    glossText = glossText.replace(REPLACE_INVALIDEZ, inval);
                }
            }
            else {
                if(dataGlosa.get(TYPE_OBJECT) == ATRIBUTE){
                    String deserializeJson = (String) objectData.get((String)dataGlosa.get(FIELD_JSON)) ; 
                    Map<String,Object> data;
                    if(dataGlosa.get(FIELD_CONDITION) != null){
                        for(Object obj: (List<Object>) System.JSON.deserializeUntyped(deserializeJson)){
                            Map<String,Object> objMap = (Map<String,Object>)obj;
                            if(objMap.get((String)dataGlosa.get(FIELD_CONDITION)) == dataGlosa.get(VALUE_CONDITION)){
                                data = objMap;
                            }
                        }
                    }else{
                        Object obj = (Object) System.JSON.deserializeUntyped(deserializeJson);
                        data = (Map<String,Object>)obj;
                    }
                    valueObject = String.ValueOf(data.get((String) dataGlosa.get(FIELD)));
                }else if (dataGlosa.get(TYPE_OBJECT) == FIELD){
                    valueObject = String.valueof(objectData.get((String)dataGlosa.get(FIELD)));
                }
                glossText = glossText.replace((String)dataGlosa.get(VALUE), valueObject != null ? valueObject : STRING_EMPTY); 
            }
            
        }
        return glossText;
    }
    
    /**
    *  @Description: Replace the def data in the gloss.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/09/2023
    */ 
    public static String replaceDef(String jsonString, String glossText, String codePlan){
        List<Object> defList = (List<Object>) System.JSON.deserializeUntyped(jsonString);
        for(Object def : defList){
            Map<String,Object> objectDef = (Map<String,Object>)def;
            for(Object plan : (List<Object>) objectDef.get(PLANS_TEXT)){
                if(plan == codePlan){
                    for(Object camposdef : (List<Object>) objectDef.get(FIELDS_DEF)){
                        Map<String,Object> objectCampoDef = (Map<String,Object>)camposdef;
                        String campo = PERCENTAGE + (String) objectCampoDef.get(FIELD_TEXT) + PERCENTAGE;
                        String valor = (String) objectCampoDef.get(VALUE_TEXT);
                        glossText = glossText.replace(campo, String.isNotBlank(valor) ? valor : VALUE_CERO);
                    }
                }
            }
        }
        return glossText;
    }
    
    /**
    *  @Description: Gets all fields of an object.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/09/2023
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
    *  @Description: Send notification
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024  
    */
    public static void sendNotification(String title, String description, String recordId, String userId){
        CustomNotificationType notificacion = [Select Id from CustomNotificationType where DeveloperName = :NAME_CUSTOM_NOTIFICATION]; 
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(title);
        notification.setBody(description);
        notification.setNotificationTypeId(notificacion.Id);
        notification.setTargetId( recordId ); 
        notification.send(new Set<String> { userId }); 
    }
    
}