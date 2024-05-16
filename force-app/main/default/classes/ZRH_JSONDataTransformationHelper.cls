/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 18/03/2024
Description  : Helper Class for Data Transformation
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Josue Alejandro Aguilar     JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      JAA         18/03/2024		    	Initial Version
********************************************************************************/
public class ZRH_JSONDataTransformationHelper {

    /**
    *  @Description: Static variables
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        18/03/2024
    */
    private static final String DATA_TYPE_DATE = 'DATE';
    private static final String DATA_TYPE_DATE_TIME = 'DATETIME';
    private static final String DATA_TYPE_DATE_BOOLEAN = 'BOOLEAN';
    private static final List<String> LIST_DATA_TYPE_DATE_DOUBLE = new  List<String>{'DOUBLE','PERCENT','CURRENCY'};
    
    /**
    *  @Description: Transform data from JSON to Custom Field
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        18/03/2024  
    */
    public static void populateSalesforceFieldFromAttributes(List<Sobject> listNew, Map<Id, Sobject> mapRecordOld){
        for(Sobject so: listNew){
            for(ZRH_DiccionarioPoblacionDatosJSON__mdt item: ZRH_DiccionarioPoblacionDatosJSON__mdt.getAll().values()) {
                if(item.ZRH_Objeto__c == String.valueOf(listNew.getSObjectType())) {
                        String dataJSON = (String) so.get(item.ZRH_CampoJSON__c);
                        if(String.isNotBlank(dataJSON) && (mapRecordOld == null || so.get(item.ZRH_CampoJSON__c) != mapRecordOld.get(so.Id).get(item.ZRH_CampoJSON__c))){
                            Object dataObj = getJsonValue(dataJSON, item.ZRH_Nodo__c, item.ZRH_NombreAtributo__c, null);
                            try{
                                if (dataObj != Null) {
                                    so.put(item.ZRH_CampoDestino__c, dataObj);
                                }
                            }catch(Exception ex){
                                assignValueField(so, item, dataObj);
                            }
                        }
                }
            }
        }
    }
   
    /**
    *  @Description: Converts the data into the destination field type
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        18/03/2024  
    */
    public static void assignValueField(Sobject so, ZRH_DiccionarioPoblacionDatosJSON__mdt item, Object dataObj){
        try{
            Map<String, String> mapField = ZRH_ClonePlanController.getFieldsObjMap(item.ZRH_Objeto__c);
            if(LIST_DATA_TYPE_DATE_DOUBLE.contains(mapField.get(item.ZRH_CampoDestino__c))){
                so.put(item.ZRH_CampoDestino__c, Double.valueOf(dataObj));
            }else if(mapField.get(item.ZRH_CampoDestino__c) == DATA_TYPE_DATE){
                so.put(item.ZRH_CampoDestino__c, Date.valueOf(dataObj));
            }else if(mapField.get(item.ZRH_CampoDestino__c) == DATA_TYPE_DATE_TIME){
                so.put(item.ZRH_CampoDestino__c, Date.valueOf(dataObj));
            }else if(mapField.get(item.ZRH_CampoDestino__c) == DATA_TYPE_DATE_BOOLEAN){
                so.put(item.ZRH_CampoDestino__c, Boolean.valueOf(dataObj));
            }
        }catch(exception ex){
            
        }
    }

    /**
    * @Description: Retrieves the value of a JSON parameter or field.
    * @Author: ATO, Deloitte, atejoso@Deloitte.com
    * @Date: 26/03/2024
    */
    public static Object getJsonValue(String jsonString, String parameterName, String fieldName, Integer index) {
        Object resultValue = null;
        try {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            
            if (parameterName != null && resultMap.containsKey(parameterName)) {
                Object parameterValue = resultMap.get(parameterName);
                
                if (fieldName != null) {
                    if (parameterValue instanceof Map<String, Object>) {
                        Map<String, Object> parameterMap = (Map<String, Object>) parameterValue;
                        resultValue = parameterMap.get(fieldName);
                    } else if (parameterValue instanceof List<Object>) {
                        List<Object> parameterList = (List<Object>) parameterValue;
                        Integer size = parameterList.size();
                        Integer targetIndex = (index != null && index >= 0 && index < size) ? index : size - 1;
                        Map<String, Object> parameterMap = (Map<String, Object>) parameterList.get(targetIndex);
                        resultValue = parameterMap.get(fieldName);
                    }
                } else {
                    resultValue = parameterValue;
                }
            }
        } catch (Exception e) {
            System.debug('Error retrieving JSON value: ' + e.getMessage());
        }
        return resultValue;
    }
}