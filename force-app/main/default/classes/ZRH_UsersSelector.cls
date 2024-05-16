/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : Query factory for Users using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/09/2023		initial version
********************************************************************************/
public class ZRH_UsersSelector extends fflib_SObjectSelector{

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public Schema.SObjectType getSObjectType(){
        return User.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       LEC, lcastanedad@deloitte.com
    *  @Date:        27/09/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            User.Id,
            User.Name,
            User.Email,
            User.ZRH_Rut__c
        };
    }
    
    /**
    *  @Description: Perform a query with the default fields with the Id of User as a condition
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public User selectById(String recordId) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.setCondition('Id = :recordId');
        return (User) Database.query( query.toSOQL() );
    }

}