/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : Query factory for StaticResorces using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/09/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_GlosasSelector extends fflib_SObjectSelector{

    /**
    *  @Description: Static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    private static final Set<String> PVR_SET_TARGET;
    private static final String CODE_PARTICULAR_GLOSS;
    private static final String CODE_POLICY_GLOSS;

    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    static {
        PVR_SET_TARGET = fillSetTarget();
        CODE_PARTICULAR_GLOSS = 'G-003';
        CODE_POLICY_GLOSS = 'D-001';
    }    

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public Schema.SObjectType getSObjectType(){
        return ZRH_Glosas__c.sObjectType;
    }

    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            ZRH_Glosas__c.Id,
            ZRH_Glosas__c.OwnerId,
            ZRH_Glosas__c.IsDeleted,
            ZRH_Glosas__c.Name,
            ZRH_Glosas__c.CurrencyIsoCode,
            ZRH_Glosas__c.CreatedDate,
            ZRH_Glosas__c.CreatedById,
            ZRH_Glosas__c.LastModifiedDate,
            ZRH_Glosas__c.LastModifiedById,
            ZRH_Glosas__c.SystemModstamp,
            ZRH_Glosas__c.ZRH_Activo__c,
            ZRH_Glosas__c.ZRH_ContenidoGlosa__c,
            ZRH_Glosas__c.ZRH_ContieneTabla__c,
            ZRH_Glosas__c.ZRH_DestinoTipoPDF__c,
            ZRH_Glosas__c.ZRH_IDGlosa__c,
            ZRH_Glosas__c.ZRH_InsurancePolicy__c,
            ZRH_Glosas__c.ZRH_LocalizacionCondicionado__c,
            ZRH_Glosas__c.ZRH_NombreArticulo__c,
            ZRH_Glosas__c.ZRH_NumeroArticulo__c,
            ZRH_Glosas__c.ZRH_Parametros__c,
            ZRH_Glosas__c.ZRH_Plan__c,
            ZRH_Glosas__c.ZRH_QuoteLineItem__c,
            ZRH_Glosas__c.ZRH_Quote__c,
            ZRH_Glosas__c.ZRH_TipoDeGlosa__c,
            ZRH_Glosas__c.ZRH_Titulo__c,
            ZRH_Glosas__c.ZRH_PlanDelContrato__c,
            ZRH_Glosas__c.ZRH_Validaciones__c
        };
    }

    /**
    *  @Description: Perform a query with the default fields with the Name of Glosas as a condition
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public ZRH_Glosas__c selectByStaticResourceNameWithLimit(String name){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Name = :name');
        query.setLimit( 1 );
        return (ZRH_Glosas__c) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Perform a query with the default fields with the ZRH_Quote__c of Glosas as a condition
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public List<ZRH_Glosas__c> selectBySetIds(Set<ID> idSet, Set<ID> idSetQLI) {
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        fflib_SObjectSelector qliSelector = new ZRH_QuoteLineItemsSelector();
        qliSelector.configureQueryFactoryFields(query, 'ZRH_QuoteLineItem__r');
        query.setCondition('ZRH_DestinoTipoPDF__c IN :PVR_SET_TARGET AND ZRH_QuoteLineItem__c IN :idSetQLI');
        //query.setCondition('ZRH_QuoteLineItem__c IN :idSetQLI');
        //query.setCondition('ZRH_DestinoTipoPDF__c IN :PVR_SET_TARGET AND (ZRH_Quote__c IN :idSet OR ZRH_QuoteLineItem__c IN :idSetQLI)');
        query.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<ZRH_Glosas__c>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Perform a query with the default fields with the ZRH_QuoteLineItem__c of Glosas as a condition
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public List<ZRH_Glosas__c> selectByQLIId(Set<ID> idSet) {        
        fflib_QueryFactory query = newQueryFactory(false, false, true);        
        query.setCondition('ZRH_DestinoTipoPDF__c IN :PVR_SET_TARGET AND ZRH_QuoteLineItem__c IN :idSet');
        query.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<ZRH_Glosas__c>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Perform a query with the default fields with the ZRH_QuoteLineItem__c of Glosas as a condition
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<ZRH_Glosas__c> selectByQLIIdAndGlossType(String quoteLineItemId) {        
        fflib_QueryFactory query = newQueryFactory(false, false, true);        
        query.setCondition('ZRH_QuoteLineItem__c = :quoteLineItemId and ZRH_TipoDeGlosa__c != \''+ CODE_PARTICULAR_GLOSS +'\'');
        return (List<ZRH_Glosas__c>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Perform a query with the default fields with the ZRH_QuoteLineItem__c of Glosas as a condition
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<ZRH_Glosas__c> selectByContractGroupPlan(String recordId) {        
        fflib_QueryFactory query = newQueryFactory(false, false, true);
		query.selectField('ZRH_PlanDelContrato__r.ZRH_CodigoProducto__c');        
        query.setCondition('ZRH_PlanDelContrato__c = :recordId and ZRH_DestinoTipoPDF__c includes ( \''+ CODE_POLICY_GLOSS +'\')');
        return (List<ZRH_Glosas__c>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Perform a query with the default fields with the ZRH_QuoteLineItem__c
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<ZRH_Glosas__c> selectByQliIdOnly(String recordId) {        
        fflib_QueryFactory query = newQueryFactory(false, false, true);        
        query.setCondition('ZRH_QuoteLineItem__c = :recordId');
        query.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<ZRH_Glosas__c>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Filling of the static target variable
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public static Set<String> fillSetTarget() {
        return new Set<String>{'D-002', 'D-001;D-002'};
    }
}