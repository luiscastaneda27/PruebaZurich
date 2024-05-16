@isTest
public class ZRH_AttributesSelector_TEST {
    
    @isTest
    private static void selectAttributesTest() {

        vlocity_ins__AttributeCategory__c attCat = new vlocity_ins__AttributeCategory__c();
        attCat.Name = 'testCat';
        attCat.vlocity_ins__DisplaySequence__c = 1;
        insert attCat;

        vlocity_ins__Attribute__c att = new vlocity_ins__Attribute__c();
        att.Name = 'test';
        att.vlocity_ins__AttributeCategoryId__c = attCat.Id;
        insert att;

        Test.startTest();
        List<vlocity_ins__Attribute__c> attSelector = new ZRH_AttributesSelector().selectAttributes();
        Test.stopTest();

        System.assertEquals(attSelector.size(), 1, 'selectAttributesTest not matching');

        
    }
}