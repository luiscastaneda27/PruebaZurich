public class ZRH_JSONPolicyProposal {
    
    public static final Set<String> PVR_SET_IDS_LIFE;
    public static final Set<String> PVR_SET_IDS_LIFESCHOOLING;
    public static final Set<String> PVR_SET_IDS_FAMILYPROTECTION;
    public static final Set<String> PVR_SET_IDS_HEALTH;
    public static final Set<String> PVR_SET_IDS_PERSONALACCIDENTS;
    
    static {
        PVR_SET_IDS_LIFE = new Set<String>{'500'};
        PVR_SET_IDS_LIFESCHOOLING = new Set<String>{'501'};
        PVR_SET_IDS_FAMILYPROTECTION = new Set<String>{'502'};
        PVR_SET_IDS_HEALTH = new Set<String>{'600', '601', '602', '603', '604', '605', '606'};
        PVR_SET_IDS_PERSONALACCIDENTS = new Set<String>{'700'};
  }
    
    public class Policy {
        public Integer Poliza { get; set; } 
        public Integer DvPoliza { get; set; } 
        public Integer NumeroSolicitud { get; set; } 
        public String DescripcionSolicitud { get; set; } 
        public String NombreContratante { get; set; } 
        public String RutContratante { get; set; }
		public String NombreContratanteLegal { get; set; }
        public String RutContratanteLegal { get; set; }
        public Integer CodigoRol { get; set; }
        public Integer VigenciaInicial { get; set; } 
        public Integer VigenciaFinal { get; set; } 
        public Integer CodigoPlan { get; set; } 
        public String NombrePlan { get; set; }
        public GrupoNegocio GrupoNegocio { get; set; } 
        public Integer FechaAceptacionContrato { get; set; } 
        public Integer MonedaPoliza { get; set; } 
        public UnidadEquivalenteAsegurada UnidadEquivalenteAsegurada { get; set; } 
        public Tarifa Tarifa { get; set; } 
        public List<Intermediarios> Intermediarios { get; set; } 
        public String PlazoPresentacion { get; set; }
        public String InstanciaAplicaDeducible { get; set; } 
        public Integer MonedaPagoSiniestros { get; set; } 
        public String FrecuienciaDePagos { get; set; } 
        public String TipoCobranza { get; set; } 
        public Integer DiaCobranza { get; set; } 
        public Integer DiaCorteCobranza { get; set; } 
        public String TipoGeneracion { get; set; }
        public String GeneraFactura { get; set; }
        public String TipoFacturacion { get; set; } 
        public List<Coaseguro> coaseguro { get; set; } 
        public String RutAsistenteComercial { get; set; }
        public List<Asegurabilidad> Asegurabilidad { get; set; } 
        public String Insitu { get; set; } 
        public String TienePortabilidad { get; set; } 
        public String Pyme { get; set; } 
        public String SegmentoCliente { get; set; } 
        public String EsContributaria { get; set; } 
        public Decimal ContribucionEmpresa { get; set; } 
        public Integer FactorStoploss { get; set; }
        public String EsRenovacion { get; set; }
        public String PolizaOrigen { get; set; } 
        public String EmisorPoliza { get; set; }
        public String Pol { get; set; } 
        public List<String> Cad { get; set; } 
        public Integer Iram { get; set; } 
        public Integer Ape { get; set; } 
        public Integer IndicadorGMM { get; set; } 
        public Integer PorcentajeArancelUco { get; set; } 
        public Integer NumeroDiasCarencia { get; set; } 
        public Decimal NumeroMaximoDeducibleFamiliar { get; set; } 
        public String NumeroCotizacion { get; set; }  
        public String CotizacionId { get; set; } 
        public String CodigoSistema { get; set; } 
        public String GroupCensusId { get; set; } 
        public String GroupClassId { get; set; } 
        public Integer Periodo { get; set; }
        public TopesTotales TopesTotales { get; set; } 
        public TopesGrupoCoberturas TopesGrupoCoberturas { get; set; } 
        public List<Coberturas> coberturas { get; set; } 
        public String Ambiente { get; set; }
        public Decimal PorcAumCapitalEval { get; set; }
        public Decimal Cobertura { get; set; }
        public Decimal ValorTopeAnual { get; set; }
    }
    
    public class PolicyHealth {
        public Integer Poliza { get; set; }
        public Integer DvPoliza { get; set; }
        public Integer NumeroSolicitud { get; set; }
        public String DescripcionSolicitud { get; set; }
        public String NombreContratante { get; set; }
        public String RutContratante { get; set; }
		public String NombreContratanteLegal { get; set; }
        public String RutContratanteLegal { get; set; }
        public Integer CodigoRol { get; set; }
        public Integer VigenciaInicial { get; set; } 
        public Integer VigenciaFinal { get; set; } 
        public Integer CodigoPlan { get; set; } 
        public String NombrePlan { get; set; }
        public GrupoNegocio GrupoNegocio { get; set; } 
        public Integer FechaAceptacionContrato { get; set; } 
        public Integer MonedaPoliza { get; set; } 
        public TarifaHealth Tarifa { get; set; } 
        public List<Intermediarios> Intermediarios { get; set; } 
        public String PlazoPresentacion { get; set; }
        public String InstanciaAplicaDeducible { get; set; } 
        public Integer MonedaPagoSiniestros { get; set; } 
        public String FrecuienciaDePagos { get; set; } 
        public String TipoCobranza { get; set; } 
        public Integer DiaCobranza { get; set; } 
        public Integer DiaCorteCobranza { get; set; } 
        public String TipoGeneracion { get; set; }
        public String GeneraFactura { get; set; }
        public String TipoFacturacion { get; set; } 
        public List<Coaseguro> coaseguro { get; set; } 
        public String RutAsistenteComercial { get; set; }
        public List<Asegurabilidad> Asegurabilidad { get; set; } 
        public String Insitu { get; set; } 
        public String TienePortabilidad { get; set; } 
        public String Pyme { get; set; } 
        public String SegmentoCliente { get; set; } 
        public String EsContributaria { get; set; } 
        public Integer ContribucionEmpresa { get; set; } 
        public Integer FactorStoploss { get; set; }
        public String EsRenovacion { get; set; }
        public String PolizaOrigen { get; set; } 
        public String EmisorPoliza { get; set; }
        public String Pol { get; set; } 
        public List<String> Cad { get; set; } 
        public Integer Iram { get; set; } 
        public Integer Ape { get; set; } 
        public Integer IndicadorGMM { get; set; } 
        public Integer PorcentajeArancelUco { get; set; } 
        public Integer NumeroDiasCarencia { get; set; } 
        public Decimal NumeroMaximoDeducibleFamiliar { get; set; } 
        public String NumeroCotizacion { get; set; }  
        public String CotizacionId { get; set; } 
        public String CodigoSistema { get; set; } 
        public String GroupCensusId { get; set; } 
        public String GroupClassId { get; set; } 
        public Integer Periodo { get; set; }
        public TopesTotales TopesTotales { get; set; } 
        public TopesGrupoCoberturas TopesGrupoCoberturas { get; set; } 
        public List<Coberturas> coberturas { get; set; } 
        public String Ambiente { get; set; }
        public Decimal PorcAumCapitalEval { get; set; }
        public Decimal Cobertura { get; set; }
        public Decimal ValorTopeAnual { get; set; }
    }
    
    public class PolicyLife {
        public Integer Poliza { get; set; } 
        public Integer DvPoliza { get; set; } 
        public Integer NumeroSolicitud { get; set; } 
        public String DescripcionSolicitud { get; set; } 
        public String NombreContratante { get; set; } 
        public String RutContratante { get; set; }
        public String NombreContratanteLegal { get; set; }
        public String RutContratanteLegal { get; set; }
        public Integer CodigoRol { get; set; }
        public Integer VigenciaInicial { get; set; } 
        public Integer VigenciaFinal { get; set; } 
        public Integer CodigoPlan { get; set; } 
        public String NombrePlan { get; set; }
        public GrupoNegocio GrupoNegocio { get; set; } 
        public Integer FechaAceptacionContrato { get; set; } 
        public Integer MonedaPoliza { get; set; } 
        public UnidadEquivalenteAsegurada UnidadEquivalenteAsegurada { get; set; } 
        public TarifaLife Tarifa { get; set; } 
        public List<Intermediarios> Intermediarios { get; set; } 
        public String PlazoPresentacion { get; set; }
        public String InstanciaAplicaDeducible { get; set; } 
        public Integer MonedaPagoSiniestros { get; set; } 
        public String FrecuienciaDePagos { get; set; } 
        public String TipoCobranza { get; set; } 
        public Integer DiaCobranza { get; set; } 
        public Integer DiaCorteCobranza { get; set; } 
        public String TipoGeneracion { get; set; }
        public String GeneraFactura { get; set; }
        public String TipoFacturacion { get; set; } 
        public List<Coaseguro> coaseguro { get; set; } 
        public String RutAsistenteComercial { get; set; }
        public List<Asegurabilidad> Asegurabilidad { get; set; } 
        public String Insitu { get; set; } 
        public String TienePortabilidad { get; set; } 
        public String Pyme { get; set; } 
        public String SegmentoCliente { get; set; } 
        public String EsContributaria { get; set; } 
        public Integer ContribucionEmpresa { get; set; } 
        public Integer FactorStoploss { get; set; }
        public String EsRenovacion { get; set; }
        public String PolizaOrigen { get; set; } 
        public String EmisorPoliza { get; set; }
        public String Pol { get; set; } 
        public List<String> Cad { get; set; } 
        public Integer Iram { get; set; } 
        public Integer Ape { get; set; } 
        public Integer IndicadorGMM { get; set; } 
        public Decimal NumeroMaximoDeducibleFamiliar { get; set; } 
        public String NumeroCotizacion { get; set; }  
        public String CotizacionId { get; set; } 
        public String CodigoSistema { get; set; } 
        public String GroupCensusId { get; set; } 
        public String GroupClassId { get; set; } 
        public Integer Periodo { get; set; }
        public List<Coberturas> coberturas { get; set; } 
        public String Ambiente { get; set; }
        public Decimal PorcAumCapitalEval { get; set; }
        public Decimal Cobertura { get; set; }
        public Decimal ValorTopeAnual { get; set; }
    }
    
     public class PolicyLifeSchooling {
        public Integer Poliza { get; set; } 
        public Integer DvPoliza { get; set; } 
        public Integer NumeroSolicitud { get; set; } 
        public String DescripcionSolicitud { get; set; } 
        public String NombreContratante { get; set; } 
        public String RutContratante { get; set; }
		public String NombreContratanteLegal { get; set; }
        public String RutContratanteLegal { get; set; }
        public Integer CodigoRol { get; set; }
        public Integer VigenciaInicial { get; set; } 
        public Integer VigenciaFinal { get; set; } 
        public Integer CodigoPlan { get; set; } 
        public String NombrePlan { get; set; }
        public GrupoNegocio GrupoNegocio { get; set; } 
        public Integer FechaAceptacionContrato { get; set; } 
        public Integer MonedaPoliza { get; set; } 
        public UnidadEquivalenteAsegurada UnidadEquivalenteAsegurada { get; set; } 
        public TarifaLifeSchooling Tarifa { get; set; } 
        public List<Intermediarios> Intermediarios { get; set; } 
        public String PlazoPresentacion { get; set; }
        public String InstanciaAplicaDeducible { get; set; } 
        public Integer MonedaPagoSiniestros { get; set; } 
        public String FrecuienciaDePagos { get; set; } 
        public String TipoCobranza { get; set; } 
        public Integer DiaCobranza { get; set; } 
        public Integer DiaCorteCobranza { get; set; } 
        public String TipoGeneracion { get; set; }
        public String GeneraFactura { get; set; }
        public String TipoFacturacion { get; set; } 
        public List<Coaseguro> coaseguro { get; set; } 
        public String RutAsistenteComercial { get; set; }
        public List<Asegurabilidad> Asegurabilidad { get; set; } 
        public String Insitu { get; set; } 
        public String TienePortabilidad { get; set; } 
        public String Pyme { get; set; } 
        public String SegmentoCliente { get; set; } 
        public String EsContributaria { get; set; } 
        public Integer ContribucionEmpresa { get; set; } 
        public Integer FactorStoploss { get; set; }
        public String EsRenovacion { get; set; }
        public String PolizaOrigen { get; set; } 
        public String EmisorPoliza { get; set; }
        public String Pol { get; set; } 
        public List<String> Cad { get; set; } 
        public Integer Iram { get; set; } 
        public Integer Ape { get; set; } 
        public Integer IndicadorGMM { get; set; } 
        public Decimal NumeroMaximoDeducibleFamiliar { get; set; } 
        public String NumeroCotizacion { get; set; }  
        public String CotizacionId { get; set; } 
        public String CodigoSistema { get; set; } 
        public String GroupCensusId { get; set; } 
        public String GroupClassId { get; set; } 
        public Integer Periodo { get; set; }
        public List<Coberturas> coberturas { get; set; } 
        public String Ambiente { get; set; }
        public Decimal PorcAumCapitalEval { get; set; }
        public Decimal Cobertura { get; set; }
        public Decimal ValorTopeAnual { get; set; }
    }
    
    
    public class Coberturas {
        public Integer CodigoGrupoCoberturas { get; set; } 
        public Integer CodigoCobertura { get; set; } 
        public String NivelManejoTopes { get; set; }
        public Decimal PorcentajeReembolso { get; set; } 
        public Decimal NumeroPrestacionesAnual { get; set; }
        public Decimal NumeroPrestacionesPorEvento { get; set; }
        public Decimal ValorMaxPrestacion { get; set; } 
        public Decimal TopeMaximoAnual { get; set; } 
        public Decimal TopeMaximoPorEvento { get; set; }
        public Decimal ValorDeducibleAnual { get; set; }
        public Decimal ValorDeduciblePorEvento { get; set; }
        public Integer ValorDeduciblePorPrestacion { get; set; }
        public Decimal PorcentajeLibreEleccionPorPrestacion { get; set; }
        public Decimal PorcentajeSinPrevisionPorPrestacion { get; set; }
        public String IndicadorCoberturaSuplementaria { get; set; }
        public Decimal ValorLimiteDeReembolso { get; set; }
        public Decimal NumeroLimiteDePrestacionesPorReembolsoSuplementario { get; set; }
        public Decimal PorcentajeReembolsoSuplementario { get; set; }
        public Decimal MontoMaximoReembolso { get; set; }
        public String IndicadorAplicaPorPrestacion { get; set; }
        public String TipoDeCapitalPorcentajeValor { get; set; }
        public Decimal PorcentajeDeCapital { get; set; } 
        public Decimal ValorDeCapital { get; set; } 
        public Decimal TasaParaLaPrima { get; set; }
        public Decimal EdadTopeDeLaCobertura { get; set; }
        
    }
    
    
    public class TopesGrupoCoberturas {
        public List<GrupoCobertura> GrupoCobertura { get; set; }
        
    }
    
    public class GrupoCobertura {
        public Integer CodigoGrupoCoberturas { get; set; } 
        public List<AtributosAgrupacion> AtributosAgrupacion { get; set; }
        public List<DeduciblePorTramos> DeduciblePorTramos { get; set; }
        
    }
    
    public class AtributosAgrupacion {
        public String NivelManejoTopes { get; set; }
        public Integer NumeroPrestacionesAnual { get; set; }
        public Decimal TopeMaximoAnual { get; set; }
        public Decimal TopeMaximoPorEvento { get; set; }
        public Decimal ValorDeducibleAnual { get; set; }
        public Decimal ValorDeduciblePorEvento { get; set; }
        
    }
    
    public class DeduciblePorTramos {
        public Integer TramoDeDucible { get; set; }
        public Integer SubTramo { get; set; }
        public Decimal ValorDeducibleTramo { get; set; }
        
    }
    
    public class TopesTotales {
        public List<AtributosAgrupacion> AtributosAgrupacion { get; set; } 
        public List<DeduciblePorTramos> DeduciblePorTramos { get; set; } 
        
    }
    
    public class Asegurabilidad {
        public String TipoRelacion { get; set; } 
        public Decimal EdadIngreso { get; set; }
        public Decimal EdadSalida { get; set; }
        public Decimal EdadTope { get; set; }
        public Decimal LimiteSolicitudDPS { get; set; } 
        public Decimal EdadDPS { get; set; }
        
    }
    
    public class Coaseguro {
        public Integer CodigoCoaseguro { get; set; } 
        public String TipoCoaseguro { get; set; } 
        public Integer PorcentajeParticipacion { get; set; } 
        
    }
    
    public class Intermediarios {
        public String RutIntermediario { get; set; } 
        public Decimal Comision { get; set; } 
        public String TipoIntermediario { get; set; } 
        
    }
    
    public class Tarifa {
        public String IdTipoTarifa { get; set; }
        public List<TarifaSalud> TarifaSalud { get; set; }
        public List<Escolaridad> Escolaridad { get; set; }
        public List<TarifaNumeroTipoIntegrante> TarifaNumeroTipoIntegrante { get; set; }
        
    }
    
    public class TarifaHealth {
        public String IdTipoTarifa { get; set; }
        public List<TarifaSalud> TarifaSalud { get; set; }
        public List<TarifaNumeroTipoIntegrante> TarifaNumeroTipoIntegrante { get; set; }
        
    }
    
    public class TarifaLife {
        public String IdTipoTarifa { get; set; }
        
    }
    
    public class TarifaLifeSchooling {
        public String IdTipoTarifa { get; set; }
        public List<Escolaridad> Escolaridad { get; set; }
        
    }
    
    
    public class Escolaridad {
        public Integer CodigoCobertura { get; set; }
        public String CodigoNivel { get; set; }
        public Decimal ValorCapital { get; set; }
        public Decimal Tasa { get; set; }
        
    }
    
    public class TarifaSalud {
        public Integer CodigoSubtipoTarifa { get; set; }
        public Decimal ValorTipoSubTipo { get; set; }
        public Decimal ValorTarifaSalud { get; set; }
        public Decimal ValorTarifaDental { get; set; }
        
    }
    
    public class TarifaNumeroTipoIntegrante {
        public Integer CodigoSubtipoTarifa { get; set; }
        public Integer Edad { get; set; }
        public Integer ValorTipoTarifaPoliza { get; set; }
        public Decimal Valtrs { get; set; }
        public Decimal ValtrD { get; set; }
        
    }
    
    public class UnidadEquivalenteAsegurada {
        public String UnidadEquivalenteAsegurada { get; set; } 
        public Integer NumeroRentas { get; set; } 
        public Integer ValorCapital { get; set; }
        
    }
    
    public class GrupoNegocio {
        public Integer codigoGrupo { get; set; } 
        public String NombreGrupo { get; set; }
        
    }
}