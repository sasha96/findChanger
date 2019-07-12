/**
*  Class name  :   SL_ctrl_FindElement
*  Created by  :   Alex Zhurylo
*  Created on  :   5/17/2019
*  Description :   Apex class for SL_FindElement lightning web component
**/

public class SL_ctrl_FindElement {
    
    /*
    * @MethodName    :   getRecordCount
    * @Description   :   method return record count of the exact type
    * @param         :   type of element, search string
    * @return        :   return exact number of record for pagination
    * @example param :   typeOfElement = 'ApexClass', searchString = 'name of apex class'
    */
    @AuraEnabled(cacheable = true)  
    public static Integer getRecordCount(String typeOfElement, String searchString) {  
        
        SL_Tooling tooling = new SL_Tooling(45, true);
        String queryResult = '';
        switch on typeOfElement {
            when  'FlowDefinition', 'FieldSet', 'CustomField'{
                queryResult = tooling.query('SELECT Id, DeveloperName FROM ' + typeOfElement + ' WHERE DeveloperName LIKE \'%' + searchString + '%\'' );
            }
            when  'RecordType', 'Profile', 'WorkflowRule'{
                queryResult = tooling.query('SELECT Id, Name FROM ' + typeOfElement + ' WHERE Name LIKE \'%' + searchString + '%\'');
            }
            when  'CustomTab' {
                queryResult = tooling.query('SELECT Id, DeveloperName FROM ' + typeOfElement);
            }
            when  'PermissionSet' {
                queryResult = tooling.query('SELECT Id, Name FROM ' + typeOfElement + ' WHERE IsOwnedByProfile = false AND Name LIKE \'%' + searchString + '%\'');
            }
            when  'ValidationRule' {
                queryResult = tooling.query('SELECT Id, ValidationName FROM ' + typeOfElement + ' WHERE ValidationName LIKE \'%' + searchString + '%\'' );
            }
            when  'FlexiPage' {
                queryResult = tooling.query('SELECT Id FROM ' + typeOfElement  );
            }
            when else {
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
        }

        Map<String, Object> mapOfObjects = (Map<String, Object>) JSON.deserializeUntyped(queryResult);
        return (Integer) mapOfObjects.get('size');    
    }  

    /*
    * @MethodName    :   getRecordsListFirstTab
    * @Description   :   method find all records due to parameters and serialize it
    * @param         :   type of element, page number, page size, search string, selected item, is asc
    * @return        :   return List<RecordsWrapper> wrapper 
    * @example param :   typeOfElement = 'ApexClass', pagenumber=1, pageSize=2, searchString = 'name of apex class', selected item = 'Name', isAsc=false
    */
    @AuraEnabled(cacheable = true)  
    public static String getRecordsListFirstTab(String typeOfElement, Integer pagenumber, 
                                        Integer pageSize, String searchString,
                                        String selectedItem, Boolean isAsc) {  
        
        final String LIMITQUERY = ' LIMIT ' + pageSize + ' OFFSET ' + (pageSize * (pagenumber - 1));  
        
        SL_Tooling tooling = new SL_Tooling(45, true);

        String strAsc = '';
        if (isAsc) {
            strAsc = ' desc';
        } else {
            strAsc = ' asc';
        }

        switch on typeOfElement {
            when  'FlowDefinition' {
                return getListOfFlowAndBuilder(tooling, searchString, LIMITQUERY, selectedItem, strAsc);
            }
            when  'RecordType' {
                return getListOfRecordType(tooling, searchString, LIMITQUERY, selectedItem, strAsc);
            }
            when  'CustomTab' {
                return getListOfCustomTab(tooling, searchString, LIMITQUERY, selectedItem, strAsc);
            }      
            when  'PermissionSet' {
                return getListOfPermissionSet(tooling, searchString, LIMITQUERY, selectedItem, strAsc);
            }
            when 'Profile' {
                return getListOfProfiles(tooling, searchString, LIMITQUERY, selectedItem, strAsc);
            }
            when  'FieldSet' {
                return getListOfFieldSet(tooling, searchString, LIMITQUERY, selectedItem, strAsc);
            }
            when  'CustomField' {
                return getListOfCustomField(tooling, searchString, LIMITQUERY, selectedItem, strAsc);
            }
            when  'ValidationRule' {
                return getListofValidationRule(tooling, searchString, LIMITQUERY, selectedItem, strAsc);
            }
            when  'WorkflowRule' {
                return getListWorkFlow(tooling, searchString, LIMITQUERY, selectedItem, strAsc);
            }
            when 'FlexiPage'{
                return getListFlexiPages(tooling, searchString, LIMITQUERY, selectedItem, strAsc );
            }
            when else {

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
                                
                List<RecordsWrapper> wrapper = getWrapperOfRecods(typeOfElement, lstSearchResultsAfterSOQL, null);

                return JSON.serialize(wrapper) ;
            }
        }     
    } 
    
    /*
    * @MethodName    :   searchElementsWithoutChacheable
    * @Description   :   method to the same things as getRecordsListFirstTab but without caching
    * @param         :   type of element, page number, page size, search string, selected item, is asc
    * @return        :   return List<RecordsWrapper> wrapper 
    * @example param :   typeOfElement = 'ApexClass', pagenumber=1, pageSize=2, searchString = 'name of apex class', selected item = 'Name', isAsc=false
    */
    @AuraEnabled
    public static String searchElementsWithoutChacheable(String typeOfElement, Integer pagenumber, 
                                                            Integer pageSize, String searchString,
                                                            String selectedItem, Boolean isAsc){
        
        return getRecordsListFirstTab(typeOfElement, pagenumber, pageSize, searchString, selectedItem, isAsc);
    }

    /*
    * @MethodName    :   getAllPages
    * @Description   :   method return all records from custom metadata FindChangerOfPage__mdt
    * @param         :   type of element, page number, page size, search string, selected item, is asc
    * @return        :   return serialized List<String> records 
    */
    @AuraEnabled(cacheable = true)
    public static String getAllPages(){

        List<String> allPages = new List<String>();

        FindChangerOfPage__mdt[] listOfMetadataValue = [SELECT MasterLabel FROM FindChangerOfPage__mdt ORDER BY MasterLabel];

        for (FindChangerOfPage__mdt threatMapping : listOfMetadataValue) {
            allPages.add(threatMapping.MasterLabel);
        }

        return JSON.serialize(allPages);
    }

    /*
    * @MethodName    :   getAllDataDueToPage
    * @Description   :   methods return all fields sue to record from custom metadata, second tab
    * @param         :   name of page
    * @return        :   return  List<List<RecordsWrapper>> lstWrapper
    * @example param :   pageName = 'name of custom page'
    */
    @AuraEnabled
    public static String getAllDataDueToPage(String pageName, Date dataModified){
        
        List<String> allPages = new List<String>();
        
        FindChangerOfPage__mdt threatMapping = [SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, Apex_Trigger__c, Aura_Definition_Bundle__c , Apex_Page__c
                                           FROM FindChangerOfPage__mdt WHERE MasterLabel =: pageName LIMIT 1];
        
        String apexClassStr = threatMapping.Apex_Class__c;
        String apexComponentStr = threatMapping.Apex_Component__c;
        String apexTriggerStr = threatMapping.Apex_Trigger__c;
        String auraDefStr = threatMapping.Aura_Definition_Bundle__c;
        String auraApexPage = threatMapping.Apex_Page__c;
        
        List<String> lstApexClasses = parseListOfFiels(apexClassStr);
        List<String> lstApexComponents = parseListOfFiels(apexComponentStr);
        List<String> lstApexTriggers = parseListOfFiels(apexTriggerStr);
        List<String> lstAuraDefs = parseListOfFiels(auraDefStr);
        List<String> lstApexPage = parseListOfFiels(auraApexPage);

        Date lastChangeData = null;
        Date myDate2 = null;
        if( dataModified != null){
            lastChangeData = dataModified;
            myDate2 = lastChangeData.addDays(1);
        }
        List<RecordsWrapper> wrapperApexClass = findListOfRecordsIncludedInPage('ApexClass', lstApexClasses, lastChangeData, myDate2);
        List<RecordsWrapper> wrapperApexComponent = findListOfRecordsIncludedInPage('ApexComponent', lstApexComponents, lastChangeData, myDate2);
        List<RecordsWrapper> wrapperApexTrigger = findListOfRecordsIncludedInPage('ApexTrigger', lstApexTriggers, lastChangeData, myDate2);
        List<RecordsWrapper> wrapperAuraDef = findListOfRecordsIncludedInPage('AuraDefinitionBundle', lstAuraDefs, lastChangeData, myDate2);
        List<RecordsWrapper> wrapperApexPage = findListOfRecordsIncludedInPage('ApexPage', lstApexPage, lastChangeData, myDate2);
    
        List<List<RecordsWrapper>> lstWrapper = new List<List<RecordsWrapper>>();
        if(wrapperApexClass != null && wrapperApexClass.size() > 0){
            lstWrapper.add(wrapperApexClass);
        }
        if(wrapperApexComponent != null && wrapperApexComponent.size() > 0){
            lstWrapper.add(wrapperApexComponent);
        }
        if(wrapperApexTrigger != null && wrapperApexTrigger.size() > 0){
            lstWrapper.add(wrapperApexTrigger);
        }
        if(wrapperAuraDef != null && wrapperAuraDef.size() > 0){
            lstWrapper.add(wrapperAuraDef);
        }
        if(wrapperApexPage != null && wrapperApexPage.size() > 0){
            lstWrapper.add(wrapperApexPage);
        }
                
        return JSON.serialize(lstWrapper);
    }

    /*
    * @MethodName    :   getRecordOfMetadataForDebugg
    * @Description   :   method for metadata type and debug mode. Finds all records due to parameters and serialize it
    * @param         :   type of element, page number, page size, search string, selected item, is asc
    * @return        :   return List<RecordsWrapper> wrapper 
    * @example param :   typeOfElement = 'ApexClass', pagenumber=1, pageSize=2, searchString = 'name of apex class', selectedItem = 'Name', isAsc=false
    */
    @AuraEnabled
    public static String getRecordOfMetadataForDebugg(String typeOfElement, Integer pagenumber, 
                                                            Integer pageSize, String searchString,
                                                            String selectedItem, Boolean isAsc){
        
        FindChangerOfPage__mdt threatMapping =  Test.isRunningTest() ? (FindChangerOfPage__mdt) JSON.deserialize(jsonForTest, FindChangerOfPage__mdt.class) : [SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, 
                                                        Apex_Trigger__c, Aura_Definition_Bundle__c , Apex_Page__c, Record_Owner_Id__c
                                                        FROM FindChangerOfPage__mdt WHERE Record_Owner_Id__c =: UserInfo.getUserId() LIMIT 1];
        
        return getRecordsList(typeOfElement, pagenumber, pageSize, searchString, threatMapping, selectedItem, isAsc);
    }

    /*
    * @MethodName    :   createCustomMetadataRecord
    * @Description   :   method calls whenever user swithchs on debug mode button
                         Check if current user has own custom record in metadata return nothing, if no create new records 
    */
    @AuraEnabled 
    public static void createCustomMetadataRecord(){

        List<FindChangerOfPage__mdt> threatMapping = [SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, 
                                                        Apex_Trigger__c, Aura_Definition_Bundle__c , Apex_Page__c, Record_Owner_Id__c
                                                        FROM FindChangerOfPage__mdt WHERE Record_Owner_Id__c =: UserInfo.getUserId()];
                                          
        if(threatMapping.size() == 0){

            User usr = [SELECT FirstName, LastName FROM user WHERE id =: UserInfo.getUserId()];
                
            String fullNameSplit = 'FindChangerOfPage.' + usr.FirstName + usr.LastName;
            
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = fullNameSplit;
            customMetadata.label = fullNameSplit;

            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'Record_Owner_Id__c';
            customField.value = UserInfo.getUserId();
            customMetadata.values.add(customField);

            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            
            CustomMetadataCallback callback = new CustomMetadataCallback ();
            
            // Enqueue custom metadata deployment

            Id jobId = Test.isRunningTest() ? null : Metadata.Operations.enqueueDeployment(mdContainer, callback); 
        }
    }

    /*
    * @MethodName    :   changeRecordFromMetadata
    * @Description   :   method for metadata type and debug mode. Change existing record of metadata
    * @param         :   type of element, is new value, value
    * @example param :   typeOfElement = 'ApexClass', isNewValue='false', value='name of file/s'
    */
    @AuraEnabled
    public static void changeRecordFromMetadata(String typeOfElement, Boolean isNewValue, String value){
        
        FindChangerOfPage__mdt record = Test.isRunningTest() ? (FindChangerOfPage__mdt) JSON.deserialize(jsonForTest, FindChangerOfPage__mdt.class) : 
                                                [SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, 
                                                Apex_Trigger__c, Aura_Definition_Bundle__c , Apex_Page__c, Record_Owner_Id__c
                                                FROM FindChangerOfPage__mdt WHERE Record_Owner_Id__c =: UserInfo.getUserId() LIMIT 1];
        
        String apiNameOfField = '';
        String lstOfElements = '';
        List<String> lstElementsFromMetadata = new List<String>();

        if(typeOfElement == 'ApexClass'){
            lstOfElements = record.Apex_Class__c;
            apiNameOfField = 'Apex_Class__c';
        }else if(typeOfElement == 'ApexComponent'){
            lstOfElements = record.Apex_Component__c;
            apiNameOfField = 'Apex_Component__c';
        }
        else if(typeOfElement == 'ApexTrigger'){
            lstOfElements = record.Apex_Trigger__c;
            apiNameOfField = 'Apex_Trigger__c';
        }
        else if(typeOfElement == 'AuraDefinitionBundle'){
            lstOfElements = record.Aura_Definition_Bundle__c;
            apiNameOfField = 'Aura_Definition_Bundle__c';
        }
        else if(typeOfElement == 'ApexPage'){
            lstOfElements = record.Apex_Page__c;
            apiNameOfField = 'Apex_Page__c';
        }

        if(isNewValue){

            if(lstOfElements != '' && lstOfElements != null){
                lstOfElements += value + ',';
            }else{
                lstOfElements = value + ',';
            }

        }else{
            lstOfElements = lstOfElements.replace(value + ',', '');
        }
  
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = record.MasterLabel;
        customMetadata.label = record.MasterLabel;
        
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = apiNameOfField;
        customField.value = lstOfElements;
        customMetadata.values.add(customField);
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        
        CustomMetadataCallback  callback = new CustomMetadataCallback ();
        
        Id jobId = Test.isRunningTest() ? null : Metadata.Operations.enqueueDeployment(mdContainer, callback); 
    }
    
    /*
    * @MethodName    :   getRecordMetadataForSendMessage
    * @Description   :   method return send email option for current user
    */
    @AuraEnabled
    public static String getRecordMetadataForSendMessage(){
        FindChangerOfPage__mdt record =  Test.isRunningTest() ?  (FindChangerOfPage__mdt) JSON.deserialize(jsonForTest, FindChangerOfPage__mdt.class) : 
                                                [SELECT Send_email__c FROM FindChangerOfPage__mdt 
                                                WHERE Record_Owner_Id__c =: UserInfo.getUserId() LIMIT 1];
        return JSON.serialize(record.Send_email__c);
    }

    /*
    * @MethodName    :   updateRecordMetadataForSendMessage
    * @Description   :   method update sent email option for current user
    * @param         :   value
    * @example param :   value can be true or false
    */
    @AuraEnabled
    public static void updateRecordMetadataForSendMessage(Boolean value){
        FindChangerOfPage__mdt record =  Test.isRunningTest() ?  (FindChangerOfPage__mdt) JSON.deserialize(jsonForTest, FindChangerOfPage__mdt.class) : 
                                                [SELECT MasterLabel, Send_email__c FROM FindChangerOfPage__mdt 
                                                WHERE Record_Owner_Id__c =: UserInfo.getUserId() LIMIT 1];
        
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = record.MasterLabel;
        customMetadata.label = record.MasterLabel;
        
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'Send_email__c';
        customField.value = value;
        customMetadata.values.add(customField);
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        
        CustomMetadataCallback  callback = new CustomMetadataCallback ();
        
        Id jobId = Test.isRunningTest() ? null : Metadata.Operations.enqueueDeployment(mdContainer, callback);   
    }

    /*
    * @MethodName    :   getRecordsList
    * @Description   :   Finds all records due to parameters and serialize it
    * @param         :   type of element, page number, page size, search string, selected item, is asc
    * @return        :   return serialize List<RecordsWrapper> wrapper 
    * @example param :   typeOfElement = 'ApexClass', pagenumber=1, pageSize=2, searchString = 'name of apex class', record='metadata record',
                         selectedItem = 'Name', isAsc=false
    */
    @testVisible
    private static String getRecordsList(String typeOfElement, Integer pagenumber, 
                                        Integer pageSize, String searchString, FindChangerOfPage__mdt record, 
                                        String selectedItem, Boolean isAsc) {  
        
        final String LIMITQUERY = ' LIMIT ' + pageSize + ' OFFSET ' + (pageSize * (pagenumber - 1));  
        
        String strAsc = '';
        String orderBy = '';
        if (isAsc) {
            strAsc = ' desc';
        } else {
            strAsc = ' asc';
        }

        SL_Tooling tooling = new SL_Tooling(45, true);

        String REQUIRED_FIELDS = 'Id, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ';
        String query = '';

        if(typeOfElement == 'AuraDefinitionBundle'){
            query = 'SELECT DeveloperName, ' + REQUIRED_FIELDS + 
                    ' FROM ' +  typeOfElement + 
                    ' WHERE DeveloperName LIKE \'%'+ searchString  +'%\' ';
            if(selectedItem != '' && selectedItem != null && selectedItem != 'Name' && selectedItem != 'Title '){
                orderBy = selectedItem;
            }else{
                orderBy = 'DeveloperName';
            }
        }else{
            query = 'SELECT Name,' + REQUIRED_FIELDS + 
                    ' FROM ' +  typeOfElement + 
                    ' WHERE Name LIKE \'%'+ searchString  +'%\' ' ;
            if(selectedItem != '' && selectedItem != null){
                orderBy = selectedItem;
            }else{
                orderBy = 'Name';
            }
        }
        
        query += ' ORDER BY ' + orderBy +  strAsc;

        query += LIMITQUERY; 
        
        List<sObject> lstSearchResultsAfterSOQL = Database.query(query);              
        List<RecordsWrapper> wrapper = getWrapperOfRecods(typeOfElement, lstSearchResultsAfterSOQL, record);
        if(wrapper == null){
            return null; 
        }else{
            return JSON.serialize(wrapper);
        }        
    }

    /*
    * @MethodName    :   findListOfRecordsIncludedInPage
    * @Description   :   Finds all records included in page due to parameters and serialize it
    * @param         :   type of element, list of records
    * @return        :   return serialize List<RecordsWrapper> wrapper 
    * @example param :   typeOfElement = 'ApexClass', lstRecords='new List<String>()'
    */
    @testVisible
    private static List<RecordsWrapper> findListOfRecordsIncludedInPage(String typeOfElement, List<String> lstRecords, Date lastChangeData, Date myDate2){
        
        if(lstRecords.size() > 0){
            String REQUIRED_FIELDS = 'Id, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ';
            String query = '';
        
            if(typeOfElement == 'AuraDefinitionBundle'){
                query = 'SELECT DeveloperName, ' + REQUIRED_FIELDS + 
                            ' FROM ' +  typeOfElement + 
                            ' WHERE DeveloperName IN : lstRecords ' ; 
                           
                if(lastChangeData != null){
                    query += ' AND LastModifiedDate >= :lastChangeData AND LastModifiedDate <= :myDate2';
                }

                query +=  ' ORDER BY DeveloperName';
            }else{
                query = 'SELECT Name,' + REQUIRED_FIELDS + 
                        ' FROM ' +  typeOfElement + 
                        ' WHERE Name IN : lstRecords ';
                
                if(lastChangeData != null){
                    query += ' AND LastModifiedDate >= :lastChangeData AND LastModifiedDate <= :myDate2' ;
                }

                query +=  ' ORDER BY Name';
            }
            
            List<sObject> lstSearchResultsAfterSOQL = Database.query(query);
                                  
            List<RecordsWrapper> wrapper = getWrapperOfRecods(typeOfElement, lstSearchResultsAfterSOQL, null);

            return wrapper ;
        }else{
            return null;
        }
    } 

    /*
    * @MethodName    :   parseListOfFiels
    * @Description   :   method parse string and find elements
    * @param         :   string for parsing
    * @return        :   return List<String> lstResult
    * @example param :   strForParsing = 'ApexClass, test'
    */
    @testVisible
    private static List<String> parseListOfFiels(String strForParsing){
        
        List<String> lstResult = new List<String>();
        Boolean isTrue = true;
        while(isTrue && strForParsing != null){
            lstResult.add(strForParsing.substringBefore(','));
            if (strForParsing.contains(',') == false){
                isTrue = false;
            } else{
                strForParsing = strForParsing.substring(strForParsing.substringBefore(',').length() + 1);
            }
        }
        return lstResult;
    }

    /*
    * @MethodName    :   getWrapperOfRecods
    * @Description   :   method prepare wrapper of records
    * @param         :   type of element, list search results after SOQL, record
    * @return        :   return List<RecordsWrapper> wrapper
    * @example param :   typeOfElement = 'ApexClass', lstSearchResultsAfterSOQL = 'new List<sObject>()', record = 'record from custom metadata'
    */
    @testVisible
    private static List<RecordsWrapper> getWrapperOfRecods(String typeOfElement, List<sObject> lstSearchResultsAfterSOQL, FindChangerOfPage__mdt record){
        
        Map<String, Schema.SObjectField> mapAllobjectFields = Schema.getGlobalDescribe().get(typeOfElement).getDescribe().fields.getMap();
        Set<Id> lstLastModifiedById = new Set<Id>();
        Set<Id> lstCreatedById = new Set<Id>();
        for(String s : mapAllobjectFields.keySet()) {
            
            for (Integer i = 0; i < lstSearchResultsAfterSOQL.size(); i++) {
                sObject obj = lstSearchResultsAfterSOQL[i];

                if(mapAllobjectFields.get(s).getDescribe().getLocalName() == 'LastModifiedById'){
                    lstLastModifiedById.add((Id)obj.get(s));
                }else if(mapAllobjectFields.get(s).getDescribe().getLocalName() == 'CreatedById'){
                    lstCreatedById.add((Id)obj.get(s));
                }
            }
        }
        
        List<User> lstLastModifiedUser = [SELECT Id, Name FROM User WHERE Id IN : lstLastModifiedById];
        List<User> lstCreatedUser = [SELECT Id, Name FROM User WHERE Id IN : lstCreatedById];

        List<RecordsWrapper> wrapper = new List<RecordsWrapper>();
        
        List<String> lstElementsFromMetadata = new List<String>();

        String nameOfFieldToRetrieve = 'Name';

        if(record != null){    

            String lstOfElements = '';

            if(typeOfElement == 'ApexClass'){
                lstOfElements = record.Apex_Class__c;
            }else if(typeOfElement == 'ApexComponent'){
                lstOfElements = record.Apex_Component__c;
            }
            else if(typeOfElement == 'ApexTrigger'){
                lstOfElements = record.Apex_Trigger__c;
            }
            else if(typeOfElement == 'AuraDefinitionBundle'){
                lstOfElements = record.Aura_Definition_Bundle__c;
                nameOfFieldToRetrieve = 'DeveloperName';
            }
            else if(typeOfElement == 'ApexPage'){
                lstOfElements = record.Apex_Page__c;
            }

            if(lstOfElements != ''){
                
            }

            lstElementsFromMetadata = parseListOfFiels(lstOfElements);
            
        }

        for (Integer i = 0; i < lstSearchResultsAfterSOQL.size(); i++) {
            sObject modifiedLast ;
            sObject createdUser ;

            for (Integer k = 0; k < lstLastModifiedUser.size(); k++) {
                if(lstLastModifiedUser[k].Id == lstSearchResultsAfterSOQL[i].get('LastModifiedById')){
                    modifiedLast = lstLastModifiedUser[k];
                }
            }

            for (Integer j = 0; j < lstCreatedUser.size(); j++) {
                if(lstCreatedUser[j].Id == lstSearchResultsAfterSOQL[i].get('CreatedById')){
                    createdUser = lstCreatedUser[j];
                }
            }
            
            if(lstElementsFromMetadata.size() > 0){
                Boolean isChecked = false;
                for (Integer h = 0; h < lstElementsFromMetadata.size(); h++) {
                    if(lstElementsFromMetadata[h] == lstSearchResultsAfterSOQL[i].get(nameOfFieldToRetrieve)){
                        isChecked = true;
                    }
                }
                wrapper.add(new RecordsWrapper(lstSearchResultsAfterSOQL[i], modifiedLast, createdUser, typeOfElement, isChecked));
            }else{
                wrapper.add(new RecordsWrapper(lstSearchResultsAfterSOQL[i], modifiedLast, createdUser, typeOfElement));
            }

        }

        return wrapper;        
    }
    
    /*
    * @MethodName    :   getListWorkFlow
    * @Description   :   method return list of WorkFlow
    * @param         :   tooling, list search string, limit of records, selected item, str asc
    * @return        :   return String
    * @example param :   tooling, searchString = 'test', LIMITQUERY = 'limit 10', selectedItem = 'name', strAsc = 'id'
    */
    private static String getListWorkFlow(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {
		
        String queryString = 'SELECT Id, Name, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ' + 
                                        ' FROM WorkflowRule ' + 
                                        ' WHERE Name LIKE \'%' + searchString +'%\'' ;
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null ){
            orderBy = selectedItem;
        }else{
            orderBy = 'Name';
        }
        
        queryString += ' ORDER BY ' + orderBy +  strAsc + LIMITQUERY;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

    /*
    * @MethodName    :   getListofValidationRule
    * @Description   :   method return list of ValidationRule
    * @param         :   tooling, list search string, limit of records, selected item, str asc
    * @return        :   return String
    * @example param :   tooling, searchString = 'test', LIMITQUERY = 'limit 10', selectedItem = 'name', strAsc = 'id'
    */
    private static String getListofValidationRule(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {
        
        String queryString = 'SELECT Id, ValidationName, EntityDefinitionId, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ' + 
                                                ' FROM ValidationRule ' + 
                                                ' WHERE ValidationName LIKE \'%' + searchString +'%\'' ;
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null && selectedItem != 'Name' && selectedItem != 'Title '){
            orderBy = selectedItem;
        }else{
            orderBy = 'ValidationName';
        }
        
        queryString += ' ORDER BY ' + orderBy +  strAsc + LIMITQUERY;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

    /*
    * @MethodName    :   getListOfCustomField
    * @Description   :   method return list of CustomField
    * @param         :   tooling, list search string, limit of records, selected item, str asc
    * @return        :   return String
    * @example param :   tooling, searchString = 'test', LIMITQUERY = 'limit 10', selectedItem = 'name', strAsc = 'id'
    */
    private static String getListOfCustomField(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {
        
        String queryString = 'SELECT Id, DeveloperName, TableEnumOrId, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ' + 
                                                ' FROM CustomField ' + 
                                                ' WHERE DeveloperName LIKE \'%' + searchString +'%\'';
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null && selectedItem != 'Name' && selectedItem != 'Title '){
            orderBy = selectedItem;
        }else{
            orderBy = 'DeveloperName';
        }
        
        queryString += ' ORDER BY ' + orderBy +  strAsc + LIMITQUERY;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

    /*
    * @MethodName    :   getListOfFieldSet
    * @Description   :   method return list of FieldSet
    * @param         :   tooling, list search string, limit of records, selected item, str asc
    * @return        :   return String
    * @example param :   tooling, searchString = 'test', LIMITQUERY = 'limit 10', selectedItem = 'name', strAsc = 'id'
    */
    private static String getListOfFieldSet(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {
        
        String queryString = 'SELECT Id, DeveloperName, MasterLabel, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ' + 
                                                ' FROM FieldSet ' + 
                                                ' WHERE DeveloperName LIKE \'%' + searchString +'%\'' ;
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null && selectedItem != 'Name' && selectedItem != 'Title '){
            orderBy = selectedItem;
        }else{
            orderBy = 'DeveloperName';
        }
        
        queryString += ' ORDER BY ' + orderBy +  strAsc + LIMITQUERY;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

    /*
    * @MethodName    :   getListOfProfiles
    * @Description   :   method return list of Profiles
    * @param         :   tooling, list search string, limit of records, selected item, str asc
    * @return        :   return String
    * @example param :   tooling, searchString = 'test', LIMITQUERY = 'limit 10', selectedItem = 'name', strAsc = 'id'
    */
    private static String getListOfProfiles(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {
        
        String queryString = 'SELECT Id, Name, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById ' + 
                                                ' FROM Profile ' + 
                                                ' WHERE Name LIKE \'%' +  searchString + '%\'' ;
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null ){
            orderBy = selectedItem;
        }else{
            orderBy = 'Name';
        }
        
        queryString += ' ORDER BY ' + orderBy +  strAsc + LIMITQUERY;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

    /*
    * @MethodName    :   getListOfPermissionSet
    * @Description   :   method return list of PermissionSet
    * @param         :   tooling, list search string, limit of records, selected item, str asc
    * @return        :   return String
    * @example param :   tooling, searchString = 'test', LIMITQUERY = 'limit 10', selectedItem = 'name', strAsc = 'id'
    */
    private static String getListOfPermissionSet(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {
        
        String queryString = 'SELECT Id, Name, Label, IsCustom, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById ' +
                                                ' FROM PermissionSet ' + 
                                                ' WHERE IsOwnedByProfile = false AND Name LIKE \'%' + searchString + '%\'' ;
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null){
            orderBy = selectedItem;
        }else{
            orderBy = 'Name';
        }
        
        queryString += ' ORDER BY ' + orderBy +  strAsc + LIMITQUERY;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

    /*
    * @MethodName    :   getListOfCustomTab
    * @Description   :   method return list of CustomTab
    * @param         :   tooling, list search string, limit of records, selected item, str asc
    * @return        :   return String
    * @example param :   tooling, searchString = 'test', LIMITQUERY = 'limit 10', selectedItem = 'name', strAsc = 'id'
    */
    private static String getListOfCustomTab(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {
        
        String queryString = 'SELECT Id, MasterLabel, Type, DeveloperName, LastModifiedById,LastModifiedDate, CreatedDate, CreatedById ' + 
                                ' FROM CustomTab ' ;
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null && selectedItem != 'Name' && selectedItem != 'Title '){
            orderBy = selectedItem;
        }else{
            orderBy = 'DeveloperName';
        }
        
        queryString += ' ORDER BY ' + orderBy +  strAsc + LIMITQUERY;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

    /*
    * @MethodName    :   getListOfRecordType
    * @Description   :   method return list of RecordType
    * @param         :   tooling, list search string, limit of records, selected item, str asc
    * @return        :   return String
    * @example param :   tooling, searchString = 'test', LIMITQUERY = 'limit 10', selectedItem = 'name', strAsc = 'id'
    */
    private static String getListOfRecordType(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {
        
        String queryString = 'SELECT Id, Name, SobjectType, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById ' + 
                                                ' FROM RecordType' + 
                                                ' WHERE Name LIKE \'%' + searchString + '%\'' ;
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null){
            orderBy = selectedItem;
        }else{
            orderBy = 'Name';
        }
        
        queryString += ' ORDER BY ' + orderBy + strAsc + LIMITQUERY;
        String returnedResult = tooling.query(queryString);   
        return prepareMataData(returnedResult);
    } 

    /*
    * @MethodName    :   getListOfFlowAndBuilder
    * @Description   :   method return list of FlowAndBuilder
    * @param         :   tooling, list search string, limit of records, selected item, str asc
    * @return        :   return String
    * @example param :   tooling, searchString = 'test', LIMITQUERY = 'limit 10', selectedItem = 'name', strAsc = 'id'
    */
    private static String getListOfFlowAndBuilder(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {

        String queryString = 'SELECT Id, DeveloperName, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById '+
                                                ' FROM FlowDefinition ' + 
                                                ' WHERE DeveloperName LIKE \'%' + searchString +'%\'' ;
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null && selectedItem != 'Name' && selectedItem != 'Title '){
            orderBy = selectedItem;
        }else{
            orderBy = 'DeveloperName';
        }
        
        queryString += ' ORDER BY ' + orderBy +  strAsc + LIMITQUERY;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

    /*
    * @MethodName    :   getListFlexiPages
    * @Description   :   method return list of FlexiPages
    * @param         :   tooling, list search string, limit of records, selected item, str asc
    * @return        :   return String
    * @example param :   tooling, searchString = 'test', LIMITQUERY = 'limit 10', selectedItem = 'name', strAsc = 'id'
    */
    private static String getListFlexiPages(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {
        String queryString = 'SELECT Id, DeveloperName, LastModifiedDate, type, EntityDefinitionId '+
                                                ' FROM flexipage ' + 
                                                ' WHERE DeveloperName LIKE \'%' + searchString +'%\'' ;
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null && selectedItem != 'Name' && selectedItem != 'Title '){
            orderBy = selectedItem;
        }else{
            orderBy = 'DeveloperName';
        }
        
        queryString += ' ORDER BY ' + orderBy +  strAsc + LIMITQUERY;
        
        String returnedResult = tooling.query(queryString);   
       
        return prepareMataData(returnedResult);
    } 
    
    /*
    * @MethodName    :   prepareMataData
    * @Description   :   method parse metadata records
    * @param         :   returnedResult
    * @return        :   return String
    * @example param :   returnedResult='test'
    */
    private static String prepareMataData(String returnedResult){
        
        JSONParser parser = JSON.createParser(returnedResult);
        list<MetadataWrapper> listOfResults = new List<MetadataWrapper>();

        Set<Id> lstLastModifiedById = new Set<Id>();
        Set<Id> lstCreatedById = new Set<Id>();

        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        MetadataWrapper inv = (MetadataWrapper)parser.readValueAs(MetadataWrapper.class);
                        
                        listOfResults.add(inv);
                        lstLastModifiedById.add(inv.LastModifiedById);
                        lstCreatedById.add(inv.CreatedById);

                        parser.skipChildren();
                    }
                }
            }   
        }

        return organizeMatadata(lstLastModifiedById, lstCreatedById, listOfResults); 
    }

    /*
    * @MethodName    :   organizeMatadata
    * @Description   :   method create wrapper of metadata records
    * @param         :   lstLastModifiedById, lstCreatedById, lstWrapper 
    * @return        :   return serialized List<RecordsWrapper> wrapper
    * @example param :   lstLastModifiedById = new Set<id>(), lstCreatedById = new Set<id>(),  lstWrapper = new List<MetadataWrapper>()
    */
    private static String organizeMatadata(Set<Id> lstLastModifiedById, Set<Id> lstCreatedById, List<MetadataWrapper> lstWrapper ){
        
        List<User> lstLastModifiedUser = [SELECT Id, Name FROM User WHERE Id IN : lstLastModifiedById];
        List<User> lstCreatedUser = [SELECT Id, Name FROM User WHERE Id IN : lstCreatedById];

        List<RecordsWrapper> wrapper = new List<RecordsWrapper>();
        
        for (Integer i = 0; i < lstWrapper.size(); i++) {
            Object record = lstWrapper[i] ;
            sObject modifiedLast ;
            sObject createdUser ;

            for (Integer k = 0; k < lstLastModifiedUser.size(); k++) {
                if(lstLastModifiedUser[k].Id == lstWrapper[i].LastModifiedById){
                    modifiedLast = lstLastModifiedUser[k];
                }
            }

            for (Integer j = 0; j < lstCreatedUser.size(); j++) {
                if(lstCreatedUser[j].Id == lstWrapper[i].CreatedById){
                    createdUser = lstCreatedUser[j];
                }
            }

            wrapper.add(new RecordsWrapper(record, modifiedLast, createdUser));
        }
        
        return JSON.serialize(wrapper);
    }

    /*
    * @Class name    :   MetadataWrapper
    * @Description   :   Inner class for metadata
    */
    @testVisible
    public class MetadataWrapper {
        public String Id {get;set;}
        public String DeveloperName {get;set;}
        public String Name {get;set;}
        public Id LastModifiedById {get;set;}
        public Id CreatedById {get;set;}
        public DateTime LastModifiedDate {get;set;}
        public DateTime CreatedDate {get;set;}
        public String MasterLabel {get;set;}
        public String SobjectType {get;set;}
        public String Type {get;set;}
        public String Label {get;set;}
        public Boolean isCustom {get;set;}
        public String TableEnumOrId {get;set;}
        public String ValidationName {get;set;}
     
        @testVisible
        public MetadataWrapper(String id, String DeveloperName, String Name, String SobjectType, String MasterLabel,
                                String Type, String Label, String ValidationName, Boolean isCustomId, Id LastModifiedById, 
                                String TableEnumOrId, DateTime LastModifiedDate, DateTime CreatedDate, Id CreatedById) {
            this.id = id;
            this.DeveloperName = DeveloperName;
            this.Name = Name;
            this.LastModifiedById = LastModifiedById;
            this.LastModifiedDate = LastModifiedDate;
            this.CreatedDate = CreatedDate;
            this.CreatedById = CreatedById;
            this.SobjectType = SobjectType;
            this.MasterLabel = MasterLabel;
            this.Type = Type;
            this.Label = Label;
            this.isCustom = isCustom;
            this.TableEnumOrId = TableEnumOrId;
            this.ValidationName = ValidationName;
        }
    }  
    
    /*
    * @Class name    :   RecordsWrapper
    * @Description   :   Inner class for objects
    */
    @testVisible
    public class RecordsWrapper {
        public sObject record {get; set;}
		public sObject lastModifiedUser {get; set;}
        public sObject lastCrearedUser {get; set;}
        public Object recordForMetadata {get; set;}
        public String typeOfElement {get;set;}
        public Boolean isChecked {get; set;}

        public RecordsWrapper(sObject record, sObject lastModifiedUser, sObject lastCrearedUser, String typeOfElement) {  
            this.record = record;   
            this.lastModifiedUser = lastModifiedUser;
            this.lastCrearedUser = lastCrearedUser;
            this.typeOfElement = labelsAndValuesOfElementType.get(typeOfElement);
            this.isChecked = false;
        }

        public RecordsWrapper(Object recordForMetadata, sObject lastModifiedUser, sObject lastCrearedUser) {  
            this.recordForMetadata = recordForMetadata;   
            this.lastModifiedUser = lastModifiedUser;
            this.lastCrearedUser = lastCrearedUser;
        }

        public RecordsWrapper(sObject record, sObject lastModifiedUser, sObject lastCrearedUser, String typeOfElement, Boolean isChecked) {  
            this.record = record;   
            this.lastModifiedUser = lastModifiedUser;
            this.lastCrearedUser = lastCrearedUser;
            this.typeOfElement = labelsAndValuesOfElementType.get(typeOfElement);
            this.isChecked = isChecked;
        }
	}

    /*
    * @Description   :   labelsAndValuesOfElementType is map of Label and api name elements for debug mode
    */
    private final static Map <String, String> labelsAndValuesOfElementType = new Map <String, String>{  'ApexClass' => 'Apex Class',
                                                                                                        'ApexComponent' => 'Apex Component',
                                                                                                        'ApexTrigger' => 'Apex Trigger',
                                                                                                        'AuraDefinitionBundle' => 'Aura Definition Bundle',
                                                                                                        'ApexPage' => 'Apex Page'};

    /*
    * @Description   :   jsonForTest for testing tooling api
    */
    public final static String jsonForTest = '{"attributes":{"type":"FindChangerOfPage__mdt","url":"/services/data/v46.0/sobjects/FindChangerOfPage__mdt/m03f2000000oMluAAE"},'+
                                                '"MasterLabel":"FindChangerOfPage.AlexZhurylo","QualifiedApiName":"AlexZhurylo","Apex_Class__c":"AccountController,AccountUtils,SL_ctrl_FindElement,",'+
                                                '"Apex_Component__c":"SiteHeader,","Apex_Trigger__c":"SiteHeader,","Aura_Definition_Bundle__c":"SiteHeader,","Apex_Page__c":"SiteHeader,","Record_Owner_Id__c":"005f2000008fc9CAAQ","Id":"m03f2000000oMluAAE"}';
                                            

}