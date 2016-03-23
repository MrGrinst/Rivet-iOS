#import <Foundation/Foundation.h>
#import "Conversation.h"
#import "UserProfile.h"
#import "UserState.h"

@interface RivetUserDefaults : NSObject

+ (void)setUserId:(NSInteger)userId;
+ (NSInteger)userId;

+ (void)setAuthToken:(NSString *)authToken;
+ (NSString *)authToken;

+ (void)setConversationStatus:(NSString *)conversationStatus;
+ (NSString *)conversationStatus;

+ (void)setActiveConversation:(Conversation *)activeConversation;
+ (Conversation *)activeConversation;

+ (void)setWaitForMatchChannel:(NSString *)waitForMatchChannel;
+ (NSString *)waitForMatchChannel;

+ (void)setHasRegisteredPushNotificationToken:(BOOL)hasRegisteredPushNotificationToken;
+ (BOOL)hasRegisteredPushNotificationToken;

+ (void)setHasSeenLocationPermissionAlert:(BOOL)hasSeenLocationPermissionAlert;
+ (BOOL)hasSeenLocationPermissionAlert;

+ (void)setHasSlidPrivacyMaskLeft:(BOOL)hasSlidPrivacyMaskLeft;
+ (BOOL)hasSlidPrivacyMaskLeft;

+ (void)setHasSeenSystemNotificationPermissionAlert:(BOOL)hasSeenSystemNotificationPermissionAlert;
+ (BOOL)hasSeenSystemNotificationPermissionAlert;

+ (void)setIsPrivacyTabOnLeft:(BOOL)isPrivacyTabOnLeft;
+ (BOOL)isPrivacyTabOnLeft;

+ (void)setUserProfile:(UserProfile *)user;
+ (UserProfile *)userProfile;

+ (UserState *)userState;
+ (void)setUserState:(UserState *)userState;

+ (void)setButtonTapCountSinceLastNotificationPermissionRequest:(NSInteger)count;
+ (NSInteger)buttonTapCountSinceLastNotificationPermissionRequest;

@end
