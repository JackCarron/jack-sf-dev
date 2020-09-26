/*
* Company: Jack's Personal Projects
* Date: 09/25/2020
* Author: Jack Carron
* Description: Called by Scheduler to sync golfer data from 
*              SwingU's APIS. Uses Service class for callouts.
*              Set's Courses, Holes, Rounds, RoundHoles data.
* History: Inspiration came from wanting to report on my own
*          golf data
*/

public with sharing class GolfSyncSwingUService {
    List<Player__c> swingUPlayerList = new List<Player__c>();
    Http httpInstance = new Http();
    HttpRequest req = new HttpRequest();
    final String GET_METHOD = Label.GET_METHOD;
    final String SWINGU_URL = Label.SWINGU_URL;
    final String PLAYERS_ENDPOINT = Label.PLAYERS_ENDPOINT;
    final String PLAYER_ROUNDS_ENDPOINT = Label.PLAYER_ROUNDS_ENDPOINT;
    final String ROUND_ENDPOINT = Label.ROUND_ENDPOINT;

    public GolfSyncSwingUService(List<Player__c> swingUPlayerList) {
        this.swingUPlayerList = swingUPlayerList;
    }

    private HttpResponse makeSwingUPlayerCallout(String playerId) {
        req.setEndpoint(SWINGU_URL + PLAYERS_ENDPOINT + playerId);
        req.setMethod(GET_METHOD);
        return httpInstance.send(req);
    }

    public HttpResponse makeSwingUPlayerRoundCallout(String playerId) {
        req.setEndpoint(SWINGU_URL + PLAYER_ROUNDS_ENDPOINT + playerId);
        req.setMethod(GET_METHOD);        
        return httpInstance.send(req);
    }

    public HttpResponse makeSwingURoundCallout(String roundId) {
        req.setEndpoint(SWINGU_URL + ROUND_ENDPOINT + roundId);
        req.setMethod(GET_METHOD);        
        return httpInstance.send(req);
    }

    public List<GolfWrapper.Player> getPlayerRoundList() {
        List<GolfWrapper.Player> swingUPlayerRoundList = new List<GolfWrapper.Player>();
        GolfWrapper.Player tempPlayer;
        for (Player__c player : swingUPlayerList) {
            if (String.isNotBlank(player.External_Id__c)) {
                HttpResponse res = 
                    makeSwingUPlayerRoundCallout(player.External_Id__c);
                swingUPlayerRoundList.add((GolfWrapper.Player)
                                           JSON.deserialize(res.getBody(),
                                           GolfWrapper.Player.class));
            }
        }
        return swingUPlayerRoundList;
    }

    public GolfWrapper.Round getRoundInfo(String roundId) {
        HttpResponse res = makeSwingURoundCallout(roundId);
        GolfWrapper.Round swingUPlayerRound = 
            (GolfWrapper.Round) JSON.deserialize(res.getBody(), 
                                                 GolfWrapper.Round.class);
        return swingUPlayerRound;
    }
}