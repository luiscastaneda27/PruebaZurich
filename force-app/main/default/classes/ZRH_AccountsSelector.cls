/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : Query factory for Accounts using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/09/2023		initial version
********************************************************************************/
public class ZRH_AccountsSelector extends fflib_SObjectSelector{

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public Schema.SObjectType getSObjectType(){
        return Account.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       LEC, lcastanedad@deloitte.com
    *  @Date:        27/09/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.OwnerId,
            Account.IsDeleted,
            Account.Name,
            Account.ZRH_Rut__c

        };
    }
    
    /**
    *  @Description: Perform a query by the Id and receiving the fields to which you want to query.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public Account selectById(String recordId, List<String> fieldList) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        for(String field: fieldList){
            query.selectField(field);
        }
        query.setCondition('Id = :recordId');
        return (Account) Database.query( query.toSOQL() );
    }
    
     /**
    *  @Description: Perform a query by the Id of the Holding.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        20/11/2023
    */
    public List<Account> selectByHoldingId(String recordId) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.setCondition('ParentId = :recordId');
        return (List<Account>) Database.query( query.toSOQL() );
    }
    
     /**
    *  @Description: Perform a query of person accounts by list of ruts
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        19/02/2024
    */
    public List<Account> selectByRutsSet(Set<String> ruts) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(Account.Id);
        query.selectField(Account.ZRH_Rut__c);
        query.setCondition('ZRH_Rut__c IN :ruts AND RecordType.DeveloperName = \'PersonAccount\'');
        return (List<Account>) Database.query( query.toSOQL() );
    }

}