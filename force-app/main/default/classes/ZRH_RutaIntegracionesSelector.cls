/*********************************************************************************
Project      : 
Created By   : Deloitte
Created Date : 19/10/2023
Description  : Query factory for Ruta Integracion using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			19/10/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_RutaIntegracionesSelector  extends fflib_SObjectSelector{

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       Abdon Tejos Deloitte, atejoso@deloitte.com
    *  @Date:        19/10/2023
    */
    public Schema.SObjectType getSObjectType(){
        return ZRH_RutaIntegracion__mdt.sObjectType;
    }

    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        19/10/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            ZRH_RutaIntegracion__mdt.Id,
            ZRH_RutaIntegracion__mdt.DeveloperName,
            ZRH_RutaIntegracion__mdt.MasterLabel,
            ZRH_RutaIntegracion__mdt.Language,
            ZRH_RutaIntegracion__mdt.NamespacePrefix,
            ZRH_RutaIntegracion__mdt.Label,
            ZRH_RutaIntegracion__mdt.QualifiedApiName,
            ZRH_RutaIntegracion__mdt.SystemModstamp,
            ZRH_RutaIntegracion__mdt.ZRH_Cabeceras__c,
            ZRH_RutaIntegracion__mdt.ZRH_Metodo__c,
            ZRH_RutaIntegracion__mdt.ZRH_RutaURL__c,
            ZRH_RutaIntegracion__mdt.ZRH_ServicioIntegracion__c
        };
    }

    /**
    *  @Description: Perform a query with the default fields with the DeveloperName of Ruta Integracion as a condition
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        19/10/2023
    */
    public List<ZRH_RutaIntegracion__mdt> selectAll(){
        fflib_QueryFactory query = newQueryFactory();
        return (List<ZRH_RutaIntegracion__mdt>) Database.query( query.toSOQL() );
    }
}