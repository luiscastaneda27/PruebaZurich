public with sharing class WS_UploadAttachment_GLB {
    
    @InvocableMethod(callout=true label='Send Case Attachments to Custodia API' description='Send case attachments to custodia API. The parameter is a List but, send only one!!!' category='Case')
    public static List<String> serviceCallout(List<Id> caseIds) { 
        Map<String, String> mimeTypes = new Map<String, String>();
        mimeTypes.put('pdf', 'application/pdf');
        mimeTypes.put('csv', 'text/csv');
        mimeTypes.put('txt', 'text/plain');
        mimeTypes.put('xls', 'application/vnd.ms-excel');
        mimeTypes.put('xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        mimeTypes.put('zip', 'application/zip');
        mimeTypes.put('png', 'image/png');
        mimeTypes.put('mp4', 'video/mp4');
        mimeTypes.put('jpg', 'image/jpeg');
        mimeTypes.put('jpeg', 'image/jpeg');
        mimeTypes.put('doc', 'application/msword');
        mimeTypes.put('docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');

        Id SingleCaseId = (Id)caseIds[0];

        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :SingleCaseId
        ];

        Case aCase = [
            SELECT Id, Subject, Description, Account.ZRH_Rut__c, GLB_P1_IDExternoCaso__c,GLBP1_Mensaje_sincronizaci_n__c 
            FROM Case
            WHERE Id = :caseIds[0]
            LIMIT 1
        ];

        Set<Id> contentIds = new Set<Id>();
        CustodiaApiCredentials__c custodiaCredentials = CustodiaApiCredentials__c.getOrgDefaults();

        for(ContentDocumentLink cdl : contentDocumentLinks) {
            contentIds.add(cdl.ContentDocumentId);
        }

        List<ContentVersion> contentVersion = [
            SELECT VersionData, FileExtension, Title
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentIds
            AND IsLatest = true
        ];

        for(ContentVersion cv : contentVersion) {
            aCase.Description = aCase.Description + ' Url Archivo "' + cv.Title + '"En servidor Custodia: ' + uploadFile(cv, custodiaCredentials, aCase, mimeTypes);
        }

        update aCase;

        List<String> result = new List<String>();
        result.add('DONE');
        return result;
    }

    public static String uploadFile(ContentVersion cv, CustodiaApiCredentials__c custodiaCredentials, Case caso, Map<String,String> mimeTypes) {
        

        Http http = new Http();
        HttpResponse response = new HttpResponse();

        List<String> responseList = new List<String>();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(custodiaCredentials.Url__c + '/api/cuentas/login');

        AuthenticationRequestBody aBody = new AuthenticationRequestBody();
        aBody.email = custodiaCredentials.Username__c;
        aBody.password = custodiaCredentials.Password__c;
        request.setBody(JSON.serialize(aBody));
        request.setHeader('Content-Type', 'application/json');

        System.debug(request.getBody());
        System.debug(request.getHeader('Content-Type'));

        response = http.send(request);
        System.debug(response.getBody());

        AuthenticationResponseBody aResponse = new AuthenticationResponseBody();
        aResponse = (AuthenticationResponseBody)JSON.deserialize(response.getBody(), AuthenticationResponseBody.class);

        Http httpData = new Http();
        HttpResponse responseData = new HttpResponse();
        HttpRequest requestData = new HttpRequest();
        requestData.setMethod('POST');
        requestData.setEndpoint(custodiaCredentials.Url__c  + '/api/Files/UploadFiles');

        UploadModelWrapper uploadWrapper = new UploadModelWrapper();
        uploadWrapper.canal = 'Salesforce';
        uploadWrapper.rut = caso.Account.ZRH_Rut__c;
        uploadWrapper.tipoDocumento = 'Adjunto Caso Salesforce';
        uploadWrapper.idTipoProceso = 0;

        EvidenciasWrapper evidencia = new EvidenciasWrapper();
        evidencia.archivoBase64 = EncodingUtil.base64Encode(cv.VersionData);
        evidencia.mimeType =  mimeTypes.get(cv.FileExtension);

        uploadWrapper.evidencias = new List<EvidenciasWrapper>();
        uploadWrapper.evidencias.add(evidencia);

        requestData.setBody(JSON.serialize(uploadWrapper));
        requestData.setHeader('Content-Type', 'application/json');
        requestData.setHeader('Authorization', 'Bearer ' + aResponse.token);

        responseData = httpData.send(requestData);

        System.debug(responseData.getBody());

        UploadModelResponseWrapper responseBody = (UploadModelResponseWrapper)JSON.deserialize(responseData.getBody(), UploadModelResponseWrapper.class);

        System.debug(responseBody);

        if(responseBody.errorMessage != null) {
            System.debug(responseBody.errorMessage);
            return 'ERROR';
        } else {
            return responseBody.documentos[0].urlDocumento;
        }
    }

    public class AuthenticationRequestBody {
        public string email;
        public string password;
    }

    public class AuthenticationResponseBody {
        public string expiracion;
        public string token;
    }

    public class UploadModelWrapper {
        public Integer idSolicitud;
        public Integer idRemesa;
        public Integer idTipoProceso;
        public String rut;
        public String tipoDocumento;
        public String codigoTipoDocumento;
        public String canal;
        public Integer codigoCanal;
        public String folderName;
        public List<MetadataModelWrapper> rrvvMetadataModel;
        public List<EvidenciasWrapper> evidencias;
    }

    public class MetadataModelWrapper {
        public string documentTitle;
        public string seriePoliza;
        public string numeroPoliza;
        public string numeroEndoso;
        public string tipoTransaccion;
        public Integer familia;
        public String codigoAgente;
        public String rutContratante;
        public String fechaEmision;
        public String fechaVigenciaDesde;
        public String fechaVigenciaHasta;
        public String numeroCajaStorbox;
        public String indicadorActualizado;
        public Integer correlativoArchivo;
        public String fechaEscaneo;
        public String numeroExpediente;
        public String loteCarga;
    }

    public class EvidenciasWrapper {
        public string archivoBase64;
        public string mimeType;
    }

    public class UploadModelResponseWrapper {
        public String estado;
        public Integer codigoTipoDocumento;
        public String tipoDocumento;
        public String idSolicitud;
        public String idTipoProceso;
        public String idRemesa;
        public String rut;
        public String canal;
        public Integer errorCode;
        public String errorMessage;
        public List<DocumentoResponseWrapper> documentos;
    }

    public class DocumentoResponseWrapper {
        public String idDocumento;
        public String urlDocumento;
        public String mimeType;
    }

}