/**
*  Class name  :   SL_ctrl_FindElement
*  Created by  :   Alex Zhurylo
*  Created on  :   5/17/2019
*  Description :   Apex class for SL_FindElement lightnign web component
**/

public class SL_ctrl_FindElement {

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

    @AuraEnabled(cacheable = true)  
    public static String getRecordsList(String typeOfElement, Integer pagenumber, 
                                        Integer numberOfRecords, Integer pageSize, String searchString,
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

    @AuraEnabled(cacheable = true)  
    public static String getRecordsList(String typeOfElement, Integer pagenumber, 
                                        Integer numberOfRecords, Integer pageSize, String searchString, FindChangerOfPage__mdt record ) {  

        final String LIMITQUERY = ' LIMIT ' + pageSize + ' OFFSET ' + (pageSize * (pagenumber - 1));  
        
        SL_Tooling tooling = new SL_Tooling(45, true);

        String REQUIRED_FIELDS = 'Id, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ';
        String query = '';

        if(typeOfElement == 'AuraDefinitionBundle'){
            query = 'SELECT DeveloperName, ' + REQUIRED_FIELDS + 
                    ' FROM ' +  typeOfElement + 
                    ' WHERE DeveloperName LIKE \'%'+ searchString  +'%\' ' + 
                    ' ORDER BY DeveloperName';
        }else{
            query = 'SELECT Name,' + REQUIRED_FIELDS + 
                    ' FROM ' +  typeOfElement + 
                    ' WHERE Name LIKE \'%'+ searchString  +'%\' ' + 
                    ' ORDER BY Name';
        }

        query += LIMITQUERY; 
        
        List<sObject> lstSearchResultsAfterSOQL = Database.query(query);              
        List<RecordsWrapper> wrapper = getWrapperOfRecods(typeOfElement, lstSearchResultsAfterSOQL, record);
        if(wrapper == null){
            return null; 
        }else{
            return JSON.serialize(wrapper);
        }
        

        //return JSON.serialize(wrapper) ;
   
    } 

    @AuraEnabled
    public static String searchElementsWithoutChacheable(String typeOfElement, Integer pagenumber, 
                                                            Integer numberOfRecords, Integer pageSize, String searchString){
        return getRecordsList(typeOfElement, pagenumber, numberOfRecords, pageSize, searchString, '', false);
    }

    @AuraEnabled(cacheable = true)
    public static String getAllPages(){

        List<String> allPages = new List<String>();

        FindChangerOfPage__mdt[] listOfMetadataValue = [SELECT MasterLabel FROM FindChangerOfPage__mdt ORDER BY MasterLabel];

        for (FindChangerOfPage__mdt threatMapping : listOfMetadataValue) {
            allPages.add(threatMapping.MasterLabel);
        }

        return JSON.serialize(allPages);
    }

    @AuraEnabled(cacheable = true)
    public static String getAllDataDueToPage(String pageName){
        
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
   
        List<RecordsWrapper> wrapperApexClass = findListOfRecordsIncludedInPage('ApexClass', lstApexClasses);
        List<RecordsWrapper> wrapperApexComponent = findListOfRecordsIncludedInPage('ApexComponent', lstApexComponents);
        List<RecordsWrapper> wrapperApexTrigger = findListOfRecordsIncludedInPage('ApexTrigger', lstApexTriggers); 
        List<RecordsWrapper> wrapperAuraDef = findListOfRecordsIncludedInPage('AuraDefinitionBundle', lstAuraDefs);
        List<RecordsWrapper> wrapperApexPage = findListOfRecordsIncludedInPage('ApexPage', lstApexPage);
    
        List<List<RecordsWrapper>> lstWrapper = new List<List<RecordsWrapper>>();
        lstWrapper.add(wrapperApexClass);
        lstWrapper.add(wrapperApexComponent);
        lstWrapper.add(wrapperApexTrigger);
        lstWrapper.add(wrapperAuraDef);
        lstWrapper.add(wrapperApexPage);
        
        return JSON.serialize(lstWrapper);
    }

    private static List<RecordsWrapper> findListOfRecordsIncludedInPage(String typeOfElement, List<String> lstRecords){
        
        if(lstRecords.size() > 0){
            String REQUIRED_FIELDS = 'Id, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ';
            String query = '';
        
            if(typeOfElement == 'AuraDefinitionBundle'){
                query = 'SELECT DeveloperName, ' + REQUIRED_FIELDS + 
                            ' FROM ' +  typeOfElement + 
                            ' WHERE DeveloperName IN : lstRecords ' + 
                            ' ORDER BY DeveloperName';
            }else{
                query = 'SELECT Name,' + REQUIRED_FIELDS + 
                        ' FROM ' +  typeOfElement + 
                        ' WHERE Name IN : lstRecords '+
                        ' ORDER BY Name';
            }
            
            List<sObject> lstSearchResultsAfterSOQL = Database.query(query);
                                  
            List<RecordsWrapper> wrapper = getWrapperOfRecods(typeOfElement, lstSearchResultsAfterSOQL, null);

            return wrapper ;
        }else{
            return null;
        }
    } 

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
            
            //return findListOfRecordsIncludedInPage(typeOfElement, lstElements);
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
    

    @AuraEnabled
    public static String getRecordOfMetadataForDebugg(String typeOfElement, Integer pagenumber, 
                                                            Integer numberOfRecords, Integer pageSize, String searchString){
        
        List<FindChangerOfPage__mdt> threatMapping = [SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, 
                                                Apex_Trigger__c, Aura_Definition_Bundle__c , Apex_Page__c, Record_Owner_Id__c
                                                FROM FindChangerOfPage__mdt WHERE Record_Owner_Id__c =: UserInfo.getUserId()];
        
        FindChangerOfPage__mdt record;

        if(threatMapping.size() > 0){
            record = threatMapping[0];
        } else {
            
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

            CustomMetadataCallback  callback = new CustomMetadataCallback ();

            // Enqueue custom metadata deployment
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback); 
            
            threatMapping = [SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, 
                                                Apex_Trigger__c, Aura_Definition_Bundle__c , Apex_Page__c, Record_Owner_Id__c
                                                FROM FindChangerOfPage__mdt WHERE Record_Owner_Id__c =: UserInfo.getUserId()];
            
            record = threatMapping[0];                       
        }
        
        return getRecordsList(typeOfElement, pagenumber, numberOfRecords, pageSize, searchString, record);


    }

