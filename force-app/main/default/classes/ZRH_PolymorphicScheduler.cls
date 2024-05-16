global class ZRH_PolymorphicScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        // Build the query map
        Map<String, String> queryMap = buildQueryMap(ZRH_DiccionarioPoblacionDatosJSON__mdt.getAll().values());
        Integer Count = 0;
        for (String key : queryMap.keySet()) {
            Count++;
            // Create an instance of the batch with the query map
            ZRH_AbstractBatch batch = new ZRH_PolymorphicJob();
            batch.setQuery(queryMap.get(key));
            // Schedule the batch to run immediately
            String jobId = System.scheduleBatch(batch, 'Polymorphic Batch ' + Count + ' ' + System.now(), 0);
            System.debug('Batch scheduled with job ID: ' + jobId);
        }
    }

    private Map<String, String> buildQueryMap(List<ZRH_DiccionarioPoblacionDatosJSON__mdt> records) {
        // Map to store unique conditions for each object
        Map<String, Set<String>> uniqueConditionsMap = new Map<String, Set<String>>();
        // Map to store field names for each object
        Map<String, Set<String>> fieldNameMap = new Map<String, Set<String>>(); 
        // Map to store final queries for each object
        Map<String, String> queryMap = new Map<String, String>();
    
        // Populate uniqueConditionsMap and fieldNameMap
        for (ZRH_DiccionarioPoblacionDatosJSON__mdt rec : records) {
            String objectName = rec.ZRH_Objeto__c;
            String fieldName = rec.ZRH_CampoJSON__c;
            String conditionField = rec.ZRH_Condicion__c;
            String conditionValue = rec.ZRH_ValorCondicion__c;
            String conditionField2 = rec.ZRH_CondicionDos__c; // New additional condition field
            String conditionValue2 = rec.ZRH_ValorCondicionDos__c; // New additional condition value
    
            // Check if objectName, conditionField, conditionValue, and conditionField2 are not blank
            if (String.isNotBlank(objectName) && rec.ZRH_Activo__c &&
                String.isNotBlank(conditionField) && String.isNotBlank(conditionValue) &&
                String.isNotBlank(conditionField2) && String.isNotBlank(conditionValue2)) {
    
                // Add conditions to the uniqueConditionsMap
                if (!uniqueConditionsMap.containsKey(objectName)) {
                    uniqueConditionsMap.put(objectName, new Set<String>());
                }
                uniqueConditionsMap.get(objectName).add(conditionField + ' = \'' + conditionValue + '\'');
                uniqueConditionsMap.get(objectName).add(conditionField2 + ' = \'' + conditionValue2 + '\''); // Add new condition
    
                // Add fieldName to the corresponding set
                if (!fieldNameMap.containsKey(objectName)) {
                    fieldNameMap.put(objectName, new Set<String>());
                }
                fieldNameMap.get(objectName).add(fieldName);
            }
        }
    
        // Build queries for each object
        for (String objectName : uniqueConditionsMap.keySet()) {
            Set<String> uniqueConditions = uniqueConditionsMap.get(objectName);
            Set<String> fieldNames = fieldNameMap.get(objectName);
            String query = 'SELECT ';
    
            // Use String.join directly with the set of fieldNames
            if (fieldNames != null && !fieldNames.isEmpty()) {
                query += String.join(new List<String>(fieldNames), ', ');
            } else {
                query += 'Id';
            }
    
            query += ' FROM ' + objectName;
    
            // Check if the uniqueConditions set is not empty
            if (!uniqueConditions.isEmpty()) {
                query += ' WHERE ';
                query += String.join(new List<String>(uniqueConditions), ' AND ');
            }
    
            queryMap.put(objectName, query);
        }
    
        // Debug the query map
        System.debug('queryMap: ' + queryMap);
        return queryMap;
    }
    
}