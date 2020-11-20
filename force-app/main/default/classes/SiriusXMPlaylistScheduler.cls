global with sharing class SiriusXMPlaylistScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        SiriusXMPlaylistBatch batch = new SiriusXMPlaylistBatch();
        Database.executeBatch(batch, 1);
     }
}