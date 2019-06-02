/**
*  Class name  :   SL_ctrl_FindElement_test
*  Created by  :   Alex Zhurylo
*  Created on  :   5/17/2019
*  Description :   Test class for SL_ctrl_FindElement
**/

@isTest
public  class SL_ctrl_FindElement_test {
    
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

    @isTest
    public static void test_getRecordCount(){

        String typeOfElement = 'ApexClass';
        String searchString = 'test'; 

        String query = 'SELECT COUNT() FROM ' + typeOfElement + ' WHERE Name like \'%' + searchString + '%\' ';  
      
        Integer expectedReultClass = Database.countQuery(query);  
        Integer returnedReultClass = SL_ctrl_FindElement.getRecordCount(typeOfElement, searchString);

        System.assertEquals(expectedReultClass, returnedReultClass);

        typeOfElement = 'AuraDefinitionBundle';

        query = 'SELECT COUNT() FROM ' + typeOfElement + ' WHERE DeveloperName like \'%' + searchString + '%\' ';  
      
        Integer expectedReultAura = Database.countQuery(query);  
        Integer returnedReultAura = SL_ctrl_FindElement.getRecordCount(typeOfElement, searchString);

        System.assertEquals(expectedReultAura, returnedReultAura);
    }


    private static String prepareExpectedREsult(String typeOfElement, Integer pagenumber, 
                                        Integer numberOfRecords, Integer pageSize, String searchString){

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

        query += ' limit ' + pageSize + ' offset ' + (pageSize * (pagenumber - 1));  

        List<sObject> lstSearchResultsAfterSOQL = Database.query(query);
                        
        List<SL_ctrl_FindElement.ListRecordsWrapper> wrapper = SL_ctrl_FindElement.findNameOfRecord(typeOfElement, lstSearchResultsAfterSOQL);

        return JSON.serialize(wrapper) ;
    }
}