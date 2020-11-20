global with sharing class SiriusAppleScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        SiriusXMService.appleMusicCalloutTest();
     }
}