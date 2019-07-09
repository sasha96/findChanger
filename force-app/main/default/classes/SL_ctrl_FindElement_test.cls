/**
*  Class name  :   SL_ctrl_FindElement_test
*  Created by  :   Alex Zhurylo
*  Created on  :   5/17/2019
*  Description :   Test class for SL_ctrl_FindElement
**/

@isTest
public  class SL_ctrl_FindElement_test {
    
    /*   init method
	* 1) Create User with Profile = 'System Admin'
	*/
    @TestSetup
    static void init(){
    
        Profile p = [SELECT id FROM Profile WHERE name='System Administrator'];
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

      
    /*   getRecordCount_test
	* 1) Create Mock class using MockQueryGenerator();
    * 2) Call getobjectSize to generate expected data and assign result to list ; 
    * 3) Create returned list and call getRecordCount, pass listElents;
    * 4) Compare both of list elements. Expected result => they are equal;
	*/
    @isTest
    public static void getRecordCount_test(){
        
        Test.startTest();
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
        Test.stopTest();
    }

    /*   getRecordsListFirstTab_test
    * 1) Create default parameters;
	* 2) Create two list: expected  and returned ;
    * 3) Create Mock class using MockQueryGenerator();
    * 4) Call getRecordsListFirstTab;
    * 5) Compare both of list elements. Expected result => they are equal;
	*/
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

    /*   searchElementsWithoutChacheable_test
    * 1) Create default parameters;
	* 2) Create two list: expected  and returned ;
    * 3) Call searchElementsWithoutChacheable;
    * 4) Compare both of list elements. Expected result => they are equal;
	*/
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

    /*   getAllPages_test
    * 1) Retutn all records from FindChangerOfPage__mdt metadata;
	* 2) Create two string: expected  and returned ;
    * 3) Call getAllPages;
    * 4) Compare both of strings. Expected result => they are equal;
	*/
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

    /*   createCustomMetadataRecord_test
    * 1) Retutn all records from FindChangerOfPage__mdt metadata where Record_Owner_Id__c = UserInfo.getUserId();
	* 2) List must has size more then 0;
    * 3) Call createCustomMetadataRecord;
	*/
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

    /*   getAllDataDueToPage_test
    * 1) Retutn 5 records from FindChangerOfPage__mdt;
	* 2) Create two list: expected  and returned ;
    * 3) Call getAllDataDueToPage;
    * 4) After call parseListOfFiels;
    * 5) After call findListOfRecordsIncludedInPage;
    * 6) Compare both of list elements. Expected result => they are equal;
	*/
    @isTest
    public static void getAllDataDueToPage_test(){
        
        list<FindChangerOfPage__mdt> threatMapping = [ SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, 
                                                        Apex_Trigger__c, Aura_Definition_Bundle__c , Apex_Page__c
                                                        FROM FindChangerOfPage__mdt LIMIT 5];
        
        List<String> lstReturnedResult = new List<String>();
        List<String> expectedResult = new List<String>();

        for (Integer i = 0; i < threatMapping.size(); i++) {
            lstReturnedResult.add(SL_ctrl_FindElement.getAllDataDueToPage(threatMapping[i].MasterLabel));    
              
            String apexClassStr = threatMapping[i].Apex_Class__c;
            String apexComponentStr = threatMapping[i].Apex_Component__c;
            String apexTriggerStr = threatMapping[i].Apex_Trigger__c;
            String auraDefStr = threatMapping[i].Aura_Definition_Bundle__c;
            String auraApexPage = threatMapping[i].Apex_Page__c;
            
            List<String> lstApexClasses = SL_ctrl_FindElement.parseListOfFiels(apexClassStr);
            List<String> lstApexComponents = SL_ctrl_FindElement.parseListOfFiels(apexComponentStr);
            List<String> lstApexTriggers = SL_ctrl_FindElement.parseListOfFiels(apexTriggerStr);
            List<String> lstAuraDefs = SL_ctrl_FindElement.parseListOfFiels(auraDefStr);
            List<String> lstApexPage = SL_ctrl_FindElement.parseListOfFiels(auraApexPage);
    
            List<SL_ctrl_FindElement.RecordsWrapper> wrapperApexClass = SL_ctrl_FindElement.findListOfRecordsIncludedInPage('ApexClass', lstApexClasses);
            List<SL_ctrl_FindElement.RecordsWrapper> wrapperApexComponent = SL_ctrl_FindElement.findListOfRecordsIncludedInPage('ApexComponent', lstApexComponents);
            List<SL_ctrl_FindElement.RecordsWrapper> wrapperApexTrigger = SL_ctrl_FindElement.findListOfRecordsIncludedInPage('ApexTrigger', lstApexTriggers); 
            List<SL_ctrl_FindElement.RecordsWrapper> wrapperAuraDef = SL_ctrl_FindElement.findListOfRecordsIncludedInPage('AuraDefinitionBundle', lstAuraDefs);
            List<SL_ctrl_FindElement.RecordsWrapper> wrapperApexPage = SL_ctrl_FindElement.findListOfRecordsIncludedInPage('ApexPage', lstApexPage);
      
            List<List<SL_ctrl_FindElement.RecordsWrapper>> lstWrapper = new List<List<SL_ctrl_FindElement.RecordsWrapper>>();
            lstWrapper.add(wrapperApexClass);
            lstWrapper.add(wrapperApexComponent);
            lstWrapper.add(wrapperApexTrigger);
            lstWrapper.add(wrapperAuraDef);
            lstWrapper.add(wrapperApexPage);
        
            expectedResult.add(JSON.serialize(lstWrapper));
        }

        for (Integer i = 0; i < lstReturnedResult.size(); i++) {
            System.assertEquals(lstReturnedResult[i], expectedResult[i]);    
        }
    }

    /*   changeRecordFromMetadata_test
    * 1) Retutn all records from FindChangerOfPage__mdt WHERE Record_Owner_Id__c =: UserInfo.getUserId();
	* 2) Run test for current user ;
    * 3) Call changeRecordFromMetadata;
	*/
    @isTest
    public static void changeRecordFromMetadata_test(){
        
        System.runAs(userId){
            Boolean isNewValue = false;
            String value = '';
            List<FindChangerOfPage__mdt> threatMapping = [SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, 
                                                            Apex_Trigger__c, Aura_Definition_Bundle__c , Apex_Page__c, Record_Owner_Id__c
                                                            FROM FindChangerOfPage__mdt WHERE Record_Owner_Id__c =: UserInfo.getUserId()];
            
            System.assertEquals(threatMapping.size(), 0);    
            for (Integer i = 0; i < lstObjectDebugMode.size(); i++) {
                if(i == lstObjectDebugMode.size() -1 ){
                    isNewValue = true;
                }
                SL_ctrl_FindElement.changeRecordFromMetadata(lstObjectDebugMode[i], isNewValue, value);
            } 
           
        }   
    }

    /*   getRecordOfMetadataForDebugg_test
    * 1) Create default parameters;
    * 2) Create two list: expected  and returned ;
    * 3) Call getRecordOfMetadataForDebugg and pass all required velues;
    * 4) Compare both of list elements. Expected result => they are equal;
	*/
    @isTest
    public static void getRecordOfMetadataForDebugg_test(){
        Integer pagenumber = 1;
        Integer numberOfRecords = 2; 
        Integer pageSize = 5;
        String searchString = 'a';
        String selectedItem = 'id';
        Boolean isAsc = true;

        List<String> returnedResult = new List<String>();
        List<String> expectedResult = new List<String>();
        for (Integer i = 0; i < lstObjectDebugMode.size(); i++) {
            returnedResult.add(SL_ctrl_FindElement.getRecordOfMetadataForDebugg(lstObjectDebugMode[i], pagenumber, pageSize,
                                                             searchString, selectedItem, isAsc ));
            SL_ctrl_FindElement.getRecordOfMetadataForDebugg(lstObjectDebugMode[i], pagenumber, pageSize,
                                                             searchString, '', false );
            expectedResult.add(SL_ctrl_FindElement.getRecordsList(lstObjectDebugMode[i], pagenumber, pageSize,
                                                             searchString, (FindChangerOfPage__mdt) JSON.deserialize(SL_ctrl_FindElement.jsonForTest, FindChangerOfPage__mdt.class),
                                                              selectedItem, isAsc ));                                                
        } 

        for (Integer i = 0; i < returnedResult.size(); i++) {
            System.assertEquals(expectedResult[i], returnedResult[i]);
        }
    }

    /*   MetadataWrapper_test
    * 1) Create default MetadataWrapper wrapper;
	*/
    @isTest
    public static void MetadataWrapper_test(){
        DateTime myDateTime = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
        
        SL_ctrl_FindElement.MetadataWrapper test= new SL_ctrl_FindElement.MetadataWrapper(
                                                    userId.id, 'test', 'test', 'test', 'test', 
                                                    'test', 'test', 'test', false, userId.id, 
                                                    'test', myDateTime, myDateTime, userId.id);
    }

    /*   getListRecordsFirstTab
    *    Method return list of records due to input parameters.
	*/
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

    /*   getListRecordsFirstTab
    *    Method return count of records due to input parameters.
	*/
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

    static User userId {
        
        get{
            if(userId == null){
                User urr = [SELECT id FROM User WHERE FirstName = 'First29' LIMIT 1];
                userId = urr;
            }
            return userId;
        } private set;
    }

    /*   MockQueryGenerator
    *    Mock class for testing tooling API
	*/
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
                respBody += '"url":"/services/data/v43.0/tooling/sobjects/AuraDefinitionBundle/0Ab1O0000004DzeSAE"},';
                respBody += '"DeveloperName":"CircularChartWithVariousColors","Id":"0Ab1O0000004DzeSAE"},';
                respBody += '"DefType":"COMPONENT","Source":""},';
                respBody += '{"attributes":{"type":"AuraDefinition","url":"/services/data/v43.0/tooling/sobjects/AuraDefinition/0Ad1O000000TQPESA4"},';
                respBody += '"Id":"0Ad1O000000TQPESA4", "CreatedById":"'+ userId.id + '","LastModifiedById":"'+ userId.id + '","AuraDefinitionBundle":{"attributes":{"type":"AuraDefinitionBundle",';
                respBody += '"url":"/services/data/v43.0/tooling/sobjects/AuraDefinitionBundle/0Ab1O000000TNRJSA4"},';
                respBody += '"DeveloperName":"cmpHomePageCustomLinks","Id":"0Ab1O000000TNRJSA4"},"DefType":"COMPONENT","Source":""}]}';
            res.setBody(respBody);
            res.setStatusCode(200);
            return res;
        }
    }

    private static List<String> lstMetadataElements = new List<String>{ 'FlowDefinition', 'FieldSet', 'CustomField', 'RecordType', 
                                                        'Profile', 'WorkflowRule','CustomTab', 'PermissionSet', 'ValidationRule', 
                                                        'FlexiPage' }; 
    
    private static List<String> lstObjectElements = new List<String>{ 'ApexClass', 'AuraDefinitionBundle', 'ApexPage', 'ApexComponent',  'StaticResource',
                                                        'ApexTrigger','AssignmentRule', 'CustomPermission', 'EmailTemplate', 'Report', 'Dashboard' }; 
    
    private static List<String> lstObjectDebugMode = new List<String>{ 'ApexClass', 'AuraDefinitionBundle', 'ApexPage', 'ApexComponent', 'ApexTrigger'}; 
}