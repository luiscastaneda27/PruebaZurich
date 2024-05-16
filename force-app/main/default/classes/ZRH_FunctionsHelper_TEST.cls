/*******************************************************************************************************
 * Project: ZURICH - Salesforce
 * Created By: Deloitte
 * Created Date: 06/09/2023
 * Description: Test class of ZRH_FunctionsHelper
 * ----------------------------------- ACRONYM OF AUTHORS -----------------------------------------------
 * AUTHOR                               ACRONYM
 * Jair Anton Atuncar                   JANTON
 * ------------------------------------------------------------------------------------------------------
 * VERSION          AUTHOR          DATE                Description
 * 1.0              JANTON          06/09/2023          initial version
 *******************************************************************************************************/
@isTest
public class ZRH_FunctionsHelper_TEST {
    /*
        @Description: execute and validate success response from function helper (replace)
        @Author: JANTON, Deloitte, jantona@deloitte.com
        @Date: 06/09/2023
    */
    @IsTest
    static void replaceFunctionSuccessTest() {
        Test.startTest();
            ZRH_FunctionsHelper helper = new ZRH_FunctionsHelper();
            Map<String, Object> args = new Map<String, Object>();
            args.put('input', new Map<String, Object>{'arguments' => new List<String> {'700, 600, 500', ', ', ';'}});
            args.put('output', new Map<String, Object>());
            args.put('options', new Map<String, Object>());
            
            Object result = helper.call('replace', args);
            Assert.areNotEqual(new Map<String, Object>(), (Map<String, Object>) args.get('output'));
        Test.stopTest();
    }

    /*
        @Description: execute and validate error response from function helper (replace)
        @Author: JANTON, Deloitte, jantona@deloitte.com
        @Date: 06/09/2023
    */
    @IsTest
    static void replaceFunctionFailedTest() {
        Test.startTest();
            ZRH_FunctionsHelper helper = new ZRH_FunctionsHelper();
            Map<String, Object> args = new Map<String, Object>();
            args.put('input', new Map<String, Object>{'arguments' => new List<String> {'700, 600, 500', ', '}});
            args.put('output', new Map<String, Object>());
            args.put('options', new Map<String, Object>());
            
            Object result = helper.call('replace', args);
            Assert.areNotEqual(new Map<String, Object>(), (Map<String, Object>) args.get('output'));
        Test.stopTest();
    }
    
    /*   @IsTest
    static void replaceFunctionFailedfilterPlansTest() {
        Test.startTest();
            ZRH_FunctionsHelper helper = new ZRH_FunctionsHelper();
            Map<String, Object> args = new Map<String, Object>();
            args.put('input', new Map<String, Object>{'arguments' => new List<String> {'700, 600, 500', ', '}});
            args.put('output', new Map<String, Object>());
            args.put('options', new Map<String, Object>());
            
            Object result = helper.call('filterPlans', args);
          //  Assert.areNotEqual(new Map<String, Object>(), (Map<String, Object>) args.get('output'));
        Test.stopTest();
    }*/
    static testMethod void testPlanExistEmpty() {
        string methodName = 'filterPlans';
        ZRH_FunctionsHelper obj = new ZRH_FunctionsHelper();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
         
        Test.startTest();
            inputMap.put('PlanesSeleccionados' , new List<String> {'700, 600, 500', ', '});
            inputMap.put('PlanesExistentes' , '');
            obj.invokeMethod(methodName, inputMap, outputMap, options);
        Test.stopTest();  
    }

    @isTest(SeeAllData=true)
    static void testPlanExistNotEmpty() {
   
        string methodName = 'filterPlans';
        ZRH_FunctionsHelper obj = new ZRH_FunctionsHelper();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Test.startTest();
        List<String> listQuoteLineItem = new List<String>();
        Opportunity opp =new Opportunity (name='myquote',StageName='New',CloseDate=Date.today());
        insert opp;
        Pricebook2 stdPb =[select Id from Pricebook2 limit 1];
        Product2 p = new product2(Name='Dental',ProductCode='500');
        p.Family = 'Salud';
        insert p;
        PricebookEntry pbe = new PricebookEntry(pricebook2id = stdPb.id, product2id = p.id,unitprice=1.0,isActive=true);
        insert pbe;
        Quote q=new Quote(Name='myquote',opportunityid=opp.id,pricebook2id=stdPb.id);
        insert q;
        QuoteLineItem i = new Quotelineitem(); 
        i.quoteid = q.id; 
        i.pricebookentryid = pbe.id; 
        i.quantity= 1; 
        i.unitprice= 1; 
        insert(i);
        listQuoteLineItem.add(JSON.serialize(i));
        // List<String> listMapQuote =  (List<String>) listQuoteLineItem;
        //  List<Map<String, Object>> existingPlans = (List<Map<String, Object>>)listQuoteLineItem;
        //System.debug('Quote i =  '+i);
        inputMap.put('PlanesSeleccionados' , new List<String> {'700, 600, 500', ', '});
        inputMap.put('PlanesExistentes' ,listQuoteLineItem);
        obj.invokeMethod(methodName, inputMap, outputMap, options);
        Test.stopTest();
        
    }
    
