/*******************************************************************************************************
* Project: ZURICH - Salesforce
* Created By: Deloitte
* Created Date: 16/10/2023
* Description: class batch for update Quote Name
* ----------------------------------- ACRONYM OF AUTHORS -----------------------------------------------
* AUTHOR                               ACRONYM
* Jean Nieto                   JNieto
* ------------------------------------------------------------------------------------------------------
* VERSION          AUTHOR          DATE                Description
* 1.0              Jean          16/10/2023          initial version
*******************************************************************************************************/

global class ZRH_UpdateQuoteNameBatch implements Database.Batchable<sObject>
{
	    List <Quote> toUpdate = new List <Quote> ();

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
        String query = 'SELECT Id,Name,	ZRH_VersionQuote__c,QuoteNumber from Quote where CreatedDate < TODAY';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Quote> scope)
    {
        for ( Quote q : scope)
        {
           q.Name='C-'+q.QuoteNumber+'-V'+q.ZRH_VersionQuote__c;
           toUpdate.add(q); 
        }
        update toUpdate;
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}