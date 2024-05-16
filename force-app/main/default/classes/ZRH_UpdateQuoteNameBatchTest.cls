@isTest
private class ZRH_UpdateQuoteNameBatchTest {
    static testMethod void testme(){
        Opportunity opp =new Opportunity (name='myquoteTest',StageName='New',CloseDate=Date.today());
        insert opp;
        Quote q = new Quote();
        q.ZRH_VersionQuote__c=1;
         q.Name='c-00012';
        q.OpportunityId=opp.Id;
        insert q;
        Test.setCreatedDate(q.Id, Date.today().addDays(-1));
        Test.startTest();
        ZRH_UpdateQuoteNameBatch ba= new ZRH_UpdateQuoteNameBatch();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();
        Quote qr = [select Name,ZRH_VersionQuote__c,QuoteNumber from Quote where id=:q.Id];
        system.assertEquals('C-'+qr.QuoteNumber+'-V'+qr.ZRH_VersionQuote__c, qr.Name);
    }
}