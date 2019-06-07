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
                                        Integer numberOfRecords, Integer pageSize, String searchString) {  

        final String LIMITQUERY = ' LIMIT ' + pageSize + ' OFFSET ' + (pageSize * (pagenumber - 1));  
        
        SL_Tooling tooling = new SL_Tooling(45, true);

        switch on typeOfElement {
            when  'FlowDefinition' {
                return getListOfFlowAndBuilder(tooling, searchString, LIMITQUERY);
            }
            when  'RecordType' {
                return getListOfRecordType(tooling, searchString, LIMITQUERY);
            }
            when  'CustomTab' {
                return getListOfCustomTab(tooling, searchString, LIMITQUERY);
            }      
            when  'PermissionSet' {
                return getListOfPermissionSet(tooling, searchString, LIMITQUERY);
            }
            when 'Profile' {
                return getListOfProfiles(tooling, searchString, LIMITQUERY);
            }
            when  'FieldSet' {
                return getListOfFieldSet(tooling, searchString, LIMITQUERY);
            }
            when  'CustomField' {
                return getListOfCustomField(tooling, searchString, LIMITQUERY);
            }
            when  'ValidationRule' {
                return getListofValidationRule(tooling, searchString, LIMITQUERY);
            }
            when  'WorkflowRule' {
                return getListWorkFlow(tooling, searchString, LIMITQUERY);
            }
            when else {

                String REQUIRED_FIELDS = 'Id, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ';
                String query = '';

                if(typeOfElement == 'Dashboard'){
                    query = 'SELECT title, ' + REQUIRED_FIELDS + 
                            ' FROM ' +  typeOfElement + 
                            ' WHERE title LIKE \'%'+ searchString  +'%\' ' + 
                            ' ORDER BY title';
                }else if(typeOfElement == 'AuraDefinitionBundle' || typeOfElement == 'CustomPermission' || typeOfElement == 'CustomPermission'){
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
                                
                List<RecordsWrapper> wrapper = findNameOfRecord(typeOfElement, lstSearchResultsAfterSOQL);

                return JSON.serialize(wrapper) ;
            }
        }     
    } 

    @AuraEnabled
    public static String searchElementsWithoutChacheable(String typeOfElement, Integer pagenumber, 
                                                            Integer numberOfRecords, Integer pageSize, String searchString){
        return getRecordsList(typeOfElement, pagenumber, numberOfRecords, pageSize, searchString);
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

        FindChangerOfPage__mdt threatMapping = [SELECT MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, Apex_Trigger__c, Aura_Definition_Bundle__c 
                                           FROM FindChangerOfPage__mdt WHERE MasterLabel =: pageName LIMIT 1];
        
        String apexClassStr = threatMapping.Apex_Class__c;
        String apexComponentStr = threatMapping.Apex_Component__c;
        String apexTriggerStr = threatMapping.Apex_Trigger__c;
        String auraDefStr = threatMapping.Aura_Definition_Bundle__c;

        RecordDueToPageWrapper wrapper = new RecordDueToPageWrapper(threatMapping , parseListOfFiels(apexClassStr), parseListOfFiels(auraDefStr), parseListOfFiels(apexTriggerStr), parseListOfFiels(apexComponentStr) );
        return JSON.serialize(wrapper);
        
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

    private static List<RecordsWrapper> findNameOfRecord(String typeOfElement, List<sObject> lstSearchResultsAfterSOQL){
        
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

            wrapper.add(new RecordsWrapper(lstSearchResultsAfterSOQL[i], modifiedLast, createdUser));
        }

        return wrapper;        
    }
    
    private static String getListWorkFlow(SL_Tooling tooling, String searchString, String LIMITQUERY) {
		String returnedResult = tooling.query('SELECT Id, Name, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ' + 
                                        ' FROM WorkflowRule ' + 
                                        ' WHERE Name LIKE \'%' + searchString +'%\'' + 
                                        ' ORDER BY Name ' + LIMITQUERY);
        return prepareMataData(returnedResult);
    } 

    private static String getListofValidationRule(SL_Tooling tooling, String searchString, String LIMITQUERY) {
        String returnedResult = tooling.query('SELECT Id, ValidationName, EntityDefinitionId, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ' + 
                                                ' FROM ValidationRule ' + 
                                                ' WHERE ValidationName LIKE \'%' + searchString +'%\'' + 
                                                ' ORDER BY ValidationName ' + LIMITQUERY);
        return prepareMataData(returnedResult);
    } 

    private static String getListOfCustomField(SL_Tooling tooling, String searchString, String LIMITQUERY) {
        String returnedResult = tooling.query('SELECT Id, DeveloperName, TableEnumOrId, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ' + 
                                                ' FROM CustomField ' + 
                                                ' WHERE DeveloperName LIKE \'%' + searchString +'%\'' + 
                                                ' ORDER BY DeveloperName ' + LIMITQUERY);
        return prepareMataData(returnedResult);
    } 

    private static String getListOfFieldSet(SL_Tooling tooling, String searchString, String LIMITQUERY) {
        String returnedResult = tooling.query('SELECT Id, DeveloperName, MasterLabel, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ' + 
                                                ' FROM FieldSet ' + 
                                                ' WHERE DeveloperName LIKE \'%' + searchString +'%\'' + 
                                                ' ORDER BY DeveloperName' + LIMITQUERY);
        return prepareMataData(returnedResult);
    } 

    private static String getListOfProfiles(SL_Tooling tooling, String searchString, String LIMITQUERY) {
        String returnedResult = tooling.query('SELECT Id, Name, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById ' + 
                                                ' FROM Profile ' + 
                                                ' WHERE Name LIKE \'%' +  searchString + '%\'' + 
                                                ' ORDER BY Name ' + LIMITQUERY);
        return prepareMataData(returnedResult);
    } 

    private static String getListOfPermissionSet(SL_Tooling tooling, String searchString, String LIMITQUERY) {
        String returnedResult = tooling.query('SELECT Id, Name, Label, IsCustom, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById ' +
                                                ' FROM PermissionSet ' + 
                                                ' WHERE IsOwnedByProfile = false AND Name LIKE \'%' + searchString + '%\'' + 
                                                ' ORDER BY Name ' + LIMITQUERY);
        return prepareMataData(returnedResult);
    } 

    private static String getListOfCustomTab(SL_Tooling tooling, String searchString, String LIMITQUERY) {
        String returnedResult = tooling.query('SELECT Id, MasterLabel, Type, DeveloperName, LastModifiedById,LastModifiedDate, CreatedDate, CreatedById ' + 
                                                ' FROM CustomTab ' + 
                                                ' ORDER BY DeveloperName '+ LIMITQUERY);
        return prepareMataData(returnedResult);
    } 

    private static String getListOfRecordType(SL_Tooling tooling, String searchString, String LIMITQUERY) {
        String returnedResult = tooling.query('SELECT Id, Name, SobjectType, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById ' + 
                                                ' FROM RecordType' + 
                                                ' WHERE Name LIKE \'%' + searchString + '%\'' + 
                                                ' ORDER BY Name ' + LIMITQUERY);
        return prepareMataData(returnedResult);
    } 

    private static String getListOfFlowAndBuilder(SL_Tooling tooling, String searchString, String LIMITQUERY) {
        String returnedResult = tooling.query('SELECT Id, DeveloperName, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById '+
                                                ' FROM FlowDefinition ' + 
                                                ' WHERE DeveloperName LIKE \'%' + searchString +'%\'' + 
                                                ' ORDER by DeveloperName' + LIMITQUERY);
        return prepareMataData(returnedResult);
    } 

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

    private class MetadataWrapper {
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
            id = id;
            DeveloperName = DeveloperName;
            Name = Name;
            LastModifiedById = LastModifiedById;
            LastModifiedDate = LastModifiedDate;
            CreatedDate = CreatedDate;
            CreatedById = CreatedById;
            SobjectType = SobjectType;
            MasterLabel = MasterLabel;
            Type = Type;
            Label = Label;
            isCustom = isCustom;
            TableEnumOrId = TableEnumOrId;
            ValidationName = ValidationName;
        }

    }  
    
    private class RecordsWrapper {
        private sObject record {get; set;}
		private sObject lastModifiedUser {get; set;}
        private sObject lastCrearedUser {get; set;}
        private Object recordForMetadata {get; set;}

        private RecordsWrapper(sObject record, sObject lastModifiedUser, sObject lastCrearedUser) {  
            this.record = record;   
            this.lastModifiedUser = lastModifiedUser;
            this.lastCrearedUser = lastCrearedUser;
        }

        private RecordsWrapper(Object recordForMetadata, sObject lastModifiedUser, sObject lastCrearedUser) {  
            this.recordForMetadata = recordForMetadata;   
            this.lastModifiedUser = lastModifiedUser;
            this.lastCrearedUser = lastCrearedUser;
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
            mapApexClasses.put('Apex class', lstApexClasses);
            mapAura.put('Aura component', lstAura);
            mapApexTriggers.put('Apex trigger', lstApexTriggers);
            mapApexComponents.put('Apex component', lstApexComponents);
        }
	}

    /*
    Don't use now
    */
    public static string getlistOfCustomMetadataNames(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        List<String> lst = new List<String>();
        for(String objectName :gd.keySet()){
            Schema.SObjectType result = gd.get(objectName);
            String nameOfObject = result.getDescribe().getName();
            if(nameOfObject.contains('_mdt')){
                system.debug('***' + result.getDescribe()); 
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
    
}