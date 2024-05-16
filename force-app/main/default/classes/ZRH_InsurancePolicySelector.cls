/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 30/12/2023
Description  : Query factory for InsurancePolicy using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Mateo Long                           ML
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ML			30/12/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_InsurancePolicySelector extends fflib_SObjectSelector {
    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        30/12/2023
    */
    public Schema.SObjectType getSObjectType(){
        return InsurancePolicy.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        30/12/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            InsurancePolicy.Id,
            InsurancePolicy.ContractGroupPlanId,          
            InsurancePolicy.PolicyType,           
            InsurancePolicy.ExpirationDate          
        };
    }

    /**
    *  @Description: Selects a list of InsurancePolicy records based on specified primary member identifiers and policy numbers. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<InsurancePolicy> selectByPrimaryMembersAndPolicyNumbers(Set<String> primaryMembers, Set<String> policyNumbers) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicy.Id);
        query.selectField(InsurancePolicy.ContractGroupPlanId);
        query.selectField(InsurancePolicy.PolicyType);
        query.selectField(InsurancePolicy.ExpirationDate);
        query.selectField(InsurancePolicy.EffectiveDate);
        query.selectField('ContractGroupPlan.ZRH_NumeroDePoliza__c');
        query.selectField('NameInsured.ZRH_Rut__c');
        query.selectField('ContractGroupPlan.ZRH_Folio__c');
        query.setCondition('NameInsured.ZRH_Rut__c IN :primaryMembers AND ContractGroupPlan.ZRH_NumeroDePoliza__c IN :policyNumbers');
        return (List<InsurancePolicy>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Selects a list of InsurancePolicy records based on specified primary member identifiers and their quotes. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        12/02/2024
    */
    public List<InsurancePolicy> selectByPrimaryMembers(Set<String> primaryMembers, Set<Id> quoteIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicy.Id);
        query.selectField(InsurancePolicy.ContractGroupPlanId);
        query.selectField(InsurancePolicy.PolicyType);
        query.selectField(InsurancePolicy.ExpirationDate);
        query.selectField(InsurancePolicy.EffectiveDate);
        query.selectField('ContractGroupPlan.ZRH_NumeroDePoliza__c');
        query.selectField('NameInsured.ZRH_Rut__c');
        query.selectField('ContractGroupPlan.ZRH_Folio__c');
        query.setCondition('NameInsured.ZRH_Rut__c IN :primaryMembers AND Status = \'Activa\' AND ContractGroupPlan.Contract.SourceQuoteId IN :quoteIds');
        return (List<InsurancePolicy>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Selects a list of InsurancePolicy records based on specified primary member identifiers the policy numbers and the quotes. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        12/02/2024
    */
    public List<InsurancePolicy> selectByPrimaryMemberRutPolicyNumberAndQuoteIds(Set<String> primaryMembers, Set<String> policyNumbers, Set<Id> quoteIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicy.Id);
        query.selectField(InsurancePolicy.ContractGroupPlanId);
        query.selectField(InsurancePolicy.PolicyType);
        query.selectField(InsurancePolicy.ExpirationDate);
        query.selectField(InsurancePolicy.EffectiveDate);
        query.selectField('ContractGroupPlan.ZRH_NumeroDePoliza__c');
        query.selectField('NameInsured.ZRH_Rut__c');
        query.selectField('ContractGroupPlan.ZRH_Folio__c');
        query.setCondition('NameInsured.ZRH_Rut__c IN :primaryMembers' + 
                           ' AND Status = \'Activa\'' + 
                           ' AND ContractGroupPlan.ZRH_NumeroDePolizaSinDV__c IN :policyNumbers' + 
                           ' AND ContractGroupPlan.Contract.SourceQuoteId IN :quoteIds'
        );
        return (List<InsurancePolicy>) Database.query( query.toSOQL() );
    }
}