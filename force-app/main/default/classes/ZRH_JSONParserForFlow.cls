global class ZRH_JSONParserForFlow {
    @InvocableMethod(label = 'Read JSON')
    global static List<JsonResponseVariables> ReadJson(List<JsonParserRequest> requests){
        List<JsonResponseVariables> responses = new List<JsonResponseVariables>();
        for(JsonParserRequest req : requests){
            responses.add(ParseAndSaveJsonFields(req));
        }
        return responses;
    }

    public static JsonResponseVariables ParseAndSaveJsonFields(JsonParserRequest request){
        JsonResponseVariables response = new JsonResponseVariables();
        Map<String, Object> json = (Map<String, Object>) JSON.deserializeUntyped(request.jsonDoc);
        if(!String.isBlank(request.keyValue1)){
            if(KeyExists(request.keyValue1, json)){
                response.jsonVal1 = (String)String.valueOf(json.get(request.keyValue1));
            } else {
                //  throw new readJsonException('Cannot find key ' + request.keyValue1 + ' in provided JSON document. Make sure the key is valid and the desired element is located on the root level of the document.');
            }
        }
        return response;
    }

    public static Boolean KeyExists(String key, Map<String, Object> jsonObj){
        if(jsonObj.containsKey(key)){
            return true;
        } 
        return false;
    }

    public class readJsonException extends Exception {}



    global class JsonParserRequest {
        @InvocableVariable(label='JSON Doc' description='The JSON Doc to parse')
        public String jsonDoc;

        @InvocableVariable(label='Key/Value to Exract 1' description='The key used to extract the desired value')
        public String keyValue1;
    }

    global class JsonResponseVariables {
        @InvocableVariable(label='Json Value 1' description='Returns the first value specified from the JSON')
        public String jsonVal1;
    }
}