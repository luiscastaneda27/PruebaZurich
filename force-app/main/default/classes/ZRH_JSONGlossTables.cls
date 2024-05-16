/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : JSON request to get Gloss Tables
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/09/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_JSONGlossTables {

	public List<CondicionadosParticulares> condicionadosParticulares;

	/**
    *  @Description: JSON CondicionadosParticulares section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public class CondicionadosParticulares {
		public Integer codigoPlan;
		public List<Condicionados> condicionados;
	}

	/**
    *  @Description: JSON Condicionados section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public class Condicionados {
		public String titulo;
		public String tipo;
		public Decimal ordenCondc;
		public String contenido;
		public Integer cantidadTablas;
		public List<TablasCondicionado> tablasCondicionado;
	}

	/**
    *  @Description: JSON TablasCondicionado section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public class TablasCondicionado {
		public Integer ordenTabla;
		public Integer cantidadcolumnas;
		public Integer cantidadFilas;
		public List<Columnas> columnas;
		public List<Filas> filas;
	}

	/**
    *  @Description: Class for sorting the columns of a table
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public class Columnas implements Comparable{
		public Transient Columnas columnasCmp;
		public String nombreColumna;
		public Transient String orden;

		public columnas() {
			//... constructor
		}

		// Constructor        
		public columnas(Columnas cl) {
			this.columnasCmp = cl;
		}

		// Compare Datos based on the Datos orden.
		public Integer compareTo(Object compareTo) {
			// Cast argument to Datos
			Columnas compareToColumnas = (Columnas)compareTo;
			
			// The return value of 0 indicates that both elements are equal.
			Integer returnValue = 0;
			if ((orden  == null) && (compareToColumnas.orden == null)) {
				// both wrappers have null order
				returnValue = 0;
			} else if ((orden  == null) && (compareToColumnas.orden != null)) {
				// nulls-first implementation
				returnValue = -1;
			} else if ((orden  != null) && (compareToColumnas.orden == null)) {
				// nulls-first implementation
				returnValue = 1;
			} else if (orden > compareToColumnas.orden) {
				// Set return value to a positive value.
				returnValue = 1;
			} else if (orden < compareToColumnas.orden) {
				// Set return value to a negative value.
				returnValue = -1;
			}
			
			return returnValue;       
		}
	}

	/**
    *  @Description: JSON Filas section
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public class Filas {
		public List<Datos> datos;
	}

	/**
    *  @Description: Class for sorting row data
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public class Datos implements Comparable{
		public Transient Datos datosCmp;
		public String dato;
		public Transient String orden;

		public datos() {
			//... constructor
		}

		// Constructor        
		public datos(Datos dt) {
			this.datosCmp = dt;
		}

		// Compare Datos based on the Datos orden.
		public Integer compareTo(Object compareTo) {
			// Cast argument to Datos
			Datos compareToDatos = (Datos)compareTo;
			
			// The return value of 0 indicates that both elements are equal.
			Integer returnValue = 0;
			if ((orden  == null) && (compareToDatos.orden == null)) {
				// both wrappers have null order
				returnValue = 0;
			} else if ((orden  == null) && (compareToDatos.orden != null)) {
				// nulls-first implementation
				returnValue = -1;
			} else if ((orden  != null) && (compareToDatos.orden == null)) {
				// nulls-first implementation
				returnValue = 1;
			} else if (orden > compareToDatos.orden) {
				// Set return value to a positive value.
				returnValue = 1;
			} else if (orden < compareToDatos.orden) {
				// Set return value to a negative value.
				returnValue = -1;
			}
			
			return returnValue;       
		}
	}

    /**
    *  @Description: Parse method
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */
	public static ZRH_JSONGlossTables parse(String json) {
		return (ZRH_JSONGlossTables) System.JSON.deserialize(json, ZRH_JSONGlossTables.class);
	}
}