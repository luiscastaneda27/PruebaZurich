/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 10/10/2023
Description  : Class test for class ZRH_QuoteLineItemsSelector
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          12/10/2023        Initial Version
********************************************************************************/
@isTest
private class ZRH_JSONMedicalRequirements_TEST {
    
    private static final String SR_REQ_MED_NAME = 'ZRH_JSON_RequisitosMedicos';
    
    /**
    *  @Description: Test for the Method parseColumns
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest 
    static void parseColumns() {
        Test.startTest();
        StaticResource reqMed = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);
        ZRH_JSONMedicalRequirements.columns objColumns = (ZRH_JSONMedicalRequirements.columns)ZRH_JSONMedicalRequirements.parseColumns(reqMed.Body.toString());
        System.assertEquals(objColumns != null, true, 'Working!');
        Test.stopTest();
    }

     /**
    *  @Description: Test for the Method parseFirstRow
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest 
    static void parseFirstRow() {
        Test.startTest();
        StaticResource reqMed = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);
        ZRH_JSONMedicalRequirements.FirstRow objFirstRow = (ZRH_JSONMedicalRequirements.FirstRow)ZRH_JSONMedicalRequirements.parseFirstRow(reqMed.Body.toString());
        System.assertEquals(objFirstRow != null, true, 'Working!');
        Test.stopTest();
    }

     /**
    *  @Description: Test for the Method parseSecondRow
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest 
    static void parseSecondRow() {
        Test.startTest();
        StaticResource reqMed = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);
        ZRH_JSONMedicalRequirements.SecondRow objSecondRow = (ZRH_JSONMedicalRequirements.SecondRow)ZRH_JSONMedicalRequirements.parseSecondRow(reqMed.Body.toString());
        System.assertEquals(objSecondRow != null, true, 'Working!');
        Test.stopTest();
    }

     /**
    *  @Description: Test for the Method parseThirdRow
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest 
    static void parseThirdRow() {
        Test.startTest();
        StaticResource reqMed = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);
        ZRH_JSONMedicalRequirements.ThirdRow objThirdRow = (ZRH_JSONMedicalRequirements.ThirdRow)ZRH_JSONMedicalRequirements.parseThirdRow(reqMed.Body.toString());
        System.assertEquals(objThirdRow != null, true, 'Working!');
        Test.stopTest();
    }

     /**
    *  @Description: Test for the Method parse
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        12/10/2023
    */
    @isTest 
    static void parse() {
        Test.startTest();
        StaticResource reqMed = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_REQ_MED_NAME);
        ZRH_JSONMedicalRequirements obj = (ZRH_JSONMedicalRequirements)ZRH_JSONMedicalRequirements.parse(reqMed.Body.toString());
        System.assertEquals(obj != null, true, 'Working!');
        Test.stopTest();
    }
}