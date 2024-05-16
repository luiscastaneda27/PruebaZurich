/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 17/11/2023
Description  : Query factory for ContractGroupPlan using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			17/11/2023		initial version
********************************************************************************/
public class ZRH_ContractGroupPlansSelector extends fflib_SObjectSelector{
    
    
    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public Schema.SObjectType getSObjectType(){
        return ContractGroupPlan.sObjectType;
    }
    
    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            ContractGroupPlan.Id,
                ContractGroupPlan.EffectiveStartDate,
                ContractGroupPlan.EffectiveEndDate,
                ContractGroupPlan.Name,
                ContractGroupPlan.ZRH_Folio__c,
                ContractGroupPlan.ZRH_NumeroDePoliza__c,
                ContractGroupPlan.ZRH_AtributosTopes__c,
                ContractGroupPlan.ZRH_AtributosRequisitosAsegurabilidad__c,
                ContractGroupPlan.ZRH_AtributosReqMedicosSeleccionado__c,
                ContractGroupPlan.ZRH_Tarifa__c,
                ContractGroupPlan.ZRH_TipoTarifa__c,
                ContractGroupPlan.vlocity_ins_fsc__AttributeSelectedValues__c,
                ContractGroupPlan.ZRH_Estado__c,
                ContractGroupPlan.ZRH_CodigoProducto__c,
                ContractGroupPlan.ZRH_Periodo__c,
                ContractGroupPlan.ZRH_EsRenovacion__c,
                ContractGroupPlan.QuoteLineItemId,
                ContractGroupPlan.ContractGroupParentPlanId,
                ContractGroupPlan.vlocity_ins_fsc__Product2Id__c
                };
                    }
    
    /**
    *  @Description: Perform a query by the Id and receiving the fields to which you want to query.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023
    */
    public Database.QueryLocator selectByDynamicCondition(String queryCondition) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField('Contract.Account.Name');
        query.selectField('Contract.Account.ZRH_SucursalRecepcion__c');
        query.selectField('Contract.Account.ShippingAddress');
        query.selectField('Contract.Account.ShippingCity');
        query.selectField('Contract.Account.ShippingState');
        query.selectField('Contract.Account.ZRH_Rut__c');
        query.selectField('Contract.Status');
        query.selectField('Contract.StartDate');
        query.selectField('Contract.EndDate');
        query.selectField('Contract.vlocity_ins__EnrollmentEndDate__c');
        query.selectField('Contract.OwnerId');
        query.selectField('Contract.Owner.Name');
        query.selectField('Contract.CurrencyIsoCode');
        query.selectField('Contract.Owner.ZRH_Rut__c');
        query.selectField('Contract.ZRH_ComisionCorredor__c');
        query.selectField('Contract.SourceQuoteId');
        query.selectField('Contract.SourceQuote.ZRH_EjecutivoPropietario__c');
        query.selectField('Contract.ZRH_NombreCorredor__c');
        query.selectField('Contract.ZRH_ComisionCorredor__c');
        query.selectField('Contract.SourceQuote.QuoteNumber');
        query.selectField('Contract.SourceQuote.vlocity_ins_fsc__GroupCensusStdId__c');
        query.selectField('Contract.vlocity_ins__AgencyBrokerageId__r.ZRH_Rut__c');
        query.selectField('Contract.ZRH_AtributosSobreprimasSeleccionados__c');
        query.selectField('Contract.ZRH_Holding__r.ZRH_CodigoGrupoNegocio__c');
        query.selectField('Contract.ZRH_Holding__r.Name');
        query.selectField('Contract.SourceQuote.Opportunity.Owner.ZRH_Rut__c');
        query.selectField('vlocity_ins_fsc__Product2Id__r.Name');
        query.setCondition(queryCondition);
        
        fflib_QueryFactory rsQF = query.subSelectQuery('ChildContractGroupPlans')
            .selectField('Name')
            .selectField('vlocity_ins_fsc__AttributeSelectedValues__c')
            .selectField('ZRH_CodigoProducto__c')
            .selectField('ZRH_GrupoDeCobertura__c')
            .selectField('vlocity_ins_fsc__Product2Id__r.vlocity_ins__AttributeDefaultValues__c')
            .selectField('vlocity_ins_fsc__Product2Id__r.Name')
            .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING);
        
        return Database.getQueryLocator(query.toSOQL());
    }
    
    /**
    *  @Description: Make a query for a holding Quote
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<ContractGroupPlan> selectByRelatedQuotes(Set<Id> quoteIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(ContractGroupPlan.Id);
        query.selectField(ContractGroupPlan.ContractGroupParentPlanId);
        query.selectField(ContractGroupPlan.Name);
        query.selectField(ContractGroupPlan.vlocity_ins_fsc__Product2Id__c);
        query.selectField(ContractGroupPlan.vlocity_ins_fsc__AttributeSelectedValues__c);
        query.selectField('Contract.EndDate');
        query.selectField('Contract.SourceQuoteId');
        query.selectField('vlocity_ins_fsc__Product2Id__r.vlocity_ins__Type__c');
        query.setCondition('QuoteLineItem.QuoteId IN :quoteIds');
        return (List<ContractGroupPlan>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Perform a query to the ContractGroupPlan by the Id of the ContractGroupPlan.
    *  @Autor:       Jean Nieto, Deloitte, jnieto@deloitte.com
    *  @Date:        14/02/2024
    */
    public List<ContractGroupPlan> selectContractGroupPlanById(Id ContractGroupPlanId) {      
        return (List<ContractGroupPlan>) Database.query(
            newQueryFactory(false, false, true)
            .selectField(ContractGroupPlan.Id)
            .selectField(ContractGroupPlan.vlocity_ins_fsc__AttributeSelectedValues__c)
            .selectField('vlocity_ins_fsc__Product2Id__r.vlocity_ins__AttributeMetadata__c')
            .setCondition('Id = :ContractGroupPlanId')
            .toSOQL()
        );
    }
    
    
    /**
    *  @Description: Query for parent plans from list of contracts
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        2/10/2023
    */
    public List<ContractGroupPlan> selectParentPlansByContractIds(Set<Id> contractIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(ContractGroupPlan.Id);
        query.setCondition('ContractId IN :contractIds AND ContractGroupParentPlanId = null');
        return (List<ContractGroupPlan>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Query for parent plans from list of policy numbers
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        29/12/2023
    */
    public List<ContractGroupPlan> selectPlansAndCoveragesByPolicyNumbers(Set<String> policyNumbers) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(ContractGroupPlan.Id);
        query.selectField(ContractGroupPlan.ContractGroupParentPlanId);
        query.selectField(ContractGroupPlan.Name);
        query.selectField(ContractGroupPlan.vlocity_ins_fsc__Product2Id__c);
        query.selectField(ContractGroupPlan.vlocity_ins_fsc__AttributeSelectedValues__c);
        query.selectField(ContractGroupPlan.ZRH_NumeroDePoliza__c);
        query.selectField(ContractGroupPlan.ZRH_Folio__c);
        query.selectField('Contract.EndDate');
        query.selectField('Contract.SourceQuoteId');
        query.selectField('vlocity_ins_fsc__Product2Id__r.vlocity_ins__Type__c');
        query.setCondition('ZRH_NumeroDePoliza__c IN :policyNumbers OR ContractGroupParentPlan.ZRH_NumeroDePoliza__c IN :policyNumbers');
        return (List<ContractGroupPlan>) Database.query( query.toSOQL() );
    }
    
    /**
    *  @Description: Perform a query with the default fields with the Id of Glosas as a condition
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        5/1/2023
    */
    public List<ContractGroupPlan> selectByIdAndCoverages(String recordId, List<String> fieldList) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField('vlocity_ins_fsc__Product2Id__r.Name');
        for(String field: fieldList){
            query.selectField(field);
        }
        query.setCondition('Id = :recordId OR ContractGroupParentPlanId = :recordId');
        query.addOrdering('ContractGroupParentPlanId', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<ContractGroupPlan>) Database.query( query.toSOQL() );
    }
    
    
    /**
    *  @Description: Perform a query by the Id and receiving ids for policy.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024
    */
    public Database.QueryLocator selectByEndorsementSentTrue() { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.setCondition('ZRH_EndosoEnviado__c = true');
        return Database.getQueryLocator(query.toSOQL());
    }
    
    
    /**
    *  @Description: Perform a query by the Id and receiving ids for policy.
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024
    */
    public List<ContractGroupPlan> selectByFolio(String condition, List<String> fieldList) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        for(String field: fieldList){
            query.selectField(field);
        }
        query.setCondition(condition);
        
        fflib_QueryFactory rsQF = query.subSelectQuery('ChildContractGroupPlans')
            .selectField('vlocity_ins_fsc__AttributeSelectedValues__c')
            .selectField('ZRH_CodigoProducto__c')
            .selectField('ZRH_GrupoDeCobertura__c')
            .selectField('vlocity_ins_fsc__Product2Id__r.Name');
        return (List<ContractGroupPlan>) Database.query( query.toSOQL() );
    }

    /**
    *  @Description: Query cgps by source quote ids and record type developer name
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        20/02/2024
    */
    public List<ContractGroupPlan> selectPlansBySourceQuoteIdAndRecTypeDeveloperName(List<Id> quoteIds, String recordTypeName) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(ContractGroupPlan.Id);
        query.setCondition('Contract.SourceQuoteId IN :quoteIds AND vlocity_ins_fsc__Product2Id__r.RecordType.DeveloperName =: recordTypeName');
        return (List<ContractGroupPlan>) Database.query( query.toSOQL() );
    }
    
    
}