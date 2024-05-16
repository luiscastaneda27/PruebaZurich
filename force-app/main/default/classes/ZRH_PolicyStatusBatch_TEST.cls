/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 13/03/2024
Description  : Test class for ZRH_PolicyStatusBatch
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Andrés Deus                 AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE             Description
1.0      AD             13/03/2024       Created Test Class
********************************************************************************/
@isTest
public class ZRH_PolicyStatusBatch_TEST {

    private static final String SR_ASV_VIDA_NAME = 'ZRH_JSON_VidaASV';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';
    private static final String SR_TARIFA_VIDA_NAME = 'ZRH_JSON_VidaTarifa';
    private static final String SR_VIDA_REQ_ASEG_NAME = 'ZRH_JSON_VidaRA';
    private static final String SR_REQ_MED_NAME = 'ZRH_JSON_RequisitosMedicos';
    private static final String SR_SALUD_LIMITS_NAME = 'ZRH_JSON_LIMITS';
    private static final String SR_FOLIO_NUMBER_ONE = '1245-1';
    private static final String SR_FOLIO_NUMBER_TWO = '1245-2';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_ConsultaEstadoPoliza';
    
    /**
    *  @Description: Test setup method to initialize necessary data for the tests
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @testSetup 
    static void setupMethod() {
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        StaticResource vidaTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_VIDA_NAME);
        StaticResource vidaRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_VIDA_REQ_ASEG_NAME);
        StaticResource vidaRM = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);
        StaticResource saludLimits = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_LIMITS_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, saludASV.Body.toString());
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, vidaASV.Body.toString());

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);

        cgpOne.ZRH_Tarifa__c = vidaTarifa.Body.toString();
        cgpOne.ZRH_AtributosTopes__c = saludLimits.Body.toString();
        cgpOne.ZRH_Folio__c = SR_FOLIO_NUMBER_ONE;
        cgpOne.ZRH_Estado__c = '3';
        cgpOne.ZRH_AtributosRequisitosAsegurabilidad__c = vidaRA.Body.toString();
        cgpTwo.ZRH_Folio__c = SR_FOLIO_NUMBER_TWO;
        cgpTwo.ZRH_Estado__c = '3';

        update cgpOne;
        update cgpTwo;
    }

    /**
    *  @Description: Test method to verify the batch process handling and state change of policy status
    *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        13/03/2024
    */
    @isTest
    static void testBatch() {
        
        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        String endPoint = service.ZRH_URLBase__c + path.ZRH_RutaURL__c;

        String expectedStatus = '2'; 
        Test.setMock(HttpCalloutMock.class, new ZRH_UtilityHttpRequestMock_TEST(endPoint, 'application/json', 200,  expectedStatus));

        Test.startTest();
        ZRH_PolicyStatusBatch batch = new ZRH_PolicyStatusBatch();
        Database.executeBatch(batch, 2);
        Test.stopTest();
    }
}