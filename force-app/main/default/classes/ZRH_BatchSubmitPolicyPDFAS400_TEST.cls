/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/11/2023
Description  : Class test for class ZRH_BatchSubmitPolicyPDFAS400
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          27/11/2023        initial version
********************************************************************************/
@isTest
public class ZRH_BatchSubmitPolicyPDFAS400_TEST {

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023  
    */
    private static final String QUERY_CONDITION = 'ContractGroupParentPlanId = null';
    private static final String SR_ASV_VIDA_NAME = 'ZRH_JSON_VidaASV';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_ASV_COBERTURA_NAME = 'ZRH_JSON_CoberturaASV';
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';
    private static final String SR_TARIFA_SCHOLARSHIP_NAME = 'ZRH_JSON_EscolaridadTarifa';
    private static final String SR_TARIFA_VIDA_NAME = 'ZRH_JSON_VidaTarifa';
    private static final String SR_REQ_MED_NAME = 'ZRH_JSON_RequisitosMedicos';
    private static final String SR_VIDA_REQ_ASEG_NAME = 'ZRH_JSON_VidaRA';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_EnvioPDFPoliza';
    private static final String SR_BODY_RESPONSE = 'ZRH_JSON_InputPDF';
    private static final String SR_FOLIO_NUMBER = '1245-0';
    private static final String CODE_POLICY_GLOSS = 'D-001';
    private static final List<Decimal> SR_GLOSS_ID = new List<Decimal> {83,143};
    private static final String METHOD_NAME_PDF = 'executeGeneratePDF';
    private static final String METHOD_NAME_PROPOSAL = 'executeSubmitProposal';
    private static final String VARIABLE_NAME = 'ContractHoldingId';
    private static final String OBJECT_CONTRACT= 'Contract';
    private static final String OBJECT_CONTRACT_GROUP_PLAN = 'ContractGroupPlan';
    private static final String OBJECT_API_NAME = 'objectApiName';
    private static final String RECORD_ID = 'recordId';
    
