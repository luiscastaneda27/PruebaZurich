@RestResource(urlMapping='/propuesta/*')
global without sharing class API_Propuesta_GLB {
    @HttpPost
    global static void createPropuesta(API_POST_PROPUESTA_WRAPPER data) {
        Boolean error = false;

        RestRequest request = RestContext.request;

        RestResponse response = RestContext.response;
        response.statusCode = 200;
        
        List<SObject> sObjectToInsert = new List<SObject>();
        List<Database.SaveResult> results;

        if(data.propuesta == null) {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_PROPUESTA_WRAPPER('Incomplete Data from JSON')));
        }

        if(data.propuesta.GLB_P1_NumeroPropuesta__c == null || data.propuesta.GLB_P1_NumeroPropuesta__c == '') {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_PROPUESTA_WRAPPER('Missing External Id for Propuesta')));
        }

        if(data.participantes.size() == 0) {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_PROPUESTA_WRAPPER('Incomplete Data from JSON')));
        }


        data.propuesta.OwnerId = UserInfo.getUserId();
        sObjectToInsert.add(data.propuesta);

        for(GLB_P1_ParticipantePropuesta__c b : data.participantes ) {
            b.OwnerId = UserInfo.getUserId();
            sObjectToInsert.add(b);
        }

        if(error != true) {            
            results = Database.insert(sObjectToInsert);
    
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_PROPUESTA_WRAPPER('Propuesta created succesfully')));
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
                    response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_PROPUESTA_WRAPPER('Failed to save Poliza to Salesforce')));
                }
            }
        }
    }

    global class API_POST_PROPUESTA_WRAPPER {
        global GLB_P1_Propuesta__c propuesta;
        global List<GLB_P1_ParticipantePropuesta__c> participantes; 
    }
    
    global class API_RESPONSE_PROPUESTA_WRAPPER {
        global API_RESPONSE_PROPUESTA_WRAPPER(String message) {
            this.message = message;
        }
        global API_RESPONSE_PROPUESTA_WRAPPER(String message, List<String> errors) {
            this.message = message;
        }
        global string message;
        global List<String> errors;
    }
}