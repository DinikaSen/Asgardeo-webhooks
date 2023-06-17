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
  
    remote function onLockUser(asgardeo:GenericEvent event ) returns error? {}

    remote function onUnlockUser(asgardeo:GenericEvent event ) returns error? {}

    remote function onUpdateUserCredentials(asgardeo:GenericEvent event ) returns error? {}

    remote function onDeleteUser(asgardeo:GenericEvent event ) returns error? {
      string? userPricipleName = event?.eventData?.userName;
      if (userPricipleName != ()) {
            json|error response = graphApiEp->delete("/users/" + userPricipleName);
            if (response is error) {
                log:printError("Deleting user from Azure failed with error for user : " + userPricipleName, response);
            } else {
                log:printInfo("Deleting user from Azure successful for user : " + userPricipleName);
            }
      } else {
            return error(string `Username not found in the event details`);
      }  
    }

    remote function onUpdateUserGroup(asgardeo:UserGroupUpdateEvent event ) returns error? {}
}

service /ignore on httpListener {}
