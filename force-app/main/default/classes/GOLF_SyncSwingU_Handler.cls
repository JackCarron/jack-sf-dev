public with sharing class GOLF_SyncSwingU_Handler {
    /*Notes for myself tomorrow:
     - Need to Create Course
     - Add course holes to course
     - Add Round
     - Add Rounds holes
     */
    
    public static void handleGolfInfo() {
        List<Player__c> playerList = [select id, isActive__c, External_Id__c, 
        (select id, external_id__c from rounds__r) from player__c where isActive__c = true AND External_Id__c <> NULL];
        Map<String,List<String>> playerRoundMap = new Map<String,List<String>>();    
        
        // Create Map of playerId and Round
        for (Player__c player : playerList) {
            List<String> roundExternalIdList = new List<String>();
            for (Round__c round : player.rounds__r) {
                roundExternalIdList.add(round.External_Id__c);
            }
            playerRoundMap.put(player.External_Id__c, roundExternalIdList);
        }

        // Create Instance of SwingUService and pass in our playerList
        GOLF_SyncSwingU_Service service = new GOLF_SyncSwingU_Service(playerList);
        List<Golf_Wrapper.Player> playerWrapperList = service.getPlayerRoundList();
        for(Golf_Wrapper.Player player : playerWrapperList ) {
            List<RoundHole__c> roundHoleList = new List<RoundHole__c>();
            // Loop through all of players rounds from swingU
            for (Golf_Wrapper.Round round : player.rounds) {
                // If round is already not in SF == TRUE
                if (!playerRoundMap.get(player.rounds[0].scorecards[0].playerId).contains(round.roundId)) {    
                    // Create New Course if course doesn't exist in SF
                    Golf_Wrapper.Round roundInfo = service.getRoundInfo(round.roundId);
                    Course__c newCourse = new Course__c(External_Id__c = round.courseId);
                    upsert newCourse;
                    // Create Round
                    Round__c newRound = new Round__c(Course__c = newCourse.Id, External_Id__c = round.roundId);
                    insert newRound;
                    // Get more in depth data on the round (ie. the hole)
                    for (GOLF_Wrapper.Hole hole : roundInfo.scorecards[0].holes) {
                        Hole__c courseHole = new Hole__c(Par__c = hole.par, Hole_Number__c = hole.holeNum, Course__c = newCourse.Id);
                        upsert courseHole;
                        RoundHole__c roundHole = new RoundHole__c(Putts__c = hole.putts, Score__c = hole.score, Round__c = newRound.Id,
                        Hole__c = courseHole.Id);
                        roundHoleList.add(roundHole);
                    }
                }   
            }
        }
    }
}