     @testSetup 
    static void setupMethod() {
        StaticResource vidaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_VIDA_NAME);
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource coberturaASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_COBERTURA_NAME);
        StaticResource saludTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        StaticResource vidaTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_VIDA_NAME);
        StaticResource vidaRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_VIDA_REQ_ASEG_NAME);
        StaticResource vidaRM = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(true);
        Product2 testLifeProduct = ZRH_DataFactory.createLifeProduct(true);
        Product2 testPersonalAccidentsProduct = ZRH_DataFactory.createPersonalAccidentsProduct(true);
        PricebookEntry testPricebookEntryHealth = ZRH_DataFactory.createPricebookEntry(true, testHealthProduct);
        PricebookEntry testPricebookEntryLife = ZRH_DataFactory.createPricebookEntry(true, testLifeProduct);
        PricebookEntry testPricebookEntryPersonalAccidents = ZRH_DataFactory.createPricebookEntry(true, testPersonalAccidentsProduct);
        Quote testQuoteOne = ZRH_DataFactory.createQuote(true, testOpportunity);
        
        QuoteLineItem testQuoteLineItemOne = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testLifeProduct, testPricebookEntryLife, vidaASV.Body.toString());
        QuoteLineItem testQuoteLineItemTwo = ZRH_DataFactory.createQuoteLineItem(true, testQuoteOne, testPersonalAccidentsProduct, testPricebookEntryPersonalAccidents,  vidaASV.Body.toString());
        
        ZRH_Glosas__c testGlosaHealthOne = ZRH_DataFactory.createRateGloss(true, testQuoteLineItemOne.Id);
        ZRH_Glosas__c testGlosaLifeOne = ZRH_DataFactory.createRateGloss(true, testQuoteLineItemOne.Id);
        ZRH_Glosas__c testGlosaLifeTwo = ZRH_DataFactory.createRequirementGloss(true, testQuoteLineItemOne.Id);
        ZRH_Glosas__c testGlosaLifeThree = ZRH_DataFactory.createMedicalRequirementGloss(true, testQuoteLineItemOne.Id);

        Contract testContract = ZRH_DataFactory.createContract(true, testQuoteOne, testAccount);
        ContractGroupPlan cgpOne = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemOne);
        ContractGroupPlan cgpTwo = ZRH_DataFactory.createContractGroupPlan(true, testContract, testQuoteLineItemTwo);
        
       
        
        cgpOne.ZRH_Tarifa__c = saludTarifa.Body.toString();
        cgpOne.ZRH_Folio__c = SR_FOLIO_NUMBER;
        cgpOne.ZRH_AtributosRequisitosAsegurabilidad__c = vidaRA.Body.toString();
        cgpOne.ZRH_AtributosReqMedicosSeleccionado__c = vidaRM.Body.toString();
        cgpOne.EffectiveStartDate = System.now();
        cgpOne.EffectiveEndDate = System.now().addYears(1);
        cgpOne.ContractGroupParentPlanId = null;
        cgpTwo.ContractGroupParentPlanId  = cgpone.Id;
        testGlosaHealthOne.ZRH_PlanDelContrato__c = cgpone.Id;
        testGlosaHealthOne.ZRH_DestinoTipoPDF__c = CODE_POLICY_GLOSS;
        testGlosaHealthOne.ZRH_ContieneTabla__c = true;
        Boolean modificacionGlosasEspeciales = false;
        testGlosaHealthOne.ZRH_ModificacionGlosasEspeciales__c = !modificacionGlosasEspeciales;
        testGlosaLifeOne.ZRH_PlanDelContrato__c = cgpone.Id;
        testGlosaLifeOne.ZRH_DestinoTipoPDF__c = CODE_POLICY_GLOSS;
        testGlosaLifeOne.ZRH_ContieneTabla__c = true;
        testGlosaLifeOne.ZRH_ModificacionGlosasEspeciales__c = !modificacionGlosasEspeciales;
        testGlosaLifeTwo.ZRH_PlanDelContrato__c = cgpone.Id;
        testGlosaLifeTwo.ZRH_DestinoTipoPDF__c = CODE_POLICY_GLOSS;
        testGlosaLifeTwo.ZRH_ContieneTabla__c = true;
        testGlosaLifeTwo.ZRH_ModificacionGlosasEspeciales__c = !modificacionGlosasEspeciales;
        testGlosaLifeThree.ZRH_PlanDelContrato__c = cgpone.Id;
        testGlosaLifeThree.ZRH_DestinoTipoPDF__c = CODE_POLICY_GLOSS;
        testGlosaLifeThree.ZRH_ContieneTabla__c = true;
        testGlosaLifeThree.ZRH_ModificacionGlosasEspeciales__c = !modificacionGlosasEspeciales;
        
        
        ZRH_Glosas__c testGlosaLifefuor = testGlosaLifeThree.clone(true);
        ZRH_Glosas__c testGlosaLifefive = testGlosaLifeThree.clone(true);
        testGlosaLifefuor.Id = null;
        testGlosaLifefuor.ZRH_IDGlosa__c = SR_GLOSS_ID[0];
        testGlosaLifefive.Id = null;
        testGlosaLifefive.ZRH_IDGlosa__c = SR_GLOSS_ID[1];
        
        update cgpone;
        update cgpTwo;
        update testGlosaHealthOne;
        update testGlosaLifeOne;
        update testGlosaLifeTwo;
        update testGlosaLifeThree;
        insert testGlosaLifefuor;
        insert testGlosaLifefive;
    }
    
    
    /**
    *  @Description: Test the for the class bathc ZRH_BatchSendPolicyPDFAS400
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */
    @isTest 
    static void batchSubmitPolicyPDFAS400Test() {
        ZRH_RutaIntegracion__mdt path = ZRH_RutaIntegracion__mdt.getInstance(INTEGRATION_ROUTE);
        ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
        
        List<String> endPoint = new List<String>();
        endPoint.add(service.ZRH_URLBase__c + path.ZRH_RutaURL__c);
        List<String> resBody = new List<String>();
        resBody.add(SR_BODY_RESPONSE);
        ZRH_UtilityHttpRequestMock_TEST.getMultimock(endPoint, resBody, 200);
        
        Test.startTest();
        Id jobId = Database.executeBatch(new ZRH_BatchSubmitPolicyPDFAS400(QUERY_CONDITION), 1);
        System.assertEquals(jobId != null, true, 'It´s Worked!');
        Test.stopTest();
    }
    
     /**
    *  @Description: Test for the Method gloss
    *  @Autor:       Luis Castañeda, Deloitte
    *  @Date:        7/11/2023
    */
    @isTest
    static  void testGloss() {
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        inputMap.put(VARIABLE_NAME, UserInfo.getUserId());
        Test.startTest();
        ZRH_PolicyPDFController obj = new ZRH_PolicyPDFController();
        Boolean response = (Boolean) obj.invokeMethod(METHOD_NAME_PDF, inputMap, outputMap, options);
        inputMap.put(RECORD_ID, UserInfo.getUserId());
        inputMap.put(OBJECT_API_NAME, OBJECT_CONTRACT);
        response = (Boolean) obj.invokeMethod(METHOD_NAME_PROPOSAL, inputMap, outputMap, options);
        
        StaticResource escolTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SCHOLARSHIP_NAME);
        ZRH_PolicyPDFController.mapRatesScholarShip(new ContractGroupPlan(ZRH_Tarifa__c = escolTarifa.Body.toString()));
        ZRH_PolicyPDFController.mapDeductibles(new ContractGroupPlan(ZRH_Tarifa__c = escolTarifa.Body.toString()));
        ZRH_PolicyPDFController.mapDeductiblesBySection(new ContractGroupPlan(ZRH_Tarifa__c = escolTarifa.Body.toString()));
        System.assertEquals(response, true, 'Working!');
        
        ContractGroupPlan cgpOne = [Select Id,ContractId, (Select Name,vlocity_ins_fsc__Product2Id__c, vlocity_ins_fsc__AttributeSelectedValues__c,ZRH_GrupoDeCobertura__c, ZRH_CodigoProducto__c from ChildContractGroupPlans) from ContractGroupPlan limit 1];
        Update new Product2 (Id = cgpOne.ChildContractGroupPlans[0].vlocity_ins_fsc__Product2Id__c, ProductCode = '12t');
        cgpOne = [Select Id,ContractId, (Select Name, vlocity_ins_fsc__Product2Id__c, vlocity_ins_fsc__AttributeSelectedValues__c,ZRH_GrupoDeCobertura__c, ZRH_CodigoProducto__c from ChildContractGroupPlans) from ContractGroupPlan  limit 1];
        ZRH_PolicyPDFController.mapDeductibles(cgpOne);
        ZRH_PolicyPDFController.mapDeductiblesBySection(cgpOne);
        Test.stopTest();   
    }

    
}