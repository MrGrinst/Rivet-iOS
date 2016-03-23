#import <Foundation/Foundation.h>
#import "Conversation.h"
#import "UserState.h"

NSString *const kConversationMode_Waiting;
NSString *const kConversationMode_PreWaiting;
NSString *const kConversationMode_Conversing;

@interface AppState : NSObject

+ (NSString *)conversationStatus;
+ (void)setConversationStatus:(NSString *)conversationStatus;

+ (Conversation *)activeConversation;
+ (void)setActiveConversation:(Conversation *)activeConversation;
+ (void)saveConversationDataToUserDefaults;

+ (NSString *)waitForMatchChannel;
+ (void)setWaitForMatchChannel:(NSString *)waitForMatchChannel;

+ (NSNumber *)selectedSegmentIndexOnConversationListView;
+ (void)setSelectedSegmentIndexOnConversationListView:(NSNumber *)selectedSegmentIndexOnConversationListView;

+ (BOOL)justOpenedApp;
+ (void)setJustOpenedApp:(BOOL)justOpenedApp;

+ (UserState *)userState;
+ (void)setUserState:(UserState *)userState;

+ (NSTimeInterval)timeSinceLastListViewRefresh;
+ (void)setTimestampOfLastListViewRefresh:(NSDate *)timestampOfLastListViewRefresh;

@end