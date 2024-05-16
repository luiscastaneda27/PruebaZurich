/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 18/03/2024
Description  : Class test for class ZRH_JSONDataTransformationHelper
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          18/03/2024        Initial Version
********************************************************************************/
@isTest
public class ZRH_JSONDataTransformationHelper_TEST {

    private static final String OBJECT_NAME = 'QuoteLineItem';
    private static final String NAME_FIELD = 'vlocity_ins__NeedReprice__c';
    private static final String JSON_FIELD = 'vlocity_ins__AttributeSelectedValues__c';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';

    /**
    *  @Description: Test the Method populateSalesforceFieldFromAttributes
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest
    static void populateSalesforceFieldFromAttributes() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote testQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, testQuote, testProduct, testPricebookEntry, saludASV.Body.toString());
        
        Map<String,Object> dataObj = (Map<String,Object>) System.JSON.deserializeUntyped(saludASV.Body.toString());
        
        ZRH_DiccionarioPoblacionDatosJSON__mdt item = new ZRH_DiccionarioPoblacionDatosJSON__mdt();
        item.ZRH_Objeto__c = OBJECT_NAME;
        item.ZRH_CampoDestino__c = NAME_FIELD;
        item.ZRH_CampoJSON__c = JSON_FIELD;
        item.ZRH_CampoDestino__c = JSON_FIELD;
        
        Test.startTest();
        ZRH_JSONDataTransformationHelper.assignValueField(testQuoteLineItem, item, dataObj);
        update testQuoteLineItem;
        Test.stopTest();
    }
}