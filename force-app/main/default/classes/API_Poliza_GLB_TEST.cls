@isTest
public with sharing class API_Poliza_GLB_TEST {

    @TestSetup
    static void testSetup(){
        Account a = new Account(
            Name = 'TEST ACCOUNT',
            GLBP1_Rut__c = '65155524-8'
        );

        insert a;
        
        Contact c = new Contact(
            FirstName = 'TEST CONTACT',
            lastName = 'TEST CONTACT',
            Accountid = a.Id
        );

        insert c;
    }

    @isTest
    public static void POST_API_TEST_FAIL_VOID_RELATIONSHIPS() {
        

        API_Poliza_GLB.API_POST_POLIZA_WRAPPER mockData = new API_Poliza_GLB.API_POST_POLIZA_WRAPPER();
        mockData.poliza = new InsurancePolicy(
            GLB_P1_NumeroPolizaExterno__c= 'P000003',
            IntermediaryAccount = new Account(GLBP1_Rut__c = '65155524-8'),
            PolicyDescription= 'Descripcion de prueba',
            Status= 'Active',
            PremiumAmount= 10000.00,
            PremiumFrequency= 'Monthly',
            Name='P000003',
            NameInsured = new Account(GLBP1_Rut__c = '65155524-8'),
            PolicyType = 'Auto'
        );
        mockData.planesDePago = new List<GLBP1_Plan_de_pago__c>();
        mockData.activosDePoliza = new List<InsurancePolicyAsset>();
        mockData.beneficiariosDePoliza = new List<GLBP1_Beneficiario_de_Poliza__c>();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestURI = '/services/apexrest/poliza';  //Request URL

        req.httpMethod = 'POST';//HTTP Request Type

        RestContext.request = req;

        RestContext.response= res;

        Test.startTest();

        API_Poliza_GLB.createPoliza(mockData);

        Test.stopTest();
    }

    @isTest
    public static void POST_API_TEST_FAIL_VOID_ID() {
        

        API_Poliza_GLB.API_POST_POLIZA_WRAPPER mockData = new API_Poliza_GLB.API_POST_POLIZA_WRAPPER();
        mockData.poliza = new InsurancePolicy(
            GLB_P1_NumeroPolizaExterno__c= '',
            IntermediaryAccount = new Account(GLBP1_Rut__c = '65155524-8'),
            PolicyDescription= 'Descripcion de prueba',
            Status= 'Active',
            PremiumAmount= 10000.00,
            PremiumFrequency= 'Monthly',
            Name='P000003',
            NameInsured = new Account(GLBP1_Rut__c = '65155524-8'),
            PolicyType = 'Auto'
        );
        mockData.planesDePago = new List<GLBP1_Plan_de_pago__c>();
        mockData.activosDePoliza = new List<InsurancePolicyAsset>();
        mockData.beneficiariosDePoliza = new List<GLBP1_Beneficiario_de_Poliza__c>();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestURI = '/services/apexrest/poliza';  //Request URL

        req.httpMethod = 'POST';//HTTP Request Type

        RestContext.request = req;

        RestContext.response= res;

        Test.startTest();

        API_Poliza_GLB.createPoliza(mockData);

        Test.stopTest();
    }

    @isTest
    public static void POST_API_TEST_SUCCESS() {
        String recordTypeIdBS = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Account a = new Account(
            Name = 'TEST ACCOUNT',
            ZRH_Rut__c = '65155524-8'
        );

        //insert a;

        a = [Select Id, GLBP1_Rut__c from Account where  Name = 'TEST ACCOUNT'];
        a.RecordTypeId = recordTypeIdBS;
        update a;
        

        API_Poliza_GLB.API_POST_POLIZA_WRAPPER mockData = new API_Poliza_GLB.API_POST_POLIZA_WRAPPER();
        mockData.poliza = new InsurancePolicy(
            GLB_P1_NumeroPolizaExterno__c= 'P000003',
            IntermediaryAccountId = a.Id,
            PolicyDescription= 'Descripcion de prueba',
            Status= 'Active',
            PremiumAmount= 10000.00,
            PremiumFrequency= 'Monthly',
            Name='P000003',
            NameInsuredId = a.Id,
            PolicyType = 'Auto'
        );
        mockData.planesDePago = new List<GLBP1_Plan_de_pago__c>();
        mockData.planesDePago.add(new GLBP1_Plan_de_pago__c(
            GLBP1_Cliente__r = new Account(GLBP1_Rut__c = '65155524-8'),
            GLBP1_Direcci_n_de_cobranza__c = 'Avenida Siempre Viva 123',
            GLBP1_Forma_de_pago__c = 'Contado',
            GLBP1_Poliza_de_seguro__r = new InsurancePolicy(GLB_P1_NumeroPolizaExterno__c = 'P000003'),
            Name = 'Plan de pago de prueba'
        ));
        mockData.activosDePoliza = new List<InsurancePolicyAsset>();
        mockData.activosDePoliza.add(new InsurancePolicyAsset(
            IsActive = true,
            AssetName = 'BMW E36 325I',
            StandardPremiumAmount = 36000.00,
            InsurancePolicy = new InsurancePolicy(GLB_P1_NumeroPolizaExterno__c = 'P000003')
        ));
        mockData.beneficiariosDePoliza = new List<GLBP1_Beneficiario_de_Poliza__c>();
        mockData.beneficiariosDePoliza.add(new GLBP1_Beneficiario_de_Poliza__c(
            GLB_P1_Rut__c = '33333333',
            Name = 'Test Name',
            GLB_P1_Sexo__c = 'Masculino',
            GLB_P1_Parentesco__c = 'Cónyuge',
            GLB_P1_Porcentaje__c = 100,
            GLB_P1_NombrePoliza__r =  new InsurancePolicy(GLB_P1_NumeroPolizaExterno__c = 'P000003')
        ));

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestURI = '/services/apexrest/poliza';  //Request URL

        req.httpMethod = 'POST';//HTTP Request Type

        RestContext.request = req;

        RestContext.response= res;

        Test.startTest();

        API_Poliza_GLB.createPoliza(mockData);

        Test.stopTest();
    }
}