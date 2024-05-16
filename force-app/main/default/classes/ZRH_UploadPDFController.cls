/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Zurich
Created Date : 30/11/2023
Description  : Class ZRH_UploadPDFController
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Edwin Rocha Quezada                 ERQ
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ERQ          30/11/2023        initial version
********************************************************************************/
public class ZRH_UploadPDFController { 
    /**
    *  @Description: Static variables
    *  @Autor:       ERQ, Zurich, edwin.rocha@mx.zurich.com
    *  @Date:        30/11/2023  
    */
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
	private static final String INTEGRATION_ROUTE = 'ZRH_SubirPDFCotizacion';
  
    /**
    *  @Description: Method to call api in metadata to upload PDF
    *  @Author:      Edwin Rocha, ZCC, edwin.rocha@mx.zurich.com
    *  @Date:        30/11/2023  
    */
    @future(callout=true)
    public static void uploadPDFQuote() {
        HttpResponse response = call(INTEGRATION_BASE);
	}
    
    /**
    *  @Description: Service Call
    *  @Author:      Edwin Rocha, ZCC, edwin.rocha@mx.zurich.com
    *  @Date:        30/11/2023  
    */
    private static HttpResponse call(String body) {
        ZRH_RestConnection objClass = new ZRH_RestConnection(INTEGRATION_BASE, INTEGRATION_ROUTE);
        return objClass.callService(body);
    }

}