@isTest
global class WS_CreateCase_Mock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"codigo":"0","mensaje":"CAS-TEST"}');
        res.setStatusCode(200);
        return res;
    }
}