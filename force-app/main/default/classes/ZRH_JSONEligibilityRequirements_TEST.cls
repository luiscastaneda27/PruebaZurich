/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 12/10/2023
Description  : Class test for class ZRH_JSONEligibilityRequirements
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Josue Alejandro Aguilar             JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JAA          12/10/2023        Initial Version
2.0		 JAA		  8/11/2023			Changes on Main Class
********************************************************************************/
@isTest
private class ZRH_JSONEligibilityRequirements_TEST {
    
    private static final String SR_ACCIDENTES_PERSONALES_REQ_ASEG_NAME = 'ZRH_JSON_AccidentesPersonalesRA';
    private static final String SR_SALUD_REQ_ASEG_NAME = 'ZRH_JSON_SaludRA';
    private static final String SR_VIDA_REQ_ASEG_NAME = 'ZRH_JSON_VidaRA';

    /**
    *  @Description: Test for the Method parsePersonalAccidents
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        8/11/2023
    */
    @isTest 
    static void parsePersonalAccidents() {
        Test.startTest();
        StaticResource accPersRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ACCIDENTES_PERSONALES_REQ_ASEG_NAME);
        List<ZRH_JSONEligibilityRequirements.PersonalAccidents> objLst = (List<ZRH_JSONEligibilityRequirements.PersonalAccidents>)ZRH_JSONEligibilityRequirements.parsePersonalAccidents(accPersRA.Body.toString());
        System.assertEquals(objLst != null, true, 'Working!');
        Test.stopTest();
    }
    
    /**
    *  @Description: Test for the Method parseLifeSchooling
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        8/11/2023
    */
    @isTest 
    static void parseLifeSchooling() {
        Test.startTest();
        StaticResource accPersRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ACCIDENTES_PERSONALES_REQ_ASEG_NAME);
        List<ZRH_JSONEligibilityRequirements.LifeSchooling> objLst = (List<ZRH_JSONEligibilityRequirements.LifeSchooling>)ZRH_JSONEligibilityRequirements.parseLifeSchooling(accPersRA.Body.toString());
        System.assertEquals(objLst != null, true, 'Working!');
        Test.stopTest();
    }
    
    /**
    *  @Description: Test for the Method parseFamilyProtection
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        8/11/2023
    */
    @isTest 
    static void parseFamilyProtection() {
        Test.startTest();
        StaticResource accPersRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_ACCIDENTES_PERSONALES_REQ_ASEG_NAME);
        List<ZRH_JSONEligibilityRequirements.FamilyProtection> objLst = (List<ZRH_JSONEligibilityRequirements.FamilyProtection>)ZRH_JSONEligibilityRequirements.parseFamilyProtection(accPersRA.Body.toString());
        System.assertEquals(objLst != null, true, 'Working!');
        Test.stopTest();
    }
    
    /**
    *  @Description: Test for the Method parseHealth
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        8/11/2023
    */
    @isTest 
    static void parseHealth() {
        Test.startTest();
        StaticResource saludRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_REQ_ASEG_NAME);
        List<ZRH_JSONEligibilityRequirements.Health> objLst = (List<ZRH_JSONEligibilityRequirements.Health>)ZRH_JSONEligibilityRequirements.parseHealth(saludRA.Body.toString());
        System.assertEquals(objLst != null, true, 'Working!');
        Test.stopTest();
    }
    
    /**
    *  @Description: Test for the Method parseLife
    *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
    *  @Date:        8/11/2023
    */
    @isTest 
    static void parseLife() {
        Test.startTest();
        StaticResource vidaRA = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_REQ_ASEG_NAME);
        List<ZRH_JSONEligibilityRequirements.Life> objLst = (List<ZRH_JSONEligibilityRequirements.Life>)ZRH_JSONEligibilityRequirements.parseLife(vidaRA.Body.toString());
        System.assertEquals(objLst != null, true, 'Working!');
        Test.stopTest();
    }
}