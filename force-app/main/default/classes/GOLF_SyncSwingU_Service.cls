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
                GolfWrapper.Player swingUPlayer = (GolfWrapper.Player) JSON.deserialize(res.getBody(), GOLF_Wrapper.Player.class);
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

    public List<GolfWrapper.Player> getPlayerRoundList() {
        List<GolfWrapper.Player> swingUPlayerRoundList = new List<GolfWrapper.Player>();
        GolfWrapper.Player tempPlayer;
        for (Player__c player : SWINGU_PLAYER_LIST) {
            if (String.isNotBlank(player.External_Id__c)) {
                HttpResponse res = makeSwingUPlayerRoundCallout(player.External_Id__c);
                swingUPlayerRoundList.add((GolfWrapper.Player) JSON.deserialize(res.getBody(), GOLF_Wrapper.Player.class));
            }
        }
        return swingUPlayerRoundList;
    }

    public GolfWrapper.Round getRoundInfo(String roundId) {
        HttpResponse res = makeSwingURoundCallout(roundId);
        System.debug(res.getBody());
        GolfWrapper.Round swingUPlayerRound = (GolfWrapper.Round) JSON.deserialize(res.getBody(), GOLF_Wrapper.Round.class);
        System.debug(swingUPlayerRound);
        return swingUPlayerRound;
    }
}