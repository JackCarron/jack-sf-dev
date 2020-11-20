public with sharing class SiriusAppleService {
    
    public static String playlistExistsInAppleMusic(String stationName) {
        String playlistId;
        Boolean morePlaylistsExists = true;
        String apiEndpoint = '/v1/me/library/playlists';
        Http http = new Http();

        while (morePlaylistsExists) {
            HttpRequest req = getHttpRequest(apiEndpoint);  
            req.setMethod('GET');        
            HTTPResponse res = http.send(req);
            SiriusAppleWrapper.AppleWrapper playlistResponse = (SiriusAppleWrapper.AppleWrapper) JSON.deserialize(res.getBody(), SiriusAppleWrapper.AppleWrapper.class); 

            for (SiriusAppleWrapper.ApplePlaylist playlist : playlistResponse.data) {
                if (playlist.attributes.name == stationName && playlist.attributes.canEdit == true && String.isNotBlank(playlist.id)) {
                    playlistId = playlist.id;
                    morePlaylistsExists = false;
                    break;
                }
            }
            
            if (String.isNotBlank(playlistResponse.next)) {
                apiEndpoint = playlistResponse.next;
            }
            else {
                morePlaylistsExists = false;
            }            
        }
        return playlistId;
    }

    public static string getPlaylistId(String stationName) {
        Http http = new Http();        
        String playlistId = playlistExistsInAppleMusic(stationName);
        if (String.isBlank(playlistId)) {
            SiriusAppleWrapper.ApplePlaylist applePlaylist = new SiriusAppleWrapper.ApplePlaylist();
            applePlaylist.attributes = new SiriusAppleWrapper.AppleAttribute();
            applePlaylist.attributes.name = stationName;
            String body = JSON.serialize(applePlaylist);
            HttpRequest req = getHttpRequest('/v1/me/library/playlists');            
            req.setBody(body);
            req.setMethod('POST');        
            HTTPResponse res = http.send(req);
            SiriusAppleWrapper.AppleWrapper playlistResponse = (SiriusAppleWrapper.AppleWrapper) JSON.deserialize(res.getBody(), SiriusAppleWrapper.AppleWrapper.class);
            if (playlistResponse.data[0].attributes.name == stationName && playlistResponse.data[0].attributes.canEdit == true && String.isNotBlank(playlistResponse.data[0].id)) {
                playlistId = playlistResponse.data[0].id;
            }
        }
        return playlistId;
    }

    // default apiEndpoint would be '/v1/me/library/playlists/' + playlistId + '/tracks'
    public static SiriusAppleWrapper.AppleWrapper getSongsInPlaylist(String stationName, String apiEndpoint, String playlistId) {
        Http http = new Http();
        SiriusAppleWrapper.AppleWrapper playlistResponse;        
        if (String.isNotBlank(playlistId)) {
            HttpRequest req = getHttpRequest(apiEndpoint);
            req.setMethod('GET');        
            HTTPResponse res = http.send(req);
            playlistResponse = (SiriusAppleWrapper.AppleWrapper) JSON.deserialize(res.getBody(), SiriusAppleWrapper.AppleWrapper.class);            
        }        
        return playlistResponse;
    }

    public static List<String> getAppleIdsFromSirius(String stationName) {
        List<SiriusXMWrapper.Song> songList = SiriusXMService.getStationSongs(stationName);
        List<String> appleCatalogIdList = SiriusXMService.getSiriusAppleIds(songList);
        return appleCatalogIdList;
    } 

    public static List<String> compareSiriusAppleTracks(String stationName) {
        List<String> newSiriusSongs = getAppleIdsFromSirius(stationName);
        Boolean morePlaylistSongsAvailable = true;
        String playlistId = getPlaylistId(stationName);  
        String apiEndpoint = '/v1/me/library/playlists/' + playlistId + '/tracks';
        SiriusAppleWrapper.AppleWrapper playlistResponse = new SiriusAppleWrapper.AppleWrapper();
        while (morePlaylistSongsAvailable) {
            playlistResponse = getSongsInPlaylist(stationName, apiEndpoint, playlistId);
            if (playlistResponse.data != null) {
                for (SiriusAppleWrapper.ApplePlaylist songWrapper : playlistResponse.data) {
                    if (songWrapper.attributes != null && 
                        songWrapper.attributes.playParams != null && 
                        songWrapper.attributes.playParams.catalogId != null) {
                        
                        String catId = songWrapper.attributes.playParams.catalogId;
                        // If Sirius Songs exist in the apple list then we are going to remove them
                        if (String.isNotBlank(catId)) {
                            if (newSiriusSongs.contains(catId)) {                            
                                newSiriusSongs.remove(newSiriusSongs.indexOf(catId));
                            }
                        }
                    }
                }
                System.debug(apiEndpoint);
                if (newSiriusSongs.isEmpty()) {
                    morePlaylistSongsAvailable = false;
                }
                else if (String.isNotBlank(playlistResponse.next)) {
                    apiEndpoint = playlistResponse.next;
                }
                else {
                    morePlaylistSongsAvailable = false;
                } 
            } else {
                morePlaylistSongsAvailable = false;
            }
        }

        return newSiriusSongs;
    }

    public static void syncPlaylists(String stationName) {
        Http http = new Http();
        List<String> newSongsToAddToApple = compareSiriusAppleTracks(stationName);        
        if (!newSongsToAddToApple.isEmpty()) {
            String playlistId = getPlaylistId(stationName);
            String apiEndpoint = '/v1/me/library/playlists/' + playlistId + '/tracks';
            HttpRequest req = getHttpRequest(apiEndpoint);
            req.setMethod('POST');
            req.setBody(createPlaylistBody(newSongsToAddToApple));
            HttpResponse res = http.send(req);
            System.debug(res.getStatusCode());
            System.debug(res.getBody());
            Database.insert(new Custom_Log__c(Name = stationName + ' | ' + res.getStatusCode() + ' | ' + Datetime.now()));            
        }
    }

    public static String createPlaylistBody(List<String> newSongsToAddToApple) {
        SiriusAppleWrapper.AppleWrapper appleWrapper = new SiriusAppleWrapper.AppleWrapper();
        appleWrapper.data = new List<SiriusAppleWrapper.ApplePlaylist>();
        SiriusAppleWrapper.ApplePlaylist songWrapper;
        for (String song : newSongsToAddToApple) {
            songWrapper = new SiriusAppleWrapper.ApplePlaylist();
            songWrapper.id = song;
            songWrapper.type = 'songs';
            appleWrapper.data.add(songWrapper);
        }
        return JSON.serialize(appleWrapper);
    }

    public static HttpRequest getHttpRequest(String apiEndpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://amp-api.music.apple.com' + apiEndpoint);
        req.setHeader('Cookie', 's_fid=136C6E6D2AF9690A-128F1DCBAF90E5A5; s_vi=[CS]v1|2FC8EB4C0515F2D7-60000B01B2E8A7DE[CE]; xp_ci=3z3FTSACzFyuz5UHzAZKzxSqwPjlc; xp_abc=17Eg4xa0; itua=US; media-user-token=Ass2Ppm4YWOAXTmnuqzO/LkotMWWjBHGomU/i9ls4Alfayi1NugKP9Ic0p76S2vV68ecJVDEOPCMbaw0Mq1XayXfAmTBrSJYuKqmiI25LYAI3L0ix2z+oY4/zRgtSEpOQIGEwlv/CIxjHvqrtAf0ZhzWdJLrqW2OgD/2NFwp8sccNbJi7jI6v2N2g3mdRB4kAR4SaKJCoV++TSAlWq4NXTHcAMTToqfHzgUBZ7BcZhHO9Uq82w==; pldfltcid=30afc35e44f74c71916a92cfb9f6ef93020; pltvcid=075bc69f6c3b41f8b226f42e1bc04022020; media-user-token=Ass2Ppm4YWOAXTmnuqzO/LkotMWWjBHGomU/i9ls4Alfayi1NugKP9Ic0p76S2vV68ecJVDEOPCMbaw0Mq1XayXfAmTBrSJYuKqmiI25LYAI3L0ix2z+oY4/zRgtSEpOQIGEwlv/CIxjHvqrtAf0ZhzWdJLrqW2OgD/2NFwp8sccNbJi7jI6v2N2g3mdRB4kAR4SaKJCoV++TSAlWq4NXTHcAMTToqfHzgUBZ7BcZhHO9Uq82w==; itua=us; itre=0; xp_ab=1#Jv0scgz+-2+7KGQkMc1#Zh4zkDd+-2+Utk2R3g0#isj11bm+-2+17Eg4xa0#yNFpB6B+-2+lrDZsLr1; geo=US; ccl=7WlUsG/4/lbh1AWCd8Sg2wxyW2ocRrDg6mIGwb4RG1+gaSJAuDUGAz59QFrNY950nYG0Zjt/gQs=; s_pathLength=no%20channel%3D1%2C; s_cc=true; s_sq=%5B%5BB%5D%5D; xp_cci=3z2PguZVz4Pgz4VMzBTfzngTGGdFY');
        req.setHeader('Authorization', 'Bearer ' + 'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlYlBsYXlLaWQifQ.eyJpc3MiOiJBTVBXZWJQbGF5IiwiaWF0IjoxNjA1MTU0MDIyLCJleHAiOjE2MjA3MDYwMjJ9.x3Ce-qBdWoMgj-k8Jwi_WdhPcA4Hwv0fsDJrfk6kGOgVMmCwk8BSmYSqnbhfg1ZB75olYsL84iTKvPZOckG2EA');
        return req;
    }
}
