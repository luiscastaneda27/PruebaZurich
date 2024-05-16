public class ZRH_insQuoteController {

    @AuraEnabled(cacheable=false)
    public static List<vlocity_ins__QuoteLineItemGroupClass__c> getQuoteLineItemGroupClasses(Id quoteId){
        List<vlocity_ins__QuoteLineItemGroupClass__c> groupClasses = new ZRH_QuoteLineItemGroupClassSelector().selectByQuoteId(quoteId);
        return groupClasses;
    }

    @AuraEnabled(cacheable=false)
    public static List<Id> getRootQuoteLineItems(Id quoteId){
        Set<Id> quoteIds = new Set<Id>();
        quoteIds.add(quoteId);
        Map<Id,QuoteLineItem> rootQuoteLineItems = new ZRH_QuoteLineItemsSelector().selectProductsBySetIds(quoteIds);
        
        List<Id> rootQLIS = new List<Id>();
        for (Id qli : rootQuoteLineItems.keySet()) {
            rootQLIS.add(qli);
        }
        return rootQLIS;
    }

    @AuraEnabled(cacheable=false)
    public static Map<Id, Integer> getRootIdToCoverageCountQuoteLineItems(Id quoteId){
       Set<Id> quoteIds = new Set<Id>();
       quoteIds.add(quoteId);
       List<QuoteLineItem> qlis = new ZRH_QuoteLineItemsSelector().selectByQuoteId(quoteIds);
      
       Map<Id, Integer> rootToCoverages = new Map<Id, Integer>();
       for (QuoteLineItem qli : qlis) {
           if (qli.vlocity_ins__ParentItemId2__c == null && !rootToCoverages.containsKey(qli.Id)) {
               rootToCoverages.put(qli.Id, 0);
           } else if (qli.vlocity_ins__ParentItemId2__c != null && !rootToCoverages.containsKey(qli.vlocity_ins__ParentItemId2__c)) {
               rootToCoverages.put(qli.vlocity_ins__ParentItemId2__c, 1);
           } else if (qli.vlocity_ins__ParentItemId2__c != null && rootToCoverages.containsKey(qli.vlocity_ins__ParentItemId2__c)) {
               Integer covCount = rootToCoverages.get(qli.vlocity_ins__ParentItemId2__c);
               rootToCoverages.put(qli.vlocity_ins__ParentItemId2__c, covCount + 1);
           }
       }
       return rootToCoverages;
   }

}