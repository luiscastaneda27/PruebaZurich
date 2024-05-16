@isTest
global class ZRH_BotonCotizador_MOCK implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','text/plain; charset=utf-8');
        res.setBody('testToken');
        res.setStatusCode(200);
        return res;
    }
}