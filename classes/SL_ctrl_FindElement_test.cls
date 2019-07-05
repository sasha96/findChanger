/**
*  Class name  :   SL_ctrl_FindElement_test
*  Created by  :   Alex Zhurylo
*  Created on  :   5/17/2019
*  Description :   Test class for SL_ctrl_FindElement
**/

@isTest
public  class SL_ctrl_FindElement_test {
    private static List<String> lstMetadataElements = new List<String>{ 'FlowDefinition', 'FieldSet', 'CustomField', 'RecordType', 
                                                        'Profile', 'WorkflowRule','CustomTab', 'PermissionSet', 'ValidationRule', 
                                                        'FlexiPage' }; 
    private static List<String> lstObjectElements = new List<String>{ 'ApexClass', 'AuraDefinitionBundle', 'ApexPage', 'ApexComponent',  'StaticResource',
                                                        'ApexTrigger','AssignmentRule', 'CustomPermission', 'EmailTemplate', 'Report', 'Dashboard' }; 

    @isTest
    public static void getRecordCount_test(){
        
        Test.setMock(HttpCalloutMock.class, new MockQueryGenerator());

        for (Integer i = 0; i < lstMetadataElements.size(); i++) {
            integer result = SL_ctrl_FindElement.getRecordCount(lstMetadataElements[i], 'a');
            System.assertNotEquals(null, result);
        }
        
        List<Integer> lstObjectCountsReturned = new List<Integer>();
        List<Integer> lstObjectCountsExpected = new List<Integer>();

        for (Integer i = 0; i < lstObjectElements.size(); i++) {
            lstObjectCountsReturned.add(SL_ctrl_FindElement.getRecordCount(lstObjectElements[i], 'a'));
            lstObjectCountsExpected.add(getobjectSize(lstObjectElements[i], 'a'));
        }

        for (Integer i = 0; i < lstObjectCountsReturned.size(); i++) {
            System.assertEquals(lstObjectCountsReturned[i], lstObjectCountsExpected[i]);
        }

    }

