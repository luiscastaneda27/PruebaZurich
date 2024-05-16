/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 30/12/2023
Description  : Query factory for InsurancePolicyParticipant using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Mateo Long                           ML
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ML			30/12/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_InsurancePolicyParticipantSelector extends fflib_SObjectSelector {
    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        30/12/2023
    */
    public Schema.SObjectType getSObjectType(){
        return InsurancePolicyParticipant.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        30/12/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            InsurancePolicyParticipant.Id,
            InsurancePolicyParticipant.InsurancePolicyId,
            InsurancePolicyParticipant.IsActiveParticipant,
            InsurancePolicyParticipant.RelatedParticipantAccountId,
            InsurancePolicyParticipant.PrimaryParticipantAccountId

        };
    }

    /**
    *  @Description: Selects a list of InsurancePolicyParticipant records based on InsurancePolicy records. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<InsurancePolicyParticipant> selectByInsurancePolicies(Set<Id> insurancePolicies) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicyParticipant.Id);
        query.selectField(InsurancePolicyParticipant.ExpirationDate);
        query.selectField(InsurancePolicyParticipant.InsurancePolicyId);
        query.selectField(InsurancePolicyParticipant.IsActiveParticipant);
        query.selectField('InsurancePolicy.ExpirationDate');
        query.setCondition('InsurancePolicyId IN :insurancePolicies AND IsActiveParticipant = true');
        return (List<InsurancePolicyParticipant>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Selects a list of InsurancePolicyParticipant records based on specified members and folio numbers. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<InsurancePolicyParticipant> selectByDependantMembersAndPolicyNumbers(Set<String> dependantMembers, Set<String> policyNumbers) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicyParticipant.Id);
        query.selectField(InsurancePolicyParticipant.ExpirationDate);
        query.selectField('RelatedParticipantAccount.ZRH_Rut__c');
        query.selectField('InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePoliza__c');
        query.setCondition('RelatedParticipantAccount.ZRH_Rut__c IN :dependantMembers AND InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePoliza__c IN :policyNumbers');
        return (List<InsurancePolicyParticipant>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Selects a list of InsurancePolicyParticipant records based on specified members and folio numbers. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<InsurancePolicyParticipant> selectByActiveRelatedAccountParticipantRuts(Set<String> dependantMembers) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicyParticipant.Id);
        query.selectField(InsurancePolicyParticipant.ExpirationDate);
        query.selectField(InsurancePolicyParticipant.RelatedParticipantAccountId);
        query.selectField(InsurancePolicyParticipant.PrimaryParticipantAccountId);
        query.selectField('RelatedParticipantAccount.ZRH_Rut__c');
        query.selectField('PrimaryParticipantAccount.ZRH_Rut__c');
        query.selectField('InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePoliza__c');
        query.setCondition('RelatedParticipantAccount.ZRH_Rut__c IN :dependantMembers AND IsActiveParticipant = true');
        return (List<InsurancePolicyParticipant>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Selects a list of InsurancePolicyParticipant records based on specified members and quotes. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        15/02/2024
    */
    public List<InsurancePolicyParticipant> selectByActiveRelatedAccountParticipantRutsAndSourceQuotes(Set<String> dependantMembers, Set<Id> quoteIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicyParticipant.Id);
        query.selectField(InsurancePolicyParticipant.ExpirationDate);
        query.selectField(InsurancePolicyParticipant.RelatedParticipantAccountId);
        query.selectField(InsurancePolicyParticipant.PrimaryParticipantAccountId);
        query.selectField('RelatedParticipantAccount.ZRH_Rut__c');
        query.selectField('PrimaryParticipantAccount.ZRH_Rut__c');
        query.selectField('InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePoliza__c');
        query.setCondition('RelatedParticipantAccount.ZRH_Rut__c IN :dependantMembers AND IsActiveParticipant = true AND InsurancePolicy.ContractGroupPlan.Contract.SourceQuoteId IN :quoteIds');
        return (List<InsurancePolicyParticipant>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Selects a list of InsurancePolicyParticipant records based on specified members and quotes. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        15/02/2024
    */
    public List<InsurancePolicyParticipant> selectByActivePrimaryOrRelatedAccountParticipantRutsAndSourceQuotes(Set<String> dependantMembers, Set<Id> quoteIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicyParticipant.Id);
        query.selectField(InsurancePolicyParticipant.ExpirationDate);
        query.selectField(InsurancePolicyParticipant.RelatedParticipantAccountId);
        query.selectField(InsurancePolicyParticipant.PrimaryParticipantAccountId);
        query.selectField('RelatedParticipantAccount.ZRH_Rut__c');
        query.selectField('PrimaryParticipantAccount.ZRH_Rut__c');
        query.selectField('InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePoliza__c');
        query.setCondition('(RelatedParticipantAccount.ZRH_Rut__c IN :dependantMembers' + 
                            ' OR (PrimaryParticipantAccount.ZRH_Rut__c IN :dependantMembers AND RelatedParticipantAccountId = null))' + 
                            ' AND IsActiveParticipant = true AND InsurancePolicy.ContractGroupPlan.Contract.SourceQuoteId IN :quoteIds');
        return (List<InsurancePolicyParticipant>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Selects a list of InsurancePolicyParticipant records based on specified members and quotes. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        15/02/2024
    */
    public List<InsurancePolicyParticipant> selectByActivePrimOrRelatedAccPartRutsPolicyNumAndSourceQuotes(Set<String> members, Set<String> policyNumbers, Set<Id> quoteIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicyParticipant.Id);
        query.selectField(InsurancePolicyParticipant.ExpirationDate);
        query.selectField(InsurancePolicyParticipant.RelatedParticipantAccountId);
        query.selectField(InsurancePolicyParticipant.PrimaryParticipantAccountId);
        query.selectField('RelatedParticipantAccount.ZRH_Rut__c');
        query.selectField('PrimaryParticipantAccount.ZRH_Rut__c');
        query.selectField('InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePoliza__c');
        query.setCondition('(RelatedParticipantAccount.ZRH_Rut__c IN :members' + 
                            ' OR (PrimaryParticipantAccount.ZRH_Rut__c IN :members AND RelatedParticipantAccountId = null))' + 
                            ' AND InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePolizaSinDV__c IN :policyNumbers' +
                            ' AND IsActiveParticipant = true AND InsurancePolicy.ContractGroupPlan.Contract.SourceQuoteId IN :quoteIds');
        return (List<InsurancePolicyParticipant>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Selects a list of InsurancePolicyParticipant records based on specified members, policy numbers and quotes. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        22/02/2024
    */
    public List<InsurancePolicyParticipant> selectByActiveRelatedAccPartsRutsPolicyNumAndSourceQuotes(Set<String> dependantMembers, Set<String> policyNumbers, Set<Id> quoteIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicyParticipant.Id);
        query.selectField(InsurancePolicyParticipant.ExpirationDate);
        query.selectField(InsurancePolicyParticipant.RelatedParticipantAccountId);
        query.selectField(InsurancePolicyParticipant.PrimaryParticipantAccountId);
        query.selectField('RelatedParticipantAccount.ZRH_Rut__c');
        query.selectField('PrimaryParticipantAccount.ZRH_Rut__c');
        query.selectField('InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePoliza__c');
        query.setCondition('RelatedParticipantAccount.ZRH_Rut__c IN :dependantMembers' + 
                           ' AND InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePolizaSinDV__c IN :policyNumbers' + 
                           ' AND IsActiveParticipant = true' + 
                           ' AND InsurancePolicy.ContractGroupPlan.Contract.SourceQuoteId IN :quoteIds');
        return (List<InsurancePolicyParticipant>) Database.query( query.toSOQL() );
    }
}