public with sharing class SiriusXMService {    

    public static void syncStations() {
        // HTTP Request: GET Station HTML
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://xmplaylist.com/station');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);

        // Split HTML by every station & Initalize Vars
        List<String> stringList = res.getBody().split('<a href="/station/');
        List<Sirius_XM_Station__c> stationList = new List<Sirius_XM_Station__c>();
        String stationName;

        // Starting at 1 because we don't want the first index
        for (Integer i = 1; i < stringList.size(); i++) {
            stationName = stringList[i].split('">')[0];
            stationList.add(new Sirius_XM_Station__c(Name = stationName,
                                            External_Id__c = stationName));
        }

        // Create new Stations if they don't already exists
        Database.upsert(stationList, Sirius_XM_Station__c.Fields.External_Id__c, false);
    }

    // @future(callout=true)
    public static List<SiriusXMWrapper.Song> getStationSongs(String stationName) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://xmplaylist.com/api/station/' + stationName);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return (List<SiriusXMWrapper.Song>) JSON.deserialize(res.getBody(), List<SiriusXMWrapper.Song>.class);        
    }

    public static void createUniqueSongRecords(String stationName, List<SiriusXMWrapper.Song> songWrapperList) {
        List<Sirius_XM_Song__c> songList = new List<Sirius_XM_Song__c>();
        List<Artist__c> artistList = new List<Artist__c>();
        List<Website__c> websiteList = new List<Website__c>();
        Sirius_XM_Song__c song;
        Artist__c artist;
        Website__c website;
        List<Sirius_XM_Station__c> stationList = [SELECT Id FROM Sirius_XM_Station__c WHERE External_Id__c = :stationName];

        if (!stationList.isEmpty()) {

            for (SiriusXMWrapper.Song songWrapper : songWrapperList) {
                song = new Sirius_XM_Song__c(Sirius_XM_Station__c = stationList[0].Id, 
                                             Album_Cover_Url__c = songWrapper.spotify.cover,
                                             Name = songWrapper.track.name,
                                             Spotify_Id__c = songWrapper.spotify.spotify_id);
                
                // Get artists for the song (1 song can have multiple artists)
                for (String artistWrapper : songWrapper.track.artists) {
                    artist = new Artist__c(Name = artistWrapper, Song__r = new Sirius_XM_Song__c(Spotify_Id__c = songWrapper.spotify.spotify_id));
                }

                // Get artists for the song (1 song can have multiple artists)
                if (songWrapper.links != null) {
                    for (SiriusXMWrapper.Website websiteWrapper : songWrapper.links) {
                        website = new Website__c(Name = websiteWrapper.site, Sirius_XM_Song__r = new Sirius_XM_Song__c(Spotify_Id__c = songWrapper.spotify.spotify_id),
                                            Url__c = websiteWrapper.url);

                        if (websiteWrapper.site == 'itunes') {
                            /*
                                Example of URL: "https://music.apple.com/US/album/lyla/940299391?i=940299397&app=music"
                                First Split: ["https://music.apple.com/US/album/lyla/940299391"],[940299397&app=music"]
                                Second Split: ["940299397","app=music"]
                            */
                            song.Apple_Id__c = websiteWrapper.url.split('i=')[1].split('&')[0];
                        }
                        //websiteList.add(website);
                    }
                }
                songList.add(song);
                //artistList.add(artist);
                
            }

            Database.UpsertResult[] upsertResult = Database.upsert(songList, Sirius_XM_Song__c.Spotify_Id__c, false);
            Database.insert(artistList, false);
            // Database.insert(websiteList, false);
            String debugLog = '';
            // Iterate through each returned result
            for (Database.upsertResult sr : upsertResult) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    debugLog += 'Successfully inserted Song. Song ID: ' + sr.getId();
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        debugLog += 'The following error has occurred.';                    
                        debugLog += (err.getStatusCode() + ': ' + err.getMessage());
                        debugLog += ('Song Fields that affected these errors: ' + err.getFields());
                    }
                }
            }

            
        }
    }

    @future(callout=true)
    public static void appleMusicCalloutTest() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://amp-api.music.apple.com/v1/me/library/playlists');
        req.setHeader('Cookie', 's_fid=136C6E6D2AF9690A-128F1DCBAF90E5A5; s_vi=[CS]v1|2FC8EB4C0515F2D7-60000B01B2E8A7DE[CE]; xp_ci=3z3FTSACzFyuz5UHzAZKzxSqwPjlc; xp_abc=17Eg4xa0; itua=US; media-user-token=Ass2Ppm4YWOAXTmnuqzO/LkotMWWjBHGomU/i9ls4Alfayi1NugKP9Ic0p76S2vV68ecJVDEOPCMbaw0Mq1XayXfAmTBrSJYuKqmiI25LYAI3L0ix2z+oY4/zRgtSEpOQIGEwlv/CIxjHvqrtAf0ZhzWdJLrqW2OgD/2NFwp8sccNbJi7jI6v2N2g3mdRB4kAR4SaKJCoV++TSAlWq4NXTHcAMTToqfHzgUBZ7BcZhHO9Uq82w==; pldfltcid=30afc35e44f74c71916a92cfb9f6ef93020; pltvcid=075bc69f6c3b41f8b226f42e1bc04022020; media-user-token=Ass2Ppm4YWOAXTmnuqzO/LkotMWWjBHGomU/i9ls4Alfayi1NugKP9Ic0p76S2vV68ecJVDEOPCMbaw0Mq1XayXfAmTBrSJYuKqmiI25LYAI3L0ix2z+oY4/zRgtSEpOQIGEwlv/CIxjHvqrtAf0ZhzWdJLrqW2OgD/2NFwp8sccNbJi7jI6v2N2g3mdRB4kAR4SaKJCoV++TSAlWq4NXTHcAMTToqfHzgUBZ7BcZhHO9Uq82w==; itua=us; itre=0; xp_ab=1#Jv0scgz+-2+7KGQkMc1#Zh4zkDd+-2+Utk2R3g0#isj11bm+-2+17Eg4xa0#yNFpB6B+-2+lrDZsLr1; geo=US; ccl=7WlUsG/4/lbh1AWCd8Sg2wxyW2ocRrDg6mIGwb4RG1+gaSJAuDUGAz59QFrNY950nYG0Zjt/gQs=; s_pathLength=no%20channel%3D1%2C; s_cc=true; s_sq=%5B%5BB%5D%5D; xp_cci=3z2PguZVz4Pgz4VMzBTfzngTGGdFY');
        req.setHeader('Authorization', 'Bearer ' + 'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlYlBsYXlLaWQifQ.eyJpc3MiOiJBTVBXZWJQbGF5IiwiaWF0IjoxNjA1MTU0MDIyLCJleHAiOjE2MjA3MDYwMjJ9.x3Ce-qBdWoMgj-k8Jwi_WdhPcA4Hwv0fsDJrfk6kGOgVMmCwk8BSmYSqnbhfg1ZB75olYsL84iTKvPZOckG2EA');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        Database.insert(new Custom_Log__c(Name = res.getStatusCode() + ' | ' + Datetime.now()));
    }

    public static List<String> getSiriusAppleIds(List<SiriusXMWrapper.Song> songWrapperList) {
        List<String> songIdList = new List<String>();
        for (SiriusXMWrapper.Song songWrapper : songWrapperList) {
            // Get artists for the song (1 song can have multiple artists)
            if (songWrapper.links != null) {
                for (SiriusXMWrapper.Website websiteWrapper : songWrapper.links) {
                    if (websiteWrapper.site == 'itunes') {
                        songIdList.add(websiteWrapper.url.split('i=')[1].split('&')[0]);
                    }                        
                }
            }
        }
        return songIdList;
    }
    
}