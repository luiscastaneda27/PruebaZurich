public with sharing class ZRH_GetContractGroupPlanId {
    /**
*  @Description: get the ContractGroupPlan by the Id of the ContractGroupPlan.
*  @Autor:       Jean Nieto, Deloitte, jnieto@deloitte.com
*  @Date:        14/02/2024
*/
    @AuraEnabled(cacheable=true)
    public static ContractGroupPlan getContractGroupPlanById(Id contractGroupPlanId) {
        List<ContractGroupPlan> listContractGroupPlan = new ZRH_ContractGroupPlansSelector().selectContractGroupPlanById(contractGroupPlanId);
        return listContractGroupPlan.get(0);
    }
    
    
    /**
*  @Description: get the Attributes Category  of the Products.
*  @Autor:       Jean Nieto, Deloitte, jnieto@deloitte.com
*  @Date:        14/02/2024
*/
    @AuraEnabled(cacheable=true)
    public static List<vlocity_ins__Attribute__c> getAttributeCategories() {
        List<vlocity_ins__Attribute__c> listAttributesProduct = new ZRH_AttributesSelector().selectAttributes();
        return listAttributesProduct;
    }
}