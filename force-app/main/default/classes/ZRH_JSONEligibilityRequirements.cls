/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : JSON request to get Eligibility Requirements
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/09/2023		initial version
1.0      ATO			30/10/2023		Life - 500 section section is added
1.0      ATO			30/10/2023		Life Schooling - 501 section section is added
1.0      ATO			30/10/2023		Family Protection Life - 502 section section is added
1.0      ATO			30/10/2023		Health - 600 section section is added
1.0      ATO			30/10/2023		Personal Accidents - 700 section section is added
********************************************************************************/
public inherited sharing class ZRH_JSONEligibilityRequirements {

	/**
    *  @Description: JSON Life - 500 section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        30/10/2023
    */
	public class Life {

		public Integer EdadMinimaIngreso;
		public Integer EdadDPS;
		public Decimal EdadTopeIngreso;
		public String CodigoCobertura;
		public Decimal EdadSalida;
		public String NombreCobertura;
		public Decimal DPSCapitalIgualMayor;

	}

	/**
    *  @Description: Parse Life method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public static List<ZRH_JSONEligibilityRequirements.Life> parseLife(String json) {
		return (List<ZRH_JSONEligibilityRequirements.Life>) System.JSON.deserialize(json, List<ZRH_JSONEligibilityRequirements.Life>.class);
	}


	/**
    *  @Description: JSON Life Schooling - 501 section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        30/10/2023
    */
	public class LifeSchooling {

		public String Parentesco;
		public Integer EdadMinimaIngresoP;
		public Integer EdadSalidaP;
		public Decimal DPSCapitalIgualMayorP;
		public Decimal EdadDPSP;
		public Decimal EdadTopeIngresoP;
	}

	/**
    *  @Description: Parse Life Schooling method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public static List<ZRH_JSONEligibilityRequirements.LifeSchooling> parseLifeSchooling(String json) {
		return (List<ZRH_JSONEligibilityRequirements.LifeSchooling>) System.JSON.deserialize(json, List<ZRH_JSONEligibilityRequirements.LifeSchooling>.class);
	}
	
	/**
    *  @Description: JSON Family Protection Life - 502 section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        30/10/2023
    */
	public class FamilyProtection {

		public String Parentesco;
		public Integer EdadMinimaIngresoP;
		public Decimal EdadSalidaP;
		public Decimal DPSCapitalIgualMayorP;
		public Decimal EdadDPSP;
		public Decimal EdadTopeIngresoP;
	}

	/**
    *  @Description: Parse Family Protection Life method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public static List<ZRH_JSONEligibilityRequirements.FamilyProtection> parseFamilyProtection(String json) {
		return (List<ZRH_JSONEligibilityRequirements.FamilyProtection>) System.JSON.deserialize(json, List<ZRH_JSONEligibilityRequirements.FamilyProtection>.class);
	}

	/**
    *  @Description: JSON Health - 600 section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        30/10/2023
    */	
	public class Health {
		public Integer EdadMinimaIngresoS;
		public String ParentescoSalud;
		public Decimal EdadTopeIngresoS;
		public Decimal EdadSalidaS;
	}

	/**
    *  @Description: Parse Health Row method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public static List<ZRH_JSONEligibilityRequirements.Health> parseHealth(String json) {
		return (List<ZRH_JSONEligibilityRequirements.Health>) System.JSON.deserialize(json, List<ZRH_JSONEligibilityRequirements.Health>.class);
	}

	/**
    *  @Description: JSON Personal Accidents - 700 section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        30/10/2023
    */	
	public class PersonalAccidents {

		public String Parentesco;
		public Decimal EdadMinimaIngresoP;
		public Decimal EdadSalidaP;
		public Decimal DPSCapitalIgualMayorP;
		public Decimal EdadDPSP;
		public Decimal EdadTopeIngresoP;
	
	}

	/**
    *  @Description: Parse Personal Accidents method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public static List<ZRH_JSONEligibilityRequirements.PersonalAccidents> parsePersonalAccidents(String json) {
		return (List<ZRH_JSONEligibilityRequirements.PersonalAccidents>) System.JSON.deserialize(json, List<ZRH_JSONEligibilityRequirements.PersonalAccidents>.class);
	}
}