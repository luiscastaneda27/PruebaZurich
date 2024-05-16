/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 29/1/2024
Description  : Batch class to send gloss
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			 29/1/2024		initial version
********************************************************************************/
global without sharing  class ZRH_BatchSubmitGlossPolicy implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        29/1/2024
    */
    private static final Set<Integer> STATUS_CODE_SUCCESSS = new Set<Integer>{200, 201, 202};
        private static final String NAME_CUSTOM_NOTIFICATION = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_EnvioGlosasPoliza';
    private static final String STR_HEADER = 'header';
    private static final String STR_PATH = 'path';
    private static final String STR_HEADER_KEY = 'Content-Type';
    private static final String STR_HEADER_VALUE = 'application/json';
    private static final String QUERY_CONDITION = 'ZRH_EnvioGlosaPendiente__c = true';
    private static final String POLICY_NUMBER = 'numberPolicy';
    private static final String NAME_GLOSS_OLD = 'CondicionParticular';
    private static final String NAME_GLOSS_NEW = 'CondicionadoParticular';
    private String queryCondition;
    
    /**
    *  @Description: Constructor method of the class
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        5/2/2023  
    */
    global ZRH_BatchSubmitGlossPolicy(String condition){
        this.queryCondition = condition;
    }
    global ZRH_BatchSubmitGlossPolicy(){
        this.queryCondition = QUERY_CONDITION;
    }

    
    
    /**
    *  @Description: Start Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:         29/1/2024 
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        return new ZRH_ContractGroupPlansSelector().selectByDynamicCondition(queryCondition);
    }
    
    /**
    *  @Description: Execute Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:         29/1/2024 
    */
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        ContractGroupPlan objPol = (ContractGroupPlan) scope?.get(0);
        try{
            ZRH_JSONPolicyPDF.PolicyPDF poliza = ZRH_PolicyPDFController.mapping(objPol);
            ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
            poliza.Ambiente = service.ZRH_Ambiente__c;
            PlocyGloss polizaGloss = (PlocyGloss) JSON.deserialize(JSON.serialize(poliza).replace(NAME_GLOSS_OLD,NAME_GLOSS_NEW), PlocyGloss.class);
            System.debug(JSON.serialize(poliza));
            System.debug(JSON.serialize(polizaGloss));
            HttpResponse res = call(JSON.serialize(polizaGloss), String.valueOf(polizaGloss.poliza));
            if(STATUS_CODE_SUCCESSS.contains(res.getStatusCode())){
                objPol.ZRH_EnvioGlosaPendiente__c = false;
                objPol.ZRH_PDFEndoso__c = true;
                objPol.ZRH_MensajeEndosoPDF__c = null;
            }else{
                objPol.ZRH_PDFEndoso__c = false;
                objPol.ZRH_MensajeEndosoPDF__c = res.getBody() != null && res.getBody().length() > 255 ? res.getBody().subString(0, 255) :  res.getBody();
            }
        }catch(exception ex){
            System.debug('Error: '+ex.getMessage() + ', Línea: '+ex.getLineNumber());
            objPol.ZRH_MensajeEndosoPDF__c = 'Error: '+ex.getMessage() + ', Línea: '+ex.getLineNumber();
        }
        update objPol;
    }
    
    
    /**
    *  @Description: Finish Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        29/1/2024
    */
    global void finish(Database.BatchableContext bc){
        System.debug('=== BatchUpdateContactBlocked.finish ===');       
    }
    
    
    /**
    *  @Description: Service Call
    *  @Author:      Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        29/1/2024  
    */
    private HttpResponse call(String body, String numberPolicy) {
        Map<String, String> mapParam = new Map<String, String>();
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        mapParam.put(POLICY_NUMBER, numberPolicy);
        setConf.put(STR_PATH, mapParam);
        mapParam = new Map<String, String>();
        mapParam.put(STR_HEADER_KEY, STR_HEADER_VALUE);
        setConf.put(STR_HEADER, mapParam);
        ZRH_RestConnection objClass = new ZRH_RestConnection(INTEGRATION_BASE, INTEGRATION_ROUTE, setConf);
        return objClass.callService(body);
    }
    
    
    public class PlocyGloss {
        public String ContractId { get; set; }
        public Integer Poliza { get; set; }
        public Integer DvPoliza { get; set; }
        public Integer Periodo { get; set; }
        public string Origen { get; set; }
        public string Ambiente { get; set; }
        public string CodigoSistema { get; set; }
        public CondicionadoParticular CondicionadoParticular { get; set; } 
        public TablasAntecedentesGrls TablasAntecedentesGrls { get; set; }
        
    }
    
    public class TablasAntecedentesGrls {
        public List<Tablas> Tablas { get; set; }
        
    }
    public class Tablas {
        public String TituloTabla { get; set; }
        public String NombreTabla { get; set; }
        public List<Columnas> Columnas { get; set; }
        public List<Filas> Filas { get; set; }
        
    }
    
    public class CondicionadoParticular {
        public List<Articulos> Articulos { get; set; }
        public List<Anexos> Anexos { get; set; }
        
    }
    public class Anexos {
        public String Nombre { get; set; }
        public String Titulo { get; set; }
        public List<SubTitulosA> SubTitulos { get; set; }
        
    }
    
    public class Articulos {
        public Decimal OrdenCondc { get; set; }
        public String Nombre { get; set; }
        public String Titulo { get; set; }
        public List<SubTitulosA> SubTitulos { get; set; }
        
    }
    
    public class SubTitulosA {
        public String Nombre { get; set; }
        public String Contenido { get; set; }
        public List<TablasA> Tablas { get; set; }
        
    }
    
    public class TablasA {
        public String TituloTabla { get; set; }
        public String NombreTabla { get; set; }
        public List<Columnas> Columnas { get; set; }
        public List<Filas> FilaTabla { get; set; }
        
    }
    
    public class Columnas {
        public String Nombre { get; set; }
        
    }
    
    public class Filas {
        public List<Datos> Datos { get; set; }
        
    }
    
    public class Datos {
        public String dato { get; set; }
        
    }
}