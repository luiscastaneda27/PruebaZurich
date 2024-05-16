/*********************************************************************************
Project      : Zurich Salesforce - Seguros colectivos
Created By   : Deloitte
Created Date : 23/03/2023
Description  : DataFactory contains all method for Account, Quote, QLI, InsurancePolicy and more object creations 
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			23/03/2023		initial version
********************************************************************************/
@isTest
public class ZRH_DataFactory {
    
    @TestVisible public static final String PRV_STR_B2B;
    @TestVisible public static final String PRV_STR_PA;
    @TestVisible public static final String PRV_STR_COV;
    @TestVisible public static final String PRV_STR_PROD;
    @TestVisible public static final String PBC_KQRY_ACC;
    @TestVisible public static final String PBC_KQRY_OPP;
    @TestVisible public static final String PBC_KQRY_QUT;
    @TestVisible public static final String PBC_KQRY_PRC;

    static {
        PRV_STR_B2B = 'Business_Account';
        PRV_STR_PA = 'PersonAccount';
        PRV_STR_COV = 'CoverageSpec';
        PRV_STR_PROD = 'Product';
        PBC_KQRY_ACC = '22321334-0';	
        PBC_KQRY_OPP = 'Opp Test';
        PBC_KQRY_QUT = 'Quote Test';
        PBC_KQRY_PRC = '600';
    }
    
