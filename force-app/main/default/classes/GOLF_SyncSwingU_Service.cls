public with sharing class GOLF_SyncSwingU_Service {
    List<Player__c> SWINGU_PLAYER_LIST = new List<Player__c>();
    Http httpInstance = new Http();
    HttpRequest req = new HttpRequest();

    public GOLF_SyncSwingU_Service(List<Player__c> swingUPlayerList) {
        SWINGU_PLAYER_LIST = swingUPlayerList;
    }

    // Must use constructor to set player ids
    public List<Player__c> setPlayersInfo() {
        for (Player__c player : SWINGU_PLAYER_LIST) {
            if (String.isNotBlank(player.External_Id__c)) {
                HttpResponse res = makeSwingUPlayerCallout(player.External_Id__c);
                Golf_Wrapper.Player swingUPlayer = (GOLF_Wrapper.Player) JSON.deserialize(res.getBody(), GOLF_Wrapper.Player.class);
                player.Handicap__c = swingUPlayer.handicap;
            }
        }
        update SWINGU_PLAYER_LIST;
        return SWINGU_PLAYER_LIST;
    }

    private HttpResponse makeSwingUPlayerCallout(String playerId) {
        req.setEndpoint('https://api.swingu.com/v1/players/' + playerId);
        req.setMethod('GET');
        return httpInstance.send(req);
    }

    public HttpResponse makeSwingUPlayerRoundCallout(String playerId) {
        req.setEndpoint('https://api.swingu.com/v1/rounds?playerid=' + playerId);
        req.setMethod('GET');        
        return httpInstance.send(req);
    }

    public HttpResponse makeSwingURoundCallout(String roundId) {
        req.setEndpoint('https://api.swingu.com/v1/rounds/' + roundId);
        req.setMethod('GET');        
        return httpInstance.send(req);
    }

    public List<Golf_Wrapper.Player> getPlayerRoundList() {
        List<Golf_Wrapper.Player> swingUPlayerRoundList = new List<Golf_Wrapper.Player>();
        Golf_Wrapper.Player tempPlayer;
        for (Player__c player : SWINGU_PLAYER_LIST) {
            if (String.isNotBlank(player.External_Id__c)) {
                HttpResponse res = makeSwingUPlayerRoundCallout(player.External_Id__c);
                swingUPlayerRoundList.add((GOLF_Wrapper.Player) JSON.deserialize(res.getBody(), GOLF_Wrapper.Player.class));
            }
        }
        return swingUPlayerRoundList;
    }

    public Golf_Wrapper.Round getRoundInfo(String roundId) {
        HttpResponse res = makeSwingURoundCallout(roundId);
        GOLF_Wrapper.Round swingUPlayerRound = (GOLF_Wrapper.Round) JSON.deserialize(res.getBody(), GOLF_Wrapper.Round.class);
        System.debug(swingUPlayerRound);
        return swingUPlayerRound;
    }
}
