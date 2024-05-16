/*********************************************************************************
Project      : 
Created By   : Deloitte
Created Date : 19/10/2023
Description  : Query factory for Servicio Integracion using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			19/10/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_ServicioIntegracionesSelector  extends fflib_SObjectSelector{

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       Abdon Tejos Deloitte, atejoso@deloitte.com
    *  @Date:        19/10/2023
    */
    public Schema.SObjectType getSObjectType(){
        return ZRH_ServicioIntegracion__mdt.sObjectType;
    }

    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        19/10/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            ZRH_ServicioIntegracion__mdt.Id,
            ZRH_ServicioIntegracion__mdt.DeveloperName,
            ZRH_ServicioIntegracion__mdt.MasterLabel,
            ZRH_ServicioIntegracion__mdt.Language,
            ZRH_ServicioIntegracion__mdt.NamespacePrefix,
            ZRH_ServicioIntegracion__mdt.Label,
            ZRH_ServicioIntegracion__mdt.QualifiedApiName,
            ZRH_ServicioIntegracion__mdt.SystemModstamp,
            ZRH_ServicioIntegracion__mdt.ZRH_URLBase__c
        };
    }

    /**
    *  @Description: Perform a query with the default fields with the DeveloperName of Servicio Integracion as a condition
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        19/10/2023
    */
    public List<ZRH_ServicioIntegracion__mdt>  selectAll(){
        fflib_QueryFactory query = newQueryFactory();
        return (List<ZRH_ServicioIntegracion__mdt> ) Database.query( query.toSOQL() );
    }
}