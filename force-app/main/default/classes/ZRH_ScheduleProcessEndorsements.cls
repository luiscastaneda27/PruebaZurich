/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 17/1/2024
Description  : Schedule class to Process Endorsements
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			17/1/2024		initial version
********************************************************************************/
global class ZRH_ScheduleProcessEndorsements implements Schedulable{
    
    
    /**
    *  @Description: Method execute
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/1/2024  
    */
    global void execute(SchedulableContext sc){
         Database.executeBatch(new ZRH_BatchProcessEndorsements(), 1);
    }
}