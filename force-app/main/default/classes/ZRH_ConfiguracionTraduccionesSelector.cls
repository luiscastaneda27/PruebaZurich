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
public inherited sharing class ZRH_ConfiguracionTraduccionesSelector extends fflib_SObjectSelector {

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public Schema.SObjectType getSObjectType() {
        return ZRH_ConfiguracionTraduccion__mdt.sObjectType;
    }

    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ZRH_ConfiguracionTraduccion__mdt.Id,
            ZRH_ConfiguracionTraduccion__mdt.DeveloperName,
            ZRH_ConfiguracionTraduccion__mdt.MasterLabel,
            ZRH_ConfiguracionTraduccion__mdt.Language,
            ZRH_ConfiguracionTraduccion__mdt.NamespacePrefix,
            ZRH_ConfiguracionTraduccion__mdt.Label,
            ZRH_ConfiguracionTraduccion__mdt.QualifiedApiName,
            ZRH_ConfiguracionTraduccion__mdt.SystemModstamp,
            ZRH_ConfiguracionTraduccion__mdt.ZRH_Tag__c,
            ZRH_ConfiguracionTraduccion__mdt.ZRH_TraduccionFuncional__c,
            ZRH_ConfiguracionTraduccion__mdt.ZRH_Estructura__c,
            ZRH_ConfiguracionTraduccion__mdt.ZRH_SubEstructura__c,
            ZRH_ConfiguracionTraduccion__mdt.ZRH_Objeto__c,
            ZRH_ConfiguracionTraduccion__mdt.ZRH_Campo__c,
            ZRH_ConfiguracionTraduccion__mdt.ZRH_Plan__c,
            ZRH_ConfiguracionTraduccion__mdt.ZRH_Orden__c
        };
    }

    /**
    *  @Description: Perform a query with the default fields with the Name of Glosas as a condition
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public List<ZRH_ConfiguracionTraduccion__mdt> selectAll() {
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        return (List<ZRH_ConfiguracionTraduccion__mdt>) Database.query( query.toSOQL() );
    }
}