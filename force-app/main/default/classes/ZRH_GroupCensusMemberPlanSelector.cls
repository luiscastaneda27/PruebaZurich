/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : Query factory for Group Census Member Plans using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Mateo Long.                         ML
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ML			23/12/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_GroupCensusMemberPlanSelector extends fflib_SObjectSelector {

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        23/12/2023
    */
    public Schema.SObjectType getSObjectType(){
        return GroupCensusMemberPlan.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        23/12/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            GroupCensusMemberPlan.Id,
            GroupCensusMemberPlan.ContractGroupPlanId,
            GroupCensusMemberPlan.GroupCensusMemberId
        };
    }

    /**
    *  @Description: Select group census member plans by ids of group census members
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        23/12/2023
    */
    public List<GroupCensusMemberPlan> selectByGroupCensusMemberIds(Set<Id> groupCensusMembers) {
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(GroupCensusMemberPlan.Id);           
        query.selectField(GroupCensusMemberPlan.ContractGroupPlanId);            
        query.selectField(GroupCensusMemberPlan.GroupCensusMemberId);           
        query.setCondition('GroupCensusMemberId IN :groupCensusMembers');
        return (List<GroupCensusMemberPlan>) Database.query( query.toSOQL() );
    }
}