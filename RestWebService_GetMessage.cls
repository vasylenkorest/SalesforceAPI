@RestResource(urlMapping='/custom/service/webhook/listen/message/*')
global without sharing class RestWebService_GetMessage {
    
	@HttpGet
    global static Message__e getTextMessage() {

        Map<String, String> smsParams = RestContext.request.params;
        
        String from_z = smsParams?.get('from');
        String to = smsParams?.get('to');
        String message = smsParams?.get('body');  

        Message__e event = new Message__e(To__c = to, From__c = from_z, Message__c = message);
        EventBus.publish(event);
		
        /*
        String leadPhone = '%' + from_z.substring(1, from_z.length())+'%';
        String userPhone = '%' + to.substring(1, to.length())+'%';
		
        User u = [SELECT Id, Name FROM User WHERE Phone LIKE :userPhone LIMIT 1];
        Lead l = [SELECT Id, Name FROM Lead WHERE Phone LIKE :leadPhone OR MobilePhone LIKE :leadPhone LIMIT 1];

        // Create bell notification
        Id typeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Message_Notification'].Id;
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setBody(message);
        notification.setTitle('You have a new message!');
        notification.setSenderId(u.Id);
        notification.setNotificationTypeId(typeId);
        notification.setTargetId(l.Id); // target object id
        
        try {
        	notification.send(new Set<String> { u.Id });
        } catch (Exception e) {
            throw e;
        }
        */

    	return event;
    }
}