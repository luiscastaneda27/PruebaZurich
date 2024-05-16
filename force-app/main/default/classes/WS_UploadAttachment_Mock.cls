@isTest
global class WS_UploadAttachment_Mock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"estado":"subido","errorMessage":null,"documentos":[{"urlDocumento":"url"}]}');
        res.setStatusCode(200);
        return res;
    }
}