/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 17/11/2023
Description  : Batch class to send policy proposal
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			17/11/2023		initial version
********************************************************************************/
global without sharing class ZRH_BatchSubmitPolicyPDFAS400 implements Database.Batchable<sObject>, Database.AllowsCallouts{

    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    private static final String NOTIFICATION_TITLE = 'Envió de pólizas';
    private static final String NOTIFICATION_TEXT = 'Se enviaron # PDF de pólizas del grupo de negocio ';
    private static final String NOTIFICATION_TITLE_ERROR = 'Error en envió de pólizas';
    private static final String NOTIFICATION_TEXT_ERROR = 'Se producido un error al enviar la póliza ';
    private static final Set<Integer> STATUS_CODE_SUCCESSS = new Set<Integer>{200, 201, 202};
    private static final String NAME_CUSTOM_NOTIFICATION = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_BASE = 'ZRH_SegurosColectivos';
    private static final String INTEGRATION_ROUTE = 'ZRH_EnvioPDFPoliza';
    private static final String STR_HEADER = 'header';
    private static final String STR_PATH = 'path';
    private static final String STR_HEADER_KEY = 'Content-Type';
    private static final String STR_HEADER_VALUE = 'application/json';
    private String queryCondition;
    
    
    /**
    *  @Description: Constructor method of the class
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    global ZRH_BatchSubmitPolicyPDFAS400(String condition){
        this.queryCondition = condition;
    }
    
    
    /**
    *  @Description: Start Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        return new ZRH_ContractGroupPlansSelector().selectByDynamicCondition(queryCondition);
    }
    
    /**
    *  @Description: Execute Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    global void execute(Database.BatchableContext bc, List<SObject> scope){
       // System.debug('=== BatchUpdateContactBlocked.execute ===');
        ContractGroupPlan objPol = (ContractGroupPlan) scope?.get(0);
        try{
            ZRH_JSONPolicyPDF.PolicyPDF poliza = ZRH_PolicyPDFController.mapping(objPol);
            ZRH_ServicioIntegracion__mdt service = ZRH_ServicioIntegracion__mdt.getInstance(INTEGRATION_BASE);
            poliza.Ambiente = service.ZRH_Ambiente__c;
            System.debug(JSON.serialize(poliza));
            HttpResponse res = call(JSON.serialize(poliza));
            if(STATUS_CODE_SUCCESSS.contains(res.getStatusCode())){
                objPol.ZRH_PDFPolizaCreado__c = true;
                objPol.ZRH_MensajeRespuestaPDF__c  = null;
                updateContract(objPol);
            }else{
                if(String.isNotBlank(res.getBody())){
                    ZRH_BatchSubmitPolicyProposalAS400.sendNotification(NOTIFICATION_TITLE_ERROR, res.getBody(),  objPol.Id, objPol.contract.OwnerId);
                }
                objPol.ZRH_PDFPolizaCreado__c = false;
                objPol.ZRH_MensajeRespuestaPDF__c  = res.getBody() != null && res.getBody().length() > 255 ? res.getBody().subString(0, 255) :  res.getBody();
            }
        }catch(exception ex){
            objPol.ZRH_PDFPolizaCreado__c = false;
            objPol.ZRH_MensajeRespuestaPDF__c  = 'Error: '+ex.getMessage() + ', Línea: '+ex.getLineNumber();
        }
        update objPol;
    }
    
    
    /**
    *  @Description: Finish Batch method of the batch
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    global void finish(Database.BatchableContext bc){
        System.debug('=== BatchUpdateContactBlocked.finish ===');       
    }
    
    
    /**
    *  @Description: Service Call
    *  @Author:      Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        20/10/2023  
    */
    private HttpResponse call(String body) {
        Map<String, String> mapParam = new Map<String, String>();
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        mapParam = new Map<String, String>();
        mapParam.put(STR_HEADER_KEY, STR_HEADER_VALUE);
        setConf.put(STR_HEADER, mapParam);
        ZRH_RestConnection objClass = new ZRH_RestConnection(INTEGRATION_BASE, INTEGRATION_ROUTE, setConf);
        return objClass.callService(body);
    }
      
    /**
    *  @Description: update status Contract
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public void  updateContract(ContractGroupPlan cgp){
        Contract c = new ZRH_ContractsSelector().selectByIds(cgp.ContractId)?.get(0);
        Boolean flagPolicy = true;
        for(ContractGroupPlan objPol : c.ContractGroupPlans){
            if(!objPol.ZRH_PDFPolizaCreado__c && objPol.Id != cgp.Id){
                flagPolicy = objPol.ZRH_PDFPolizaCreado__c;
            }
        }
        if(flagPolicy){   
            String description = NOTIFICATION_TEXT + ' ' +  c.Account.ZRH_CodigoGrupoNegocio__c + ' ' + c.Account.Name;
            description = description.replace('#', String.valueOf(c.ContractGroupPlans.size()));
            ZRH_BatchSubmitPolicyProposalAS400.sendNotification(NOTIFICATION_TITLE, description, c.Id, c.OwnerId);
        }
    }
    
}