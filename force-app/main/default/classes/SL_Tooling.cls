/**
 * tests: SL_Tooling_Test
 * */
public class SL_Tooling {
    
    private String baseUrl;
    private Boolean logRequests;
    
    public SL_Tooling(Integer apiVersion, boolean logRequests) {
        
        if(apiVersion == null) apiVersion = 43;
        this.logRequests = logRequests;
        if(logRequests == null) this.logRequests = false;
        //baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v' + apiVersion + '.0/tooling/';
        baseUrl = 'callout:FindChangerCred/services/data/v45.0/tooling/';
        
    }
    
    private HTTPRequest getReqByRelativePath (String relativePath, String method) {        
        
        if(relativePath.startsWith('/')) relativePath = relativePath.substring(1);
        return getReqByFullPath(baseUrl + relativePath, method);

    }
    
    private HTTPRequest getReqByFullPath(String fullPath, String method) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(fullPath);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        return req;

    }
        
    
    private HttpResponse execute(HTTPRequest req) {
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        if(logRequests) {
            System.debug('request >>>');
            System.debug(req.getEndpoint());
            System.debug(req.getBody());
        	System.debug('response >>>');
            System.debug(res.getBody());
        }
        
        return res;

    }
    
    public String query(String query) {
       
        HTTPRequest req =  getReqByRelativePath('query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'), 'GET');
        HttpResponse res = execute(req);
        if(res.getStatusCode() == 200) {
        	return res.getBody();    
        } else {            
        	throw new CalloutException(getErrorMessage(res.getBody()));    
        }

    }
    public String queryNextRecordsUrl(String nextRecordsUrl) {
        
        HTTPRequest req =  getReqByFullPath(URL.getSalesforceBaseUrl().toExternalForm() + nextRecordsUrl, 'GET');
        HttpResponse res = execute(req);
        if(res.getStatusCode() == 200) {
        	return res.getBody();    
        } else {            
        	throw new CalloutException(getErrorMessage(res.getBody()));    
        }

    }
    
    @testVisible
    private String getErrorMessage(String errorJSON) {
        
        if(errorJSON.startsWith('[')) {
            List<Object> aResponse = (List<Object>) JSON.deserializeUntyped(errorJSON);
            if(aResponse.size() > 0) {
                Map<String,Object> mapResponse = (Map<String, Object>) aResponse[0];
                if(mapResponse.containsKey('message')) return (String) mapResponse.get('message');                
                return '';
            }
            return '';
            
        } else if (errorJSON.startsWith('{')) {
            Map<String, Object> mapResonse = (Map<String, Object>) JSON.deserialize(errorJSON, Map<String, Object>.class);
            if(mapResonse.containsKey('message')) return (String) mapResonse.get('message');
            return '';
        }
        return '';
        
    }
        

}