    /**
    * @Description: Create Account
    * @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    * @Date:        23/03/2023
    */
    public static Account createAccount(Boolean doInsert) {
		Account acc = new Account(Name='Test Account');
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PRV_STR_B2B).getRecordTypeId();
        acc.ZRH_RUT__c = PBC_KQRY_ACC;
        if (doInsert) {
            insert acc;
        }
        return acc;
    }

    /**
    * @Description: Create Account with RUT
    * @Autor:       Andres Deus, Deloitte, adeusme@deloitte.com
    * @Date:        19/05/2023
    */
    public static Account createAccountWithRUT(Boolean doInsert, String rut) {
		Account acc = new Account(Name='Test Account');
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PRV_STR_B2B).getRecordTypeId();
        acc.ZRH_RUT__c = rut;
        if (doInsert) {
            insert acc;
        }
        return acc;
    }

    /**
    * @Description: Create Person Account with RUT
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        09/01/2024
    */
    public static Account createPersonAccountWithRUT(Boolean doInsert, String rut) {
		Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'PA ' + Math.random();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PRV_STR_PA).getRecordTypeId();
        acc.ZRH_RUT__c = rut;
        if (doInsert) {
            insert acc;
        }
        return acc;
    }
    
    /**
    * @Description: Create Account
    * @Autor:       Seiger Santana, Deloitte, ssantanac@deloitte.com
    * @Date:        25/03/2023
    */
    public static Opportunity createOpportunity(Boolean doInsert, Account acct) {        
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = acct.Id;
        opportunity.Name = PBC_KQRY_OPP;        
        opportunity.StageName = 'Closed Won';
        opportunity.CloseDate = Date.today();
                
        if (doInsert) {
            
            insert opportunity;
        }
        
        return opportunity;
    }

    /**
    * @Description: Create with Opportunity Name
    * @Autor:       Andres Deus, Deloitte, adeusme@deloitte.com
    * @Date:        19/05/2023
    */
    public static Opportunity createOpportunityWithName(Boolean doInsert, Account acct, String name) {        
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = acct.Id;
        opportunity.Name = name;        
        opportunity.StageName = 'Closed Won';
        opportunity.CloseDate = Date.today();
                
        if (doInsert) {
            
            insert opportunity;
        }
        
        return opportunity;
    }
    
    /**
    * @Description: Create Account
    * @Autor:       Seiger Santana, Deloitte, ssantanac@deloitte.com
    * @Date:        25/03/2023
    */
    public static Quote createQuote(Boolean doInsert, Opportunity opportunity) {
        
        Quote quote = new Quote();
        quote.OpportunityId = opportunity.Id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Name = PBC_KQRY_QUT;
        
        if (doInsert) {
            
            insert quote;
        }
        
        return quote;
    }

    
    /**
    * @Description: Create Child Quote
    * @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    * @Date:        12/10/2023
    */
    public static Quote createChildQuote(Boolean doInsert, Opportunity opportunity, Quote parentQuote) {
        
        Quote quote = new Quote();
        quote.OpportunityId = opportunity.Id;
        quote.ZRH_CotizacionHolding__c = parentQuote.Id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Name = PBC_KQRY_QUT;
        
        if (doInsert) {
            insert quote;
        }
        
        return quote;
    }
    
    /**
    * @Description: Create Account
    * @Autor:       Seiger Santana, Deloitte, ssantanac@deloitte.com
    * @Date:        25/03/2023
    */
    public static Product2 createProduct(Boolean doInsert) {        
        
        Product2 product = new Product2();
        product.Name = 'TEST';
        product.Description = 'Test';
        product.ProductCode = PBC_KQRY_PRC;
        product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(PRV_STR_COV).getRecordTypeId();
        if (doInsert) {
            
            insert product;
        }
        
        return product;
    }

    /**
    * @Description: Create Health Product
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        25/08/2023
    */
    public static Product2 createHealthProduct(Boolean doInsert) {        
        
        Product2 product = new Product2();
        product.Name = 'Health';
        product.Description = 'Test';
        product.ProductCode = '600';
        product.vlocity_ins__Type__c = 'Salud';
        product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(PRV_STR_PROD).getRecordTypeId();
        if (doInsert) {
            insert product;
        }
        return product;
    }

    /**
    * @Description: Create Life Product
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        25/08/2023
    */
    public static Product2 createLifeProduct(Boolean doInsert) {        
        
        Product2 product = new Product2();
        product.Name = 'Life';
        product.Description = 'Test';
        product.ProductCode = '500';
        product.vlocity_ins__Type__c = 'Vida';
        product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(PRV_STR_PROD).getRecordTypeId();
        if (doInsert) {
            insert product;
        }
        return product;
    }

    /**
    * @Description: Create Scholar Product
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        25/08/2023
    */
    public static Product2 createScholarProduct(Boolean doInsert) {        
        
        Product2 product = new Product2();
        product.Name = 'Scholar';
        product.Description = 'Test';
        product.ProductCode = '501';
        product.vlocity_ins__Type__c = 'Vida';
        product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(PRV_STR_PROD).getRecordTypeId();
        if (doInsert) {
            insert product;
        }
        return product;
    }
    
    /**
    * @Description: Create Personal Accidents Product
    * @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    * @Date:        8/11/2023
    */
    public static Product2 createPersonalAccidentsProduct(Boolean doInsert) {        
        
        Product2 product = new Product2();
        product.Name = 'Personal Accidents';
        product.Description = 'Test';
        product.ProductCode = '700';
        product.vlocity_ins__Type__c = 'Vida';
        product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(PRV_STR_PROD).getRecordTypeId();
        if (doInsert) {
            insert product;
        }
        return product;
    }
    
    /**
    * @Description: Create Account
    * @Autor:       Seiger Santana, Deloitte, ssantanac@deloitte.com
    * @Date:        25/03/2023
    */
    public static PricebookEntry createPricebookEntry(Boolean doInsert, Product2 product) {  
        
        PricebookEntry objPBEntry = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id=product.Id,UnitPrice=500,IsActive=true);
        
        if (doInsert) {
            
            Insert objPBEntry;
        }
        
        return objPBEntry;
    }
    
    /**
    * @Description: Create Account
    * @Autor:       Seiger Santana, Deloitte, ssantanac@deloitte.com
    * @Date:        25/03/2023
    */
    public static QuoteLineItem createQuoteLineItem(Boolean doInsert, Quote quote, Product2 product, PricebookEntry objPBEntry, String attributeSelectedValues) {  
        
        QuoteLineItem quoteLineItem = new QuoteLineItem();
        quoteLineItem.QuoteId = quote.Id;
        quoteLineItem.Product2Id = product.Id;
        quoteLineItem.Quantity = 1;
        quoteLineItem.UnitPrice = 1;
        quoteLineItem.PricebookEntryId = objPBEntry.Id;   
        quoteLineItem.vlocity_ins__AttributeSelectedValues__c = attributeSelectedValues;
        
        if (doInsert) {
            
            insert quoteLineItem;
        }
        
        return quoteLineItem;
    }

    /**
    * @Description: Create Account
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        11/05/2023
    */
    public static ZRH_Convenio__c createConvenio(Boolean doInsert) {
		ZRH_Convenio__c conv = new ZRH_Convenio__c();
        conv.Name = 'Test Convenio';
        conv.ZRH_Codigo__c = 1;
        conv.ZRH_TipoDeContrato__c = '1';
        conv.ZRH_FechaDeVigenciaInicial__c = Date.today();
        conv.ZRH_CodigoDeTipoDeContrato__c = '1';
    
        if (doInsert) {
            insert conv;
        }
        return conv;
    }
    
    
    /**
    * @Description: Create Masestro de Glosa
    * @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    * @Date:        6/10/2023
    */
    public static ZRH_MaestroGlosas__c createMasterGloss(Boolean doInsert, Decimal glosaId) {
		ZRH_MaestroGlosas__c gloss = new ZRH_MaestroGlosas__c();
        gloss.ZRH_IDGlosa__c = glosaId;
        gloss.ZRH_Activo__c = true;
        gloss.ZRH_ContenidoGlosa__c ='Test';
        gloss.ZRH_ContieneTabla__c = true;
        gloss.ZRH_Plan__c = PBC_KQRY_PRC;
        gloss.ZRH_TipoDeGlosa__c = 'G-001';
        if (doInsert) {
            insert gloss;
        }
        return gloss;
    }
    
    /**
    * @Description: Create Masestro de Glosa
    * @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    * @Date:        6/10/2023
    */
    public static ZRH_Glosas__c createGloss(Boolean doInsert, Id quoteLineItemId) {
		ZRH_Glosas__c gloss = new ZRH_Glosas__c();
        gloss.ZRH_IDGlosa__c = 1;
        gloss.ZRH_Activo__c = true;
        gloss.ZRH_ContenidoGlosa__c ='Test';
        gloss.ZRH_ContieneTabla__c = true;
        gloss.ZRH_Plan__c = PBC_KQRY_PRC;
        gloss.ZRH_TipoDeGlosa__c = 'G-001';
        gloss.ZRH_DestinoTipoPDF__c = 'D-002';
        gloss.ZRH_QuoteLineItem__c = quoteLineItemId;
        if (doInsert) {
            insert gloss;
        }
        return gloss;
    }

    /**
    * @Description: Create Glosa con Tarifa
    * @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    * @Date:        13/10/2023
    */
    public static ZRH_Glosas__c createRateGloss(Boolean doInsert, Id quoteLineItemId) {
		ZRH_Glosas__c gloss = new ZRH_Glosas__c();
        gloss.ZRH_IDGlosa__c = 141;
        gloss.ZRH_Activo__c = true;
        gloss.ZRH_ContenidoGlosa__c ='Test';
        gloss.ZRH_ContieneTabla__c = true;
        gloss.ZRH_Plan__c = '500';
        gloss.ZRH_TipoDeGlosa__c = 'G-001';
        gloss.ZRH_DestinoTipoPDF__c = 'D-002';
        gloss.ZRH_QuoteLineItem__c = quoteLineItemId;
        if (doInsert) {
            insert gloss;
        }
        return gloss;
    }

    /**
    * @Description: Create Glosa con Coberturas
    * @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    * @Date:        13/10/2023
    */
    public static ZRH_Glosas__c createCoverageGloss(Boolean doInsert, Id quoteLineItemId) {
		ZRH_Glosas__c gloss = new ZRH_Glosas__c();
        gloss.ZRH_IDGlosa__c = 85;
        gloss.ZRH_Activo__c = true;
        gloss.ZRH_ContenidoGlosa__c ='Test';
        gloss.ZRH_ContieneTabla__c = true;
        gloss.ZRH_Plan__c = '600';
        gloss.ZRH_TipoDeGlosa__c = 'G-001';
        gloss.ZRH_DestinoTipoPDF__c = 'D-002';
        gloss.ZRH_QuoteLineItem__c = quoteLineItemId;
        if (doInsert) {
            insert gloss;
        }
        return gloss;
    }

    /**
    * @Description: Create Glosa con Requerimientos de Asegurabilidad
    * @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    * @Date:        13/10/2023
    */
    public static ZRH_Glosas__c createRequirementGloss(Boolean doInsert, Id quoteLineItemId) {
		ZRH_Glosas__c gloss = new ZRH_Glosas__c();
        gloss.ZRH_IDGlosa__c = 153;
        gloss.ZRH_Activo__c = true;
        gloss.ZRH_ContenidoGlosa__c ='Test';
        gloss.ZRH_ContieneTabla__c = true;
        gloss.ZRH_Plan__c = '500';
        gloss.ZRH_TipoDeGlosa__c = 'G-001';
        gloss.ZRH_DestinoTipoPDF__c = 'D-002';
        gloss.ZRH_QuoteLineItem__c = quoteLineItemId;
        if (doInsert) {
            insert gloss;
        }
        return gloss;
    }

    /**
    * @Description: Create Glosa con Requerimientos Medicos
    * @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    * @Date:        13/10/2023
    */
    public static ZRH_Glosas__c createMedicalRequirementGloss(Boolean doInsert, Id quoteLineItemId) {
		ZRH_Glosas__c gloss = new ZRH_Glosas__c();
        gloss.ZRH_IDGlosa__c = 158;
        gloss.ZRH_Activo__c = true;
        gloss.ZRH_ContenidoGlosa__c ='Test';
        gloss.ZRH_ContieneTabla__c = true;
        gloss.ZRH_Plan__c = '500';
        gloss.ZRH_TipoDeGlosa__c = 'G-001';
        gloss.ZRH_DestinoTipoPDF__c = 'D-002';
        gloss.ZRH_QuoteLineItem__c = quoteLineItemId;
        if (doInsert) {
            insert gloss;
        }
        return gloss;
    }
    
    /**
    * @Description: Create Content Version
    * @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    * @Date:        25/10/2023
    */
    public static ContentVersion createContentVersion(Boolean doInsert) {
		ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        if (doInsert) {
            insert cv;
        }
        return cv;
    }
    
    /**
    * @Description: Create Content Document Link
    * @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    * @Date:        25/10/2023
    */
    public static ContentDocumentLink createContentDocumentLink(Boolean doInsert, Id objectId, Id contentDocumentId) {
		ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = objectId;
        cdl.ContentDocumentId = contentDocumentId;
        cdl.shareType = 'V';
        if (doInsert) {
            insert cdl;
        }
        return cdl;
    }
    
    /**
    * @Description: Create Contract
    * @Autor:       Luis Castañeda, Deloitte, lcastaneda@deloitte.com
    * @Date:        27/11/2023
    */
    public static Contract createContract(Boolean doInsert, Quote quote, Account acc) {
		Contract c = new Contract();
        c.SourceQuoteId = quote.Id;
        c.AccountId = acc.Id;
        if (doInsert) {
            insert c;
        }
        return c;
    }
    
    /**
    * @Description: Create Contract
    * @Autor:       Luis Castañeda, Deloitte, lcastaneda@deloitte.com
    * @Date:        27/11/2023
    */
    public static ContractGroupPlan createContractGroupPlan(Boolean doInsert, Contract contr, QuoteLineItem qli) {
		ContractGroupPlan cgp = new ContractGroupPlan();
        cgp.ContractId = contr.Id;
        cgp.vlocity_ins_fsc__Product2Id__c = qli.Product2Id;
        cgp.vlocity_ins_fsc__AttributeSelectedValues__c = qli.vlocity_ins__AttributeSelectedValues__c;
        cgp.QuoteLineItemId = qli.Id;
        cgp.ZRH_Periodo__c = 0;
        cgp.Name = 'Test';
        if (doInsert) {
            insert cgp;
        }
        return cgp;
    }

    /**
    * @Description: Create Group Class
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        19/12/2023
    */
    public static GroupClass createGroupClass(Boolean doInsert, Account acc) {
		GroupClass gc = new GroupClass();
        gc.AccountId = acc.Id;
        gc.Code = '1';
        gc.Name = acc.Id + ' ' + Math.random();
        if (doInsert) {
            insert gc;
        }
        return gc;
    }

    /**
    * @Description: Create Contract Group Plan Group Class
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        19/12/2023
    */
    public static ContractGroupPlanGroupClass createContractGroupPlanGroupClass(Boolean doInsert, ContractGroupPlan cgp, GroupClass gc) {
		ContractGroupPlanGroupClass cgpgc = new ContractGroupPlanGroupClass();
        cgpgc.ContractGroupPlanId = cgp.Id;
        cgpgc.GroupClassId = gc.Id;
        cgpgc.Name = cgp.Id + ' ' + Math.random();
        if (doInsert) {
            insert cgpgc;
        }
        return cgpgc;
    }    

    /**
    * @Description: Create Group Census
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        19/12/2023
    */
    public static GroupCensus createGroupCensus(Boolean doInsert, Account acc) {
		GroupCensus gc = new GroupCensus();
        gc.AccountId = acc.Id;
        gc.Status = 'Active';
        gc.Name = acc.Id + ' ' + Math.random();
        if (doInsert) {
            insert gc;
        }
        return gc;
    }

    /**
    * @Description: Create Group Census Member
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        19/12/2023
    */
    public static GroupCensusMember createGroupCensusMember(Boolean doInsert, GroupCensus gcensus, GroupClass gc, GroupCensusMember primaryGcm) {
        GroupCensusMember gcm = new GroupCensusMember();
        gcm.GroupCensusId = gcensus.Id;
        gcm.GroupClassId = gc.Id;
        gcm.PrimaryGroupCensusMemberId = primaryGcm.Id;
        gcm.RelationshipToPrimaryMember = 'Otros';
        gcm.Name = gcensus.Id + ' ' + Math.random();
        gcm.FirstName = gcensus.Id + ' ' + Math.random();
        gcm.LastName = gcensus.Id + ' ' + Math.random();
        gcm.ZRH_Banco__c = '42';
        gcm.ZRH_Capital__c = 10000;
        gcm.ZRH_CapitalVidaVoluntario__c = 50000;
        gcm.ZRH_ClaveSincronizacion__c = 'ASD';
        gcm.ZRH_CodigoMonedaRenta__c = 'USD';
        gcm.ZRH_FechaConversionCapital__c = Date.today();
        gcm.ZRH_Rut__c = ('1' + Math.random()).substring(0,9);
        gcm.ZRH_TipoCuentaBancaria__c = 'Cuenta Vista';
        gcm.ZRH_VigenciaHistorica__c = Date.today();
        gcm.PolicyStartDate = Date.today();
        gcm.ZRH_Poliza__c = '12345-6';
    
        if (doInsert) {
            insert gcm;
        }
        return gcm;
    }

    /**
    * @Description: Create Group Census Member with movement type
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        19/12/2023
    */
    public static GroupCensusMember createGroupCensusMemberWithMovement(Boolean doInsert, GroupCensus gcensus, GroupClass gc, GroupCensusMember primaryGcm, String tipoMovimiento) {
        GroupCensusMember gcm = new GroupCensusMember();
        gcm.GroupCensusId = gcensus.Id;
        gcm.GroupClassId = gc.Id;
        gcm.PrimaryGroupCensusMemberId = primaryGcm.Id;
        gcm.RelationshipToPrimaryMember = 'Otros';
        gcm.Name = gcensus.Id + ' ' + Math.random();
        gcm.FirstName = gcensus.Id + ' ' + Math.random();
        gcm.LastName = gcensus.Id + ' ' + Math.random();
        gcm.ZRH_Banco__c = '42';
        gcm.ZRH_Capital__c = 10000;
        gcm.ZRH_CapitalVidaVoluntario__c = 50000;
        gcm.ZRH_ClaveSincronizacion__c = 'ASD';
        gcm.ZRH_CodigoMonedaRenta__c = 'USD';
        gcm.ZRH_FechaConversionCapital__c = Date.today();
        gcm.ZRH_Rut__c = ('1' + Math.random()).substring(0,9);
        gcm.ZRH_TipoCuentaBancaria__c = 'Cuenta Vista';
        gcm.ZRH_VigenciaHistorica__c = Date.today();
        gcm.policyStartDate = Date.today();
        gcm.ZRH_TipoMovimiento__c = tipoMovimiento;
        gcm.ZRH_Poliza__c = '12345-6';
    
        if (doInsert) {
            insert gcm;
        }
        return gcm;
    }
    
    /**
    * @Description: Create Group Census Member
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        19/12/2023
    */
    public static GroupCensusMember createPrimaryGroupCensusMember(Boolean doInsert, GroupCensus gcensus, GroupClass gc) {
		GroupCensusMember gcm = new GroupCensusMember();
        gcm.GroupCensusId = gcensus.Id;
        gcm.GroupClassId = gc.Id;
        gcm.Name = gcensus.Id + ' ' + Math.random();
        gcm.FirstName = gcensus.Id + ' ' + Math.random();
        gcm.LastName = gcensus.Id + ' ' + Math.random();
        gcm.ZRH_Banco__c = '42';
        gcm.ZRH_Capital__c = 10000;
        gcm.ZRH_CapitalVidaVoluntario__c = 50000;
        gcm.ZRH_ClaveSincronizacion__c = 'ASD';
        gcm.ZRH_CodigoMonedaRenta__c = 'USD';
        gcm.ZRH_FechaConversionCapital__c = Date.today();
        gcm.ZRH_Rut__c = ('1' + Math.random()).substring(0,9);
        gcm.ZRH_TipoCuentaBancaria__c = 'Cuenta Vista';
        gcm.ZRH_VigenciaHistorica__c = Date.today();
        gcm.PolicyStartDate = Date.today();
        gcm.ZRH_Poliza__c = '12345-6';

        if (doInsert) {
            insert gcm;
        }
        return gcm;
    }
    
    /**
    * @Description: Create Group Census Member
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        19/12/2023
    */
    public static GroupCensusMember createPrimaryGroupCensusMemberWithMovement(Boolean doInsert, GroupCensus gcensus, GroupClass gc, String tipoMovimiento) {
		GroupCensusMember gcm = new GroupCensusMember();
        gcm.GroupCensusId = gcensus.Id;
        gcm.GroupClassId = gc.Id;
        gcm.Name = gcensus.Id + ' ' + Math.random();
        gcm.FirstName = gcensus.Id + ' ' + Math.random();
        gcm.LastName = gcensus.Id + ' ' + Math.random();
        gcm.ZRH_Banco__c = '42';
        gcm.ZRH_Capital__c = 10000;
        gcm.ZRH_CapitalVidaVoluntario__c = 50000;
        gcm.ZRH_ClaveSincronizacion__c = 'ASD';
        gcm.ZRH_CodigoMonedaRenta__c = 'USD';
        gcm.ZRH_FechaConversionCapital__c = Date.today();
        gcm.ZRH_Rut__c = ('1' + Math.random()).substring(0,9);
        gcm.ZRH_TipoCuentaBancaria__c = 'Cuenta Vista';
        gcm.ZRH_VigenciaHistorica__c = Date.today();
        gcm.PolicyStartDate = Date.today();
        gcm.ZRH_TipoMovimiento__c = tipoMovimiento;
        gcm.ZRH_Poliza__c = '12345-6';
        
        if (doInsert) {
            insert gcm;
        }
        return gcm;
    }

    /**
    * @Description: Create Group Census Member Plan
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        19/12/2023
    */
    public static GroupCensusMemberPlan createGroupCensusMemberPlan(Boolean doInsert, Id memberId, Id cgpId) {
		GroupCensusMemberPlan gcmp = new GroupCensusMemberPlan();
        gcmp.ContractGroupPlanId = cgpId;
        gcmp.GroupCensusMemberId = memberId;
        gcmp.Name = 'test';
        if (doInsert) {
            insert gcmp;
        }
        return gcmp;
    }

    /**
    * @Description: Create Insurance Policy
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        08/01/2023
    */
    public static InsurancePolicy createInsurancePolicy(Boolean doInsert, Id memberId, Id cgpId) {
		InsurancePolicy ip = new InsurancePolicy();
        ip.ContractGroupPlanId = cgpId;
        ip.NameInsuredId = memberId;
        ip.Name = 'test';
        if (doInsert) {
            insert ip;
        }
        return ip;
    }

    /**
    * @Description: Create Insurance Policy Coverage
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        08/01/2024
    */
    public static InsurancePolicyCoverage createInsurancePolicyCoverage(Boolean doInsert, Id insurancePolicyId, Id productId) {
		InsurancePolicyCoverage ip = new InsurancePolicyCoverage();
        ip.vlocity_ins_fsc__Product2Id__c = productId;
        ip.InsurancePolicyId = insurancePolicyId;
        if (doInsert) {
            insert ip;
        }
        return ip;
    }

    /**
    * @Description: Create Insurance Policy Participant
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        08/01/2024
    */
    public static InsurancePolicyParticipant createPrimaryInsurancePolicyParticipant(Boolean doInsert, Id insurancePolicyId, Id memberId) {
		InsurancePolicyParticipant ip = new InsurancePolicyParticipant();
        ip.PrimaryParticipantAccountId = memberId;
        ip.Role = 'Titular';
        ip.InsurancePolicyId = insurancePolicyId;
        if (doInsert) {
            insert ip;
        }
        return ip;
    }

    /**
    * @Description: Create Dependant Insurance Policy Participant
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        08/01/2024
    */
    public static InsurancePolicyParticipant createDependantInsurancePolicyParticipant(Boolean doInsert, Id insurancePolicyId, Id memberId) {
		InsurancePolicyParticipant ip = new InsurancePolicyParticipant();
        ip.RelatedParticipantAccountId = memberId;
        ip.Role = 'Beneficiario';
        ip.InsurancePolicyId = insurancePolicyId;
        if (doInsert) {
            insert ip;
        }
        return ip;
    }

    /**
    * @Description: Create Objects to use for policy member inscription
    * @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    * @Date:        08/01/2024
    */
    public static List<Object> generateMockPrimaryMembers(Integer numberOfRecords, Id groupCensusId, Id groupClassId, List<String> polizas) {
        List<Object> members = new List<Object>();

        for (Integer i = 0; i < numberOfRecords; i++) {
            Map<String,Object> member = new Map<String,Object>();
            member.put('groupCensusId', groupCensusId);
            member.put('groupClassId', groupClassId);
            member.put('relationshipToInsured', 'Self');
            member.put('claveSincronizacion', 'ZRH' + i);
            member.put('firstName', 'Name-' + i);
            member.put('lastName', 'LastName-' + i);
            member.put('rut', '1234-' + i);
            member.put('rutTitular', null);
            member.put('email', 'email-' + i + '@example.com');
            member.put('gender', 'Masculino');
            member.put('street', '123 Main St');
            member.put('city', 'Cityville');
            member.put('state', 'ST');
            member.put('postalCode', '12345');
            member.put('country', 'Chile');
            member.put('birthdate', '1990-01-01');
            member.put('phoneNumber', '555-1234');
            member.put('annualEligibleSalary', 50000.00);
            member.put('banco', '1');
            member.put('capital', 100000.00);
            member.put('capitalVidaVoluntario', 50000.00);
            member.put('codigoMonedaRenta', 'CLP');
            member.put('fechaConversionCapital', '2023-12-31');
            member.put('nivelEscolaridad', '2S');
            member.put('numeroRentas', 10.0);
            member.put('numeroTelefonoAlternativo', '555-5678');
            member.put('omitirRequisitosAsegurabilidad', false);
            member.put('tipoCuentaBancaria', 'Cuenta Corriente');
            member.put('vigenciaHistorica', '2023-12-31');
            member.put('polizas', polizas);
            member.put('policyStartDate', '2023-12-31');

            members.add(member);
        }

        return members;
    }

    
}