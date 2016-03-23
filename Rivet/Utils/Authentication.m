#import "Authentication.h"
#import "UserRepository.h"
#import "ConstUtil.h"
#import "RivetUserDefaults.h"
#import <Crashlytics/Crashlytics.h>
#import "EventTrackingUtil.h"

@implementation Authentication

+ (BOOL)isUserLoggedIn {
    return [RivetUserDefaults authToken] != nil;
}

+ (void)saveNewUser:(NewUser *)newUser {
    [RivetUserDefaults setAuthToken:newUser.authToken];
    [RivetUserDefaults setUserId:newUser.userId];
    [CrashlyticsKit setUserIdentifier:[NSString stringWithFormat:@"%li", (long)newUser.userId]];
    [EventTrackingUtil setUserId:newUser.userId];
    [EventTrackingUtil openedApp];
}

+ (void)resetCredentials {
    [RivetUserDefaults setAuthToken:nil];
    [RivetUserDefaults setUserId:-1];
}

@end