
// Salesforce API Integration

// GET - Retrieve data identified by a URL
// POST - Create a resource or post data to the server.
// DELETE - Delete a resource identified by a URL.
// PUT - Create or replace the resource sent in the request body.


// REQUEST EXAMPLE

String endpoint = 'https://mytestcompany-4d-dev-ed.lightning.force.com/getData';
String method = 'GET';

Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint(endpoint);
request.setMethod(method);
request.setHeader('Content-Type', 'application/json; charset=UTF-8');
request.setBody('{"Name" : "Account Name Example"}');

HttpResponse response = http.send(request);

if (response.getStatusCode() == 200) {
    //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    Request deserializedBody = (Request) JSON.deserialize(response.getBody(), Request.class);
}


//************************************************************************* */

// JSON 

{
    "data" : {
        "account" : {
            "Name" : "Test Account",
            "Phone" : "+380660313433",
            "BillingState" : "New York",
            "Website": "www.peeklogic.com" 
        },
        "contact" : {
            "FirstName": "Test",
            "LastName": "Contact",
            "Email" : "orest.v@peeklogic.com",
            "Phone" : "+380660313433"
        },
        "coordinates" : {
            "lng" : 38.8951,
            "lat" : -77.0364
        }
    }
}


// WRAPPERS & JSON2APEX. PARSING DATA.

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

// https://json2apex.herokuapp.com/


//*******************************

// AUTHORIZATION

// - BASIC

String username = 'ACa35094842fdf7785ca221e4cd9e9ee28';
String password = '75cb97d7435d5cda2c69b7bb82c7a089';

HttpRequest request = new HttpRequest();
request.setEndpoint('https://api.twilio.com/2010-04-01/Accounts');
request.setMethod('GET');

Blob headerValue = Blob.valueOf(username + ':' + password);
request.setHeader('Authorization', 'BASIC ' + EncodingUtil.base64Encode(headerValue));
//request.setHeader('Authorization', 'Bearer ' + getAccessToken());

Http http = new Http();
HTTPResponse response = http.send(request);
System.debug(response.getBody());


// - BEARER ACCESS TOKEN (OAUTH2.0) & CONNECTED APP

// ConnectedAppPlugin Class

1. client_id 
2. client_secret 
3. grant_type
4. username
5. password

HttpRequest req = new HttpRequest();
req.setEndpoint('https://mytestcompany-4d-dev-ed.my.salesforce.com/services/oauth2/token' + 
                '?grant_type=password&' + 
                'client_id=3MVG9cHH2bfKACZbgckKfAHDBHY2VYcZXnu6PeNiGmp_iB1sA_c_gB2EJW4Id7SdJfHAOEzy2.DBmnSeHJVft' + 
                '&client_secret=049022E687E671811AD9A6DF86DA09E3718D49E0266D4DE34DA7E2EFDE739A20' + 
                '&username=orest.vasy11enko@peeklogic.com' + 
                '&password=1q2w3e4r5t6yT1XsrKNw3ryyZG4fToiDoywMe');

req.setMethod('POST');
req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

Http http = new Http();
HTTPResponse res = http.send(req);
System.debug(res.getBody());


//*******************************


// POSTMAN

// Postman is an API platform for building and using APIs. 
//Postman simplifies each step of the API lifecycle and streamlines collaboration so you can create better APIs—faster.


//************************************************************************* */


// @RestResource APEX & Platform Events.

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
}


// Platform Events
Message__e event = new Message__e(To__c = to, From__c = from_z, Message__c = message);
EventBus.publish(event);

// Aura 

    const replayId = -1
    const empApi = cmp.find("empApi")

    const callback = function (message) { 
        console.log('message: ', JSON.parse(JSON.stringify(message.data.payload))) 
    }

    empApi.subscribe('/event/Message__e', replayId, callback).then(function(newSubscription) {})
    empApi.onError(message => console.error("Received error ", JSON.stringify(message))) 


// HANDLED ERRORS & CUSTOM ENDPOINTS.

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


// OPEN API || SWAGGER 

/services/apexrest/getUserProfile/v1:
    get:
      summary: Returns user profile
      parameters:
        - name: externalUId
          schema:
            type: string
            example: wqEpNHuJMjQHi0iGfnifXuGvTe
          in: query
          required: true
      responses:
        "200":
        description: "success"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/GetUserProfileResponse"
        "400":
          description: "error"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/400GetUserProfile"
        "404":
          description: "Can not find records in database with ExternalUId : "
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/404GetUserProfile"

// https://app.swaggerhub.com/apis/Peeklogic4/InstaJetOpenAPI/1.0.1#/



// CONNECT TWO ORGs With Connected App & Auth. Provider & Named Credentials

// org1 <- org2

/***************

1. Create Connected App ( org2 ) -> get cliend id, client secret
2. Create Auth Provider ( org1 ) -> put cliend id, client secret in auth. provider
3. Configure Callback URL ( org2 ) -> Copy callback url from auth. provider
4. Create Name Credentials & Login With Credentials. ( org1 )

***************/


HttpRequest request = new HttpRequest();
request.setEndpoint('callout:CalloutExample/services/data/v54.0/sobjects/Account/0017Q0000060dhiQAA');
request.setMethod('GET');
Http http = new Http();
HTTPResponse response = http.send(request);
System.debug(response.getBody());



// SSL Certificates 

// https://www.sslshopper.com/certificate-decoder.html

HttpRequest req = new HttpRequest();
req.setClientCertificateName('certificate');

