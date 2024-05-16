@RestResource(urlMapping='/poliza/*')
global without sharing class API_Poliza_GLB {
    @HttpPost
    global static void createPoliza(API_POST_POLIZA_WRAPPER data) {
        Boolean error = false;

        RestRequest request = RestContext.request;

        RestResponse response = RestContext.response;
        response.statusCode = 200;
        
        List<SObject> sObjectToInsert = new List<SObject>();
        List<Database.SaveResult> results;

        if(data.poliza == null) {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_POLIZA_WRAPPER('Incomplete Data from JSON')));
        }

        if(data.poliza.GLB_P1_NumeroPolizaExterno__c == null || data.poliza.GLB_P1_NumeroPolizaExterno__c == '') {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_POLIZA_WRAPPER('Missing External Id for Poliza')));
        }

        if(data.planesDePago.size() == 0) {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_POLIZA_WRAPPER('Incomplete Data from JSON')));
        }

        if(data.activosDePoliza.size() == 0) {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_POLIZA_WRAPPER('Incomplete Data from JSON')));
        }

        if(data.beneficiariosDePoliza.size() == 0) {
            error = true;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_POLIZA_WRAPPER('Incomplete Data from JSON')));
        }

        data.Poliza.OwnerId = UserInfo.getUserId();
        sObjectToInsert.add(data.Poliza);

        for(GLBP1_Beneficiario_de_Poliza__c b : data.beneficiariosDePoliza ) {
            b.OwnerId = UserInfo.getUserId();
            sObjectToInsert.add(b);
        }

        for(InsurancePolicyAsset b : data.activosDePoliza ) {
            b.OwnerId = UserInfo.getUserId();
            sObjectToInsert.add(b);
        }

        for(GLBP1_Plan_de_pago__c b : data.planesDePago ) {
            b.OwnerId = UserInfo.getUserId();
            sObjectToInsert.add(b);
        }

        if(error != true) {            
            results = Database.insert(sObjectToInsert);
    
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_POLIZA_WRAPPER('Poliza created succesfully')));
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
                    response.responseBody = Blob.valueOf(JSON.serialize(new API_RESPONSE_POLIZA_WRAPPER('Failed to save Poliza to Salesforce')));
                }
            }
        }
    }

    global class API_POST_POLIZA_WRAPPER {
        global InsurancePolicy poliza;
        global List<GLBP1_Plan_de_pago__c> planesDePago;
        global List<InsurancePolicyAsset> activosDePoliza;
        global List<GLBP1_Beneficiario_de_Poliza__c> beneficiariosDePoliza;
    }

    global class API_RESPONSE_POLIZA_WRAPPER {
        global API_RESPONSE_POLIZA_WRAPPER(String message) {
            this.message = message;
        }
        global API_RESPONSE_POLIZA_WRAPPER(String message, List<String> errors) {
            this.message = message;
        }
        global string message;
        global List<String> errors;
    }
}