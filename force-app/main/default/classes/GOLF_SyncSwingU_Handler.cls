public with sharing class GOLF_SyncSwingU_Handler {
    /*Notes for myself tomorrow:
     - Need to Create Course
     - Add course holes to course
     - Add Round
     - Add Rounds holes
     */
    
    public static void handleGolfInfo() {
        List<Player__c> playerList = [
            SELECT id, isActive__c, External_Id__c 
            FROM player__c where isActive__c = true 
            AND External_Id__c <> NULL];   
        GOLF_SyncSwingU_Service service = new GOLF_SyncSwingU_Service(
            playerList);
        
        List<Golf_Wrapper.Player> playerWrapperList = service.getPlayerRoundList();
        System.debug(playerWrapperList);
    }
}