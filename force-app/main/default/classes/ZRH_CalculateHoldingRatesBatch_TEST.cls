@isTest
private class ZRH_CalculateHoldingRatesBatch_TEST {

    @isTest
    static void testHealthProductCalculations() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote2 = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote3 = ZRH_DataFactory.createQuote(true, testOpportunity);

        childQuote1.ZRH_CotizacionHolding__c = holdingQuote.Id;
        update childQuote1;
        
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, childQuote1, testProduct, testPricebookEntry, 'Test Attribute Values');
        testQuoteLineItem.ZRH_Tarifa__c = '{"IdTipoTarifa":"7","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO SOLO","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO CON UNA CARGA","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"2"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"3"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"4"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"5"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"6"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"7"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"8"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CINCO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"9"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludPV":200,"TarifaSaludNT":20}]}';
        testQuoteLineItem.ZRH_TipoTarifa__c = '7';
        testQuoteLineItem.ZRH_TarifaModificada__c = true;
        update testQuoteLineItem;

        Test.startTest();
        ZRH_CalculateHoldingRatesBatch batch = new ZRH_CalculateHoldingRatesBatch();
        batch.quoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        QuotelineItem updatedQuoteLineItem = [SELECT ZRH_Tarifa__c, ZRH_TipoTarifa__c FROM QuoteLineItem WHERE QuoteId = :holdingQuote.Id];
        System.assertEquals('7', updatedQuoteLineItem.ZRH_TipoTarifa__c);
    }

    @isTest
    static void testHealthProductCalculationsHoldingWithPriorQLIS() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote2 = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote3 = ZRH_DataFactory.createQuote(true, testOpportunity);

        childQuote1.ZRH_CotizacionHolding__c = holdingQuote.Id;
        update childQuote1;
        
        QuoteLineItem testQuoteLineItemHolding = ZRH_DataFactory.createQuoteLineItem(true, holdingQuote, testProduct, testPricebookEntry, 'Test Attribute Values');
        testQuoteLineItemHolding.ZRH_TipoTarifa__c = '7';
        update testQuoteLineItemHolding;

        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, childQuote1, testProduct, testPricebookEntry, 'Test Attribute Values');
        testQuoteLineItem.ZRH_Tarifa__c = '{"IdTipoTarifa":"7","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO SOLO","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO CON UNA CARGA","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"2"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"3"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"4"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"5"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"6"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"7"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"8"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CINCO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"9"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludPV":200,"TarifaSaludNT":20}]}';
        testQuoteLineItem.ZRH_TipoTarifa__c = '7';
        testQuoteLineItem.ZRH_TarifaModificada__c = true;
        update testQuoteLineItem;

        Test.startTest();
        ZRH_CalculateHoldingRatesBatch batch = new ZRH_CalculateHoldingRatesBatch();
        batch.quoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<QuotelineItem> updatedQuoteLineItem = [SELECT ZRH_Tarifa__c, ZRH_TipoTarifa__c FROM QuoteLineItem WHERE QuoteId = :holdingQuote.Id];
        System.assertEquals('7', updatedQuoteLineItem[0].ZRH_TipoTarifa__c);
        System.assert(updatedQuoteLineItem.size() == 1);
    }

    @isTest
    static void testLifeProductCalculations() {
        // Create test data with JSON content in your custom field
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote2 = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote3 = ZRH_DataFactory.createQuote(true, testOpportunity);

        childQuote1.ZRH_CotizacionHolding__c = holdingQuote.Id;
        update childQuote1;
        
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, childQuote1, testProduct, testPricebookEntry, 'Test Attribute Values');
        testQuoteLineItem.ZRH_Tarifa__c = '{"IdTipoTarifa":"6","TarifaVida":[{"NumeroAsegurados":10,"PrimaAnualUF":0.1,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13FAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"1","IdProductoCotizacion":"0QL75000000E8oRGAS","NumeroAsegurados700":null,"NombreCobertura":"FALLECIMIENTO"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13PAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"3","IdProductoCotizacion":"0QL75000000E8oSGAS","NumeroAsegurados700":null,"NombreCobertura":"MUERTE ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13ZAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"83","IdProductoCotizacion":"0QL75000000E8oUGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13jAAC","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"80","IdProductoCotizacion":"0QL75000000E8oVGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ PERMANENTE (80)"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001HIJbAAO","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"71","IdProductoCotizacion":"0QL75000000E8oWGAS","NumeroAsegurados700":null,"NombreCobertura":"GASTOS MEDICOS Y FUNERARIOS POR FALL"},{"PrimaAnualUF":0.5,"NumeroAsegurados":10,"CapitalAseguradoUF":50,"PrimaMensualUF":0.05,"NombreCobertura":"TOTAL"}]}';
        testQuoteLineItem.ZRH_TipoTarifa__c = '6';
        testQuoteLineItem.ZRH_TarifaModificada__c = true;
        update testQuoteLineItem;

        Test.startTest();
        ZRH_CalculateHoldingRatesBatch batch = new ZRH_CalculateHoldingRatesBatch();
        batch.quoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        QuotelineItem updatedQuoteLineItem = [SELECT ZRH_Tarifa__c, ZRH_TipoTarifa__c FROM QuoteLineItem WHERE QuoteId = :holdingQuote.Id];
        System.assertEquals('6', updatedQuoteLineItem.ZRH_TipoTarifa__c);
    }

    @isTest
    static void testLifeProductCalculationsMaximumNumberPossible() {
        // Create test data with JSON content in your custom field
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote2 = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote3 = ZRH_DataFactory.createQuote(true, testOpportunity);

        childQuote1.ZRH_CotizacionHolding__c = holdingQuote.Id;
        update childQuote1;

        List<QuoteLineItem> qlisToCreate = new List<QuoteLineItem>();
        for (Integer i = 0; i < 10; i++) {
            QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(false, childQuote1, testProduct, testPricebookEntry, 'Test Attribute Values');
            testQuoteLineItem.ZRH_Tarifa__c = '{"IdTipoTarifa":"6","TarifaVida":[{"NumeroAsegurados":10,"PrimaAnualUF":0.1,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13FAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"1","IdProductoCotizacion":"0QL75000000E8oRGAS","NumeroAsegurados700":null,"NombreCobertura":"FALLECIMIENTO"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13PAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"3","IdProductoCotizacion":"0QL75000000E8oSGAS","NumeroAsegurados700":null,"NombreCobertura":"MUERTE ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13ZAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"83","IdProductoCotizacion":"0QL75000000E8oUGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13jAAC","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"80","IdProductoCotizacion":"0QL75000000E8oVGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ PERMANENTE (80)"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001HIJbAAO","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"71","IdProductoCotizacion":"0QL75000000E8oWGAS","NumeroAsegurados700":null,"NombreCobertura":"GASTOS MEDICOS Y FUNERARIOS POR FALL"},{"PrimaAnualUF":0.5,"NumeroAsegurados":10,"CapitalAseguradoUF":50,"PrimaMensualUF":0.05,"NombreCobertura":"TOTAL"}]}';
            testQuoteLineItem.ZRH_TipoTarifa__c = '6';
            testQuoteLineItem.ZRH_TarifaModificada__c = true;
            qlisToCreate.add(testQuoteLineItem);
        }
        insert qlisToCreate;

        Test.startTest();
        ZRH_CalculateHoldingRatesBatch batch = new ZRH_CalculateHoldingRatesBatch();
        batch.quoteId = holdingQuote.Id;
        Database.executeBatch(batch, 2000);
        Test.stopTest();

        QuotelineItem updatedQuoteLineItem = [SELECT ZRH_Tarifa__c, ZRH_TipoTarifa__c FROM QuoteLineItem WHERE QuoteId = :holdingQuote.Id];
        List<QuoteLineItem> childQlisNotUpdated = [SELECT Id, ZRH_TarifaModificada__c FROM QuoteLineItem WHERE Id IN :qlisToCreate AND ZRH_TarifaModificada__c = true];
        System.assertEquals('6', updatedQuoteLineItem.ZRH_TipoTarifa__c);
        System.assert(childQlisNotUpdated.size() == 0);
    }

    @isTest
    static void testScholarProductCalculations() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createScholarProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        
        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote2 = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote3 = ZRH_DataFactory.createQuote(true, testOpportunity);

        childQuote1.ZRH_CotizacionHolding__c = holdingQuote.Id;
        update childQuote1;
        
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, childQuote1, testProduct, testPricebookEntry, 'Test Attribute Values');
        testQuoteLineItem.ZRH_Tarifa__c = '{"IdTipoTarifa":"4","TarifaEscolaridad":{"Niveles":[{"NAseguradosEsc":1,"CapAsegEsc":1,"PrimaAnualEsc":0.001,"TasaMensualEsc":0.08,"TasaAnualEsc":1,"DescripcionNivel":"SEPTIMO SUPERIOR 7 AÑOS","CodigoNivel":"77","PrimaMensualEsc":0.0001},{"NAseguradosEsc":1,"CapAsegEsc":1,"PrimaAnualEsc":0.001,"DescripcionNivel":"TOTAL","PrimaMensualEsc":0.0001}],"CodigoCobertura":"1","NombreCobEsc":"FALLECIMIENTO"}}';
        testQuoteLineItem.ZRH_TipoTarifa__c = '4';
        testQuoteLineItem.ZRH_TarifaModificada__c = true;
        update testQuoteLineItem;

        Test.startTest();
        ZRH_CalculateHoldingRatesBatch batch = new ZRH_CalculateHoldingRatesBatch();
        batch.quoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        QuotelineItem updatedQuoteLineItem = [SELECT ZRH_Tarifa__c, ZRH_TipoTarifa__c FROM QuoteLineItem WHERE QuoteId = :holdingQuote.Id];
        System.assertEquals('4', updatedQuoteLineItem.ZRH_TipoTarifa__c);
    }

    // @isTest
    // static void testRateChangesAndRatesNotModified() {
    //     Account testAccount = ZRH_DataFactory.createAccount(true);
    //     Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        
    //     //Scholar has only one product, so if it is modified in any child it will need to change in holding
    //     Product2 scholarProduct = ZRH_DataFactory.createScholarProduct(true);

    //     //We will be testing a life that does not changes and one that changes in childs
    //     Product2 lifeProduct = ZRH_DataFactory.createLifeProduct(true);
    //     Product2 lifeProduct2 = ZRH_DataFactory.createLifeProduct(false);
    //     lifeProduct2.ProductCode = '700';
    //     insert lifeProduct2;

    //     //Health products can change its rate type, in this case, we need to update both the rate type to which is was changed and the rate type that was changed from
    //     Product2 healthProduct = ZRH_DataFactory.createHealthProduct(true);
    //     Product2 healthProduct1 = ZRH_DataFactory.createHealthProduct(false);
    //     healthProduct1.ProductCode = '601';
    //     insert healthProduct1;
    //     Product2 healthProduct2 = ZRH_DataFactory.createHealthProduct(false);
    //     healthProduct2.ProductCode = '605';
    //     insert healthProduct2;

    //     List<PricebookEntry> pbs = new List<PricebookEntry>();
    //     PricebookEntry scholarPricebookEntry = ZRH_DataFactory.createPricebookEntry(false, scholarProduct);
    //     pbs.add(scholarPricebookEntry);
    //     PricebookEntry lifePricebookEntry = ZRH_DataFactory.createPricebookEntry(false, lifeProduct);
    //     pbs.add(lifePricebookEntry);
    //     PricebookEntry lifePricebookEntry2 = ZRH_DataFactory.createPricebookEntry(false, lifeProduct2);
    //     pbs.add(lifePricebookEntry2);
    //     PricebookEntry healthPricebookEntry = ZRH_DataFactory.createPricebookEntry(false, healthProduct);
    //     pbs.add(healthPricebookEntry);
    //     PricebookEntry healthPricebookEntry1 = ZRH_DataFactory.createPricebookEntry(false, healthProduct1);
    //     pbs.add(healthPricebookEntry1);
    //     PricebookEntry healthPricebookEntry2 = ZRH_DataFactory.createPricebookEntry(false, healthProduct2);
    //     pbs.add(healthPricebookEntry2);
    //     insert pbs;

        
    //     Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
    //     Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);
    //     Quote childQuote2 = ZRH_DataFactory.createQuote(true, testOpportunity);
    //     Quote childQuote3 = ZRH_DataFactory.createQuote(true, testOpportunity);

    //     List<Quote> quotes = new List<Quote>();
    //     childQuote1.ZRH_CotizacionHolding__c = holdingQuote.Id;
    //     quotes.add(childQuote1);
    //     update quotes;
        
    //     List<QuoteLineItem> qlis = new List<QuoteLineItem>();

    //     //Holding QLIS
    //     //Scholar that will be modified in rate
    //     QuoteLineItem scholarHolding1 = ZRH_DataFactory.createQuoteLineItem(false, holdingQuote, scholarProduct, scholarPricebookEntry, 'Test Attribute Values');
    //     scholarHolding1.ZRH_Tarifa__c = '{"IdTipoTarifa":"4","TarifaEscolaridad":{"Niveles":[{"NAseguradosEsc":1,"CapAsegEsc":1,"PrimaAnualEsc":0.001,"TasaMensualEsc":0.08,"TasaAnualEsc":1,"DescripcionNivel":"SEPTIMO SUPERIOR 7 AÑOS","CodigoNivel":"77","PrimaMensualEsc":0.0001},{"NAseguradosEsc":1,"CapAsegEsc":1,"PrimaAnualEsc":0.001,"DescripcionNivel":"TOTAL","PrimaMensualEsc":0.0001}],"CodigoCobertura":"1","NombreCobEsc":"FALLECIMIENTO"}}';
    //     scholarHolding1.ZRH_TipoTarifa__c = '4';
    //     qlis.add(scholarHolding1);

    //     //Life that won't be modified
    //     QuoteLineItem lifeHolding1 = ZRH_DataFactory.createQuoteLineItem(false, holdingQuote, lifeProduct, lifePricebookEntry, 'Test Attribute Values');
    //     lifeHolding1.ZRH_Tarifa__c = '{"IdTipoTarifa":"6","TarifaVida":[{"NumeroAsegurados":10,"PrimaAnualUF":0.1,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13FAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"1","IdProductoCotizacion":"0QL75000000E8oRGAS","NumeroAsegurados700":null,"NombreCobertura":"FALLECIMIENTO"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13PAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"3","IdProductoCotizacion":"0QL75000000E8oSGAS","NumeroAsegurados700":null,"NombreCobertura":"MUERTE ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13ZAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"83","IdProductoCotizacion":"0QL75000000E8oUGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13jAAC","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"80","IdProductoCotizacion":"0QL75000000E8oVGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ PERMANENTE (80)"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001HIJbAAO","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"71","IdProductoCotizacion":"0QL75000000E8oWGAS","NumeroAsegurados700":null,"NombreCobertura":"GASTOS MEDICOS Y FUNERARIOS POR FALL"},{"PrimaAnualUF":0.5,"NumeroAsegurados":10,"CapitalAseguradoUF":50,"PrimaMensualUF":0.05,"NombreCobertura":"TOTAL"}]}';
    //     lifeHolding1.ZRH_TipoTarifa__c = '6';
    //     qlis.add(lifeHolding1);
        
    //     //Life that will be modified in rate
    //     QuoteLineItem lifeHolding2 = ZRH_DataFactory.createQuoteLineItem(false, holdingQuote, lifeProduct2, lifePricebookEntry2, 'Test Attribute Values');
    //     lifeHolding2.ZRH_Tarifa__c = '{"IdTipoTarifa":"6","TarifaVida":[{"NumeroAsegurados":10,"PrimaAnualUF":0.1,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13FAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"1","IdProductoCotizacion":"0QL75000000E8oRGAS","NumeroAsegurados700":null,"NombreCobertura":"FALLECIMIENTO"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13PAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"3","IdProductoCotizacion":"0QL75000000E8oSGAS","NumeroAsegurados700":null,"NombreCobertura":"MUERTE ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13ZAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"83","IdProductoCotizacion":"0QL75000000E8oUGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13jAAC","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"80","IdProductoCotizacion":"0QL75000000E8oVGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ PERMANENTE (80)"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001HIJbAAO","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"71","IdProductoCotizacion":"0QL75000000E8oWGAS","NumeroAsegurados700":null,"NombreCobertura":"GASTOS MEDICOS Y FUNERARIOS POR FALL"},{"PrimaAnualUF":0.5,"NumeroAsegurados":10,"CapitalAseguradoUF":50,"PrimaMensualUF":0.05,"NombreCobertura":"TOTAL"}]}';
    //     lifeHolding2.ZRH_TipoTarifa__c = '6';
    //     qlis.add(lifeHolding2);
        
    //     //Health that won't be modified
    //     QuoteLineItem healthHolding = ZRH_DataFactory.createQuoteLineItem(false, holdingQuote, healthProduct, healthPricebookEntry, 'Test Attribute Values');
    //     healthHolding.ZRH_Tarifa__c = '{"IdTipoTarifa":"3","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"PROMEDIO ASEGURADOS","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"ADICIONAL POR CARGA","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"2"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludNT":20,"TarifaSaludPV":200}]}';
    //     healthHolding.ZRH_TipoTarifa__c = '3';
    //     qlis.add(healthHolding);
        
    //     //Health that will be modified in rate
    //     QuoteLineItem healthHolding1 = ZRH_DataFactory.createQuoteLineItem(false, holdingQuote, healthProduct1, healthPricebookEntry1, 'Test Attribute Values');
    //     healthHolding1.ZRH_Tarifa__c = '{"IdTipoTarifa":"3","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"PROMEDIO ASEGURADOS","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"ADICIONAL POR CARGA","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"2"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludNT":20,"TarifaSaludPV":200}]}';
    //     healthHolding1.ZRH_TipoTarifa__c = '3';
    //     qlis.add(healthHolding1);

    //     //Health that will be modified in rate type
    //     QuoteLineItem healthHolding2 = ZRH_DataFactory.createQuoteLineItem(false, holdingQuote, healthProduct2, healthPricebookEntry2, 'Test Attribute Values');
    //     healthHolding2.ZRH_Tarifa__c = '{"IdTipoTarifa":"7","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO SOLO","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO CON UNA CARGA","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"2"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"3"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"4"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"5"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"6"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"7"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"8"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CINCO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"9"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludPV":200,"TarifaSaludNT":20}]}';
    //     healthHolding2.ZRH_TipoTarifa__c = '7';
    //     qlis.add(healthHolding2);

    //     //Child QLIS
    //     //Scholar that will be modified in rate
    //     QuoteLineItem scholarChild1 = ZRH_DataFactory.createQuoteLineItem(false, childQuote1, scholarProduct, scholarPricebookEntry, 'Test Attribute Values');
    //     scholarChild1.ZRH_Tarifa__c = '{"IdTipoTarifa":"4","TarifaEscolaridad":{"Niveles":[{"NAseguradosEsc":10000,"CapAsegEsc":1,"PrimaAnualEsc":0.001,"TasaMensualEsc":0.08,"TasaAnualEsc":1,"DescripcionNivel":"SEPTIMO SUPERIOR 7 AÑOS","CodigoNivel":"77","PrimaMensualEsc":0.0001},{"NAseguradosEsc":1,"CapAsegEsc":1,"PrimaAnualEsc":0.001,"DescripcionNivel":"TOTAL","PrimaMensualEsc":0.0001}],"CodigoCobertura":"1","NombreCobEsc":"FALLECIMIENTO"}}';
    //     scholarChild1.ZRH_TipoTarifa__c = '4';
    //     scholarChild1.ZRH_TarifaModificada__c = true;
    //     qlis.add(scholarChild1);

    //     //Life that won't be modified
    //     QuoteLineItem lifeChild1 = ZRH_DataFactory.createQuoteLineItem(false, childQuote1, lifeProduct, lifePricebookEntry, 'Test Attribute Values');
    //     lifeChild1.ZRH_Tarifa__c = '{"IdTipoTarifa":"6","TarifaVida":[{"NumeroAsegurados":10,"PrimaAnualUF":0.1,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13FAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"1","IdProductoCotizacion":"0QL75000000E8oRGAS","NumeroAsegurados700":null,"NombreCobertura":"FALLECIMIENTO"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13PAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"3","IdProductoCotizacion":"0QL75000000E8oSGAS","NumeroAsegurados700":null,"NombreCobertura":"MUERTE ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13ZAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"83","IdProductoCotizacion":"0QL75000000E8oUGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13jAAC","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"80","IdProductoCotizacion":"0QL75000000E8oVGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ PERMANENTE (80)"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001HIJbAAO","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"71","IdProductoCotizacion":"0QL75000000E8oWGAS","NumeroAsegurados700":null,"NombreCobertura":"GASTOS MEDICOS Y FUNERARIOS POR FALL"},{"PrimaAnualUF":0.5,"NumeroAsegurados":10,"CapitalAseguradoUF":50,"PrimaMensualUF":0.05,"NombreCobertura":"TOTAL"}]}';
    //     lifeChild1.ZRH_TipoTarifa__c = '6';
    //     qlis.add(lifeChild1);
        
    //     //Life that will be modified in rate
    //     QuoteLineItem lifeChild2 = ZRH_DataFactory.createQuoteLineItem(false, childQuote1, lifeProduct2, lifePricebookEntry2, 'Test Attribute Values');
    //     lifeChild2.ZRH_Tarifa__c = '{"IdTipoTarifa":"6","TarifaVida":[{"NumeroAsegurados":1000000,"PrimaAnualUF":0.1,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13FAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"1","IdProductoCotizacion":"0QL75000000E8oRGAS","NumeroAsegurados700":null,"NombreCobertura":"FALLECIMIENTO"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13PAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"3","IdProductoCotizacion":"0QL75000000E8oSGAS","NumeroAsegurados700":null,"NombreCobertura":"MUERTE ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13ZAAS","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"83","IdProductoCotizacion":"0QL75000000E8oUGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ ACCIDENTAL"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001H13jAAC","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"80","IdProductoCotizacion":"0QL75000000E8oVGAS","NumeroAsegurados700":null,"NombreCobertura":"INVALIDEZ PERMANENTE (80)"},{"PrimaAnualUF":0.1,"NumeroAsegurados":10,"TasaMensual":0.8333,"IdCobertura":"01t75000001HIJbAAO","CapitalAseguradoUF":10,"PrimaMensualUF":0.01,"TasaAnual":10,"CodigoCobertura":"71","IdProductoCotizacion":"0QL75000000E8oWGAS","NumeroAsegurados700":null,"NombreCobertura":"GASTOS MEDICOS Y FUNERARIOS POR FALL"},{"PrimaAnualUF":0.5,"NumeroAsegurados":10,"CapitalAseguradoUF":50,"PrimaMensualUF":0.05,"NombreCobertura":"TOTAL"}]}';
    //     lifeChild2.ZRH_TipoTarifa__c = '6';
    //     lifeChild2.ZRH_TarifaModificada__c = true;
    //     qlis.add(lifeChild2);
        
    //     //Health that won't be modified
    //     QuoteLineItem healthChild = ZRH_DataFactory.createQuoteLineItem(false, childQuote1, healthProduct, healthPricebookEntry, 'Test Attribute Values');
    //     healthChild.ZRH_Tarifa__c = '{"IdTipoTarifa":"3","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"PROMEDIO ASEGURADOS","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"ADICIONAL POR CARGA","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"2"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludNT":20,"TarifaSaludPV":200}]}';
    //     healthChild.ZRH_TipoTarifa__c = '3';
    //     qlis.add(healthChild);
        
    //     //Health that will be modified in rate
    //     QuoteLineItem healthChild1 = ZRH_DataFactory.createQuoteLineItem(false, childQuote1, healthProduct1, healthPricebookEntry1, 'Test Attribute Values');
    //     healthChild1.ZRH_Tarifa__c = '{"IdTipoTarifa":"3","TarifaSalud":[{"TarifaSaludPP":1000000,"DescTarifaSalud":"PROMEDIO ASEGURADOS","TarifaSaludNT":1000000,"TarifaSaludPV":1000000,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":1000000,"DescTarifaSalud":"ADICIONAL POR CARGA","TarifaSaludNT":1000000,"TarifaSaludPV":1000000,"CodigoSubtipoTarifa":"2"},{"TarifaSaludPP":2000000,"DescTarifaSalud":"TOTAL","TarifaSaludNT":200000,"TarifaSaludPV":2000000}]}';
    //     healthChild1.ZRH_TipoTarifa__c = '3';
    //     healthChild1.ZRH_TarifaModificada__c = true;
    //     qlis.add(healthChild1);

    //     //Health that will be modified in rate type
    //     QuoteLineItem healthChild2 = ZRH_DataFactory.createQuoteLineItem(false, childQuote1, healthProduct2, healthPricebookEntry2, 'Test Attribute Values');
    //     healthChild2.ZRH_Tarifa__c = '{"IdTipoTarifa":"3","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"PROMEDIO ASEGURADOS","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"ADICIONAL POR CARGA","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"2"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludNT":20,"TarifaSaludPV":200}]}';
    //     healthChild2.ZRH_TipoTarifa__c = '3';
    //     healthChild2.ZRH_TarifaModificada__c = true;
    //     healthChild2.ZRH_TipoTarifaPrevia__c = '1';
    //     qlis.add(healthChild2);
        
    //     update qlis;

    //     Test.startTest();
    //     ZRH_CalculateHoldingRatesBatch batch = new ZRH_CalculateHoldingRatesBatch();
    //     batch.quoteId = holdingQuote.Id;
    //     Database.executeBatch(batch);
    //     Test.stopTest();

    //     QuotelineItem updatedQuoteLineItem = [SELECT ZRH_Tarifa__c, ZRH_TipoTarifa__c, Product2.ProductCode, ZRH_TarifaModificada__c, ZRH_TipoTarifaPrevia__c, vlocity_ins__Type__c FROM QuoteLineItem WHERE QuoteId = :holdingQuote.Id];
    //     // System.assertEquals('4', updatedQuoteLineItem.ZRH_TipoTarifa__c);
    //     // System.assertEquals('4', updatedQuoteLineItem.ZRH_TipoTarifa__c);
    //     // System.assertEquals('4', updatedQuoteLineItem.ZRH_TipoTarifa__c);
    //     // System.assertEquals('4', updatedQuoteLineItem.ZRH_TipoTarifa__c);
    //     // System.assertEquals('4', updatedQuoteLineItem.ZRH_TipoTarifa__c);
    //     // System.assertEquals('4', updatedQuoteLineItem.ZRH_TipoTarifa__c);
    //     // System.assertEquals('4', updatedQuoteLineItem.ZRH_TipoTarifa__c);
    // }

    @isTest
    static void testHealthRateTypeChangeWithNoOtherRateForChangedRate() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);

        //Health products can change its rate type, in this case, we need to update both the rate type to which is was changed and the rate type that was changed from
        Product2 healthProduct2 = ZRH_DataFactory.createHealthProduct(false);
        healthProduct2.ProductCode = '605';
        insert healthProduct2;

        List<PricebookEntry> pbs = new List<PricebookEntry>();
        PricebookEntry healthPricebookEntry2 = ZRH_DataFactory.createPricebookEntry(false, healthProduct2);
        pbs.add(healthPricebookEntry2);
        insert pbs;

        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);

        List<Quote> quotes = new List<Quote>();
        childQuote1.ZRH_CotizacionHolding__c = holdingQuote.Id;
        quotes.add(childQuote1);
        update quotes;
        
        List<QuoteLineItem> qlis = new List<QuoteLineItem>();

        //Holding QLI
        //Health that will be modified in rate type
        QuoteLineItem healthHolding2 = ZRH_DataFactory.createQuoteLineItem(false, holdingQuote, healthProduct2, healthPricebookEntry2, 'Test Attribute Values');
        healthHolding2.ZRH_Tarifa__c = '{"IdTipoTarifa":"7","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO SOLO","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO CON UNA CARGA","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"2"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"3"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"4"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"5"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"6"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"7"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"8"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CINCO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"9"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludPV":200,"TarifaSaludNT":20}]}';
        healthHolding2.ZRH_TipoTarifa__c = '7';
        qlis.add(healthHolding2);

        //Child QLI
        //Health that will be modified in rate type
        QuoteLineItem healthChild2 = ZRH_DataFactory.createQuoteLineItem(false, childQuote1, healthProduct2, healthPricebookEntry2, 'Test Attribute Values');
        healthChild2.ZRH_Tarifa__c = '{"IdTipoTarifa":"3","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"PROMEDIO ASEGURADOS","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"ADICIONAL POR CARGA","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"2"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludNT":20,"TarifaSaludPV":200}]}';
        healthChild2.ZRH_TipoTarifa__c = '3';
        healthChild2.ZRH_TarifaModificada__c = true;
        healthChild2.ZRH_TipoTarifaPrevia__c = '1';
        qlis.add(healthChild2);
        
        insert qlis;

        Test.startTest();
        ZRH_CalculateHoldingRatesBatch batch = new ZRH_CalculateHoldingRatesBatch();
        batch.quoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<QuotelineItem> updatedQuoteLineItem = [SELECT ZRH_Tarifa__c, ZRH_TipoTarifa__c, Product2.ProductCode, ZRH_TarifaModificada__c, ZRH_TipoTarifaPrevia__c, vlocity_ins__Type__c FROM QuoteLineItem WHERE QuoteId = :holdingQuote.Id];
        // rate type changed
        System.assertEquals('3', updatedQuoteLineItem[0].ZRH_TipoTarifa__c);
        // old rate type no longer exists in holding
        System.assert(updatedQuoteLineItem.size() == 1);
    }

    @isTest
    static void testHealthRateTypeChangeWithOtherRateForChangedRate() {
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);

        //Health products can change its rate type, in this case, we need to update both the rate type to which is was changed and the rate type that was changed from
        Product2 healthProduct2 = ZRH_DataFactory.createHealthProduct(false);
        healthProduct2.ProductCode = '605';
        insert healthProduct2;

        List<PricebookEntry> pbs = new List<PricebookEntry>();
        PricebookEntry healthPricebookEntry2 = ZRH_DataFactory.createPricebookEntry(false, healthProduct2);
        pbs.add(healthPricebookEntry2);
        insert pbs;

        Quote holdingQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote1 = ZRH_DataFactory.createQuote(true, testOpportunity);

        List<Quote> quotes = new List<Quote>();
        childQuote1.ZRH_CotizacionHolding__c = holdingQuote.Id;
        quotes.add(childQuote1);
        update quotes;
        
        List<QuoteLineItem> qlis = new List<QuoteLineItem>();

        //Holding QLI
        //Health that will be modified in rate type
        QuoteLineItem healthHolding2 = ZRH_DataFactory.createQuoteLineItem(false, holdingQuote, healthProduct2, healthPricebookEntry2, 'Test Attribute Values');
        healthHolding2.ZRH_Tarifa__c = '{"IdTipoTarifa":"7","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO SOLO","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO CON UNA CARGA","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"2"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"3"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"4"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"5"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"6"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"7"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"8"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CINCO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"9"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludPV":200,"TarifaSaludNT":20}]}';
        healthHolding2.ZRH_TipoTarifa__c = '7';
        qlis.add(healthHolding2);

        //Child QLI
        //Health that will be modified in rate type
        QuoteLineItem healthChild2 = ZRH_DataFactory.createQuoteLineItem(false, childQuote1, healthProduct2, healthPricebookEntry2, 'Test Attribute Values');
        healthChild2.ZRH_Tarifa__c = '{"IdTipoTarifa":"3","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"PROMEDIO ASEGURADOS","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"ADICIONAL POR CARGA","TarifaSaludNT":10,"TarifaSaludPV":10,"CodigoSubtipoTarifa":"2"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludNT":20,"TarifaSaludPV":200}]}';
        healthChild2.ZRH_TipoTarifa__c = '3';
        healthChild2.ZRH_TarifaModificada__c = true;
        healthChild2.ZRH_TipoTarifaPrevia__c = '1';
        qlis.add(healthChild2);

        QuoteLineItem healthChild3 = ZRH_DataFactory.createQuoteLineItem(false, childQuote1, healthProduct2, healthPricebookEntry2, 'Test Attribute Values');
        healthChild3.ZRH_Tarifa__c = '{"IdTipoTarifa":"7","TarifaSalud":[{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO SOLO","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"1"},{"TarifaSaludPP":10,"DescTarifaSalud":"EMPLEADO CON UNA CARGA","SumaProductoNTPP":100,"SumaProductoNTPV":100,"EdadTermino":10,"TarifaSaludNT":10,"TarifaSaludPV":10,"EdadInicio":10,"CodigoSubtipoTarifa":"2"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"3"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON DOS O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"4"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"5"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON TRES CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"6"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"7"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CUATRO CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"8"},{"SumaProductoNTPV":0,"DescTarifaSalud":"EMPLEADO CON CINCO O MAS CARGAS","SumaProductoNTPP":0,"CodigoSubtipoTarifa":"9"},{"TarifaSaludPP":200,"DescTarifaSalud":"TOTAL","TarifaSaludPV":200,"TarifaSaludNT":20}]}';
        healthChild3.ZRH_TipoTarifa__c = '7';
        qlis.add(healthChild3);
        
        insert qlis;

        Test.startTest();
        ZRH_CalculateHoldingRatesBatch batch = new ZRH_CalculateHoldingRatesBatch();
        batch.quoteId = holdingQuote.Id;
        Database.executeBatch(batch);
        Test.stopTest();

        List<QuotelineItem> updatedQuoteLineItem = [SELECT ZRH_Tarifa__c, ZRH_TipoTarifa__c, Product2.ProductCode, ZRH_TarifaModificada__c, ZRH_TipoTarifaPrevia__c, vlocity_ins__Type__c FROM QuoteLineItem WHERE QuoteId = :holdingQuote.Id];
        // old rate type still exists in holding
        System.assert(updatedQuoteLineItem.size() == 2);
    }
}