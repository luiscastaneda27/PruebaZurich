public class ZRH_CreateContractsFromQuotesBatch implements Database.Batchable<SObject>, Database.Stateful{

    /**
    *  @Description: Variables
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/02/2024  
    */
    private static final String INTEGRATION_PROCEDURE_NAME = 'zrhCrearContratos_SegurosColectivos';
    private static final String QUEUEABLE_CHAINABLE_OPT = 'queueableChainable';
    private static final String QUOTE_ID = 'IdCotizacion';
    private static final String CONTRACT_ID = 'IdContrato';
    private static final String COVERAGE_RECORD_TYPE = 'CoverageSpec';
    private static final String PRODUCT_RECORD_TYPE = 'Product';
    private static final String CONTRACT_STATUS = '2';
    private static final String PLAN_STATUS = 'Active';

    public List<Id> quoteIds = new List<Id>();

    public ZRH_CreateContractsFromQuotesBatch(List<Id> quotes){
        quoteIds = quotes;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        Database.QueryLocator quotesToUse = new ZRH_QuotesSelector().selectQuotesByIds(quoteIds);
        return quotesToUse;
    }

    public void execute(Database.BatchableContext BC, List<Quote> scope){
        // set ids
        Set<Id> qIds = new Set<Id>();
        for (Quote quote : scope) {
            qIds.add(quote.Id);
        }

        // query records
        List<Quote> quotes = new ZRH_QuotesSelector().selectQuotesById(qIds);
        List<QuoteLineItem> qlis = new ZRH_QuoteLineItemsSelector().selectByQuoteId(qIds);

        // maps
        Map<Id, List<QuoteLineItem>> sourceQuoteIdToCoverage = new Map<Id, List<QuoteLineItem>>();
        Map<Id, List<QuoteLineItem>> sourceQuoteIdToRoot = new Map<Id, List<QuoteLineItem>>();

        for (QuoteLineItem qli : qlis) {
            if (qli.vlocity_ins__ParentItemId2__c != null) {
                // coverages
                if (!sourceQuoteIdToCoverage.containsKey(qli.QuoteId)) {
                    sourceQuoteIdToCoverage.put(qli.QuoteId, new List<QuoteLineItem>());
                }
                sourceQuoteIdToCoverage.get(qli.QuoteId).add(qli);
            } else {
                // roots
                if (!sourceQuoteIdToRoot.containsKey(qli.QuoteId)) {
                    sourceQuoteIdToRoot.put(qli.QuoteId, new List<QuoteLineItem>());
                }
                sourceQuoteIdToRoot.get(qli.QuoteId).add(qli);
            }

        }

        // collections
        List<Contract> contracts = new List<Contract>();
        List<ContractGroupPlan> rootPlans = new List<ContractGroupPlan>();
        List<ContractGroupPlan> coveragePlans = new List<ContractGroupPlan>();
        List<ContractGroupPlan> allPlans = new List<ContractGroupPlan>();
        Map<Id,ContractGroupPlan> parentQliToParentCgp = new Map<Id,ContractGroupPlan>();
        
        // create contracts
        for (Quote quote : quotes) {            
            Contract cont = new Contract();
            cont.AccountId = quote.Opportunity.AccountId;
            cont.Pricebook2Id = quote.Pricebook2Id;
            cont.SourceQuoteId = quote.Id;
            cont.StartDate = quote.ZRH_VigenciaInicio__c;
            cont.vlocity_ins__EnrollmentEndDate__c = quote.ZRH_VigenciaTermino__c;
            cont.Name = quote.Opportunity.AccountId;
            cont.vlocity_ins__AgencyBrokerageId__c = quote.vlocity_ins__AgencyBrokerageId__c;
            cont.vlocity_ins__ProducerId__c = quote.vlocity_ins__ProducerId__c;
            cont.vlocity_ins__UnderwriterId__c = quote.vlocity_ins__UnderwriterId__c;
            cont.ZRH_AtributosAsistenciasSeleccionados__c = quote.ZRH_AtributosAsistenciasSeleccionados__c;
            cont.ZRH_AtributosConveniosLineaSeleccionados__c = quote.ZRH_AtributosConveniosLineaSeleccionados__c;
            cont.ZRH_AtributosConveniosSeleccionados__c = quote.ZRH_AtributosConveniosSeleccionados__c;
            cont.ZRH_AtributosSobreprimasSeleccionados__c = quote.ZRH_AtributosSobreprimasSeleccionados__c;
            cont.ZRH_CoberturaEnElExterior__c = quote.ZRH_CoberturaEnElExterior__c;
            cont.ZRH_ComisionCorredor__c = quote.ZRH_ComisionCorredor__c;
            cont.ZRH_ConsideraTopePreexistencias__c = quote.ZRH_ConsideraTopePreexistencias__c;
            cont.ZRH_CualesPreexistencias__c = quote.ZRH_CualesPreexistencias__c;
            cont.ZRH_CubrePreexistencias__c = quote.ZRH_CubrePreexistencias__c;
            cont.ZRH_CubreTodasPreexistencias__c = quote.ZRH_CubreTodasPreexistencias__c;
            cont.ZRH_FondoLibreDisposicion__c = quote.ZRH_FondoLibreDisposicion__c;
            cont.ZRH_Holding__c = quote.ZRH_Holding__c;
            cont.ZRH_Moneda__c = quote.ZRH_Moneda__c;
            cont.ZRH_MontoAnualFondo__c = quote.ZRH_MontoAnualFondo__c;
            cont.ZRH_MontoTopePreexistencias__c = quote.ZRH_MontoTopePreexistencias__c;
            cont.ZRH_NivelAsistencia__c = quote.ZRH_NivelAsistencia__c; 
            cont.ZRH_NivelConvenio__c = quote.ZRH_NivelConvenio__c;
            cont.ZRH_NivelConvenioLinea__c = quote.ZRH_NivelConvenioLinea__c;
            cont.ZRH_NivelDeCoberturaEnElExterior__c = quote.ZRH_NivelDeCoberturaEnElExterior__c; 
            cont.ZRH_NivelFondoLibreDisposicion__c = quote.ZRH_NivelFondoLibreDisposicion__c;
            cont.ZRH_NivelPreexistencia__c = quote.ZRH_NivelPreexistencia__c;
            cont.ZRH_NivelSobreprima__c = quote.ZRH_NivelSobreprima__c;
            cont.ZRH_NumeroDiasLibrePreexistencias__c = quote.ZRH_NumeroDiasLibrePreexistencias__c;
            cont.ZRH_PrimaTotalAnual_UF__c = quote.ZRH_PrimaTotalAnual_UF__c;
            cont.ZRH_PrimaTotalAnualUF_Salud__c = quote.ZRH_PrimaTotalAnualUF_Salud__c;
            cont.ZRH_PrimaTotalAnualUF_Vida__c = quote.ZRH_PrimaTotalAnualUF_Vida__c;
            cont.ZRH_TipoTopePreexistencias__c = quote.ZRH_TipoTopePreexistencias__c;
            cont.ZRH_TopeDeCobertura__c = quote.ZRH_TopeDeCobertura__c;
            cont.ZRH_TopeTodasPreexistencias__c = quote.ZRH_TopeTodasPreexistencias__c;

            contracts.add(cont);
        }

        if (contracts.size() > 0) {
            insert contracts;
        }

        // create root contract group plans
        for (Contract cont : contracts) {
            
            if (!sourceQuoteIdToRoot.containsKey(cont.SourceQuoteId)) {
                continue;
            }
            List<QuoteLineItem> root = sourceQuoteIdToRoot.get(cont.SourceQuoteId);
            
            for (QuoteLineItem qli : root) {
                ContractGroupPlan cgp = new ContractGroupPlan();
                cgp.AccountId = cont.AccountId;
                cgp.ContractId = cont.Id;
                cgp.Name = qli.Product2.Name;
                cgp.QuoteLineItemId = qli.Id;
                cgp.Status = PLAN_STATUS;
                cgp.vlocity_ins_fsc__AttributeSelectedValues__c = qli.vlocity_ins__AttributeSelectedValues__c;
                cgp.vlocity_ins_fsc__Product2Id__c = qli.Product2Id;
                cgp.EnrollmentStartDate = qli.Quote.ZRH_VigenciaInicio__c;
                cgp.EnrollmentEndDate = qli.Quote.ZRH_VigenciaTermino__c;
                rootPlans.add(cgp);

                parentQliToParentCgp.put(qli.Id, cgp);
            }
        }    

        if (rootPlans.size() > 0) {
            insert rootPlans;
        }

        // create coverage contract group plans
        for (Contract cont : contracts) {

            if (!sourceQuoteIdToCoverage.containsKey(cont.SourceQuoteId)) {
                continue;
            }
            List<QuoteLineItem> coverages = sourceQuoteIdToCoverage.get(cont.SourceQuoteId);

            for (QuoteLineItem qli : coverages) {
                ContractGroupPlan cgp = new ContractGroupPlan();
                cgp.AccountId = cont.AccountId;
                cgp.ContractId = cont.Id;
                cgp.ContractGroupParentPlanId = parentQliToParentCgp.get(qli.vlocity_ins__ParentItemId2__c).Id;
                cgp.Name = qli.Product2.Name;
                cgp.QuoteLineItemId = qli.Id;
                cgp.Status = PLAN_STATUS;
                cgp.vlocity_ins_fsc__AttributeSelectedValues__c = qli.vlocity_ins__AttributeSelectedValues__c;
                cgp.vlocity_ins_fsc__Product2Id__c = qli.Product2Id;
                cgp.vlocity_ins_fsc__ProductChildItemId__c = qli.vlocity_ins__ProductChildItemId__c;
                cgp.EnrollmentStartDate = qli.Quote.ZRH_VigenciaInicio__c;
                cgp.EnrollmentEndDate = qli.Quote.ZRH_VigenciaTermino__c;
                coveragePlans.add(cgp);
            }
        }        

        if (coveragePlans.size() > 0) {
            insert coveragePlans;
        }
    }

    public void finish(Database.BatchableContext BC){

        AsyncApexJob a = new ZRH_AsyncApexJobsSelector().selectById(BC.getJobId())[0];
        
        // Email the Batch Job's submitter that the Job is finished.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        
        if (a.NumberOfErrors <= 0) {
            
            Id childQuoteId = quoteIds[0];
    

            List<String> quoteFields = new List<String>{'Id','AccountId', 'ZRH_CotizacionHolding__c', 'ZRH_CuentasDEF__c'};
            Quote childQuote = new ZRH_QuotesSelector().selectById(childQuoteId, quoteFields);
            Quote holdingQuote = new ZRH_QuotesSelector().selectById(childQuote.ZRH_CotizacionHolding__c, quoteFields);

            List<QuoteLineItem> listQLIHolding = new ZRH_QuoteLineItemsSelector().selectById(holdingQuote.Id);
    
            //Create holding contract
            Contract holdingContract = new Contract();
            holdingContract.AccountId = holdingQuote.AccountId;
            holdingContract.StartDate = holdingQuote.ZRH_VigenciaInicio__c;
            holdingContract.Status = CONTRACT_STATUS;
            holdingContract.vlocity_ins__EnrollmentEndDate__c = holdingQuote.ZRH_VigenciaTermino__c;
            holdingContract.SourceQuoteId = holdingQuote.Id;
            holdingContract.ZRH_CuentasDEF__c = holdingQuote.ZRH_CuentasDEF__c;
            insert holdingContract;

            List<ContractGroupPlan> holdingContractGroupPlans = new List<ContractGroupPlan>();

            for (QuoteLineItem qli : listQLIHolding) {
                ContractGroupPlan cgp = new ContractGroupPlan();
                cgp.ContractId = holdingContract.Id;
                cgp.vlocity_ins_fsc__Product2Id__c = qli.Product2Id;
                cgp.QuoteLineItemId = qli.Id;
                cgp.ZRH_Tarifa__c = qli.ZRH_Tarifa__c;
                cgp.ZRH_TipoTarifa__c = qli.ZRH_TipoTarifa__c;
                cgp.Name = qli.Product2.Name;
                cgp.EnrollmentStartDate = qli.Quote.ZRH_VigenciaInicio__c;
                cgp.EnrollmentEndDate = qli.Quote.ZRH_VigenciaTermino__c;
                holdingContractGroupPlans.add(cgp);
            }
            if (holdingContractGroupPlans.size() > 0) {
                insert holdingContractGroupPlans;
            }
            
            //Link child contracts to holding contract
            List<Contract> childContracts = new ZRH_ContractsSelector().selectContractsBySourceQuoteIds(quoteIds);
            for (Contract ct : childContracts) {
                ct.ZRH_ContratoHolding__c = holdingContract.Id;
                ct.Status = CONTRACT_STATUS;
            }
    
            upsert childContracts;  

            //Lock quotes
            List<Quote> quotesToLock = new ZRH_QuotesSelector().selectQuotesForGroup(holdingQuote.Id);
            for (Quote quoteToLock : quotesToLock) {
                Approval.lock(quoteToLock.Id);
            }
            
            //Send email notification confirming creation of contracts
            mail.setToAddresses(toAddresses);
            mail.setSubject('Estado creación de contratos: ' + a.Status);
            mail.setPlainTextBody('Se procesaron ' + a.TotalJobItems + ' contratos con exito.');

        } else {

            // query coverages
            List<ContractGroupPlan> cgpCoveragesCreated = new ZRH_ContractGroupPlansSelector().selectPlansBySourceQuoteIdAndRecTypeDeveloperName(quoteIds, COVERAGE_RECORD_TYPE);
            if (cgpCoveragesCreated.size() > 0) {
                delete cgpCoveragesCreated;
            }
            // query plans
            List<ContractGroupPlan> cgpPlansCreated = new ZRH_ContractGroupPlansSelector().selectPlansBySourceQuoteIdAndRecTypeDeveloperName(quoteIds, PRODUCT_RECORD_TYPE);
            if (cgpPlansCreated.size() > 0) {
                delete cgpPlansCreated;
            }
            // query contracts
            List<Contract> contractsCreated = new ZRH_ContractsSelector().selectContractsBySourceQuoteIds(quoteIds);
            if (contractsCreated.size() > 0) {
                delete contractsCreated;
            }
            
            //Send email notification informing errors
            mail.setToAddresses(toAddresses);
            mail.setSubject('Estado creación de contratos: ' + a.Status);
            mail.setPlainTextBody('Se encontraron ' + a.NumberOfErrors + 
            ' errores. Facilitar el siguiente error al Administrador del sistema: ExtendedStatus: ' + a.ExtendedStatus);
        }
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public class PolicyCreationException extends Exception {

    }
}