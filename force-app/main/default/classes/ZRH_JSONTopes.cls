/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 13/02/2024
Description  : JSON class for Coverage caps
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                             ACRONYM
Luis Enrique Castañeda D.            LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC			13/02/2024		initial version
********************************************************************************/
public class ZRH_JSONTopes {
    
    public List<TopesGrupoCobertura> TopesGrupoCobertura { get; set; }
    public List<TopesPoliza> TopesPoliza { get; set; }
    public List<TopesAdicional> TopesAdicional { get; set; }
    
    /**
    *  @Description: JSON structure parsing
    *  @Autor:       LEC, lcastanedad@deloitte.com
    *  @Date:        3/02/2024
    */
    public static ZRH_JSONTopes parse(String json) {
        return (ZRH_JSONTopes) System.JSON.deserialize(json, ZRH_JSONTopes.class);
    }
   	/**
	*  @Description: Class for Coverage caps
	*  @Autor:       LEC, lcastanedad@deloitte.com
	*  @Date:        13/02/2024
	*/
    public class TopesGrupoCobertura {
        public Integer Id { get; set; }
        public String Tope { get; set; }
        public String TopeLabel { get; set; }
        public String Agrupacion { get; set; }
        public String AgrupacionLabel { get; set; }
        public String Rol { get; set; }
        public String RolLabel { get; set; }
        public String GrupoCobertura { get; set; }
        public String GrupoCoberturaLabel { get; set; }
        public String Valor { get; set; }
        public String ValorDeducible { get; set; }
        public String NroPrestAnuales { get; set; }
        
    }
    
    /**
	*  @Description: Class for policy caps
	*  @Autor:       LEC, lcastanedad@deloitte.com
	*  @Date:        13/02/2024
	*/
    public class TopesPoliza {
        public Integer Id { get; set; }
        public String Tope { get; set; }
        public String TopeLabel { get; set; }
        public String Agrupacion { get; set; }
        public String AgrupacionLabel { get; set; }
        public String Rol { get; set; }
        public String RolLabel { get; set; }
        public String Valor { get; set; }
        public String ValorDeducible { get; set; }
        
    }
    
    /**
	*  @Description: Class for Additional  caps
	*  @Autor:       LEC, lcastanedad@deloitte.com
	*  @Date:        13/02/2024
	*/
    public class TopesAdicional {
        public Integer Id { get; set; }
        public String Tope { get; set; }
        public String TopeLabel { get; set; }
        public String Alternativa { get; set; }
        public String Rol { get; set; }
        public String RolLabel { get; set; }
        public String Valor { get; set; }
        
        
    }
}