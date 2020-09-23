public with sharing class GOLF_SyncSwingU_Handler {
    /*Notes for myself tomorrow:
     - Need to Create Course
     - Add course holes to course
     - Add Round
     - Add Rounds holes
     */         
    Set<String> courseIdSet = new Set<String>();
    List<String> roundIdList;
    Set<String> sfCourseIdSet = new Set<String>();
    Map<String,String> courseIdNameMap = 
        new Map<String,String>();
    Map<String,List<String>> playerRoundIdMap = 
        new Map<String,List<String>>();
    List<Course__c> newCourseList = new List<Course__c>();

    public void handleGolfInfo() {
        List<Player__c> playerList = [
            SELECT Id, isActive__c, External_Id__c 
            FROM Player__c 
            WHERE isActive__c = true 
            AND External_Id__c <> NULL];   
        GOLF_SyncSwingU_Service service = new GOLF_SyncSwingU_Service(
            playerList);
        List<Golf_Wrapper.Player> playerWrapperList = 
            service.getPlayerRoundList();

        // Get Courses that player has played
        for (Golf_Wrapper.Player playerWrapper : playerWrapperList) {
            roundIdList = new List<String>();
            for (Golf_Wrapper.Round round : playerWrapper.rounds) {
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
                    roundIdList.add(round.roundId);
                }
            }
            playerRoundIdMap.put(
                playerWrapper.playerId, roundIdList);
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
    }
}