    /* need to add logic for adding and removing new records in metadata due to user id */
    @AuraEnabled
    public static void changeRecordFromMetadata(String typeOfElement, Boolean isNewValue, String value){
         
        FindChangerOfPage__mdt record = [SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, 
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
        
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback); 

    }

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
        
        queryString += ' ORDER BY ' + orderBy +  strAsc;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

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
        
        queryString += ' ORDER BY ' + orderBy +  strAsc;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

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
        
        queryString += ' ORDER BY ' + orderBy +  strAsc;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

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
        
        queryString += ' ORDER BY ' + orderBy +  strAsc;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

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
        
        queryString += ' ORDER BY ' + orderBy +  strAsc;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

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
        
        queryString += ' ORDER BY ' + orderBy +  strAsc;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

    private static String getListOfCustomTab(SL_Tooling tooling, String searchString, String LIMITQUERY, String selectedItem, String strAsc) {
        String queryString = 'SELECT Id, MasterLabel, Type, DeveloperName, LastModifiedById,LastModifiedDate, CreatedDate, CreatedById ' + 
                                ' FROM CustomTab ' ;
        String orderBy = '';
        if(selectedItem != '' && selectedItem != null && selectedItem != 'Name' && selectedItem != 'Title '){
            orderBy = selectedItem;
        }else{
            orderBy = 'DeveloperName';
        }
        
        queryString += ' ORDER BY ' + orderBy +  strAsc;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

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
        
        queryString += ' ORDER BY ' + orderBy + strAsc;
        String returnedResult = tooling.query(queryString);   
        return prepareMataData(returnedResult);
    } 

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
        
        queryString += ' ORDER BY ' + orderBy +  strAsc;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 

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
        
        queryString += ' ORDER BY ' + orderBy +  strAsc;

        String returnedResult = tooling.query(queryString);   

