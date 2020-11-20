global class SiriusXMPlaylistBatch implements Database.Batchable<Sobject>, Database.AllowsCallouts {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, isActive__c, External_Id__c FROM Sirius_XM_Station__c WHERE isActive__c = true');
    }

    public void execute(Database.BatchableContext BC, List<Sirius_XM_Station__c> activeSiriusXmStationList){
        for (Sirius_XM_Station__c xmStation : activeSiriusXmStationList) {
            SiriusAppleService.syncPlaylists(xmStation.External_Id__c);
        }        
    }

    public void finish(Database.BatchableContext BC) {}
}
