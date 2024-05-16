/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 17/11/2023
Description  : Query factory for ContractGroupPlan using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			17/11/2023		initial version
********************************************************************************/
public class ZRH_QuoteLineItemGroupClassSelector extends fflib_SObjectSelector{

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public Schema.SObjectType getSObjectType(){
        return vlocity_ins__QuoteLineItemGroupClass__c.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            vlocity_ins__QuoteLineItemGroupClass__c.Id,
            vlocity_ins__QuoteLineItemGroupClass__c.Name,
            vlocity_ins__QuoteLineItemGroupClass__c.vlocity_ins__GroupClassId__c,
            vlocity_ins__QuoteLineItemGroupClass__c.vlocity_ins__QuoteLineItemId__c
        };
    }
    
    /**
    *  @Description: Perform a query by the QuoteLineItemId.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public List<vlocity_ins__QuoteLineItemGroupClass__c> selectByQuoteLineItems(Id recordId) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(vlocity_ins__QuoteLineItemGroupClass__c.vlocity_ins__GroupClassId__c);
        query.selectField(vlocity_ins__QuoteLineItemGroupClass__c.vlocity_ins__QuoteLineItemId__c);
        query.setCondition('vlocity_ins__QuoteLineItemId__c = :recordId');
        return (List<vlocity_ins__QuoteLineItemGroupClass__c>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Perform a query by the QuoteId.
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        24/02/2024
    */
    public List<vlocity_ins__QuoteLineItemGroupClass__c> selectByQuoteId(Id recordId) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(vlocity_ins__QuoteLineItemGroupClass__c.vlocity_ins__GroupClassId__c);
        query.selectField(vlocity_ins__QuoteLineItemGroupClass__c.vlocity_ins__QuoteLineItemId__c);
        query.selectField('vlocity_ins__GroupClassId__r.Name');
        query.setCondition('vlocity_ins__QuoteLineItemId__r.QuoteId = :recordId');
        return (List<vlocity_ins__QuoteLineItemGroupClass__c>) Database.query( query.toSOQL() );
    }
}