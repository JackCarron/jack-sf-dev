/*
* Company: Jack's Personal Projects
* Date: 09/25/2020
* Author: Jack Carron
* Description: Used for test class to mock the HTTP Requests to sync
               SwingU data.
* History: Inspiration came from wanting to report on my own
*          golf data
*/
public with sharing class GolfSyncSwingUMock implements HttpCalloutMock{

    final String PLAYER_ID = '23797591';
    final String ROUND_ID = '38357624';
    
    public HTTPResponse respond(HTTPRequest req) { 
        HTTPResponse res = new HTTPResponse(); 
        res.setStatusCode(200); 
        if (req.getEndpoint() == Label.SWINGU_URL + Label.PLAYER_ROUNDS_ENDPOINT + PLAYER_ID) {
            res.setBody(getPlayerRoundCalloutMock());
        }
        else if (req.getEndpoint() == Label.SWINGU_URL + Label.ROUND_ENDPOINT + ROUND_ID) {
            res.setBody(getRoundCalloutMock());
        }
        return res;
    }

    public static String getPlayerRoundCalloutMock() {
        /* This method returns the JSON below
        {
            "rounds": [
                {
                    "roundId": 38357624,
                    "courseId": 18060,
                    "scorecards": [
                        {
                            "playerId": 23797591,
                            "roundId": 38357624,
                            "courseId": 18060,
                            "courseName": "Encanto Nine Golf Club"
                        }
                    ]
                }
            ]
        }
        */
        return '{"rounds":[{"roundId":38357624,"courseId":18060,"scorecards":'+
               '[{"playerId":23797591,"roundId":38357624,"courseId":18060,"'+
               'courseName":"Encanto Nine Golf Club"}]}]}';
    }

    public static String getRoundCalloutMock() {
        /* This method returns the JSON below
        {
            "roundId": 38357624,
            "courseId": 18060,
            "course": "Encanto Nine Golf Club",
            "inserted": "2020-09-23T20:40:08-04:00",
            "scorecards": [
                {
                    "playerId": 23797591,
                    "roundId": 38357624,
                    "courseId": 18060,
                    "holes": [
                        {
                            "holeNum": 1,
                            "scorecardHoleId": 2408548843,
                            "courseHoleId": 309081,
                            "par": 4,
                            "score": 4,
                            "putts": 2,
                            "strokeIndex": 3
                        },
                        {
                            "holeNum": 2,
                            "scorecardHoleId": 2408549658,
                            "courseHoleId": 309082,
                            "par": 3,
                            "score": 4,
                            "putts": 3,
                            "strokeIndex": 17
                        },
                        {
                            "holeNum": 3,
                            "scorecardHoleId": 2408550516,
                            "courseHoleId": 309083,
                            "par": 3,
                            "score": 4,
                            "putts": 2,
                            "strokeIndex": 15
                        },
                        {
                            "holeNum": 4,
                            "scorecardHoleId": 2408551134,
                            "courseHoleId": 309084,
                            "par": 3,
                            "score": 4,
                            "putts": 2,
                            "strokeIndex": 13
                        },
                        {
                            "holeNum": 5,
                            "scorecardHoleId": 2408552113,
                            "courseHoleId": 309085,
                            "par": 4,
                            "score": 5,
                            "putts": 2,
                            "strokeIndex": 9
                        },
                        {
                            "holeNum": 6,
                            "scorecardHoleId": 2408552591,
                            "courseHoleId": 309086,
                            "par": 3,
                            "score": 4,
                            "putts": 2,
                            "strokeIndex": 11
                        },
                        {
                            "holeNum": 7,
                            "scorecardHoleId": 2408549642,
                            "courseHoleId": 309087,
                            "par": 3,
                            "score": 4,
                            "putts": 3,
                            "strokeIndex": 5
                        },
                        {
                            "holeNum": 8,
                            "scorecardHoleId": 2408554653,
                            "courseHoleId": 309088,
                            "par": 3,
                            "score": 4,
                            "putts": 2,
                            "strokeIndex": 7
                        },
                        {
                            "holeNum": 9,
                            "scorecardHoleId": 2408554656,
                            "courseHoleId": 309089,
                            "par": 4,
                            "score": 4,
                            "putts": 2,
                            "strokeIndex": 1
                        }
                    ]
                }
            ]
        }
        */
        return '{"roundId":38357624,"courseId":18060,"course":"Encanto Nine Golf Club"' + 
               ',"inserted":"2020-09-23T20:40:08-04:00","scorecards":[{"playerId":' + 
               '23797591,"roundId":38357624,"courseId":18060,"holes":[{"holeNum":1,' + 
               '"scorecardHoleId":2408548843,"courseHoleId":309081,"par":4,"score":4,' + 
               '"putts":2,"strokeIndex":3},{"holeNum":2,"scorecardHoleId":2408549658,' + 
               '"courseHoleId":309082,"par":3,"score":4,"putts":3,"strokeIndex":17},' + 
               '{"holeNum":3,"scorecardHoleId":2408550516,"courseHoleId":309083,"par":3,' +
               '"score":4,"putts":2,"strokeIndex":15},{"holeNum":4,"scorecardHoleId":' + 
               '2408551134,"courseHoleId":309084,"par":3,"score":4,"putts":2,"strokeIndex":' + 
               '13},{"holeNum":5,"scorecardHoleId":2408552113,"courseHoleId":309085,"par":4,' + 
               '"score":5,"putts":2,"strokeIndex":9},{"holeNum":6,"scorecardHoleId":2408552591,' + 
               '"courseHoleId":309086,"par":3,"score":4,"putts":2,"strokeIndex":11},{"holeNum":' + 
               '7,"scorecardHoleId":2408549642,"courseHoleId":309087,"par":3,"score":4,"putts":3' + 
               ',"strokeIndex":5},{"holeNum":8,"scorecardHoleId":2408554653,"courseHoleId":309088' + 
               ',"par":3,"score":4,"putts":2,"strokeIndex":7},{"holeNum":9,"scorecardHoleId":2408554656' + 
               ',"courseHoleId":309089,"par":4,"score":4,"putts":2,"strokeIndex":1}]}]}';
    }
}