/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : Query factory for master gloss using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR            DATE              Description
1.0      ATO			27/09/2023		  initial version
********************************************************************************/
public class ZRH_MaestroGlosasSelector extends fflib_SObjectSelector{
    
    
    
    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/09/2023
    */
    public Schema.SObjectType getSObjectType(){
        return ZRH_MaestroGlosas__c.sObjectType;
    }
    
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            ZRH_MaestroGlosas__c.Id,
            ZRH_MaestroGlosas__c.OwnerId,
            ZRH_MaestroGlosas__c.IsDeleted,
            ZRH_MaestroGlosas__c.Name,
            ZRH_MaestroGlosas__c.CurrencyIsoCode,
            ZRH_MaestroGlosas__c.CreatedDate,
            ZRH_MaestroGlosas__c.CreatedById,
            ZRH_MaestroGlosas__c.LastModifiedDate,
            ZRH_MaestroGlosas__c.LastModifiedById,
            ZRH_MaestroGlosas__c.ZRH_LogicaCondiciones__c,
            ZRH_MaestroGlosas__c.SystemModstamp,
            ZRH_MaestroGlosas__c.ZRH_Activo__c,
            ZRH_MaestroGlosas__c.ZRH_ContenidoGlosa__c,
            ZRH_MaestroGlosas__c.ZRH_ContieneTabla__c,
            ZRH_MaestroGlosas__c.ZRH_DestinoTipoPDF__c,
            ZRH_MaestroGlosas__c.ZRH_IDGlosa__c,
            ZRH_MaestroGlosas__c.ZRH_LocalizacionCondicionado__c,
            ZRH_MaestroGlosas__c.ZRH_NombreArticulo__c,
            ZRH_MaestroGlosas__c.ZRH_NumeroArticulo__c,
            ZRH_MaestroGlosas__c.ZRH_Parametros__c,
            ZRH_MaestroGlosas__c.ZRH_Plan__c,
            ZRH_MaestroGlosas__c.ZRH_TipoDeGlosa__c,
            ZRH_MaestroGlosas__c.ZRH_Titulo__c,
            ZRH_MaestroGlosas__c.ZRH_Validaciones__c
        };
    }
    
    /**
    *  @Description: Perform a query with the default fields with the plan code of Glosas as a condition
    *  @Autor:       Luis Castañeda Donaire, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/09/2023
    */
    public List<ZRH_MaestroGlosas__c> selectByPlanCode(String planCode){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('ZRH_Activo__c = true and ZRH_Plan__c INCLUDES (:planCode)');
        return (List<ZRH_MaestroGlosas__c>) Database.query( query.toSOQL() );
    }

}