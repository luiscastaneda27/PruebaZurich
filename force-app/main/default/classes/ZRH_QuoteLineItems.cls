/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 18/03/2024
Description  : Handler Class for QuoteLineItem
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Josue Alejandro Aguilar     JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      JAA         18/03/2024		    	Initial Version
********************************************************************************/
public class ZRH_QuoteLineItems extends fflib_SObjectDomain{
    
    /**
    *  @Description: Constructor method of the class
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        18/03/2024  
    */
    public ZRH_QuoteLineItems(List<QuoteLineItem> sObjectList){
        Super(sObjectList);
    }
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<Sobject> sObjectList){
            return new ZRH_QuoteLineItems(sObjectList);
        }
    }
    
    
    /**
    *  @Description: Method that is executed before inserting
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        18/03/2024  
    */
    public override void onBeforeInsert() {
        ZRH_JSONDataTransformationHelper.populateSalesforceFieldFromAttributes(records, null);
    }
    
    
    /**
    *  @Description: Method that is executed before updating
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        18/03/2024  
    */
    public override void onBeforeUpdate(Map<Id,SObject> mapOldRecord) {
        ZRH_JSONDataTransformationHelper.populateSalesforceFieldFromAttributes(records, mapOldRecord);
    }
    
    

}