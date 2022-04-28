@RestResource(urlMapping='/accounts/*')
global with sharing class AccountAPIUtils {

    @HttpGet
    global static Response getAccounts() {
        try {
            
            Account[] accounts = new Account[]{};
                
            // Get parameters
            String name = RestContext.request.params.get('name');
            String phone = RestContext.request.params.get('phone');
            
            // Get accounts according to prodvided params
            if (name != null) {
                String searchedName = '%' + name + '%';
                accounts = [SELECT Id, Name, Phone, Website, BillingState FROM Account WHERE Name LIKE :searchedName LIMIT 50000];
            } else if (phone != null) {
                accounts = [SELECT Id, Name, Phone, Website, BillingState FROM Account WHERE Phone = :phone LIMIT 50000];
            } else {
                accounts = [SELECT Id, Name, Phone, Website, BillingState FROM Account LIMIT 50000];
            }
    
            return new Response(200, accounts);
            
        } catch(Exception e){ return new Response(400, e.getMessage()); }
    }

    @HttpPost
    global static Response upsertAccountAndContact(Request data) {
        try {

            Coordinates coordinates = data?.coordinates; 
            
            Account account = data?.account;
            account.BillingLatitude = coordinates.lat;
            account.BillingLongitude  = coordinates.lng;
            
            upsert account;
            
            Contact contact = (Contact) System.JSON.deserialize(JSON.serialize(data?.contact), Contact.class);
            contact.AccountId = account?.Id;
            
            upsert contact;
            
            
            return new Response(201, account, contact, coordinates);
            
        } catch(Exception e){ return new Response(400, e.getMessage()); }
    }
    
    @HttpDelete
    global static Boolean deleteAccount() {
        String accountId = RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/') + 1);

        Database.DeleteResult dr = Database.delete(new Account(Id = accountId));
        return dr.isSuccess();  
    }
    
    
    // Wrapper Classes
    
    global class Response {
        global Integer code;
        global String message;
        global Account account;
        global Contact contact;
        global Coordinates coordinates;
        global Account[] accounts;
        
        global Response(Integer code, Account[] accounts){
            this.code = code;
            this.accounts = accounts;
        }
        
        global Response(Integer code, Account account, Contact contact, Coordinates coordinates){
            this.code = code;
            this.account = account;
            this.contact = contact;
            this.coordinates = coordinates;
        }
        
        global Response(Integer code, String message){
            this.code = code;
            this.message = message;
        }
    }
    
    global class Request {    
        global Account account;
        global Contact contact;
        global Coordinates coordinates;
        
        global Request(Account account, Contact contact, Coordinates coordinates){
            this.account = account;
            this.contact = contact;
            this.coordinates = coordinates;
        }
    }
    
    global class Coordinates {
        global Double lng;
        global Double lat;
    }
}