public with sharing class GolfWrapper {
    public GolfWrapper() {

    }

    public class Player {
        public String playerId;
        public Decimal handicap;
        public List<Round> rounds;
    }

    public class Round {
        public String roundId;
        public String playerId;
        public String courseId;
        public String course;
        public String inserted;
        public List<Scorecard> scorecards;
    }

    public class Scorecard {
        public String courseName;
        public List<Hole> holes;
        public Integer par;
        public Integer score;
        public String playerId;
    }

    public class Hole {
        public Integer holeNum;
        public String courseHoleId;
        public String scorecardHoleId;
        public Integer par;
        public Integer score;
        public Integer putts;
        public Integer strokeIndex;
    }
}