import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:RegistrationService on webhookListener {

    remote function onAddUser(asgardeo:AddUserEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }
}

service asgardeo:UserOperationService on webhookListener {

    remote function onLockUser(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onUnlockUser(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onUpdateUserCredentials(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onDeleteUser(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onUpdateUserGroup(asgardeo:UserGroupUpdateEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }
}

service asgardeo:LoginService on webhookListener {

    remote function onLoginSuccess(asgardeo:LoginSuccessEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onLoginFailed(asgardeo:LoginFailedEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }
}

service /ignore on httpListener {}