    static User userId {
        
        get{
            if(userId == null){
                User urr = [SELECT id FROM User WHERE FirstName = 'First29' LIMIT 1];
                userId = urr;
            }
            return userId;
        } private set;
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
                respBody += '"Id":"0Ad1O0000004ImXSAU", "CreatedById":"'+ userId.id + '","LastModifiedById":"'+ userId.id + '","AuraDefinitionBundle":{"attributes":{"type":"AuraDefinitionBundle",';
                //respBody += '"Id":"0Ad1O0000004ImXSAU","AuraDefinitionBundle":{"attributes":{"type":"AuraDefinitionBundle",';
                respBody += '"url":"/services/data/v43.0/tooling/sobjects/AuraDefinitionBundle/0Ab1O0000004DzeSAE"},';
                respBody += '"DeveloperName":"CircularChartWithVariousColors","Id":"0Ab1O0000004DzeSAE"},';
                respBody += '"DefType":"COMPONENT","Source":""},';
                respBody += '{"attributes":{"type":"AuraDefinition","url":"/services/data/v43.0/tooling/sobjects/AuraDefinition/0Ad1O000000TQPESA4"},';
                respBody += '"Id":"0Ad1O000000TQPESA4", "CreatedById":"'+ userId.id + '","LastModifiedById":"'+ userId.id + '","AuraDefinitionBundle":{"attributes":{"type":"AuraDefinitionBundle",';
               // respBody += '"Id":"0Ad1O000000TQPESA4","AuraDefinitionBundle":{"attributes":{"type":"AuraDefinitionBundle",';
                respBody += '"url":"/services/data/v43.0/tooling/sobjects/AuraDefinitionBundle/0Ab1O000000TNRJSA4"},';
                respBody += '"DeveloperName":"cmpHomePageCustomLinks","Id":"0Ab1O000000TNRJSA4"},"DefType":"COMPONENT","Source":""}]}';
            res.setBody(respBody);
            res.setStatusCode(200);
            return res;
        }
    }

    private static Integer getobjectSize(String typeOfElement, String searchString){
        
        String query = 'SELECT COUNT() FROM ' + typeOfElement;

        if (searchString != null && searchString != '') {  
            if(typeOfElement == 'Dashboard'){
                query += ' WHERE title like \'%' + searchString + '%\' '; 
            }else if(typeOfElement == 'AuraDefinitionBundle' || typeOfElement == 'CustomPermission' || typeOfElement == 'CustomPermission'){
                query += ' WHERE DeveloperName like \'%' + searchString + '%\' ';  
            }else{
                query += ' WHERE Name like \'%' + searchString + '%\' ';  
            }
        }  
        return Database.countQuery(query);  
    }
    /*private static Integer getMetadataSize(String typeOfMetadata, String searchString){
        
        SL_Tooling tooling = new SL_Tooling(45, true);
        String query = '';

        switch on typeOfMetadata {
            when  'FlowDefinition', 'FieldSet', 'CustomField'{
                query = tooling.query('SELECT Id, DeveloperName FROM ' + typeOfMetadata + ' WHERE DeveloperName LIKE \'%' + searchString + '%\'' );
            }
            when  'RecordType', 'Profile', 'WorkflowRule'{
                query = tooling.query('SELECT Id, Name FROM ' + typeOfMetadata + ' WHERE Name LIKE \'%' + searchString + '%\'');
            }
            when  'CustomTab' {
                query = tooling.query('SELECT Id, DeveloperName FROM ' + typeOfMetadata);
            }
            when  'PermissionSet' {
                query = tooling.query('SELECT Id, Name FROM ' + typeOfMetadata + ' WHERE IsOwnedByProfile = false AND Name LIKE \'%' + searchString + '%\'');
            }
            when  'ValidationRule' {
                query = tooling.query('SELECT Id, ValidationName FROM ' + typeOfMetadata + ' WHERE ValidationName LIKE \'%' + searchString + '%\'' );
            }
            when  'FlexiPage' {
                query = tooling.query('SELECT Id FROM ' + typeOfMetadata  );
            }
        }

        Map<String, Object> mapOfObjects = (Map<String, Object>) JSON.deserializeUntyped(query);
        
        return (Integer) mapOfObjects.get('size'); 
    }*/


    @isTest
    public static void getRecordsListFirstTab_test(){
                    
            Integer pagenumber = 1;
            Integer numberOfRecords = 2; 
            Integer pageSize = 5;
            String searchString = 'a';
            String selectedItem ;
            Boolean isAsc = true;

            List<String> lstExpectedResultStrings = new List<String>();
            List<String> lstReturnedResultStrings = new List<String>();

            for (Integer i = 0; i < lstObjectElements.size(); i++) {
                selectedItem = 'id';
                lstExpectedResultStrings.add(getListRecordsFirstTab(lstObjectElements[i], pagenumber, pageSize, searchString,selectedItem, isAsc));
                lstReturnedResultStrings.add(SL_ctrl_FindElement.getRecordsListFirstTab(lstObjectElements[i], pagenumber, pageSize, searchString,selectedItem, isAsc));

                if(lstObjectElements[i] == 'Dashboard' || lstObjectElements[i] == 'AuraDefinitionBundle' || lstObjectElements[i] == 'ApexClass'){
                    selectedItem = '';
                    lstExpectedResultStrings.add(getListRecordsFirstTab(lstObjectElements[i], pagenumber, pageSize, searchString,selectedItem, isAsc));
                    lstReturnedResultStrings.add(SL_ctrl_FindElement.getRecordsListFirstTab(lstObjectElements[i], pagenumber, pageSize, searchString,selectedItem, isAsc));
                }
            }
            

            for (Integer i = 0; i < lstExpectedResultStrings.size(); i++) {
                System.assertEquals(lstExpectedResultStrings[i], lstReturnedResultStrings[i]);
            }

            isAsc = false;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockQueryGenerator());
            for (Integer i = 0; i < lstMetadataElements.size(); i++) {
                
                selectedItem = 'id';
                String result = SL_ctrl_FindElement.getRecordsListFirstTab(lstMetadataElements[i], pagenumber, pageSize, searchString,selectedItem, isAsc);
                System.assertNotEquals(null, result);
                
                selectedItem = '';
                String resultEmptyFilter = SL_ctrl_FindElement.getRecordsListFirstTab(lstMetadataElements[i], pagenumber, pageSize, searchString,selectedItem, isAsc);
                System.assertNotEquals(null, resultEmptyFilter);
            }
            Test.stopTest();
    }

    @isTest 
    public static void searchElementsWithoutChacheable_test(){
        Integer pagenumber = 1;
        Integer numberOfRecords = 2; 
        Integer pageSize = 5;
        String searchString = 'a';
        String selectedItem = 'id';
        Boolean isAsc = true;

        List<String> lstExpectedResultStrings = new List<String>();
        List<String> lstReturnedResultStrings = new List<String>();

        lstExpectedResultStrings.add(getListRecordsFirstTab(lstObjectElements[1], pagenumber, pageSize, searchString,selectedItem, isAsc));
        lstReturnedResultStrings.add(SL_ctrl_FindElement.searchElementsWithoutChacheable(lstObjectElements[1], pagenumber, pageSize, searchString,selectedItem, isAsc));

        for (Integer i = 0; i < lstExpectedResultStrings.size(); i++) {
            System.assertEquals(lstExpectedResultStrings[i], lstReturnedResultStrings[i]);
        }
    }

    @isTest
    public static void getAllPages_test(){
        
        List<String> allPages = new List<String>();

        FindChangerOfPage__mdt[] listOfMetadataValue = [SELECT MasterLabel FROM FindChangerOfPage__mdt ORDER BY MasterLabel];

        for (FindChangerOfPage__mdt threatMapping : listOfMetadataValue) {
            allPages.add(threatMapping.MasterLabel);
        }

        String expectedResult = JSON.serialize(allPages);
        String returnedResult = SL_ctrl_FindElement.getAllPages();
        
        System.assertEquals(expectedResult, returnedResult);
    }

    @isTest
    public static void createCustomMetadataRecord_test(){
        
        System.runAs(userId){
            List<FindChangerOfPage__mdt> threatMapping = [SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, 
                                                            Apex_Trigger__c, Aura_Definition_Bundle__c , Apex_Page__c, Record_Owner_Id__c
                                                            FROM FindChangerOfPage__mdt WHERE Record_Owner_Id__c =: UserInfo.getUserId()];
            
            System.assertEquals(threatMapping.size(), 0);    

            SL_ctrl_FindElement.createCustomMetadataRecord();
           
        }                         
    }

    @TestSetup
    static void init(){
    
        Profile p = [select id from Profile where name='System Administrator'];
        User userId = new User();
            userId.alias = 'utest';
            userId.email='Unit.Test@unittest.com';
            userId.emailencodingkey='UTF-8'; 
            userId.firstName='First29'; 
            userId.lastname='Last';
            userId.languagelocalekey='en_US';
            userId.localesidkey='en_US'; 
            userId.profileid = p.id;
            userId.timezonesidkey='Europe/London';
            userId.username='test29t@ukr.com';
        insert userId;
    
    }
    private static String getListRecordsFirstTab(String typeOfElement, Integer pagenumber, 
                                            Integer pageSize, String searchString,
                                            String selectedItem, Boolean isAsc){
        
        final String LIMITQUERY = ' LIMIT ' + pageSize + ' OFFSET ' + (pageSize * (pagenumber - 1));
        
        String strAsc = '';
        if (isAsc) {
            strAsc = ' desc';
        } else {
            strAsc = ' asc';
        }

        String REQUIRED_FIELDS = 'Id, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ';
        String query = '';
        String orderBy = '';
        if(typeOfElement == 'Dashboard'){
            query = 'SELECT title, ' + REQUIRED_FIELDS + 
                    ' FROM ' +  typeOfElement + 
                    ' WHERE title LIKE \'%'+ searchString  +'%\' ' ;
            if(selectedItem != '' && selectedItem != null && selectedItem != 'Name' && selectedItem != 'DeveloperName'){
                orderBy = selectedItem;
            }else{
                orderBy = 'title';
            }
            
            query += ' ORDER BY ' + orderBy +  strAsc;
        }else if(typeOfElement == 'AuraDefinitionBundle' || typeOfElement == 'CustomPermission' || typeOfElement == 'CustomPermission'){
            query = 'SELECT DeveloperName, ' + REQUIRED_FIELDS + 
                    ' FROM ' +  typeOfElement + 
                    ' WHERE DeveloperName LIKE \'%'+ searchString  +'%\' ' ;

            if(selectedItem != '' && selectedItem != null && selectedItem != 'Name' && selectedItem != 'Title '){
                orderBy = selectedItem;
            }else{
                orderBy = 'DeveloperName';
            }
            
            query += ' ORDER BY ' + orderBy +  strAsc;
        }else{
            query = 'SELECT Name,' + REQUIRED_FIELDS + 
                    ' FROM ' +  typeOfElement + 
                    ' WHERE Name LIKE \'%'+ searchString  +'%\' ' ;

            if(selectedItem != '' && selectedItem != null){
                orderBy = selectedItem;
            }else{
                orderBy = 'Name';
            }
            
            query += ' ORDER BY ' + orderBy +  strAsc;
        }

        query += LIMITQUERY; 
        
        List<sObject> lstSearchResultsAfterSOQL = Database.query(query);
                        
        List<SL_ctrl_FindElement.RecordsWrapper> wrapper = SL_ctrl_FindElement.getWrapperOfRecods(typeOfElement, lstSearchResultsAfterSOQL, null);

        return JSON.serialize(wrapper) ;                                        
    }

