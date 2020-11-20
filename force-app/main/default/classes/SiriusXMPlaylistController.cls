/*
* Company: Jack's Personal Projects
* Date: 09/25/2020
* Author: Jack Carron
* Description: Controller to for SiriusXM Playlist App
* History: Inspiration came from wanting better playlists
*/
public with sharing class SiriusXMPlaylistController {

    @AuraEnabled
    public static List<AggregateResult> getStationsHTML(){
        try {
            return [SELECT Sirius_XM_Station__r.Name, COUNT(Id) 
                    FROM Sirius_XM_Song__c 
                    WHERE is_Apple_Music_Synced__c = false 
                    AND Sirius_XM_Station__r.isActive__c = true
                    AND Apple_Id__c <> ''
                    GROUP By Sirius_XM_Station__r.Name];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}