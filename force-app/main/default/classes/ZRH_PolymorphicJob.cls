public without sharing class ZRH_PolymorphicJob extends ZRH_AbstractBatch {

    public override void execute(Database.BatchableContext context, SObject[] scope) {
        List<Sobject> soUpdate = new List<Sobject>();
        for (Sobject so: scope) {
            for (ZRH_DiccionarioPoblacionDatosJSON__mdt item: ZRH_DiccionarioPoblacionDatosJSON__mdt.getAll().values()) {
                String dataJSON = (String) so.get(item.ZRH_CampoJSON__c);
                if (item.ZRH_Objeto__c == String.valueOf(scope.getSObjectType())) {
                        if (String.isNotBlank(dataJSON) && dataJSON != Null ) {
                            Object dataObj = ZRH_JSONDataTransformationHelper.getJsonValue(dataJSON, item.ZRH_Nodo__c, item.ZRH_NombreAtributo__c, null);
                            try {
                                if (dataObj != Null) {
                                    so.put(item.ZRH_CampoDestino__c, dataObj);
                                }                                
                            } catch (Exception ex) {
                                ZRH_JSONDataTransformationHelper.assignValueField(so, item, dataObj);
                            }                            
                        }
                }                    
            }
            soUpdate.add(so);
        }
    
        Database.SaveResult[] srList = Database.update(soUpdate, false);

        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    public override void finish(Database.BatchableContext context) {
        // And finish up
    }
}