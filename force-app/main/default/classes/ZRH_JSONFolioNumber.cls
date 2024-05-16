/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 18/10/2023
Description  : JSON request to get Folio Number
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O			    ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      ATO            18/10/2023		   	Created Class
********************************************************************************/
public inherited sharing class ZRH_JSONFolioNumber {

    /**
    *  @Description: JSON Request
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        18/10/2023
    */
    public class Request {
        public String origen;
        public Integer cantidad;        
    }

    /**
    *  @Description: Parse Request
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        18/10/2023
    */
    public static ZRH_JSONFolioNumber.Request parseRequest(String json) {
        return (ZRH_JSONFolioNumber.Request) System.JSON.deserialize(json, ZRH_JSONFolioNumber.Request.class);
    }

    /**
    *  @Description: JSON Response
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        18/10/2023
    */
    public class Response {
        public Integer id;
        public Integer folioInicial;
        public Integer folioFinal;
    }

    /**
    *  @Description: Parse Response
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        18/10/2023
    */
    public static ZRH_JSONFolioNumber.Response parseResponse(String json) {
        return (ZRH_JSONFolioNumber.Response) System.JSON.deserialize(json, ZRH_JSONFolioNumber.Response.class);
    }
}