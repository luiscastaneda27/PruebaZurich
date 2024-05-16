/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/03/2024
Description  : Handler Class for ContractGroupPlan
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      ATO         27/03/2024		    	Initial Version
********************************************************************************/
public class ZRH_ContractGroupPlan extends fflib_SObjectDomain{
    
    /**
    *  @Description: Constructor method of the class
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        27/03/2024
    */
    public ZRH_ContractGroupPlan(List<ContractGroupPlan> sObjectList){
        Super(sObjectList);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<Sobject> sObjectList){
            return new ZRH_ContractGroupPlan(sObjectList);
        }
    }   
    
    /**
    *  @Description: Method that is executed before inserting
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        27/03/2024
    */
    public override void onBeforeInsert() {
        ZRH_JSONDataTransformationHelper.populateSalesforceFieldFromAttributes(records, null);
    }    
    
    /**
    *  @Description: Method that is executed before updating
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        27/03/2024
    */
    public override void onBeforeUpdate(Map<Id,SObject> mapOldRecord) {
        ZRH_JSONDataTransformationHelper.populateSalesforceFieldFromAttributes(records, mapOldRecord);
    }
}