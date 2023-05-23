import ballerinax/trigger.asgardeo;
import ballerina/http;
import ballerina/log;

configurable asgardeo:ListenerConfig config = ?;

configurable string graphAPIClientID = ?;
configurable string graphAPIClientSecret = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

final http:Client graphApiEp = check new("https://graph.microsoft.com/v1.0",
    auth = {
        tokenUrl: "https://login.microsoftonline.com/fedtest.uk/oauth2/v2.0/token",
        clientId: graphAPIClientID,
        clientSecret: graphAPIClientSecret,
        scopes: "https://graph.microsoft.com/.default",
        defaultTokenExpTime: 3600
    }
);

service asgardeo:UserOperationService on webhookListener {
  
    remote function onLockUser(asgardeo:GenericEvent event ) returns error? {
      //Not Implemented
    }

    remote function onUnlockUser(asgardeo:GenericEvent event ) returns error? {
      //Not Implemented
    }

    remote function onUpdateUserCredentials(asgardeo:GenericEvent event ) returns error? {
      //Not Implemented
    }

    remote function onDeleteUser(asgardeo:GenericEvent event ) returns error? {
      string? userPricipleName = event?.eventData?.userName;
      if (userPricipleName != ()) {
          log:printInfo("Deteling user : " + userPricipleName);
          json response = check deleteUserFromAzureDomain(userPricipleName);
          log:printInfo(response.toJsonString());
      } else {
        return error(string `Username not found in the event details`);
      }  
    }

    remote function onUpdateUserGroup(asgardeo:UserGroupUpdateEvent event ) returns error? {
      log:printInfo("Updating groups for user");
      log:printInfo(event.toJsonString());
    }
}

service /ignore on httpListener {}

function deleteUserFromAzureDomain(string userPrincipalName) returns json|error {

    json response = check graphApiEp->delete("/users/" + userPrincipalName);
    return response;
}
