global with sharing class SiriusAppleScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        SiriusXMPlaylistBatch batchable = new SiriusXMPlaylistBatch();
        Database.executeBatch(batchable, 1);
     }
}