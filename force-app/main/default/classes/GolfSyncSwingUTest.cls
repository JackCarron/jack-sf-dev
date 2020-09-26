/*
* Company: Jack's Personal Projects
* Date: 09/25/2020
* Author: Jack Carron
* Description: Test class covers all the Swing U ingestion 
               classes.
* History: Inspiration came from wanting to report on my own
*          golf data
*/
@isTest
public with sharing class GolfSyncSwingUTest {

    @TestSetup
    static void setup(){
        Player__c player = new Player__c(isActive__c = true,
                                         External_Id__c = '23797591');
        insert player;
    }

    @isTest
    static void testScheduler() {

        Test.setMock(HttpCalloutMock.class, new GolfSyncSwingUMock());

        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        String jobId = 
            System.schedule('GolfSyncSwingUScheduler',  
                            CRON_EXP, 
                            new GolfSyncSwingUScheduler());
                            CronTrigger ct = [SELECT Id,
                                              CronExpression,
                                              TimesTriggered,
                                              NextFireTime 
                                              FROM CronTrigger 
                                              WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }

    @isTest
    static void testSchedulerWithRoundAlreadyExisting() {
        Round__c round = new Round__c(External_Id__c = '38357624');
        insert round;

        Test.setMock(HttpCalloutMock.class, new GolfSyncSwingUMock());

        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        String jobId = 
            System.schedule('GolfSyncSwingUScheduler',  
                            CRON_EXP, 
                            new GolfSyncSwingUScheduler());
                            CronTrigger ct = [SELECT Id,
                                              CronExpression,
                                              TimesTriggered,
                                              NextFireTime 
                                              FROM CronTrigger 
                                              WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }

}