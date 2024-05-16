/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Zurich
Created Date : 07/12/2023
Description  : Class ZRH_UploadPolicyPDF
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Edwin Rocha Quezada                 ERQ
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ERQ          07/12/2023        initial version
********************************************************************************/
global class ZRH_UploadPolicyPDFSchedulable implements Schedulable {
    /**
    *  @Description: Method to execute Schedule Job
    *  @Autor:       ERQ, Zurich, edwin.rocha@mx.zurich.com
    *  @Date:        07/12/2023  
    */
    global void execute(SchedulableContext sc){
        ZRH_UploadPolicyPDF.uploadPolicyPDF();
    }
}