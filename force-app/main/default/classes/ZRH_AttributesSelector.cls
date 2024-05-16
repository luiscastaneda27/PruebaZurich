/**********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 14/02/2024
Description  : Query factory for vlocity_ins__Attribute__c using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Jean Baljean Nieto Meregote.             jnietom
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			14/02/2024		initial version
********************************************************************************/
public class ZRH_AttributesSelector extends fflib_SObjectSelector{
    
    /**
*  @Description: Defines the type of object handled in the selector
*  @Autor:       JNIETOM, Deloitte, jnietom@deloitte.com
*  @Date:        14/02/2024
*/
    public Schema.SObjectType getSObjectType(){
        return vlocity_ins__Attribute__c.sObjectType;
    }
    
    /**
*  @Description: Defines the fields that will be queried in a default query
*  @Autor:       JNIETOM, Deloitte, JNIETOM@deloitte.com
*  @Date:        14/02/2024
*/
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            vlocity_ins__Attribute__c.Id,
                vlocity_ins__Attribute__c.Name,
                vlocity_ins__Attribute__c.vlocity_ins__Code__c,
                vlocity_ins__Attribute__c.vlocity_ins__AttributeCategoryId__c
                };
                    }
    
        /**
*  @Description: Get list vlocity_ins__Attribute__c
*  @Autor:       JNIETOM, Deloitte, JNIETOM@deloitte.com
*  @Date:        14/02/2024
*/
    public List<vlocity_ins__Attribute__c> selectAttributes() { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(vlocity_ins__Attribute__c.Id);
        query.selectField(vlocity_ins__Attribute__c.Name);
        query.selectField(vlocity_ins__Attribute__c.vlocity_ins__Code__c);
        query.selectField('vlocity_ins__AttributeCategoryId__r.Name');
        return (List<vlocity_ins__Attribute__c>) Database.query( query.toSOQL() );
    }
    
}