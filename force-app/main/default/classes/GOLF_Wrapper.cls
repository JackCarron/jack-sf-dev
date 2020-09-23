public with sharing class GOLF_Wrapper {
    public GOLF_Wrapper() {

    }

    public class Player {
        public String playerId;
        public Decimal handicap;
        public List<Round> rounds;
    }

    public class Round {
        public String roundId;
        public String courseId;
        public String course;
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
        public Integer par;
        public Integer score;
        public Integer putts;
        public String strokeIndex;
    }
}