/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 13/03/2024
Description  : Test class for ZRH_PolicyStatusQueueable, ensuring that the queueable
               class responsible for handling policy status updates operates correctly.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Andrés Deus                 AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE             Description
1.0      AD             13/03/2024       Created Test Class
********************************************************************************/
@IsTest
private class ZRH_PolicyStatusQueueable_TEST {
    
    private static final String QUERY_CONDITION = 'ContractGroupParentPlanId = null';
    private static final String SR_ASV_VIDA_NAME = 'ZRH_JSON_VidaASV';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_TARIFA_SCHOLARSHIP_NAME = 'ZRH_JSON_EscolaridadTarifa';
    private static final String SR_ASV_COBERTURA_NAME = 'ZRH_JSON_CoberturaASV';
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';
    private static final String SR_TARIFA_VIDA_NAME = 'ZRH_JSON_VidaTarifa';
    private static final String SR_REQ_MED_NAME = 'ZRH_JSON_RequisitosMedicos';
    private static final String SR_VIDA_REQ_ASEG_NAME = 'ZRH_JSON_VidaRA';
    private static final String SR_SALUD_LIMITS_NAME = 'ZRH_JSON_LIMITS';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_ConsultaEstadoPoliza';
    private static final String BODY_RESPONSE = '2';
    private static final String FOLIO_NUMBER = '373951';
    private static final String LIFE_SCHOLARSHIP_RATE = 'TarifaEscolaridad';

    /**
    *  @Description: Setup method to prepare data for test scenarios
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @testSetup 
    static void setupMethod() {
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        StaticResource saludTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        StaticResource vidaTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_VIDA_NAME);
        StaticResource vidaRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_VIDA_REQ_ASEG_NAME);
        StaticResource vidaRM = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);
        StaticResource saludLimits = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_LIMITS_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        Product2 testPersonalAccidentsProduct = ZRH_DataFactory.createPersonalAccidentsProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        PricebookEntry testPricebookEntryPersonalAccidents = ZRH_DataFactory.createPricebookEntry(true, testPersonalAccidentsProduct);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testPersonalAccidentsProduct, testPricebookEntryPersonalAccidents,  vidaASV.Body.toString());
        
        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues att = (ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues) JSON.deserialize(cgpTwo.vlocity_ins_fsc__AttributeSelectedValues__c, ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues.class);
        Integer valorCero = 0;
        att.Asegurado = valorCero;
        att.EmpUnaCrg = valorCero;
        att.EmpDosCrgs = valorCero;
        att.EmpDosMasCrgs = valorCero;
        att.EmpTresMasCrgs = valorCero;
        att.EmpTresCrgs = valorCero;
        att.EmpCuatroMasCrgs = valorCero;
        att.EmpCuatroCrgs = valorCero;
        att.EmpCincoMasCrgs = valorCero;
        att.NumMaxDedGrpFam = valorCero;
       
        
        cgpOne.ZRH_Tarifa__c = saludTarifa.Body.toString();
        cgpOne.ZRH_AtributosTopes__c = saludLimits.Body.toString();
        cgpOne.ZRH_Folio__c = FOLIO_NUMBER;
        cgpOne.ZRH_AtributosRequisitosAsegurabilidad__c = vidaRA.Body.toString();
        cgpTwo.ContractGroupParentPlanId  = cgpOne.Id;
        cgpTwo.vlocity_ins_fsc__AttributeSelectedValues__c = JSON.serialize(att);
        
        update cgpone;
        update cgpTwo;
    }

    /**
    *  @Description: Test method to verify the constructor's functionality in initializing the instance
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @IsTest 
    static void testConstructor() {
        
        String condition = 'ZRH_Folio__c = \'' + FOLIO_NUMBER + '\'';
        List<ContractGroupPlan> mockPlans = new ZRH_ContractGroupPlansSelector().selectByFolio(condition, new List<String>{'Name'});
        Set<Id> contractGroupPlanIds = new Set<Id>{mockPlans[0].Id};
        List<String> outputVariables = new List<String>();

        Test.startTest();
        ZRH_PolicyStatusQueueable instance = new ZRH_PolicyStatusQueueable(contractGroupPlanIds, outputVariables);
        Test.stopTest();
    }

    /**
    *  @Description: Test method to verify the makeCallout method's functionality and HTTP callout behavior
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @IsTest 
    static void testMakeCallout() {
        String condition = 'ZRH_Folio__c = \'' + FOLIO_NUMBER + '\'';
        List<ContractGroupPlan> mockPlans = new ZRH_ContractGroupPlansSelector().selectByFolio(condition, new List<String>{'Name'});
        Set<Id> contractGroupPlanIds = new Set<Id>{mockPlans[0].Id};
        List<String> outputVariables = new List<String>();

        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        String endPoint = service.ZRH_URLBase__c + path.ZRH_RutaURL__c;
        Test.setMock(HttpCalloutMock.class, new ZRH_UtilityHttpRequestMock_TEST(endPoint, 'application/json', 200, BODY_RESPONSE));

        Test.startTest();
        ZRH_PolicyStatusQueueable.makeCallout(contractGroupPlanIds, outputVariables);
        Test.stopTest();
    }

    /**
    *  @Description: Test method to verify the makeCallout method's functionality and HTTP callout behavior for Failure
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @IsTest 
    static void testMakeCalloutFailure() {
        String condition = 'ZRH_Folio__c = \'' + FOLIO_NUMBER + '\'';
        List<ContractGroupPlan> mockPlans = new ZRH_ContractGroupPlansSelector().selectByFolio(condition, new List<String>{'Name'});
        Set<Id> contractGroupPlanIds = new Set<Id>{mockPlans[0].Id};
        List<String> outputVariables = new List<String>();

        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        String endPoint = service.ZRH_URLBase__c + path.ZRH_RutaURL__c;

        Test.setMock(HttpCalloutMock.class, new ZRH_UtilityHttpRequestMock_TEST(endPoint, 'application/json', 200, 'error'));

        Test.startTest();
        ZRH_PolicyStatusQueueable.makeCallout(contractGroupPlanIds, outputVariables);
        Test.stopTest();
    }
}