/*
    @isTest
    public static void getRecordsList_test() {

        String typeOfElement = 'ApexClass';
        Integer pagenumber = 1;
        Integer numberOfRecords = 10;
        Integer pageSize = 10;
        String searchString = 'test'; 

        String expectedResultClasses = prepareExpectedREsult(typeOfElement, pagenumber, numberOfRecords, pageSize, searchString); 
        String returnedResultClasses = SL_ctrl_FindElement.getRecordsList(typeOfElement, pagenumber, numberOfRecords, pageSize, searchString);
        
        System.assertEquals(expectedResultClasses, returnedResultClasses);

        typeOfElement = 'AuraDefinitionBundle';
        
        String expectedResultAuraBundle = prepareExpectedREsult(typeOfElement, pagenumber, numberOfRecords, pageSize, searchString);
        String returnedResultAura = SL_ctrl_FindElement.getRecordsList(typeOfElement, pagenumber, numberOfRecords, pageSize, searchString);

        System.assertEquals(expectedResultAuraBundle, returnedResultAura);
        
        String searchElementsWithoutChacheable = SL_ctrl_FindElement.searchElementsWithoutChacheable(typeOfElement, pagenumber, numberOfRecords, pageSize, searchString);
        
        System.assertEquals(searchElementsWithoutChacheable, expectedResultAuraBundle);
    }
*/
}