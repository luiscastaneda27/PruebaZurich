/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 18/10/2023
Description  : Class responsible to do the Rest Connection
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O			    ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      ATO            18/10/2023		   	Created Class
********************************************************************************/
public without sharing class ZRH_RestConnection {
    
    /**
    *  @Description: Static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        19/10/2023
    */
    private static final Map<String, ZRH_RutaIntegracion__mdt> PVR_MAP_PATH;
    private static final Map<String, ZRH_ServicioIntegracion__mdt> PVR_MAP_SERVICE;
    private static final String PVR_STR_HEADER;
    private static final String PVR_STR_QUERY;
    private static final String PVR_STR_PATH;
    private static final String PVR_STR_COLON;
    private static final String PVR_STR_SMCOLON;
    

    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        19/10/2023
    */
    static {
        PVR_MAP_PATH = setPath();
        PVR_MAP_SERVICE = setService();
        PVR_STR_HEADER = 'header';
        PVR_STR_QUERY = 'query';
        PVR_STR_PATH = 'path';
        PVR_STR_COLON = ':';
        PVR_STR_SMCOLON = ';';
    }  
    
    private static ZRH_ServicioIntegracionesSelector serviceSelector;
    private static ZRH_RutaIntegracionesSelector pathSelector;
    private ZRH_ServicioIntegracion__mdt service;
    private ZRH_RutaIntegracion__mdt path;
    private Map <String, Map<String,String>> connSetting;

    /**
    *  @Description: Constructor to initialize the class
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        18/10/2023
    */    
    public ZRH_RestConnection(String nameService, String namePath) {
        this.service = PVR_MAP_SERVICE.get(nameService);
        this.path = PVR_MAP_PATH.get(namePath);
        Map<String, String> mapHeader = new Map<String, String>();
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        setConf.put(PVR_STR_HEADER, mapHeader);
        this.connSetting = setConf;
    }

    /**
    *  @Description: Constructor to initialize the class
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        18/10/2023
    */    
    public ZRH_RestConnection(String nameService, String namePath, Map <String, Map<String,String>> connSetting) {
        this.service = PVR_MAP_SERVICE.get(nameService);        
        this.path = PVR_MAP_PATH.get(namePath);
        this.connSetting = connSetting;
    }

    /**
    *  @Description: Call service, centralization of rest calls
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        18/10/2023
    */    
    public HttpResponse callService(String body) {
        HttpResponse response;
        try {

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            // Setting Named Credential and endpoint
            String endpoint = service.ZRH_URLBase__c + path.ZRH_RutaURL__c;

            if (connSetting.containsKey(PVR_STR_PATH)) {
                for (String param : connSetting.get(PVR_STR_PATH).keyset()) {
                    endpoint = endpoint + '/' + connSetting.get(PVR_STR_PATH).get(param);
                }
            } else if (connSetting.containsKey(PVR_STR_QUERY)) {
                Integer i = 0;
                endpoint += !connSetting.get(PVR_STR_QUERY).isEmpty() ? '?' : '';
                for (String param : connSetting.get(PVR_STR_QUERY).keyset()) {
                    endpoint += param + '=' + connSetting.get(PVR_STR_QUERY).get(param);
                    endpoint += ++i == connSetting.get(PVR_STR_QUERY).size() ? '' : '&';
                }
            } 
            if (connSetting.containsKey(PVR_STR_HEADER)) {
                connSetting.get(PVR_STR_HEADER).putAll(fillMapHeader(path.ZRH_Cabeceras__c));
                for (String param : connSetting.get(PVR_STR_HEADER).keySet()) {
                    req.setHeader(param, connSetting.get(PVR_STR_HEADER).get(param));
                }
            }
            req.setEndpoint(endpoint);
            req.setMethod(path.ZRH_Metodo__c);
            req.setTimeout(120000);            
            if (String.isNotBlank(body)) {
                req.setBody(body);
            }
			
            System.debug('Resquest Body: '+req.getBody());
            System.debug('Resquest Enpoint: '+req.getEndpoint());
            HttpResponse res = http.send(req);
            System.debug('Response code from external API: ' + res.getStatusCode()); 
            System.debug('Response body from external API: ' + res.getBody());  

            // Create a map with the response details
            response = res;
        } catch (CalloutException ex) {
            throw new ServiceException(ex.getMessage(), ex);
        } catch (JSONException ex) {
            throw new ServiceException(ex.getMessage());
        }
        return response;
    }
    
    /**
    *  @Description: Filling service object
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public static Map<String, ZRH_ServicioIntegracion__mdt> setService() {
        serviceSelector = new ZRH_ServicioIntegracionesSelector();
        Map<String, ZRH_ServicioIntegracion__mdt> objMap =  new Map<String, ZRH_ServicioIntegracion__mdt>();
        List<ZRH_ServicioIntegracion__mdt> listObj = serviceSelector.selectAll();
        for (ZRH_ServicioIntegracion__mdt eo : listObj){
            objMap.put(eo.DeveloperName, eo);
        }
        return objMap;
    }
    
    /**
    *  @Description: Filling path object
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        27/09/2023
    */    
    public static Map<String, ZRH_RutaIntegracion__mdt> setPath() {
        pathSelector = new ZRH_RutaIntegracionesSelector();
        Map<String, ZRH_RutaIntegracion__mdt> objMap =  new Map<String, ZRH_RutaIntegracion__mdt>();
        List<ZRH_RutaIntegracion__mdt> listObj = pathSelector.selectAll();
        for (ZRH_RutaIntegracion__mdt eo : listObj){
            objMap.put(eo.DeveloperName, eo);
        }
        return objMap;
    }

    /**
    *  @Description: Fill map header, headers used in the integration
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        07/11/2023
    */    
    private Map<String, String> fillMapHeader(String vrb) {
        Map<String, String>  str = new Map<String, String>();
        Map<String, String>  stcMap = new Map<String, String>();
        if (!String.isBlank(vrb)) {
            String[] splitStr = vrb.Split(PVR_STR_SMCOLON);
            for (String c : splitStr) {
                if (stcMap.containsKey(c.Split(PVR_STR_COLON)[0])) {
                	str.put(c.Split(PVR_STR_COLON)[0], stcMap.get(c.Split(PVR_STR_COLON)[0])); 
                } else {
                    str.put(c.Split(PVR_STR_COLON)[0], c.Split(PVR_STR_COLON)[1]);
                }
            }
        }
        return str;
    }


    /**
    *  @Description: Create error service, used to create and throw a service error
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        18/10/2023
    */    
    private void createErrorService (String message, integer code){
        switch on code {
            when  400 {
                throw new ServiceException(message, code);
            }
            when  401 {
                throw new ServiceException(message, code);
            }
            when  404 {
                throw new ServiceException(message, code);
            }
            when  500 {
                throw new ServiceException(message, code);
            }
            when else {
                throw new ServiceException(message, code);
            }
        }
    }

    /**
    *  @Description: Service exception, wrapper class used to set a service exception
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        18/10/2023
    */    
    public class ServiceException extends Exception {
        public Integer code;
        public ServiceException(String message, Integer code)
        {
            this(message);
            this.code = code;            
        }
    }
}