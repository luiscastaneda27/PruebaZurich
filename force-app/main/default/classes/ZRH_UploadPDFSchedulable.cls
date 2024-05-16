/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Zurich
Created Date : 30/11/2023
Description  : Class ZRH_UploadPDFSchedulable
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Edwin Rocha Quezada                 ERQ
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ERQ          30/11/2023        initial version
********************************************************************************/
global class ZRH_UploadPDFSchedulable implements Schedulable{
    /**
    *  @Description: Method to execute Schedule Job
    *  @Autor:       ERQ, Zurich, edwin.rocha@mx.zurich.com
    *  @Date:        30/11/2023  
    */
    global void execute(SchedulableContext sc){
        ZRH_UploadPDFController.uploadPDFQuote();
    }
}