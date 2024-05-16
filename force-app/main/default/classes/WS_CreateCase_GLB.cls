/**
 * @description       : Callout service that will submit a case into Dynamycs Web Service.
 * @author            : Santiago Muñoz
 * @group             : Globant
 * @last modified on  : 04-20-2024
 * @last modified by  : Santiago Muñoz
**/
public without sharing class WS_CreateCase_GLB {

    
    @InvocableMethod(callout=true label='Send Case to Dynamycs' description='Send case to Dynamycs. The parameter is a List but, send only one!!!' category='Case')
    public static List<String> serviceCallout(List<Id> caseIds) {
        Http http = new Http();
        HttpResponse response = new HttpResponse();

        Case aCase = [
            SELECT Id, Subject, Description, Account.ZRH_Rut__c, GLB_P1_IDExternoCaso__c,GLBP1_Mensaje_sincronizaci_n__c 
            FROM Case
            WHERE Id = :caseIds[0]
            LIMIT 1
        ];

        List<String> responseList = new List<String>();

        if(aCase.GLB_P1_IDExternoCaso__c != '' && aCase.GLB_P1_IDExternoCaso__c != null) {
            System.debug('Error --- El caso ya fue ingresado previamente y ya cuenta con ID de dynamics.');
            responseList.add('Error --- El caso ya fue ingresado previamente y ya cuenta con ID de dynamics.');
            return responseList;
        }

        DynamicsCredentials__c credentials = DynamicsCredentials__c.getOrgDefaults();

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(credentials.Url__c + '/Users/authenticate');

        AuthenticationRequestBody aBody = new AuthenticationRequestBody();
        aBody.username = credentials.Username__c;
        aBody.password = credentials.Password__c;
        request.setBody(JSON.serialize(aBody));
        request.setHeader('Content-Type', 'application/json');

        System.debug(request.getBody());
        System.debug(request.getHeader('Content-Type'));

        response = http.send(request);
        System.debug(response.getBody());

        AuthenticationResponseBody aResponse = new AuthenticationResponseBody();
        aResponse = (AuthenticationResponseBody)JSON.deserialize(response.getBody(), AuthenticationResponseBody.class);

        System.debug(aResponse);

        Http httpData = new Http();
        HttpResponse responseData = new HttpResponse();
        HttpRequest requestData = new HttpRequest();
        requestData.setMethod('POST');
        requestData.setEndpoint(credentials.Url__c  + '/api/CRM/CrearCaso');

        List<String> splittedRut = aCase.Account.ZRH_Rut__c.split('-');

        CaseRequestBody cBody = new CaseRequestBody();
        cBody.titulo = aCase.Subject;
        cBody.rut = splittedRut[0];
        cBody.dv = splittedRut[1];
        cBody.canal = '3';
        cBody.origen = '6';
        cBody.tipificacion = 'LN12MC9MA6';
        cBody.tipoCaso = '858820001';
        cBody.descripcion = aCase.Description;
        cBody.ejecutivo = 'Salesforce';
        cBody.iD_Producto = '';
        cbody.tipoProducto = '1';
        cBody.propietario = 'svc-crm-chile@zurich.com';
        requestData.setBody(JSON.serialize(cBody));
        requestData.setHeader('Content-Type', 'application/json');
        requestData.setHeader('Authorization', 'Bearer ' + aResponse.token);

        responseData = httpData.send(requestData);

        System.debug(responseData.getBody());

        CaseResponseBody aPostResponse = new CaseResponseBody();
        aPostResponse = (CaseResponseBody)JSON.deserialize(responseData.getBody(), CaseResponseBody.class);

        
        if(aPostResponse.codigo == 0) {
            aCase.GLB_P1_IDExternoCaso__c = aPostResponse.mensaje;
            aCase.GLBP1_Mensaje_sincronizaci_n__c = 'Exito';
            update aCase;
            responseList.add('Exito');
            System.debug('CASO INGRESADO EXITOSAMENTE ID: ' + aPostResponse.mensaje);
            return responseList;
        } else {
            aCase.GLBP1_Mensaje_sincronizaci_n__c = 'Error - No se registro la cuenta en dynamics. Mensaje: ' + aPostResponse.mensaje;
            responseList.add('Error - No se registro la cuenta en dynamics. Mensaje: ' + aPostResponse.mensaje);
            update aCase;
            System.debug('ERROR AL INGRESAR CASO: ' + aPostResponse.mensaje);
            return responseList;
        }
    }

    public class AuthenticationRequestBody {
        public string username;
        public string password;
    }

    public class AuthenticationResponseBody {
        public string status;
        public string detalle;
        public string token;
    }

    public class CaseRequestBody {
        public string titulo;
        public string rut;
        public string dv;
        public string canal;
        public string origen;
        public string tipificacion;
        public string tipoCaso;
        public string tipoProducto;
        public string iD_Producto;
        public string descripcion;
        public string propietario;
        public string ejecutivo;
    }

    public class CaseResponseBody {
        public Integer codigo;
        public string mensaje;
    }
}