    /**
    *  @Description: Test for the Method gloss
    *  @Autor:       Luis Castañeda, Deloitte
    *  @Date:        7/11/2023
    */
    @isTest
    static  void testGloss() {
   
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testHealthCoverage = ZRH_DataFactory.createProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryHealthCoverage = ZRH_DataFactory.createPricebookEntry(true, testHealthCoverage);
        Quote parentQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        Quote childQuote = ZRH_DataFactory.createChildQuote(true, testOpportunity, parentQuote);
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        inputMap.put(ZRH_FunctionsHelper.TEXT_RECORD , childQuote.Id);
        Test.startTest();
        ZRH_FunctionsHelper obj = new ZRH_FunctionsHelper();
        obj.invokeMethod(ZRH_FunctionsHelper.GLOSS_CONTRACTOR, inputMap, outputMap, options);
        obj.invokeMethod(ZRH_FunctionsHelper.GLOSS_HONDING, inputMap, outputMap, options);
        System.assertEquals(inputMap != null, true, 'Working!');
        Test.stopTest();
    }

    @isTest static void testSortLifeRates() {
        List<Map<String, Object>> tarifaVida = new List<Map<String, Object>>{
            new Map<String, Object>{
                'NumeroAsegurados' => 5,
                'TasaMensual' => 0.4167,
                'CapitalAseguradoUF' => 5,
                'IdProductoCotizacion' => '0QL8B000000IHt3WAG',
                'NumeroAsegurados700' => null,
                'PrimaAnualVigenteUF' => 0.025,
                'NombreCobertura' => 'FALLECIMIENTO',
                'PrimaAnualUF' => 0.025,
                'TasaAnualVigente' => 5,
                'IdCobertura' => '01t78000008YAesAAG',
                'PrimaMensualUF' => 0,
                'PrimaMensualVigenteUF' => 0,
                'TasaAnual' => 5,
                'CodigoCobertura' => '1',
                'TasaMensualVigente' => 0.4167
            },
            new Map<String, Object>{
                'NumeroAsegurados' => 5,
                'TasaMensual' => 0.4167,
                'CapitalAseguradoUF' => 5,
                'IdProductoCotizacion' => '0QL8B000000IHt2WAG',
                'NumeroAsegurados700' => null,
                'PrimaAnualVigenteUF' => 0.025,
                'NombreCobertura' => 'MUERTE ACCIDENTAL',
                'PrimaAnualUF' => 0.025,
                'TasaAnualVigente' => 5,
                'IdCobertura' => '01t78000008YAepAAG',
                'PrimaMensualUF' => 0,
                'PrimaMensualVigenteUF' => 0,
                'TasaAnual' => 5,
                'CodigoCobertura' => '3',
                'TasaMensualVigente' => 0.4167
            },
            new Map<String, Object>{
                'NumeroAsegurados' => 5,
                'TasaMensual' => 0.4167,
                'CapitalAseguradoUF' => 5,
                'IdProductoCotizacion' => '0QL8B000000IHszWAG',
                'NumeroAsegurados700' => null,
                'PrimaAnualVigenteUF' => 0.025,
                'NombreCobertura' => 'PAGO MENSUAL POR INCAPACIDAD TEMPORAL',
                'PrimaAnualUF' => 0.025,
                'TasaAnualVigente' => 5,
                'IdCobertura' => '01t78000008YAelAAG',
                'PrimaMensualUF' => 0,
                'PrimaMensualVigenteUF' => 0,
                'TasaAnual' => 5,
                'CodigoCobertura' => '27',
                'TasaMensualVigente' => 0.4167
            },
            new Map<String, Object>{
                'NumeroAsegurados' => 5,
                'TasaMensual' => 0.4167,
                'CapitalAseguradoUF' => 5,
                'IdProductoCotizacion' => '0QL8B000000IHt0WAG',
                'NumeroAsegurados700' => null,
                'PrimaAnualVigenteUF' => 0.025,
                'NombreCobertura' => 'INVALIDEZ PERMANENTE (80)',
                'PrimaAnualUF' => 0.025,
                'TasaAnualVigente' => 5,
                'IdCobertura' => '01t78000008YAemAAG',
                'PrimaMensualUF' => 0,
                'PrimaMensualVigenteUF' => 0,
                'TasaAnual' => 5,
                'CodigoCobertura' => '80',
                'TasaMensualVigente' => 0.4167
            },
            new Map<String, Object>{
                'NumeroAsegurados' => 5,
                'TasaMensual' => 0.4167,
                'CapitalAseguradoUF' => 5,
                'IdProductoCotizacion' => '0QL8B000000IHt1WAG',
                'NumeroAsegurados700' => null,
                'PrimaAnualVigenteUF' => 0.025,
                'NombreCobertura' => 'INVALIDEZ ACCIDENTAL',
                'PrimaAnualUF' => 0.025,
                'TasaAnualVigente' => 5,
                'IdCobertura' => '01t78000008YAenAAG',
                'PrimaMensualUF' => 0,
                'PrimaMensualVigenteUF' => 0,
                'TasaAnual' => 5,
                'CodigoCobertura' => '83',
                'TasaMensualVigente' => 0.4167
            }
        };

        ZRH_FunctionsHelper helper = new ZRH_FunctionsHelper();
        Map<String, Object> inputs = new Map<String, Object>{'arguments' => tarifaVida};
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Test.startTest();
        Boolean isSuccess = helper.invokeMethod('sortLifeRates', inputs, output, options);
        Test.stopTest();

        List<Object> sortedResults = (List<Object>)output.get('result');
        System.assert(isSuccess, 'Method invocation should be successful');
        System.assertNotEquals(null, sortedResults, 'Results should not be null');

        Map<String, Object> firstSortedItem = (Map<String, Object>)sortedResults.get(0);
        System.assertEquals('1', firstSortedItem.get('CodigoCobertura'), 'The first item should have CodigoCobertura 1');
    }
}