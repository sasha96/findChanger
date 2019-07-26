/*
*  Batch name  :   SL_batch_FindChanger
*  Created by  :   Alex Zhurylo
*  Created on  :   7/12/2019
*  Description :   batch send emails for users who track their files
*/
global class SL_batch_FindChanger implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator( getQuery() );
    }

    global void execute(Database.BatchableContext bc, List<FindChangerOfPage__mdt> scope){
        
        List<FindChangerOfPage__mdt> newScope = new List<FindChangerOfPage__mdt>();
        
        for (Integer i = 0; i < scope.size(); i++) {
            if(scope[i].Send_email__c){
                newScope.add(scope[i]);
            }
        }
       
        Set<Id> userIds = new Set<Id>();
        List<String> recordNameList = new List<String>();

        Map<String, FindChangerOfPage__mdt> mapOfRecords = new Map<String, FindChangerOfPage__mdt>();

        for (Integer i = 0; i < newScope.size(); i++) {
            mapOfRecords.put(newScope[i].MasterLabel, newScope[i]);
            userIds.add(newScope[i].Record_Owner_Id__c);
            recordNameList.add(newScope[i].MasterLabel);
        }
        List<User> usersList = [SELECT id, Email, FirstName, LastName FROM User WHERE id IN : userIds];
        
        List<String> returnedSerializeStrings = new List<String>();
        Datetime dT = Datetime.now();
        Date myDate = Date.newinstance(dT.year(), dT.month(), dT.day());
        
        Map<String, String> mapOfNameAndValues = new Map<String, String>();
                
        for (Integer i = 0; i < recordNameList.size(); i++) {
        
            String element = SL_ctrl_FindElement.getAllDataDueToPage(recordNameList[i], myDate);
            if(element != '[]'){
                returnedSerializeStrings.add(element);
                mapOfNameAndValues.put(recordNameList[i], element);
            }

        }
        
        Map<String, List<List<SL_ctrl_FindElement.RecordsWrapper>>> finalMap = new Map<String, List<List<SL_ctrl_FindElement.RecordsWrapper>>>();
                
        for (Integer i = 0; i < returnedSerializeStrings.size(); i++) {
            List<List<SL_ctrl_FindElement.RecordsWrapper>> elemFinal = (List<List<SL_ctrl_FindElement.RecordsWrapper>> ) JSON.deserialize(returnedSerializeStrings[i], List<List<SL_ctrl_FindElement.RecordsWrapper>>.class);
            
            for (String item : mapOfNameAndValues.keyset()) {
                if(returnedSerializeStrings[i] == mapOfNameAndValues.get(item)){
                    finalMap.put(item, elemFinal);
                }
            }

        }

        EmailTemplate et = [SELECT Id, Subject, BrandTemplateId, HtmlValue, body FROM EmailTemplate where DeveloperName =: 'FindChanger'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        Map<Messaging.SingleEmailMessage, List<String>> mapEmailIdAndBodies = new Map<Messaging.SingleEmailMessage, List<String>>();
        for (String nameOfPage : finalMap.keySet()) {
            
            String contactId = '';
            String nameElemenets = '';
            String userName = '';
            String userEmail = '';
            String changeElements = '';
            
            for (String innerElem : mapOfRecords.keySet()) {
                
                if(innerElem == nameOfPage){
                    contactId = mapOfRecords.get(innerElem).Record_Owner_Id__c;
                    nameElemenets = mapOfRecords.get(innerElem).MasterLabel;
                }

            }
           
            if(contactId.length() == 18){
                contactId = contactId.substring(0, contactId.length()-3);
            }

            for (Integer i = 0; i < usersList.size(); i++) {
                
                String idRec = (String) usersList[i].get('id');
                idRec = idRec.substring(0,idRec.length()-3);
                if( idRec == contactId){
                    userName = (String) usersList[i].get('FirstName') + ' ' + (String) usersList[i].get('LastName');
                    userEmail = (String) usersList[i].get('email');
                    break;
                }

            }

            List<List<SL_ctrl_FindElement.RecordsWrapper>> onePageList = finalMap.get(nameOfPage);
            
            for (Integer k = 0; k < onePageList.size(); k++) {
                
                List<SL_ctrl_FindElement.RecordsWrapper> oneListOfElems = onePageList[k];
                
                for (Integer j = 0; j < oneListOfElems.size(); j++) {
                    
                    changeElements += oneListOfElems[j].typeOfElement + ' has been changed by ' + 
                                      oneListOfElems[j].lastModifiedUser.get('Name') + ' in ' + 
                                      oneListOfElems[j].record.get('LastModifiedDate') + '; ' +'<br/>';
                }
            }

            List<string> lstValues = new List<String>();
                lstValues.add(userName);
                lstValues.add(changeElements);
                lstValues.add(nameElemenets); 
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                singleMail.setTemplateId(et.Id);
                singleMail.setToAddresses(new list<string> {userEmail});
                singleMail.setUseSignature(false);
                singleMail.setSaveAsActivity(false);
                singleMail.setSenderDisplayName('Silverline ');
                singleMail.setTargetObjectId(UserInfo.getUserId());
            emails.add(singleMail);  
            mapEmailIdAndBodies.put(singleMail, lstValues) ; 
        }

        
        if(emails.size() > 0){
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(emails);
            Database.rollback(sp);
        }         

        for (Integer i = 0; i < emails.size(); i++) {
            String htmlBody = emails[i].getHTMLBody();
            List<String> returnedValues = new List<String>();
            for(Messaging.SingleEmailMessage idrecord : mapEmailIdAndBodies.keySet()){
                if(idrecord == emails[i]){
                    returnedValues = mapEmailIdAndBodies.get(idrecord);
                }
            }
           
            htmlBody = htmlBody.replace('contactName', returnedValues[0]);
            returnedValues[1] =  returnedValues[1].substring(0,returnedValues[1].length()-7);
            htmlBody = htmlBody.replace('nameOfMetadata', returnedValues[1]);
            htmlBody = htmlBody.replace('nameElemenets', ' ' + returnedValues[2]);
            emails[i].setHtmlBody(htmlBody);
        }

        if(emails.size() > 0){
            Messaging.sendEmail(emails);
        }


    }   

    global void finish(Database.BatchableContext bc){
    }    

    public void execute( SchedulableContext context ) {
        Database.executeBatch( this );
    }

    private String getQuery() {
        return  ' SELECT id, MasterLabel, QualifiedApiName, Apex_Class__c, Apex_Component__c, ' +
                ' Apex_Trigger__c, Aura_Definition_Bundle__c , Apex_Page__c, Record_Owner_Id__c, Send_email__c ' +
                ' FROM FindChangerOfPage__mdt ' ;
    }

}