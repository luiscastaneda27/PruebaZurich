/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 09/11/2023
Description  : JSON request to get Surcharge
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			09/11/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_JSONSurcharge {

	public String porcSobreprima;
	public String parentesco;
	public String edadSobre;

    /**
    *  @Description: JSON structure parsing
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        09/11/2023
    */
	public static List<ZRH_JSONSurcharge> parse(String json) {
		return (List<ZRH_JSONSurcharge>) System.JSON.deserialize(json, List<ZRH_JSONSurcharge>.class);
	}
}