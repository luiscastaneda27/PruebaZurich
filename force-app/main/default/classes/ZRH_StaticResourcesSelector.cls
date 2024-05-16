/*********************************************************************************
Project      : 
Created By   : Deloitte
Created Date : 26/09/2023
Description  : Query factory for StaticResorces using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			26/09/2023		initial version
********************************************************************************/
public without sharing class ZRH_StaticResourcesSelector extends fflib_SObjectSelector{

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/09/2023
    */
    public Schema.SObjectType getSObjectType(){
        return StaticResource.sObjectType;
    }

    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/09/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            StaticResource.Name, 
            StaticResource.NamespacePrefix,
            StaticResource.Body,
            StaticResource.SystemModStamp
        };
    }

    /**
    *  @Description: Perform a query with the default fields with the Name of StaticResources as a condition
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/09/2023
    */
    public StaticResource selectByStaticResourceNameWithLimit(String name){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Name = :name');
        query.setLimit( 1 );
        return (StaticResource) Database.query( query.toSOQL() );
    }
}