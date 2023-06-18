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
    string onPremisesImmutableId;
    #Setting a default password with forced password reset enabled.
    json passwordProfile = {
      forceChangePasswordNextSignIn : true,
      password : "xWwvJ]6NMw+bWH-d"
    };
};

configurable string graphAPIClientID = ?;
configurable string graphAPIClientSecret = ?;

configurable asgardeo:ListenerConfig config = ?;

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
        if (userData != () && userData?.userId != () && userData?.userName != ()) {
            string username = <string> userData?.userName;
            map<string>? userClaims = userData?.claims;
            string displayName = "";
            if (userClaims != ()) {
                string firstName = userClaims.hasKey("http://wso2.org/claims/givenname") ? userClaims.get("http://wso2.org/claims/givenname") : "";
                string lastName = userClaims.hasKey("http://wso2.org/claims/lastname") ? userClaims.get("http://wso2.org/claims/lastname") : "";
                displayName = firstName + " " + lastName;
            }
            User azureUser = {
                displayName: displayName == "" ? username : displayName,
                mailNickname: regex:split(username, "@")[0],
                userPrincipalName: username,
                onPremisesImmutableId: <string> userData?.userId
                };
            log:printInfo("Provisioning user : " + azureUser.toJsonString());
            json|error response = graphApiEp->post("/users", azureUser);
            if (response is error) {
                log:printError( "Provisioning to Azure failed for user : " + username , response);
            } else {
                log:printInfo("Provisioning to Azure successful for user : " + username);
            }
        } else {
            return error(string `Insufficient user data in the event details.`);
      }
    }
  
    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {}
  
    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {}
}

service /ignore on httpListener {}
