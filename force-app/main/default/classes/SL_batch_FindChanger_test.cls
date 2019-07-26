/**
*  Test name   :   SL_batch_FindChanger_test
*  Created by  :   Alex Zhurylo
*  Created on  :   7/12/2019
*  Description :   test class for SL_batch_FindChanger
**/
@isTest
public class SL_batch_FindChanger_test {
   
    @isTest
    static void testBatch() {
        Test.StartTest();
		SL_batch_FindChanger testsche = new SL_batch_FindChanger();
		String sch = '0 0 23 * * ?';
		String jobId = system.schedule('Test status Check', sch, testsche );
        System.assert(jobId != null);
        Test.stopTest();
    }

}