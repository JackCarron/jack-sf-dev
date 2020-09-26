@RestResource(urlMapping='/Messages/*')
global without sharing class MessageRest {
    @HttpPost 
    global static String createNewMessage(String email, String subject, String message) {
        Message__c newMessage = new Message__c(Sender_Email__c = email,
                                               Subject__c = subject,
                                               Message_Content__c = message);        
        insert newMessage;

        return 'Message Added Successfully';
   }
}
