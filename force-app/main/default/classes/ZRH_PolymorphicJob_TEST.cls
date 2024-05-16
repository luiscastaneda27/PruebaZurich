/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 8/4/2024
Description  : Class test for class ZRH_PolymorphicJob
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Felipe Romualdo Gaete              FRP
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      FRP          8/4/2024        initial version
********************************************************************************/
@IsTest
private class ZRH_PolymorphicJob_TEST {
    
    private static final String OBJECT_NAME = 'QuoteLineItem';
    private static final String NAME_FIELD = 'vlocity_ins__NeedReprice__c';
    private static final String JSON_FIELD = 'vlocity_ins__AttributeSelectedValues__c';
    private static final String SR_ASV_SALUD_NAME = 'ZRH_JSON_SaludASV';
    private static final String SR_TARIFA_SALUD_NAME = 'ZRH_JSON_SaludTarifa';

    // Método setup que crea registros de prueba necesarios antes de ejecutar las pruebas
    @TestSetup
    static void setup() {
        // Código para crear registros de prueba si es necesario
    }

    // Método de prueba para el método execute de ZRH_PolymorphicJob
    @IsTest
    static void testExecute() {
        StaticResource saludASV = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ASV_SALUD_NAME);
        StaticResource saludTarifa = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_TARIFA_SALUD_NAME);
        
        Account testAccount = ZRH_DataFactory.createAccount(true);
        Opportunity testOpportunity = ZRH_DataFactory.createOpportunity(true, testAccount);
        Product2 testProduct = ZRH_DataFactory.createHealthProduct(true);
        PricebookEntry testPricebookEntry = ZRH_DataFactory.createPricebookEntry(true, testProduct);
        Quote testQuote = ZRH_DataFactory.createQuote(true, testOpportunity);
        QuoteLineItem testQuoteLineItem = ZRH_DataFactory.createQuoteLineItem(true, testQuote, testProduct, testPricebookEntry, saludASV.Body.toString());
        testQuoteLineItem.ZRH_Tarifa__c = saludTarifa.Body.toString();
        // Configurar los datos de prueba necesarios
        List<QuoteLineItem> scope = new List<QuoteLineItem>();
        scope.add(testQuoteLineItem);
        // Agregar registros de prueba al ámbito

        // Iniciar el contexto de la prueba
        Test.startTest();

        // Crear una instancia de la clase bajo prueba
        ZRH_PolymorphicJob jobInstance = new ZRH_PolymorphicJob();

        // Llamar al método execute
        jobInstance.execute(null, scope);
        
        // Llamar al método finish
        jobInstance.finish(null);

        // Detener el contexto de la prueba
        Test.stopTest();
    }
}