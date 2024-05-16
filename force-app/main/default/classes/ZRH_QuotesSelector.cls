/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : Query factory for Quotes using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/09/2023		initial version
********************************************************************************/
public class ZRH_QuotesSelector extends fflib_SObjectSelector{

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public Schema.SObjectType getSObjectType(){
        return Quote.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Quote.Id,
            Quote.OwnerId,
            Quote.IsDeleted,
            Quote.Name,
            Quote.AccountId,
            Quote.Pricebook2Id,
            Quote.vlocity_ins__AgencyBrokerageId__c,
            Quote.vlocity_ins__ProducerId__c,
            Quote.ZRH_Holding__c,
            Quote.ZRH_Moneda__c,
            Quote.ZRH_CotizacionHolding__c,
            Quote.ZRH_CuentasDEF__c,
            Quote.ZRH_IdJobCreacionPolizas__c,
            Quote.vlocity_ins_fsc__GroupCensusStdId__c,
            Quote.vlocity_ins__AgencyBrokerageId__c,
            Quote.vlocity_ins__ProducerId__c,
            Quote.vlocity_ins__UnderwriterId__c,
            Quote.ZRH_AtributosAsistenciasSeleccionados__c,
            Quote.ZRH_AtributosConveniosLineaSeleccionados__c,
            Quote.ZRH_AtributosConveniosSeleccionados__c,
            Quote.ZRH_AtributosSobreprimasSeleccionados__c,
            Quote.ZRH_CoberturaEnElExterior__c,
            Quote.ZRH_ComisionCorredor__c,
            Quote.ZRH_ConsideraTopePreexistencias__c,
            Quote.ZRH_CualesPreexistencias__c,
            Quote.ZRH_CubrePreexistencias__c,
            Quote.ZRH_CubreTodasPreexistencias__c,
            Quote.ZRH_FondoLibreDisposicion__c,
            Quote.ZRH_Holding__c,
            Quote.ZRH_Moneda__c,
            Quote.ZRH_MontoAnualFondo__c,
            Quote.ZRH_MontoTopePreexistencias__c,
            Quote.ZRH_NivelAsistencia__c,
            Quote.ZRH_NivelConvenio__c,
            Quote.ZRH_NivelConvenioLinea__c,
            Quote.ZRH_NivelDeCoberturaEnElExterior__c,
            Quote.ZRH_NivelFondoLibreDisposicion__c,
            Quote.ZRH_NivelPreexistencia__c,
            Quote.ZRH_NivelSobreprima__c,
            Quote.ZRH_NumeroDiasLibrePreexistencias__c,
            Quote.ZRH_PrimaTotalAnual_UF__c,
            Quote.ZRH_PrimaTotalAnualUF_Salud__c,
            Quote.ZRH_PrimaTotalAnualUF_Vida__c,
            Quote.ZRH_TipoTopePreexistencias__c,
            Quote.ZRH_TopeDeCobertura__c,
            Quote.ZRH_TopeTodasPreexistencias__c,
            Quote.ZRH_VigenciaInicio__c,
            Quote.ZRH_VigenciaTermino__c
        };
    }
    
    
    /**
    *  @Description: Perform a query by the Id and receiving the fields to which you want to query.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public Quote selectById(String recordId, List<String> fieldList) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField('Opportunity.OwnerId');
        for(String field: fieldList){
            query.selectField(field);
        }
        query.setCondition('Id = :recordId');
        return (Quote) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Make a query for a holding Quote
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<Quote> selectByQuoteHolding(String recordId) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(Quote.ZRH_AtributosCondicionadosParticulares__c);
        query.selectField('ZRH_CotizacionHolding__r.ZRH_RenovacionFlag__c'); 
        query.setCondition('ZRH_CotizacionHolding__c = :recordId');
        return (List<Quote>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Get quotes from list of ids
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        30/10/2023
    */
    public Database.QueryLocator selectQuotesByIds(List<Id> quoteIds) { 
        return Database.getQueryLocator(
            newQueryFactory(false, false, true)
            .selectField(Quote.Id)            
            .selectField(Quote.ZRH_CotizacionHolding__c)            
            .selectField('Opportunity.AccountId')            
            .setCondition('Id IN :quoteIds')
            .toSOQL()
            );
    }

    /**
    *  @Description: Get quotes group
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        30/10/2023
    */
    public List<Quote> selectQuotesForGroup(Id quoteId) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(Quote.Id);           
        query.selectField(Quote.ZRH_CotizacionHolding__c);            
        query.selectField(Quote.vlocity_ins_fsc__GroupCensusStdId__c);
        query.selectField('Opportunity.AccountId');            
        query.setCondition('Id = :quoteId OR ZRH_CotizacionHolding__c = :quoteId');
        return (List<Quote>) Database.query( query.toSOQL() );
    }

        /**
    *  @Description: Get quotes group
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        19/12/2023
    */
    public List<Quote> selectQuotesFromGroupHolding(Id quoteId) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(Quote.Id);           
        query.selectField(Quote.ZRH_CotizacionHolding__c);            
        query.selectField(Quote.vlocity_ins_fsc__GroupCensusStdId__c);
        query.selectField('Opportunity.AccountId');            
        query.setCondition('ZRH_CotizacionHolding__c = :quoteId');
        return (List<Quote>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Get quote by set id
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        19/12/2023
    */
    public List<Quote> selectQuotesById(Set<Id> quoteIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(Quote.Id);           
        query.selectField(Quote.ZRH_CotizacionHolding__c);                                        
        query.selectField(Quote.Pricebook2Id);                    
        query.selectField(Quote.vlocity_ins__AgencyBrokerageId__c);                    
        query.selectField(Quote.vlocity_ins__ProducerId__c);
        query.selectField(Quote.vlocity_ins__UnderwriterId__c);
        query.selectField(Quote.ZRH_AtributosAsistenciasSeleccionados__c);
        query.selectField(Quote.ZRH_AtributosConveniosLineaSeleccionados__c);
        query.selectField(Quote.ZRH_AtributosConveniosSeleccionados__c);
        query.selectField(Quote.ZRH_AtributosSobreprimasSeleccionados__c);
        query.selectField(Quote.ZRH_CoberturaEnElExterior__c);
        query.selectField(Quote.ZRH_ComisionCorredor__c);
        query.selectField(Quote.ZRH_ConsideraTopePreexistencias__c);
        query.selectField(Quote.ZRH_CualesPreexistencias__c);
        query.selectField(Quote.ZRH_CubrePreexistencias__c);
        query.selectField(Quote.ZRH_CubreTodasPreexistencias__c);
        query.selectField(Quote.ZRH_FondoLibreDisposicion__c);
        query.selectField(Quote.ZRH_Holding__c);
        query.selectField(Quote.ZRH_Moneda__c);
        query.selectField(Quote.ZRH_MontoAnualFondo__c);
        query.selectField(Quote.ZRH_MontoTopePreexistencias__c);
        query.selectField(Quote.ZRH_NivelAsistencia__c);
        query.selectField(Quote.ZRH_NivelConvenio__c);
        query.selectField(Quote.ZRH_NivelConvenioLinea__c);
        query.selectField(Quote.ZRH_NivelDeCoberturaEnElExterior__c);
        query.selectField(Quote.ZRH_NivelFondoLibreDisposicion__c);
        query.selectField(Quote.ZRH_NivelPreexistencia__c);
        query.selectField(Quote.ZRH_NivelSobreprima__c);
        query.selectField(Quote.ZRH_NumeroDiasLibrePreexistencias__c);
        query.selectField(Quote.ZRH_PrimaTotalAnual_UF__c);
        query.selectField(Quote.ZRH_PrimaTotalAnualUF_Salud__c);
        query.selectField(Quote.ZRH_PrimaTotalAnualUF_Vida__c);
        query.selectField(Quote.ZRH_TipoTopePreexistencias__c);
        query.selectField(Quote.ZRH_TopeDeCobertura__c);
        query.selectField(Quote.ZRH_TopeTodasPreexistencias__c);
        query.selectField(Quote.Quote.vlocity_ins__ProducerId__c);                    
        query.selectField(Quote.Quote.ZRH_VigenciaInicio__c);                    
        query.selectField(Quote.Quote.ZRH_VigenciaTermino__c);                    
        query.selectField('Opportunity.AccountId');            
        query.setCondition('Id IN :quoteIds');
        return (List<Quote>) Database.query( query.toSOQL() );
    }


}