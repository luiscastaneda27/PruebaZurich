/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Zurich
Created Date : 07/3/2024
Description  : Class ZRH_EjecucionPipelineNominas
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Edwin Rocha Quezada / Pablo Leyton                ERQ
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ERQ          08/3/2024        initial version
********************************************************************************/
public class ZRH_EjecucionPipelineNominas {
 /**
    *  @Description: Static variables
    *  @Autor:       Edwin Rocha,Pablo Leyton Zurich, edwin.rocha@mx.zurich.com
    *  @Date:        08/03/2024 
    */
    
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
	private static final String INTEGRATION_ROUTE = 'ZRH_Ejecucion_Pipeline_Nominas';
    
    
    /**
    *  @Description: Method to call api in execute Pipeline 
    *  @Author:      Edwin Rocha,Pablo Leyton  ZCC, edwin.rocha@mx.zurich.com
    *  @Date:        08/03/2024 
    */
    @future(callout=true)
    public static void ejecutarPipelineNominas() {
        HttpResponse response = call(INTEGRATION_BASE);
	}
    
    
    /**
    *  @Description: Service Call
    *  @Author:      Edwin Rocha,Pablo Leyton ZCC, edwin.rocha@mx.zurich.com
    *  @Date:        08/03/2024
    */
    private static HttpResponse call(String body) {
        ZRH_RestConnection objClass = new ZRH_RestConnection(INTEGRATION_BASE, INTEGRATION_ROUTE);
        return objClass.callService(body);
    }
    
}