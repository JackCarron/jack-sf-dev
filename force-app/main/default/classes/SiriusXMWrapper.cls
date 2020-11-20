public with sharing class SiriusXMWrapper {
    List<Song> songList = new List<Song>();

    // Used for Sirius callouts
    public with sharing class Song {
        public String id;
        public Spotify spotify;
        public Track track = new Track();
        public List<Website> links = new List<Website>();
    }

    public with sharing class Spotify {
        public String spotify_id;
        public String preview_url;
        public String cover;
    }

    public with sharing class Track {
        public String id;
        public String name;
        public List<String> artists = new List<String>();
    }

    public with sharing class Website {
        public String url;
        public String site;
    }    
}