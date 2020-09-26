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

public with sharing class GOLFSyncSwingUHandler {
    Set<String> courseIdSet = new Set<String>();
    Set<String> sfCourseIdSet = new Set<String>();
    Set<String> sfRoundIdSet = new Set<String>();
    List<Course__c> newCourseList = new List<Course__c>();
    List<Round__c> newRoundList = new List<Round__c>();
    List<Hole__c> newHoleList = new List<Hole__c>();
    List<RoundHole__c> newRoundHoleList = new List<RoundHole__c>();
    Map<String,String> courseIdNameMap = new Map<String,String>();
    Map<String,GolfWrapper.Round> roundIdRoundMap = new Map<String,GolfWrapper.Round>();

    public void handleGolfInfo() {

        // Query players to add course information for
        List<Player__c> playerList = 
            [SELECT Id, isActive__c, External_Id__c 
             FROM Player__c 
             WHERE isActive__c = true 
             AND External_Id__c <> NULL];

        // Service class will limit it's operations to queried players
        GolfSyncSwingUService service = new GolfSyncSwingUService(playerList);

        // Callout will return the 20 most recent rounds
        List<GolfWrapper.Player> playerWrapperList = service.getPlayerRoundList();

        // Get Courses that player has played
        for (GolfWrapper.Player playerWrapper : playerWrapperList) {

            for (GolfWrapper.Round round : playerWrapper.rounds) {

                if (String.isNotBlank(round.scorecards[0].playerId)
                        && String.isBlank(playerWrapper.playerId)) {
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

        // Add courses to list for upsert
        for (String courseId : courseIdSet) {
            newCourseList.add(new Course__c(
                              Name = courseIdNameMap.get(courseId),
                              External_Id__c = courseId));
            }            

        // Recent round that exist in SF
        List<Round__c> sfRoundList = [
            SELECT Id, Name, External_Id__c 
            FROM Round__c 
            WHERE External_Id__c IN :roundIdRoundMap.keySet()];

        for (Round__c roundFromQuery : sfRoundList) {
            sfRoundIdSet.add(roundFromQuery.External_Id__c);
        }

        // Avoiding inserting recent rounds that already exist in SF
        if (roundIdRoundMap.keyset().size() > sfRoundIdSet.size()) {

            for (String roundId : roundIdRoundMap.keySet()) {

                if (!sfRoundIdSet.contains(roundId)) {
                    GolfWrapper.Round round = service.getRoundInfo(roundId);

                    // Callout returns inserted time in format: YYYY-MM-DDThh:mm:ss+zz:zz
                    // Need to format to SF date = yyyy-MM-dd HH:mm:ss
                    String roundInsertedRawText = String.join(round.inserted.split('T'),' ');
                    roundInsertedRawText = roundInsertedRawText.left(roundInsertedRawText.length() - 6);

                    // Add new round to list for inserting
                    newRoundList.add(new Round__c(
                                     Date_Played__c = DateTime.valueOf(roundInsertedRawText),
                                     Player__r = new Player__c(External_Id__c = roundIdRoundMap.get(roundId).playerId),
                                     Course__r = new Course__c(External_Id__c = roundIdRoundMap.get(roundId).courseId),
                                     External_Id__c = roundId));

                    for (GolfWrapper.Hole hole : round.scorecards[0].holes) {

                        // Add hole for the course
                        newHoleList.add(new Hole__c(
                                        Hole_Number__c = (Integer) hole.holeNum, 
                                        Par__c = (Integer) hole.par,
                                        Handicap__c = (Integer) hole.strokeIndex,
                                        External_Id__c = hole.courseHoleId,
                                        Course__r = new Course__c(External_Id__c = roundIdRoundMap.get(roundId).courseId)));

                        // Add hole for the round
                        newRoundHoleList.add(new RoundHole__c(
                                             Hole__r = new Hole__c(External_Id__c = hole.courseHoleId),
                                             Round__r = new Round__c(External_Id__c = roundId),
                                             Putts__c = hole.putts,
                                             Score__c = hole.score,
                                             External_Id__c = hole.scorecardHoleId));
                    }                    
                }
            }

            // Insert/Upsert all new course, round, hole, and round hole data
            Database.upsert(newCourseList, Course__c.External_Id__c, True);
            Database.insert(newRoundList, True);
            Database.upsert(newHoleList, Hole__c.External_Id__c, True);
            Database.insert(newRoundHoleList, True);
        }
    }
}