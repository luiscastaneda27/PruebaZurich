public class ZRH_JSONPolicyPDF {
    
    public class PolicyPDF {
        public String Ambiente { get; set; }
        public String Asegurados { get; set; }
        public String Beneficiarios { get; set; }
        public List<string> Cad { get; set; }
        public String Carencia { get; set; }
        public String CodigoSistema { get; set; }
        public String Comision { get; set; }
        public String ConcideracionesEspeciales { get; set; }
        public CondicionParticular CondicionParticular { get; set; } 
        public String ContractId { get; set; }
        public Contratante Contratante { get; set; } 
        public String Corredor { get; set; }
        public Integer DvPoliza { get; set; }
        public String Ejecutivo { get; set; }
        public String NumeroCotizacion { get; set; }
        public String Origen { get; set; }
        public Integer Periodo { get; set; }
        public Plan Plan { get; set; } 
        public String Pol { get; set; }
        public Integer Poliza { get; set; }
        public TablasAntecedentesGrls TablasAntecedentesGrls { get; set; } 
        public Tarifa Tarifa { get; set; } 
        public String TipoPoliza { get; set; }
        public Integer VigenciaFinal { get; set; }
        public Integer VigenciaInicial { get; set; }
        
    }
    
    
    public class CondicionParticular {
        public List<Articulos> Articulos { get; set; }
        public List<Anexos> Anexos { get; set; }
        
    }
    
    public class Articulos {
        public double OrdenCondc { get; set; }
        public String Nombre { get; set; }
        public String Titulo { get; set; }
        public List<SubTitulosA> SubTitulos { get; set; }
        
    }
    
    public class SubTitulos {
        public String Nombre { get; set; }
        public String Contenido { get; set; }
        public List<Tablas> Tablas { get; set; }
    }
    
     public class SubTitulosA {
        public String Nombre { get; set; }
        public String Contenido { get; set; }
        public List<TablasA> Tablas { get; set; }
    }
    
    public class Anexos {
        public String Nombre { get; set; }
        public String Titulo { get; set; }
        public List<SubTitulosA> SubTitulos { get; set; }
        
    }
    
    public class Contratante {
        public String NombreContratante { get; set; }
        public String RutContratante { get; set; }
        public String GrupoNegocios { get; set; }
        public Integer Sucursal { get; set; }
        public String SubGrupo { get; set; }
        public String Direccion { get; set; }
        public String ComunaCiudad { get; set; }
        
    }
    public class Plan {
        public Integer CodigoPlan { get; set; }
        public String NombrePlan { get; set; }
        public String FrecuenciaPagoPrima { get; set; }
        public String Moneda { get; set; }
        public String Rol { get; set; }
        
    }
    public class Columnas {
        public String Nombre { get; set; }
        
    }
    public class Datos {
        public String dato { get; set; }
        
    }
    public class Filas {
        public List<Datos> Datos { get; set; }
        
    }
    public class Tablas {
        public String TituloTabla { get; set; }
        public String NombreTabla { get; set; }
        public List<Columnas> Columnas { get; set; }
        public List<Filas> Filas { get; set; }
        
    }
    
    
    public class TablasA {
        public String TituloTabla { get; set; }
        public String NombreTabla { get; set; }
        public List<Columnas> Columnas { get; set; }
        public List<Filas> FilaTabla { get; set; }
        
    }
    
    public class TablasAntecedentesGrls {
        public List<Tablas> Tablas { get; set; }
        
    }
    public class Tarifa {
        public String IdTipoTarifa { get; set; }
        public String NombreTarifa { get; set; }
        
    }
}