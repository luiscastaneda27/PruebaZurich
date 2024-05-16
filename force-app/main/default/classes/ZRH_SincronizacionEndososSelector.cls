/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 8/1/2024
Description  : Query factory for SincronizacionEndoso using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO		  8/1/2024		  initial version
********************************************************************************/
public class ZRH_SincronizacionEndososSelector extends fflib_SObjectSelector {

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024
    */
    public Schema.SObjectType getSObjectType(){
        return ZRH_SincronizacionEndoso__c.sObjectType;
    }
    
    
     /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            ZRH_SincronizacionEndoso__c.Id,
            ZRH_SincronizacionEndoso__c.ZRH_CampoCondicion__c,
            ZRH_SincronizacionEndoso__c.ZRH_CampoCondicionDos__c,
            ZRH_SincronizacionEndoso__c.ZRH_CampoCondicionTres__c,
            ZRH_SincronizacionEndoso__c.ZRH_GrupoNegocio__c,
            ZRH_SincronizacionEndoso__c.ZRH_Estado__c,
            ZRH_SincronizacionEndoso__c.ZRH_Folio__c,
            ZRH_SincronizacionEndoso__c.ZRH_NombreAtributo__c,
            ZRH_SincronizacionEndoso__c.ZRH_NombreCampo__c,
            ZRH_SincronizacionEndoso__c.ZRH_NombreObjeto__c,
            ZRH_SincronizacionEndoso__c.ZRH_ObservacionError__c,
            ZRH_SincronizacionEndoso__c.ZRH_TipoCampo__c,
            ZRH_SincronizacionEndoso__c.ZRH_TipoEndoso__c,
            ZRH_SincronizacionEndoso__c.ZRH_TipoObjeto__c,
            ZRH_SincronizacionEndoso__c.ZRH_Valor__c,
            ZRH_SincronizacionEndoso__c.ZRH_ValorCondicion__c,
            ZRH_SincronizacionEndoso__c.ZRH_ValorCondicionDos__c,
            ZRH_SincronizacionEndoso__c.ZRH_ValorCondicionTres__c
        };
    }
    
    
    /**
    *  @Description: Perform a query by the Condition as a parameter.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public Database.QueryLocator selectByDynamicCondition(String queryCondition) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.setCondition(queryCondition);
        return Database.getQueryLocator(query.toSOQL());
    }
}