public with sharing class GOLFSyncSwingUHandler {
    Set<String> courseIdSet = new Set<String>();
    Set<String> sfCourseIdSet = new Set<String>();
    Set<String> sfRoundIdSet = new Set<String>();
    Map<String,String> courseIdNameMap = 
        new Map<String,String>();
    Map<String,GolfWrapper.Round> roundIdRoundMap = 
        new Map<String,GolfWrapper.Round>();
    List<Course__c> newCourseList = new List<Course__c>();
    List<Round__c> newRoundList = new List<Round__c>();
    List<Hole__c> newHoleList = new List<Hole__c>();
    List<RoundHole__c> newRoundHoleList = new List<RoundHole__c>();

    public void handleGolfInfo() {
        List<Player__c> playerList = [
            SELECT Id, isActive__c, External_Id__c 
            FROM Player__c 
            WHERE isActive__c = true 
            AND External_Id__c <> NULL];   
        GOLF_SyncSwingU_Service service = new GOLF_SyncSwingU_Service(
            playerList);
        List<GolfWrapper.Player> playerWrapperList = 
            service.getPlayerRoundList();

        // Get Courses that player has played
        for (GolfWrapper.Player playerWrapper : playerWrapperList) {
            for (GolfWrapper.Round round : playerWrapper.rounds) {
                if (String.isNotBlank(round.scorecards[0].playerId) &&
                String.isBlank(playerWrapper.playerId)) {
                    playerWrapper.playerId = round.scorecards[0].playerId;
                }
                if (String.isNotBlank(round.courseId)) {
                    courseIdSet.add(round.courseId);
                    if (String.isNotBlank(round.scorecards[0].courseName)) {
                        courseIdNameMap.put(round.courseId, 
                            round.scorecards[0].courseName);
                    }
                }
                if (String.isNotBlank(round.roundId)) {
                    GolfWrapper.Round roundInstance = new GolfWrapper.Round();
                    roundInstance.playerId = playerWrapper.playerId;
                    roundInstance.courseId = round.courseId;
                    roundIdRoundMap.put(round.roundId, roundInstance);
                }
            }
            
        }

        // Courses that exist in SF
        List<Course__c> sfCourseList = [
            SELECT Id, Name, External_Id__c 
            FROM Course__c 
            WHERE External_Id__c IN :courseIdSet];

        for (Course__c courseFromQuery : sfCourseList) {
            sfCourseIdSet.add(courseFromQuery.External_Id__c);
        }

        // Avoiding inserting courses that already exist in SF
        if (courseIdSet.size() > sfCourseIdSet.size()) {
            for (String courseId : courseIdSet) {
                if (!sfCourseIdSet.contains(courseId)) {
                    newCourseList.add(new Course__c(
                        Name = courseIdNameMap.get(courseId),
                        External_Id__c = courseId));
                }
            }
            insert newCourseList;
        }

        // Round that exist in SF
        List<Round__c> sfRoundList = [
            SELECT Id, Name, External_Id__c 
            FROM Round__c 
            WHERE External_Id__c IN :roundIdRoundMap.keySet()];
    

        for (Round__c roundFromQuery : sfRoundList) {
            sfRoundIdSet.add(roundFromQuery.External_Id__c);
        }

        // Avoiding inserting rounds that already exist in SF
        if (roundIdRoundMap.keyset().size() > sfRoundIdSet.size()) {
            for (String roundId : roundIdRoundMap.keySet()) {
                if (!sfRoundIdSet.contains(roundId)) {
                    GolfWrapper.Round round = service.getRoundInfo(roundId);
                    String roundInsertedRawText = String.join(round.inserted.split('T'),' ');
                    roundInsertedRawText = roundInsertedRawText.left(roundInsertedRawText.length() - 6);
                    newRoundList.add(new Round__c(
                        Date_Played__c = DateTime.valueOf(roundInsertedRawText),
                        Player__r = new Player__c(External_Id__c = roundIdRoundMap.get(roundId).playerId),
                        Course__r = new Course__c(External_Id__c = roundIdRoundMap.get(roundId).courseId),
                        External_Id__c = roundId));
                    System.debug(round);
                    List<GolfWrapper.Hole> holeList = new List<GolfWrapper.Hole>();
                    for (GolfWrapper.Hole hole : round.scorecards[0].holes) {
                        newHoleList.add(new Hole__c(
                            Hole_Number__c = (Integer) hole.holeNum, 
                            Par__c = (Integer) hole.par,
                            Handicap__c = (Integer) hole.strokeIndex,
                            External_Id__c = hole.courseHoleId,
                            Course__r = new Course__c(External_Id__c = roundIdRoundMap.get(roundId).courseId) 
                            ));
                        newRoundHoleList.add(new RoundHole__c(
                            Hole__r = new Hole__c(External_Id__c = hole.courseHoleId),
                            Round__r = new Round__c(External_Id__c = roundId),
                            Putts__c = hole.putts,
                            Score__c = hole.score,
                            External_Id__c = hole.scorecardHoleId
                        ));
                    }                    
                }
            }
            System.debug(newHoleList);
            System.debug(newRoundHoleList);
            insert newRoundList;
            Database.upsert(newHoleList, false);
            insert newRoundHoleList;
        }
    }
}