/**
*  Class name  :   SL_ctrl_FindElement
*  Created by  :   Alex Zhurylo
*  Created on  :   5/17/2019
*  Description :   Apex class for SL_FindElement lightnign web component
**/

public without sharing class SL_ctrl_FindElement {
   
   @AuraEnabled(cacheable=true)
   public static String searchElements(String typeOfElement, String searchString, String limitOfRecords){
        
        String REQUIRED_FIELDS = 'Id, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ';

        if(searchString != ''){     
            String soql = '';
            if(typeOfElement == 'AuraDefinitionBundle'){
                soql =  'SELECT DeveloperName, ' + REQUIRED_FIELDS + ' FROM ' +  typeOfElement + ' WHERE DeveloperName LIKE \'%'+ searchString  +'%\' ORDER BY DeveloperName LIMIT ' + limitOfRecords;
            }else{
                soql = 'SELECT Name,' + REQUIRED_FIELDS + ' FROM ' +  typeOfElement + ' WHERE Name LIKE \'%'+ searchString  +'%\' ORDER BY Name LIMIT ' +limitOfRecords;
            }
            
            List<sObject> lstSearchResultsAfterSOQL = Database.query(soql);
                        
            List<ListRecordsWrapper> wrapper = findNameOfRecord(typeOfElement, lstSearchResultsAfterSOQL);
            
            return JSON.serialize(wrapper) ;
        }else {
            return '';
        }
   }

    @AuraEnabled
    public static String searchElementsWithoutChacheable(String typeOfElement, String searchString, String limitOfRecords){
        return searchElements(typeOfElement, searchString, limitOfRecords);
    }

    public static List<ListRecordsWrapper> findNameOfRecord(String typeOfElement, List<sObject> lstSearchResultsAfterSOQL){
        
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

        List<ListRecordsWrapper> wrapper = new List<ListRecordsWrapper>();
        
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

            wrapper.add(new ListRecordsWrapper(lstSearchResultsAfterSOQL[i], modifiedLast, createdUser));
        }

        return wrapper;        
    }
    
    public class ListRecordsWrapper {
        public sObject record {get; set;}
		public sObject lastModifiedUser {get; set;}
        public sObject lastCrearedUser {get; set;}
   
        public ListRecordsWrapper(sObject record, sObject lastModifiedUser, sObject lastCrearedUser) {  
            this.record = record;   
            this.lastModifiedUser = lastModifiedUser;
            this.lastCrearedUser = lastCrearedUser;
        }
	}

}