/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 8/1/2024
Description  : Batch class to Process Endorsements.
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO		  8/1/2024		initial version
********************************************************************************/
global without sharing class ZRH_BatchProcessEndorsements implements Database.Batchable<sObject>, Database.AllowsCallouts{

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024  
    */
    public static final String QUERY_CONDITION = 'ZRH_Estado__c = \'Ingresado\'';
    public static final String STATUS_ERROR = 'Error';
    public static final String STATUS_SUCCESS = 'Procesado';
    public static final String STATUS_SUCCESS_ERROR = 'Procesado con Error';
    public static final String QUERY_CONDITION_DELETE = 'ZRH_Estado__c = \'Procesado\' and LastModifiedDate < LAST_N_DAYS:6';
    private String queryCondition;
    
    /**
    *  @Description: Constructor method of the class
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        5/2/2023  
    */
    global ZRH_BatchProcessEndorsements(String condition){
        this.queryCondition = condition;
    }
    global ZRH_BatchProcessEndorsements(){
        this.queryCondition = QUERY_CONDITION;
    }
        
    /**
    *  @Description: Start Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024 
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        return new ZRH_SincronizacionEndososSelector().selectByDynamicCondition(queryCondition);
    }
    
    /**
    *  @Description: Execute Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024 
    */
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        ZRH_SincronizacionEndoso__c objEndoso = (ZRH_SincronizacionEndoso__c) scope?.get(0);
        try{
            String cgpId = ZRH_ProcessEndorsementsController.processEndorsements(objEndoso);
            objEndoso.ZRH_Estado__c = String.isNotBlank(cgpId) ? STATUS_SUCCESS : STATUS_SUCCESS_ERROR;
            objEndoso.ZRH_ObservacionError__c = null;
            objEndoso.ZRH_Poliza__c = cgpId;
        }catch(Exception ex){
            objEndoso.ZRH_Estado__c = STATUS_ERROR;
            objEndoso.ZRH_ObservacionError__c = 'Error: ' + ex.getMessage() + ', Línea: ' +ex.getLineNumber();
        }
        update objEndoso;
    }
    
    /**
    *  @Description: Finish Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024
    */
    global void finish(Database.BatchableContext bc){
        System.debug('=== BatchUpdateContactBlocked.finish ===');       
        List<ZRH_SincronizacionEndoso__c>  listSync =  DataBase.query(new ZRH_SincronizacionEndososSelector().selectByDynamicCondition(this.queryCondition).getQuery());
        if(listSync.isEmpty()){
            Database.executeBatch(new ZRH_BatchGeneratePolicyGloss(), 1);
        }else{
            deleteRecords(QUERY_CONDITION_DELETE);
        }
    }
    
    
    /**
    *  @Description: Delete records old.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        15/1/2023
    */ 
    public static void deleteRecords(String queryCondition){
        List<ZRH_SincronizacionEndoso__c> listSync = new List<ZRH_SincronizacionEndoso__c>();
        for(ZRH_SincronizacionEndoso__c item: DataBase.query(new ZRH_SincronizacionEndososSelector().selectByDynamicCondition(queryCondition).getQuery())){
            if(listSync.size() < 9900){
                listSync.add(item);
            }
        }
        DataBase.delete(listSync, false);
    }
    
}