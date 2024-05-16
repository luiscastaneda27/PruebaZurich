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
public class ZRH_ContractsSelector extends fflib_SObjectSelector{

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public Schema.SObjectType getSObjectType(){
        return Contract.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Contract.Id,
            Contract.Name,
            Contract.AccountId,
            Contract.Status,
            Contract.ContractNumber,
            Contract.ZRH_ContratoHolding__c
        };
    }

    /**
    *  @Description: Perform a query to the contract by the Id of the contract.
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        24/11/2023
    */
    public List<Contract> selectContractById(Id contractId) {      
        return (List<Contract>) Database.query(
            newQueryFactory(false, false, true)
            .selectField(Contract.Id)
            .setCondition('Id = :contractId')
            .toSOQL()
        );
    }

    /**
    *  @Description: Perform a query to the contract by the Id of the source quote.
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        24/11/2023
    */
    public List<Contract> selectContractsBySourceQuoteIds(List<Id> sourceQuoteIds) {      
        return (List<Contract>) Database.query(
            newQueryFactory(false, false, true)
            .selectField(Contract.Id)
            .selectField(Contract.ContractNumber)
            .selectField(Contract.ZRH_ContratoHolding__c)
            .selectField('Account.Name')
            .selectField('Account.ZRH_CodigoGrupoNegocio__c')
            .setCondition('SourceQuoteId IN :sourceQuoteIds')
            .toSOQL()
        );
    }
    
    /**
    *  @Description: Perform a query by the Id.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public List<Contract> selectByIds(Id recordId) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField('Account.Name');
        query.selectField('Account.ZRH_CodigoGrupoNegocio__c');
        query.selectField('OwnerId');
        query.selectField('EndDate');
        query.selectField('StartDate');
        query.setCondition('Id = :recordId');
        
        fflib_QueryFactory subQuey = query.subSelectQuery('ContractGroupPlans')
            .selectField('Id')
            .selectField('ZRH_Estado__c')
            .selectField('ZRH_Folio__c') 
            .selectField('ZRH_GrupoDeCobertura__c')
            .selectField('ZRH_PDFPolizaCreado__c')
            .selectField('ZRH_Periodo__c') 
            .setCondition('ZRH_TipoDeProducto__c = \'Product\'');
        
        return (List<Contract>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Perform a query by the AccountIds.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public List<Contract> selectByAccountIds(List<String> accountList) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField('Account.Name');
        query.selectField('OwnerId');
        query.selectField('EndDate');
        query.selectField('StartDate');
        query.setCondition('AccountId in :accountList');
        
        fflib_QueryFactory subQuey = query.subSelectQuery('ContractGroupPlans')
            .selectField('Id')
            .selectField('ZRH_Estado__c')
            .selectField('ZRH_Folio__c') 
            .selectField('ZRH_GrupoDeCobertura__c')
            .selectField('ZRH_PDFPolizaCreado__c')
            .selectField('ZRH_CodigoProducto__c')
            .selectField('ZRH_Periodo__c') 
            .setCondition('ZRH_TipoDeProducto__c = \'Product\'');
        
        return (List<Contract>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Perform a query by the Id and receiving the fields to which you want to query.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024
    */
    public Contract selectById(String recordId, List<String> fieldList) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        for(String field: fieldList){
            query.selectField(field);
        }
        query.setCondition('Id = :recordId');
        return (Contract) Database.query( query.toSOQL() );
    }
}