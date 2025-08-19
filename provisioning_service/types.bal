// Security Event Token (SET) payload structure
public type SecurityEventToken record {
    string iss; // Issuer
    int iat; // Issued At timestamp
    string jti; // JWT ID
    map<json> events; // Events object with dynamic keys
};

// Registration success event data
public type RegistrationSuccessEvent record {
    string initiatorType;
    RegistrationUserInfo user;
    TenantInfo tenant;
    UserStoreInfo userStore;
    string action;
};

// User profile updated event data
public type UserProfileUpdatedEvent record {
    string initiatorType;
    ProfileUpdateUserInfo user;
    TenantInfo tenant;
    UserStoreInfo userStore;
    string action;
};

// User deleted event data
public type UserDeletedEvent record {
    string initiatorType;
    RegistrationUserInfo user;
    TenantInfo tenant;
    UserStoreInfo userStore;
};

// User info for registration events
public type RegistrationUserInfo record {
    string id;
    string ref;
    UserClaim[] claims;
};

// User info for profile update events
public type ProfileUpdateUserInfo record {
    string id;
    string ref;
    UserClaim[]? addedClaims;
    UserClaim[]? updatedClaims;
};

// User claim structure
public type UserClaim record {
    string uri;
    string value;
};

// Tenant info structure
public type TenantInfo record {
    string id;
    string name;
};

// User store info structure
public type UserStoreInfo record {
    string id;
    string name;
};

// Webhook response
public type WebhookResponse record {
    string message;
    boolean success;
};

// Webhook subscription verification parameters
public type SubscriptionVerification record {
    string hubMode;
    string hubTopic;
    string hubChallenge;
    string hubLeaseSeconds;
};