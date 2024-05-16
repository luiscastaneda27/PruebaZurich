/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Zurich
Created Date : 23/2/2024
Description  : Class ZRH_PDFCotizacionReintentosSchedulable
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Edwin Rocha Quezada                 ERQ
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ERQ          23/2/2024        initial version
********************************************************************************/
global class ZRH_PDFCotizacionReintentosSchedulable implements Schedulable {
    /**
    *  @Description: Method to execute Schedule Job
    *  @Autor:       ERQ, Zurich, edwin.rocha@mx.zurich.com
    *  @Date:        23/2/2024  
    */
    global void execute(SchedulableContext sc){
        ZRH_GenerarPDFCotizacionReintentos.generarPDFCotizacionReintento();
    }
}