        return prepareMataData(returnedResult);
    } 
    
    public static String prepareMataData(String returnedResult){
        
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

    public class MetadataWrapper {
        private String Id {get;set;}
        private String DeveloperName {get;set;}
        private String Name {get;set;}
        private Id LastModifiedById {get;set;}
        private Id CreatedById {get;set;}
        private DateTime LastModifiedDate {get;set;}
        private DateTime CreatedDate {get;set;}
        private String MasterLabel {get;set;}
        private String SobjectType {get;set;}
        private String Type {get;set;}
        private String Label {get;set;}
        private Boolean isCustom {get;set;}
        private String TableEnumOrId {get;set;}
        private String ValidationName {get;set;}

        private MetadataWrapper(String id, String DeveloperName, String Name, String SobjectType, String MasterLabel,
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
    
    private class RecordsWrapper {
        private sObject record {get; set;}
		private sObject lastModifiedUser {get; set;}
        private sObject lastCrearedUser {get; set;}
        private Object recordForMetadata {get; set;}
        private String typeOfElement {get;set;}
        private Boolean isChecked {get; set;}

        private RecordsWrapper(sObject record, sObject lastModifiedUser, sObject lastCrearedUser, String typeOfElement) {  
            this.record = record;   
            this.lastModifiedUser = lastModifiedUser;
            this.lastCrearedUser = lastCrearedUser;
            this.typeOfElement = labelsAndValuesOfElementType.get(typeOfElement);
            this.isChecked = false;
        }

        private RecordsWrapper(Object recordForMetadata, sObject lastModifiedUser, sObject lastCrearedUser) {  
            this.recordForMetadata = recordForMetadata;   
            this.lastModifiedUser = lastModifiedUser;
            this.lastCrearedUser = lastCrearedUser;
        }

        private RecordsWrapper(sObject record, sObject lastModifiedUser, sObject lastCrearedUser, String typeOfElement, Boolean isChecked) {  
            this.record = record;   
            this.lastModifiedUser = lastModifiedUser;
            this.lastCrearedUser = lastCrearedUser;
            this.typeOfElement = labelsAndValuesOfElementType.get(typeOfElement);
            this.isChecked = isChecked;
        }
	}

    private class RecordDueToPageWrapper {
        private sObject record {get; set;}
		private Map<String, List<String>> mapApexClasses = new Map<String, List<String>>();
        private Map<String, List<String>> mapAura = new Map<String, List<String>>();
        private Map<String, List<String>> mapApexTriggers = new Map<String, List<String>>();
        private Map<String, List<String>> mapApexComponents = new Map<String, List<String>>();

        private RecordDueToPageWrapper(sObject record, List<String> lstApexClasses, List<String> lstAura, List<String> lstApexTriggers, List<String> lstApexComponents ) {  
            this.record = record;   
            this.mapApexClasses.put('Apex class', lstApexClasses);
            this.mapAura.put('Aura component', lstAura);
            this.mapApexTriggers.put('Apex trigger', lstApexTriggers);
            this.mapApexComponents.put('Apex component', lstApexComponents);
        }
	}

    private final static Map <String, String> labelsAndValuesOfElementType = new Map <String, String>{  'ApexClass' => 'Apex Class',
                                                                                                        'ApexComponent' => 'Apex Component',
                                                                                                        'ApexTrigger' => 'Apex Trigger',
                                                                                                        'AuraDefinitionBundle' => 'Aura Definition Bundle',
                                                                                                        'ApexPage' => 'Apex Page'};



   
    /*
    Don't use now
    
    public static string getlistOfCustomMetadataNames(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        List<String> lst = new List<String>();
        for(String objectName :gd.keySet()){
            Schema.SObjectType result = gd.get(objectName);
            String nameOfObject = result.getDescribe().getName();
            if(nameOfObject.contains('_mdt')){
                lst.add(result.getDescribe().getName());
            }
        }  
        return JSON.serialize(lst);
    }

    public static String getListOfCustomObject() {
        SL_Tooling tooling = new SL_Tooling(45, true);
        String result = tooling.query('SELECT Id, DeveloperName, ExternalName, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById FROM CustomObject ORDER BY DeveloperName');
        JSONParser parser = JSON.createParser(result);
        list<CustomObjectWrapper> listOfResults = new List<CustomObjectWrapper>();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        CustomObjectWrapper inv = (CustomObjectWrapper)parser.readValueAs(CustomObjectWrapper.class);
                        listOfResults.add(inv);
                        parser.skipChildren();
                    }
                }
            }
        }
        return JSON.serialize(listOfResults) ;
    } 

    public class CustomObjectWrapper {
      
        public String id;
        public String DeveloperName;
        public String ExternalName;
        public Id LastModifiedById;
        public Id CreatedById;
        public DateTime LastModifiedDate;
        public DateTime CreatedDate;
        
        public CustomObjectWrapper(String id, String DeveloperName, String ExternalName, Id LastModifiedById, DateTime LastModifiedDate, DateTime CreatedDate, Id CreatedById) {
            id = id;
            DeveloperName = DeveloperName;
            ExternalName = ExternalName;
            LastModifiedById = LastModifiedById;
            LastModifiedDate = LastModifiedDate;
            CreatedDate = CreatedDate;
            CreatedById = CreatedById;
        }
    } 
    */
}