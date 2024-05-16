/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Zurich
Created Date : 07/3/2024
Description  : Class ZRH_InsertarSincRenovacionPolizas
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Edwin Rocha Quezada                 ERQ
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ERQ          07/3/2024        initial version
********************************************************************************/
public class ZRH_InsertarSincRenovacionPolizas {
    /**
    *  @Description: Static variables
    *  @Autor:       Edwin Rocha, Zurich, edwin.rocha@mx.zurich.com
    *  @Date:        23/2/2024 
    */
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
	private static final String INTEGRATION_ROUTE = 'ZRH_InsertarSincRenovacionPolizas';

    /**
    *  @Description: Method to call api in metadata Insert Policy PDF
    *  @Author:      Edwin Rocha, ZCC, edwin.rocha@mx.zurich.com
    *  @Date:        23/12/2023 
    */
    @future(callout=true)
    public static void insertarSincRenovacionPoliza() {
        HttpResponse response = call(INTEGRATION_BASE);
	}

    /**
    *  @Description: Service Call
    *  @Author:      Edwin Rocha, ZCC, edwin.rocha@mx.zurich.com
    *  @Date:        23/12/2023
    */
    private static HttpResponse call(String body) {
        ZRH_RestConnection objClass = new ZRH_RestConnection(INTEGRATION_BASE, INTEGRATION_ROUTE);
        return objClass.callService(body);
    }
}