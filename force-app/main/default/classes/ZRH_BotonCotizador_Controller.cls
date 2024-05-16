public with sharing class ZRH_BotonCotizador_Controller {
    @AuraEnabled(cacheable=true)
    public static string retrieveToken(String recordId){
        try {
            String token = '';
            ConfiguradorCotizador__c c;
            if(!Test.isRunningTest()) {
                c = ConfiguradorCotizador__c.getOrgDefaults();
            } else {
                c = new ConfiguradorCotizador__c(
                    ApiKey__c = 'apiKey',
                    Url__c = 'Test.com'
                );
            }

            Opportunity o = [
                SELECT Id, Owner.GLBP1_Rut__c
                FROM Opportunity
                WHERE Id = :recordId
            ];

            Http http = new Http();
            HttpResponse response = new HttpResponse();
            HttpRequest request = new HttpRequest();
            request.setTimeout(30000);
            request.setMethod('GET');
            request.setEndpoint(c.Url__c + '/Corporate/Web/PlataformaCotizacion/ApiVentas/api/v1/Token/encriptarToken?datos=idLead_' + recordId + '_rut_' + o.Owner.GLBP1_Rut__c);
            request.setHeader('ApiKey', c.ApiKey__c);

            response = http.send(request);

            token = response.getBody().toString();

            return token;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}