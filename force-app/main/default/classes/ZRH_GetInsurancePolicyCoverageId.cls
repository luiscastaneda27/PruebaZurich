public with sharing class ZRH_GetInsurancePolicyCoverageId {
    /**
*  @Description: get the InsurancePolicyCoverage by the Id of the InsurancePolicyCoverage.
*  @Autor:       Jean Nieto, Deloitte, jnieto@deloitte.com
*  @Date:        19/02/2024
*/
    @AuraEnabled(cacheable=true)
    public static InsurancePolicyCoverage getInsurancePolicyCoverageById(Id InsurancePolicyCoverageId) {
        List<InsurancePolicyCoverage> listInsurancePolicyCoverage = new ZRH_InsurancePolicyCoverageSelector().selectInsurancePolicyCoverageById(InsurancePolicyCoverageId);
        system.debug('LISTA'+listInsurancePolicyCoverage);
        return listInsurancePolicyCoverage.get(0);
    }
    
     /**
*  @Description: get the Attributes of the Products.
*  @Autor:       Jean Nieto, Deloitte, jnieto@deloitte.com
*  @Date:        19/02/2024
*/
    @AuraEnabled(cacheable=true)
    public static List<vlocity_ins__Attribute__c> getAttributeCategories() {
        List<vlocity_ins__Attribute__c> listAttributesProduct = new ZRH_AttributesSelector().selectAttributes();
        return listAttributesProduct;
    }
}