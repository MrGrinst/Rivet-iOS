#import <Foundation/Foundation.h>

@interface ConversationListener : NSObject

+ (void)ifNotificationsNotEnabledListenToActiveConversationOrWaitForMatchChannel;
+ (void)stopListeningToEverything;

@end