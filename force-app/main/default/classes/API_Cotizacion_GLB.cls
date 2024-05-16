@RestResource(urlMapping='/cotizacion/*')
global without sharing class API_Cotizacion_GLB {
    @HttpPost
    global static void createCotizacion(API_POST_COTIZACION_WRAPPER data) {
        Boolean error = false;

        RestRequest request = RestContext.request;

        RestResponse response = RestContext.response;
        response.statusCode = 200;
        
        List<SObject> sObjectToInsert = new List<SObject>();
        List<Database.SaveResult> results;

        if(data.cotizacion == null) {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_COTIZACION_WRAPPER('Incomplete Data from JSON')));
        }

        if(data.cotizacion.GLBP1_ID_Externo_Cotizacion__c == null || data.cotizacion.GLBP1_ID_Externo_Cotizacion__c == '') {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_COTIZACION_WRAPPER('Missing External Id for Poliza')));
        }

        if(data.participantes.size() == 0) {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_COTIZACION_WRAPPER('Incomplete Data from JSON')));
        }

        if(data.partidas.size() == 0) {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_COTIZACION_WRAPPER('Incomplete Data from JSON')));
        }

        data.cotizacion.OwnerId = UserInfo.getUserId();
        sObjectToInsert.add(data.cotizacion);

        for(GLBP1_Participante_de_cotizacion__c b : data.participantes ) {
            sObjectToInsert.add(b);
        }

        for(QuoteLineItem b : data.partidas ) {
            sObjectToInsert.add(b);
        }

        if(error != true) {            
            results = Database.insert(sObjectToInsert);
    
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_COTIZACION_WRAPPER('Cotizacion created succesfully')));
                }
                else {
                    /* Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                    */
    
                    response.statusCode = 400 ;
                    response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_COTIZACION_WRAPPER('Failed to save Cotizacion to Salesforce')));
                }
            }
        }
    }

    global class API_POST_COTIZACION_WRAPPER {
        global Quote cotizacion;
        global List<GLBP1_Participante_de_cotizacion__c> participantes;
        global List<QuoteLineItem> partidas;
    }
    
    global class API_RESPONSE_COTIZACION_WRAPPER {
        global API_RESPONSE_COTIZACION_WRAPPER(String message) {
            this.message = message;
        }
        global API_RESPONSE_COTIZACION_WRAPPER(String message, List<String> errors) {
            this.message = message;
        }
        global string message;
        global List<String> errors;
    }
}