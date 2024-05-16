/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 8/4/2024
Description  : Class test for class ZRH_PolymorphicScheduler
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Felipe Romualdo Gaete              FRP
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      FRP          8/4/2024        initial version
********************************************************************************/
@IsTest
public class ZRH_PolymorphicScheduler_TEST {

    // Método de prueba para el método execute de ZRH_PolymorphicScheduler
    @IsTest
    static void testExecute() {
        // Configurar los datos de prueba necesarios
        List<ZRH_DiccionarioPoblacionDatosJSON__mdt> mdtRecords = new List<ZRH_DiccionarioPoblacionDatosJSON__mdt>();
        // Agregar registros de prueba a la lista

        // Iniciar el contexto de la prueba
        Test.startTest();

        // Crear una instancia de la clase bajo prueba
        ZRH_PolymorphicScheduler schedulerInstance = new ZRH_PolymorphicScheduler();

        // Llamar al método execute
        schedulerInstance.execute(null);

        // Detener el contexto de la prueba
        Test.stopTest();

        // Realizar afirmaciones necesarias
        // Puedes agregar afirmaciones aquí para verificar el comportamiento del método execute
    }
}