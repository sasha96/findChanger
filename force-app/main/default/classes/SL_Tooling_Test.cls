@isTest
public class SL_Tooling_Test {
    
    @isTest
    static void test_query() {        
        SL_Tooling tooling = new SL_Tooling(43, true);
        Test.setMock(HttpCalloutMock.class, new MockQueryGenerator());
        String result = tooling.query('test query');
        System.assertNotEquals(null, result);
    }
    @isTest
    static void test_queryNextRecordsUrl() {        
        SL_Tooling tooling = new SL_Tooling(43, true);
        Test.setMock(HttpCalloutMock.class, new MockQueryGenerator());
        String result = tooling.queryNextRecordsUrl('test query');
        System.assertNotEquals(null, result);
    }
    
    public class MockQueryGenerator implements HttpCalloutMock {        
        public HTTPResponse respond(HTTPRequest req) {                     
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            Boolean done = false;
            if(req.getEndpoint().contains('query/01g')) done = true;
            String respBody = '{"size":398,"totalSize":398,"done":'+done+',"nextRecordsUrl":"/services/data/v43.0/tooling/query/01g1F00000BeHc5QAF-200",';
                respBody += '"queryLocator":"01g1F00000BeHc5QAF-200","entityTypeName":"AuraDefinition",';
                respBody += '"records":[{"attributes":{"type":"AuraDefinition","url":"/services/data/v43.0/tooling/sobjects/AuraDefinition/0Ad1O0000004ImXSAU"},';
                respBody += '"Id":"0Ad1O0000004ImXSAU","AuraDefinitionBundle":{"attributes":{"type":"AuraDefinitionBundle",';
                respBody += '"url":"/services/data/v43.0/tooling/sobjects/AuraDefinitionBundle/0Ab1O0000004DzeSAE"},';
                respBody += '"DeveloperName":"CircularChartWithVariousColors","Id":"0Ab1O0000004DzeSAE"},';
                respBody += '"DefType":"COMPONENT","Source":""},';
                respBody += '{"attributes":{"type":"AuraDefinition","url":"/services/data/v43.0/tooling/sobjects/AuraDefinition/0Ad1O000000TQPESA4"},';
                respBody += '"Id":"0Ad1O000000TQPESA4","AuraDefinitionBundle":{"attributes":{"type":"AuraDefinitionBundle",';
                respBody += '"url":"/services/data/v43.0/tooling/sobjects/AuraDefinitionBundle/0Ab1O000000TNRJSA4"},';
                respBody += '"DeveloperName":"cmpHomePageCustomLinks","Id":"0Ab1O000000TNRJSA4"},"DefType":"COMPONENT","Source":""}]}';
            res.setBody(respBody);
            res.setStatusCode(200);
            return res;
        }
    }

}