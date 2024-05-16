/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : Query factory for StaticResorces using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/09/2023		initial version
********************************************************************************/
public class ZRH_QuoteLineItemsSelector extends fflib_SObjectSelector {
	
    public Schema.SObjectType getSObjectType() {
        return QuoteLineItem.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            	QuoteLineItem.Id,
                QuoteLineItem.Product2Id,
                QuoteLineItem.QuoteId,
                QuoteLineItem.ZRH_AtributosRequisitosAsegurabilidad__c,
                QuoteLineItem.ZRH_AtributosBMI__c,
                QuoteLineItem.ZRH_Tarifa__c,
                QuoteLineItem.ZRH_TarifaModificada__c,
                QuoteLineItem.ZRH_TipoTarifa__c,
                QuoteLineItem.ZRH_TipoTarifaPrevia__c,
                QuoteLineItem.ZRH_AtributosReqMedicosSeleccionado__c,
                QuoteLineItem.ZRH_CodigoProducto__c,
                QuoteLineItem.ZRH_AtributosConvenios__c,
                QuoteLineItem.vlocity_ins__AttributeSelectedValues__c,
                QuoteLineItem.vlocity_ins__ParentItemId2__c,
                QuoteLineItem.vlocity_ins__ProductChildItemId__c,
                QuoteLineItem.vlocity_ins__ProductName__c,
                QuoteLineItem.vlocity_ins__RecordTypeName__c,
                QuoteLineItem.ZRH_NumeroDePlanesEnContratantes__c
            };
    }

    public Map<Id,QuoteLineItem> selectProductsBySetIds(Set<ID> idSet){
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField('Quote.ZRH_AtributosSobreprimasSeleccionados__c');
        query.setCondition('vlocity_ins__RecordTypeName__c  = \'Product\' AND QuoteId IN :idSet');
        query.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return new Map<Id,QuoteLineItem>((List<QuoteLineItem>) Database.query(query.toSOQL()));
    }

    
    public List<QuoteLineItem> selectCoverageBySetIds(Set<ID> idSet){
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.setCondition('QuoteId IN :idSet');
        query.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<QuoteLineItem>) Database.query(query.toSOQL());
    }
    
    public List<QuoteLineItem> selectByQuoteId(Set<ID> idSet) {
        return (List<QuoteLineItem>) Database.query(
            newQueryFactory(false, false, true)
            .selectField(QuoteLineItem.Id)    
            .selectField(QuoteLineItem.QuoteId)    
            .selectField(QuoteLineItem.Product2Id)
            .selectField(QuoteLineItem.vlocity_ins__AttributeSelectedValues__c)
            .selectField(QuoteLineItem.vlocity_ins__ParentItemId2__c)
            .selectField(QuoteLineItem.vlocity_ins__ProductChildItemId__c)
            .selectField('Product2.vlocity_ins__RecordTypeName__c')
            .selectField('Product2.Name')
            .selectField('Product2.ProductCode')   
            .selectField('Quote.ZRH_VigenciaInicio__c')   
            .selectField('Quote.ZRH_VigenciaTermino__c')   
            .setCondition('QuoteId IN :idSet')
            .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .toSOQL()
        );
    }

    public Database.QueryLocator selectChildAccountRootQLIsByParentQuoteId(Id quoteId) {      
        return Database.getQueryLocator(
            newQueryFactory(false, false, true)
            .selectField(QuoteLineItem.Id)
            .selectField(QuoteLineItem.ZRH_Tarifa__c)
            .selectField(QuoteLineItem.ZRH_TipoTarifa__c)
            .selectField(QuoteLineItem.Product2Id)
            .selectField(QuoteLineItem.PricebookEntryId)
            .selectField(QuoteLineItem.vlocity_ins__ParentItemId2__c)
            .selectField('Product2.vlocity_ins__Type__c')
            .selectField('Product2.ProductCode')
            .selectField('Quote.ZRH_CotizacionHolding__c')
            .setCondition('Quote.ZRH_CotizacionHolding__c =: quoteId AND Product2.RecordType.DeveloperName = \'Product\' AND ZRH_TipoTarifa__c != null')
            .toSOQL()
        );
    }

    public List<QuoteLineItem> selectChildRootQLIsByParentQuoteId(Id quoteId) {      
        return (List<QuoteLineItem>) Database.query(
            newQueryFactory(false, false, true)
            .selectField(QuoteLineItem.Id)
            .selectField(QuoteLineItem.ZRH_Tarifa__c)
            .selectField(QuoteLineItem.ZRH_TipoTarifa__c)
            .selectField(QuoteLineItem.Product2Id)
            .selectField(QuoteLineItem.PricebookEntryId)
            .selectField(QuoteLineItem.vlocity_ins__ParentItemId2__c)
            .selectField(QuoteLineItem.ZRH_TipoTarifaPrevia__c)
            .selectField(QuoteLineItem.ZRH_TarifaModificada__c)
            .selectField('Product2.vlocity_ins__Type__c')
            .selectField('Product2.ProductCode')
            .selectField('Quote.ZRH_CotizacionHolding__c')
            .setCondition('Quote.ZRH_CotizacionHolding__c =: quoteId AND Product2.RecordType.DeveloperName = \'Product\' AND ZRH_TipoTarifa__c != null')
            .toSOQL()
        );
    }

    public List<QuoteLineItem> selectById(Id quoteId) {
        return (List<QuoteLineItem>) Database.query(
            newQueryFactory(false, false, true)
            .selectField(QuoteLineItem.Id)
            .selectField(QuoteLineItem.ZRH_Tarifa__c)
            .selectField(QuoteLineItem.ZRH_TipoTarifa__c)
            .selectField(QuoteLineItem.Product2Id)
            .selectField(QuoteLineItem.PricebookEntryId)
            .selectField(QuoteLineItem.vlocity_ins__ParentItemId2__c)
            .selectField(QuoteLineItem.ZRH_NumeroDePlanesEnContratantes__c)
            .selectField('Product2.ProductCode')
            .selectField('Product2.Name')
            .selectField('Product2.vlocity_ins__Type__c') 
            .selectField('Quote.ZRH_CotizacionHolding__c')
            .selectField('Quote.ZRH_VigenciaInicio__c')   
            .selectField('Quote.ZRH_VigenciaTermino__c')   
            .setCondition('QuoteId =: quoteId')
            .toSOQL()
        );        
    }
    
    /**
    *  @Description: Perform a query with the default fields with the Id of Glosas as a condition
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<QuoteLineItem> selectByIdAndCoverages(String recordId, List<String> fieldList) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField('Product2.Name');
        for(String field: fieldList){
            query.selectField(field);
        }
        query.setCondition('Id = :recordId OR vlocity_ins__ParentItemId2__c = :recordId');
        query.addOrdering('vlocity_ins__ParentItemId2__c', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<QuoteLineItem>) Database.query( query.toSOQL() );
    }
    
    
    /**
    *  @Description: Make a query by quote item, receiving a list as a parameter.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<QuoteLineItem> selectByIdsList(List<String> recordList) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.setCondition('Id in :recordList');
        return (List<QuoteLineItem>) Database.query( query.toSOQL() );
    }
}