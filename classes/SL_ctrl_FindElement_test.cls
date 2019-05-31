/**
*  Class name  :   SL_ctrl_FindElement_test
*  Created by  :   Alex Zhurylo
*  Created on  :   5/17/2019
*  Description :   Test class for SL_ctrl_FindElement
**/

@isTest
public  class SL_ctrl_FindElement_test {
    
    @isTest
    public static void searchElements_test() {

        String typeOfElement = 'ApexClass';
        String searchString = 'test'; 
        String limitOfRecords = '5';

        String expectedResultClasses = prepareExpectedREsult(typeOfElement, searchString, limitOfRecords); 
        String returnedResultClasses = SL_ctrl_FindElement.searchElements(typeOfElement, searchString, limitOfRecords);
        
        System.assertEquals(expectedResultClasses, returnedResultClasses);

        typeOfElement = 'AuraDefinitionBundle';
        
        String expectedResultAuraBundle = prepareExpectedREsult(typeOfElement, searchString, limitOfRecords);
        String returnedResultAura = SL_ctrl_FindElement.searchElements(typeOfElement, searchString, limitOfRecords);

        System.assertEquals(expectedResultAuraBundle, returnedResultAura);
        
        String emptyResult = SL_ctrl_FindElement.searchElements('', '', '');

        System.assertEquals(emptyResult, '');

    }


    private static String prepareExpectedREsult(String typeOfElement, String searchString, String limitOfRecords){

        String REQUIRED_FIELDS = 'Id, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById ';
   
        String soql = '';
        if(typeOfElement == 'AuraDefinitionBundle'){
            soql =  'SELECT DeveloperName, ' + REQUIRED_FIELDS + ' FROM ' +  typeOfElement + ' WHERE DeveloperName LIKE \'%'+ searchString  +'%\' ORDER BY DeveloperName LIMIT ' + limitOfRecords;
        }else{
            soql = 'SELECT Name,' + REQUIRED_FIELDS + ' FROM ' +  typeOfElement + ' WHERE Name LIKE \'%'+ searchString  +'%\' ORDER BY Name LIMIT ' +limitOfRecords;
        }
        
        List<sObject> lstSearchResultsAfterSOQL = Database.query(soql);
        
        map<Id, sObject> mapS = new Map<Id, SObject>();

        for (Integer i = 0; i < lstSearchResultsAfterSOQL.size(); i++) {
            mapS.put(lstSearchResultsAfterSOQL[i].Id, lstSearchResultsAfterSOQL[i]);
        }
        List<SL_ctrl_FindElement.ListRecordsWrapper> wrapper = SL_ctrl_FindElement.findNameOfRecord(typeOfElement, lstSearchResultsAfterSOQL);
        
        return JSON.serialize(wrapper) ;
    
    }
}