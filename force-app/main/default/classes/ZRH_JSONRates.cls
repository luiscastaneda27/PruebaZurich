/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : JSON class for plan rates
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.              ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/09/2023		initial version
********************************************************************************/
public inherited sharing class ZRH_JSONRates {
    
    public List<TarifaVida> TarifaVida;
    public List<TarifaSalud> TarifaSalud;
    public String IdTipoTarifa;
    
    /**
*  @Description: Class for life plan rates
*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
*  @Date:        27/09/2023
*/
    public class TarifaVida {
        public Integer NumeroAsegurados;
        public Decimal PrimaAnualUF;
        public Decimal TasaMensual;
        public Decimal CapitalAseguradoUF;
        public Decimal PrimaMensualUF;
        public Decimal TasaAnual;
        public String NombreCobertura;
        public Integer CodigoCobertura;
    }
    
    /**
*  @Description: Class for health plan rates
*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
*  @Date:        27/09/2023
*/
    public class TarifaSalud {
        public Decimal TarifaSaludPP;
        public String DescTarifaSalud;
        public Integer EdadTermino;
        public Decimal TarifaSaludNT;
        public Decimal TarifaSaludPV;
        public Integer EdadInicio;
        public Integer CodigoSubtipoTarifa;
    }
    
    /**
*  @Description: JSON structure parsing
*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
*  @Date:        27/09/2023
*/
    public static ZRH_JSONRates parse(String json) {
        ZRH_JSONRates objRate = (ZRH_JSONRates) System.JSON.deserialize(json, ZRH_JSONRates.class);
        ZRH_JSONRates objRateReturn= new ZRH_JSONRates();
        objRateReturn.TarifaVida = new List<TarifaVida>();
        objRateReturn.TarifaSalud = new List<TarifaSalud>();
        objRateReturn.IdTipoTarifa = objRate.IdTipoTarifa;
        if(objRate.TarifaVida != null){
            for (TarifaVida tarfVida :  objRate.TarifaVida){
                if((tarfVida.NumeroAsegurados != 0 && tarfVida.NumeroAsegurados != null ) || tarfVida.NombreCobertura != null){ 
                    objRateReturn.TarifaVida.add(tarfVida);   
                }
            }
        }
        if(objRate.TarifaSalud != null){
            for ( TarifaSalud tarfSalud : objRate.TarifaSalud){
                if(tarfSalud.TarifaSaludNT!=0 && tarfSalud.TarifaSaludNT!=null){ 
                    objRateReturn.TarifaSalud.add(tarfSalud);   
                }
            }
        }
        
        return objRateReturn;
    }
}