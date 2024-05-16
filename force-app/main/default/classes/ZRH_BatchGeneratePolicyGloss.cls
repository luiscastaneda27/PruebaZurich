/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 8/1/2024
Description  : Batch class to generate policy gloss.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO		  8/1/2024		initial version
********************************************************************************/
global without sharing class ZRH_BatchGeneratePolicyGloss implements Database.Batchable<sObject>, Database.AllowsCallouts{

    
    /**
    *  @Description: Start Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024 
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        return new ZRH_ContractGroupPlansSelector().selectByEndorsementSentTrue();
    }
    
    /**
    *  @Description: Execute Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024 
    */
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        ContractGroupPlan objPol = (ContractGroupPlan) scope?.get(0);
        ZRH_ControllerGlossPolicy.manageGloss(objPol.Id);
        update new ContractGroupPlan(Id = objPol.Id, ZRH_EndosoEnviado__c = false, ZRH_EnvioGlosaPendiente__c = true);
    }
    
    /**
    *  @Description: Finish Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024
    */
    global void finish(Database.BatchableContext bc){
        System.debug('=== BatchUpdateContactBlocked.finish ===');    
        if(DataBase.query(new ZRH_ContractGroupPlansSelector().selectByEndorsementSentTrue().getQuery()).size() == 0){
             Database.executeBatch(new ZRH_BatchSubmitGlossPolicy(), 1);
        }
    }
    
}