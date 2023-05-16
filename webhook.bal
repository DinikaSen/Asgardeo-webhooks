import ballerinax/trigger.asgardeo;
import ballerina/http;
import ballerina/log;
import ballerina/regex;

#User object for Graph API with minimum required details.
type User record {
    boolean accountEnabled = true;
    string displayName;
    string mailNickname;
    string userPrincipalName;
    #Setting a default password with forced password reset enabled.
    json passwordProfile = {
      forceChangePasswordNextSignIn : true,
      password : "xWwvJ]6NMw+bWH-d"
    };
};

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

service asgardeo:RegistrationService on webhookListener {
  
    remote function onAddUser(asgardeo:AddUserEvent event ) returns error? {
        asgardeo:AddUserData? userData = event.eventData;
        if (userData != () && userData?.userName != null && userData?.userName != ()) {
          string username = <string> userData?.userName;
          User azureUser = {
            displayName: username,
            mailNickname: regex:split(username, "@")[0],
            userPrincipalName: username
          };
          json response = check addUserToAzureDomain(azureUser);
          log:printInfo("Before");
          log:printInfo(response.toJsonString());
          log:printInfo("After");
        }
    }
  
    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {
        // Not Implemented
    }
  
    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {
        // Not Implemented
    }
}

function addUserToAzureDomain(User user) returns json|error {

    json response = check graphApiEp->post("/users", user);
    return response;
}
