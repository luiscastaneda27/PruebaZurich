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
public class ZRH_ContractGroupPlanGroupClassSelector extends fflib_SObjectSelector{

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public Schema.SObjectType getSObjectType(){
        return ContractGroupPlanGroupClass.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            ContractGroupPlanGroupClass.Id,
            ContractGroupPlanGroupClass.Name
        };
    }
    
    /**
    *  @Description: Get cgp group classes from contract group plan ids
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        18/12/2023
    */
    public List<ContractGroupPlanGroupClass> selectByContractGroupPlanIds(Set<Id> contractGroupPlanIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(ContractGroupPlanGroupClass.Id);
        query.selectField(ContractGroupPlanGroupClass.ContractGroupPlanId);
        query.selectField(ContractGroupPlanGroupClass.GroupClassId);
        query.setCondition('ContractGroupPlanId IN :contractGroupPlanIds');
        return (List<ContractGroupPlanGroupClass>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Perform a query by the QuoteLineItemId.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public List<ContractGroupPlanGroupClass > selectByContractGroupPlan(Id recordId) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(ContractGroupPlanGroupClass.GroupClassId);
        query.selectField(ContractGroupPlanGroupClass.ContractGroupPlanId);
        query.selectField('GroupClass.Name');
        query.setCondition('ContractGroupPlanId  = :recordId');
        return (List<ContractGroupPlanGroupClass >) Database.query( query.toSOQL() );
    }
}