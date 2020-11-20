public with sharing class SiriusAppleWrapper {
    // Used for Apple Callouts
    public with sharing class AppleWrapper {
        public String next;
        public List<ApplePlaylist> data;
        public AppleMeta meta;
    }

    public with sharing class AppleMeta {
        Integer total;
    }

    public with sharing class ApplePlaylist {
        public String id;
        public String type;
        public String href;
        public AppleAttribute attributes;
    }

    public with sharing class AppleAttribute {
        public String name;
        public Boolean canEdit;
        public AppleSong playParams;
    }

    public with sharing class AppleSong {
        public String id;
        public String catalogId;        
    }
}
