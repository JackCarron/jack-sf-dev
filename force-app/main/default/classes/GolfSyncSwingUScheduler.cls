global with sharing class GolfSyncSwingUScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        GOLFSyncSwingUHandler handler = new GOLFSyncSwingUHandler();
        handler.handleGolfInfo();
     }
}
