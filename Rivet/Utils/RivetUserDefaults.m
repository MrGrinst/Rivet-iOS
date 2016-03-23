#import "RivetUserDefaults.h"
#import "Authentication.h"

NSString *const kUserDefaultsKey_userId = @"userId";
NSString *const kUserDefaultsKey_userProfile = @"userProfile";
NSString *const kUserDefaultsKey_userState = @"userState";
NSString *const kUserDefaultsKey_authToken = @"authToken";
NSString *const kUserDefaultsKey_alreadySlidPrivacyMaskLeft = @"alreadySlidPrivacyMaskLeft";
NSString *const kUserDefaultsKey_registeredPushNotificationToken = @"registeredPushNotificationToken";
NSString *const kUserDefaultsKey_conversationStatus = @"conversationStatus";
NSString *const kUserDefaultsKey_activeConversation = @"activeConversation";
NSString *const kUserDefaultsKey_waitForMatchChannel = @"waitForMatchChannel";
NSString *const kUserDefaultsKey_hasSeenLocationPermissionAlert = @"hasSeenLocationPermissionAlert";
NSString *const kUserDefaultsKey_hasSeenSystemNotificationPermissionAlert = @"hasSeenSystemNotificationPermissionAlert";
NSString *const kUserDefaultsKey_isPrivacyTabOnLeft = @"isPrivacyTabOnLeft";
NSString *const kUserDefaultsKey_buttonTapCountSinceLastNotificationPermissionRequest = @"numberOfConversationsSinceLastNotificationPermissionRequest";
static UICKeyChainStore *_keychainStore;

@implementation RivetUserDefaults

+ (void)setUserId:(NSInteger)userId {
    [self keychainStore][kUserDefaultsKey_userId] = [NSString stringWithFormat:@"%li", (long)userId];
}

+ (NSInteger)userId {
    return ((NSString *)[self keychainStore][kUserDefaultsKey_userId]).integerValue;
}

+ (void)setAuthToken:(NSString *)authToken {
    [self keychainStore][kUserDefaultsKey_authToken] = authToken;
}

+ (NSString *)authToken {
    return [self keychainStore][kUserDefaultsKey_authToken];
}

+ (void)setConversationStatus:(NSString *)conversationStatus {
    [[NSUserDefaults standardUserDefaults] setObject:conversationStatus
                                              forKey:kUserDefaultsKey_conversationStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)conversationStatus {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKey_conversationStatus];
}

+ (void)setActiveConversation:(Conversation *)activeConversation {
    NSData *conversationData = [NSKeyedArchiver archivedDataWithRootObject:activeConversation];
    [[NSUserDefaults standardUserDefaults] setObject:conversationData
                                              forKey:kUserDefaultsKey_activeConversation];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (Conversation *)activeConversation {
    NSData *conversationData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKey_activeConversation];
    if (conversationData) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:conversationData];
    }
    return nil;
}

+ (void)setWaitForMatchChannel:(NSString *)waitForMatchChannel {
    [[NSUserDefaults standardUserDefaults] setObject:waitForMatchChannel
                                              forKey:kUserDefaultsKey_waitForMatchChannel];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)waitForMatchChannel {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKey_waitForMatchChannel];
}

+ (void)setHasRegisteredPushNotificationToken:(BOOL)hasRegisteredPushNotificationToken {
    [[NSUserDefaults standardUserDefaults] setBool:hasRegisteredPushNotificationToken
                                            forKey:kUserDefaultsKey_registeredPushNotificationToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)hasRegisteredPushNotificationToken {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKey_registeredPushNotificationToken];
}

+ (void)setHasSeenLocationPermissionAlert:(BOOL)hasSeenLocationPermissionAlert {
    [[NSUserDefaults standardUserDefaults] setBool:hasSeenLocationPermissionAlert
                                            forKey:kUserDefaultsKey_hasSeenLocationPermissionAlert];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)hasSeenLocationPermissionAlert {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKey_hasSeenLocationPermissionAlert];
}

+ (void)setHasSlidPrivacyMaskLeft:(BOOL)hasSlidPrivacyMaskLeft {
    [[NSUserDefaults standardUserDefaults] setBool:hasSlidPrivacyMaskLeft
                                            forKey:kUserDefaultsKey_alreadySlidPrivacyMaskLeft];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)hasSlidPrivacyMaskLeft {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKey_alreadySlidPrivacyMaskLeft];
}

+ (void)setHasSeenSystemNotificationPermissionAlert:(BOOL)hasSeenSystemNotificationPermissionAlert {
    [[NSUserDefaults standardUserDefaults] setBool:hasSeenSystemNotificationPermissionAlert
                                            forKey:kUserDefaultsKey_hasSeenSystemNotificationPermissionAlert];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)hasSeenSystemNotificationPermissionAlert {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKey_hasSeenSystemNotificationPermissionAlert];
}
+ (void)setIsPrivacyTabOnLeft:(BOOL)isPrivacyTabOnLeft {
    [[NSUserDefaults standardUserDefaults] setBool:isPrivacyTabOnLeft
                                            forKey:kUserDefaultsKey_isPrivacyTabOnLeft];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isPrivacyTabOnLeft {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKey_isPrivacyTabOnLeft];
}

+ (void)setUserProfile:(UserProfile *)user {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:data
                                              forKey:kUserDefaultsKey_userProfile];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UserProfile *)userProfile {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKey_userProfile];
    if (data) {
        @try {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
            [self setUserProfile:nil];
        }
    }
    return nil;
}

+ (UserState *)userState {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKey_userState];
    if (data) {
        @try {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
            [self setUserState:nil];
        }
    }
    return nil;
}

+ (void)setUserState:(UserState *)userState {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userState];
    [[NSUserDefaults standardUserDefaults] setObject:data
                                              forKey:kUserDefaultsKey_userState];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setButtonTapCountSinceLastNotificationPermissionRequest:(NSInteger)count {
    [[NSUserDefaults standardUserDefaults] setInteger:count
                                               forKey:kUserDefaultsKey_buttonTapCountSinceLastNotificationPermissionRequest];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)buttonTapCountSinceLastNotificationPermissionRequest {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultsKey_buttonTapCountSinceLastNotificationPermissionRequest];
}

#pragma mark - Keychain Store

+ (UICKeyChainStore *)keychainStore {
    if (!_keychainStore) {
        _keychainStore = [UICKeyChainStore keyChainStoreWithService:[NSString stringWithFormat:@"com.rivetsocial.%@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]]];
    }
    return _keychainStore;
}

@end
