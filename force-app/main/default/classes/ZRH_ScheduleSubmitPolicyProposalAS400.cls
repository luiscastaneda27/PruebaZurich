/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 17/11/2023
Description  : Schedule class to send policy proposal
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			17/11/2023		initial version
********************************************************************************/
global class ZRH_ScheduleSubmitPolicyProposalAS400 implements Schedulable{

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    private static final String QUERY_CONDITION = 'Contract.Status = \'2\' and ZRH_TipoDeProducto__c = \'Product\' and ZRH_Folio__c != null and ZRH_Estado__c = \'2\'';
    private static final Integer BATCH_SIZE = 1;
    
    
    /**
    *  @Description: Method execute
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    global void execute(SchedulableContext sc){
         Database.executeBatch(new ZRH_BatchSubmitPolicyProposalAS400(QUERY_CONDITION), BATCH_SIZE);
    }
    
   

}