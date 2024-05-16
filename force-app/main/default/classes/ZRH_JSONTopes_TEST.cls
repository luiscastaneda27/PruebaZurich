/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/11/2023
Description  : Class test for class ZRH_JSONTopes
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda              LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LEC          27/11/2023        initial version
********************************************************************************/
@isTest
public class ZRH_JSONTopes_TEST {
    
    
    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023  
    */
    private static final String SR_SALUD_LIMITS_NAME = 'ZRH_JSON_LIMITS';
    
     @testSetup 
    static void setupMethod() {
        // no insert data
    }
    
    /**
    *  @Description: Test the for the class ZRH_JSONTopes
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */
    @isTest 
    static void limitsTest() {
        StaticResource saludLimits = new ZRH_StaticResourcesSelector().selectByStaticResourceNameWithLimit(SR_SALUD_LIMITS_NAME);
        ZRH_JSONTopes limits = ZRH_JSONTopes.parse(saludLimits.Body.toString());
        
        for(ZRH_JSONTopes.TopesGrupoCobertura item: limits.TopesGrupoCobertura){
            ZRH_JSONTopes.TopesGrupoCobertura obj = new ZRH_JSONTopes.TopesGrupoCobertura();
            obj.Id = item.Id;
            obj.Tope = item.Tope;
            obj.TopeLabel = item.TopeLabel;
            obj.Agrupacion = item.Agrupacion;
            obj.AgrupacionLabel = item.AgrupacionLabel;
            obj.Rol = item.Rol;
            obj.RolLabel = item.RolLabel;
            obj.GrupoCobertura = item.GrupoCobertura;
            obj.GrupoCoberturaLabel = item.GrupoCoberturaLabel;
            obj.Valor = item.Valor;
            obj.ValorDeducible = item.ValorDeducible;
            obj.NroPrestAnuales = item.NroPrestAnuales;
        }
        
        
        
        for(ZRH_JSONTopes.TopesPoliza item: limits.TopesPoliza){
            ZRH_JSONTopes.TopesPoliza obj = new ZRH_JSONTopes.TopesPoliza();
            obj.Id = item.Id;
            obj.Tope = item.Tope;
            obj.TopeLabel = item.TopeLabel;
            obj.Agrupacion = item.Agrupacion;
            obj.AgrupacionLabel = item.AgrupacionLabel;
            obj.Rol = item.Rol;
            obj.RolLabel = item.RolLabel;
            obj.Valor = item.Valor;
            obj.ValorDeducible = item.ValorDeducible;
        }
        
        for(ZRH_JSONTopes.TopesAdicional item: limits.TopesAdicional){
            ZRH_JSONTopes.TopesAdicional obj = new ZRH_JSONTopes.TopesAdicional();
            obj.Id = item.Id;
            obj.Tope = item.Tope;
            obj.TopeLabel = item.TopeLabel;
            obj.Rol = item.Rol;
            obj.RolLabel = item.RolLabel;
            obj.Alternativa = item.Alternativa;
            obj.Valor = item.Valor;
        }
    }
    
}