/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : JSON request to get Medical Requirements
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/09/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_JSONMedicalRequirements {

    public Columns columns;
    public FirstRow firstRow;
    public SecondRow secondRow;
    public ThirdRow thirdRow;

    /**
    *  @Description: JSON Columns section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public class Columns {
        public String Rango;
        public String RangoHasta; // columns
        public String RangoEntre1; // columns
        public String RangoEntre2; // columns
        public String RangoEntre3; // columns
        public String RangoSobre; // columns
	}

    /**
    *  @Description: JSON First Row section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public class FirstRow {        
        public String EdadInferior; // row1
        public String EdadInferiorRangoHasta; // row1        
        public String EdadInferiorRangoEntre1; // row1
        public String EdadInferiorRangoEntre2; // row1	
        public String EdadInferiorRangoEntre3; // row1
        public String EdadInferiorRangoSobre; // row1
	}

    /**
    *  @Description: JSON Second Row section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public class SecondRow {
        public String EdadMedio; // row2
        public String EdadMedioRangoHasta; // row2        
        public String EdadMedioRangoEntre1; // row2
        public String EdadMedioRangoEntre2; // row2
        public String EdadMedioRangoEntre3; // row2
        public String EdadMedioRangoSobre; // row2
	}

    /**
    *  @Description: JSON Third Row section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public class ThirdRow {
        public String EdadSuperior; // row3
        public String EdadSuperiorRangoHasta; // row3        
        public String EdadSuperiorRangoEntre1; // row3
        public String EdadSuperiorRangoEntre2; // row3
        public String EdadSuperiorRangoEntre3; // row3
        public String EdadSuperiorRangoSobre; // row3
	}

    /**
    *  @Description: Parse columns method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public static ZRH_JSONMedicalRequirements.Columns parseColumns(String json) {
        ZRH_JSONMedicalRequirements.Columns obj = (ZRH_JSONMedicalRequirements.Columns) System.JSON.deserialize(json, ZRH_JSONMedicalRequirements.Columns.class);        
        return obj;
    }

    /**
    *  @Description: Parse First Row method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public static ZRH_JSONMedicalRequirements.FirstRow parseFirstRow(String json) {
        return (ZRH_JSONMedicalRequirements.FirstRow) System.JSON.deserialize(json, ZRH_JSONMedicalRequirements.FirstRow.class);
    }

    /**
    *  @Description: Parse Second Row method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public static ZRH_JSONMedicalRequirements.SecondRow parseSecondRow(String json) {
        return (ZRH_JSONMedicalRequirements.SecondRow) System.JSON.deserialize(json, ZRH_JSONMedicalRequirements.SecondRow.class);
    }

    /**
    *  @Description: Parse Third Row method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public static ZRH_JSONMedicalRequirements.ThirdRow parseThirdRow(String json) {
        return (ZRH_JSONMedicalRequirements.ThirdRow) System.JSON.deserialize(json, ZRH_JSONMedicalRequirements.ThirdRow.class);
    }

    /**
    *  @Description: Parse method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
    public static ZRH_JSONMedicalRequirements parse(String json) {
        return (ZRH_JSONMedicalRequirements) System.JSON.deserialize(json, ZRH_JSONMedicalRequirements.class);
    }
}