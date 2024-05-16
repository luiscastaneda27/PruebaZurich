/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 30/12/2023
Description  : Query factory for InsurancePolicyCoverage using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Mateo Long                           ML
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ML			30/12/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_InsurancePolicyCoverageSelector extends fflib_SObjectSelector {
    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        30/12/2023
    */
    public Schema.SObjectType getSObjectType(){
        return InsurancePolicyCoverage.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        30/12/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            InsurancePolicyCoverage.Id,
            InsurancePolicyCoverage.InsurancePolicyId,
            InsurancePolicyCoverage.vlocity_ins_fsc__AttributesSelectedValues__c    
        };
    }

    /**
    *  @Description: Selects a list of InsurancePolicyCoverage records based on InsurancePolicy records. 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<InsurancePolicyCoverage> selectByInsurancePolicies(Set<Id> insurancePolicies) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(InsurancePolicyCoverage.Id);
        query.selectField(InsurancePolicyCoverage.InsurancePolicyId);
        query.selectField('InsurancePolicy.ExpirationDate');
        query.setCondition('InsurancePolicyId IN :insurancePolicies');
        return (List<InsurancePolicyCoverage>) Database.query( query.toSOQL() );
    }
    
    
     /**
*  @Description: Perform a query to the InsurancePolicyCoverage by the Id of the InsurancePolicyCoverage.
*  @Autor:       Jean Nieto, Deloitte, jnieto@deloitte.com
*  @Date:        19/02/2024
*/
    public List<InsurancePolicyCoverage> selectInsurancePolicyCoverageById(Id InsurancePolicyCoverageId) {      
        return (List<InsurancePolicyCoverage>) Database.query(
            newQueryFactory(false, false, true)
            .selectField(InsurancePolicyCoverage.Id)
            .selectField(InsurancePolicyCoverage.vlocity_ins_fsc__AttributesSelectedValues__c)
            .setCondition('Id = :InsurancePolicyCoverageId')
            .toSOQL()
        );
    }
}