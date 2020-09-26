/*
* Company: Jack's Personal Projects
* Date: 09/25/2020
* Author: Jack Carron
* Description: Scheduler to sync golfer data from 
*              SwingU's APIS. Uses Service class for callouts.
*              Set's Courses, Holes, Rounds, RoundHoles data.
* History: Inspiration came from wanting to report on my own
*          golf data
*/

global with sharing class GolfSyncSwingUScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        GolfSyncSwingUIngestion.handleGolfInfo();
     }
}