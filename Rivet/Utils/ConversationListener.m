#import "ConversationListener.h"
#import "RealtimeConnection.h"
#import "AppState.h"
#import "LNNotificationsUI_iOS7.1.h"
#import "RivetUserDefaults.h"
#import "Message.h"
#import "SearchHeartbeatGenerator.h"

@interface ConversationListener()<RealtimeChatDelegate>
@end

static RealtimeConnection   *_realtimeConnection;
static ConversationListener *_delegate;
static BOOL                  isListeningToChannel;

@implementation ConversationListener

+ (void)ifNotificationsNotEnabledListenToActiveConversationOrWaitForMatchChannel {
    if (![RivetUserDefaults hasRegisteredPushNotificationToken]) {
        if ([AppState waitForMatchChannel]) {
            [self listenToWaitForMatchChannel];
        } else if ([AppState activeConversation] && [AppState activeConversation].conversationId != 0 && [[AppState activeConversation] isActive]) {
            [self listenToActiveConversation];
        }
        isListeningToChannel = YES;
    }
}

+ (void)stopListeningToEverything {
    [_realtimeConnection stopListeningToChannel:[AppState activeConversation].channel];
    [_realtimeConnection stopListeningToChannel:[AppState waitForMatchChannel]];
    _realtimeConnection = nil;
    isListeningToChannel = NO;
}

+ (void)listenToActiveConversation {
    if (!isListeningToChannel) {
        [[self realtimeConnection] listenToChannel:[AppState activeConversation].channel
                           withEventName:kRealtimeEventName_message
                            withDelegate:[self delegate]
                            withSelector:@selector(messageReceived:)];
        [[self realtimeConnection] listenToChannel:[AppState activeConversation].channel
                           withEventName:kRealtimeEventName_conversationEnded
                            withDelegate:[self delegate]
                                      withSelector:@selector(conversationEnded:)];
    }
}

+ (void)listenToWaitForMatchChannel {
    if (!isListeningToChannel) {
        [[self realtimeConnection] listenToChannel:[AppState waitForMatchChannel]
                                     withEventName:kRealtimeEventName_matchFound
                                      withDelegate:[self delegate]
                                      withSelector:@selector(matchFound)];
    }
}

- (void)matchFound {
    [self showNotificationWithMessage:@"You've been paired into a conversation."];
    [SearchHeartbeatGenerator stopSendingHeartbeat];
}

- (void)messageReceived:(NSDictionary *)dto {
    Message *message = [[Message alloc] initWithDto:dto];
    [self showNotificationWithMessage:[NSString stringWithFormat:@"The other user said: %@", message.text]];
}

- (void)conversationEnded:(NSDictionary *)conversationDetailsDto {
    [self showNotificationWithMessage:@"The other user ended the conversation."];
}

- (void)showNotificationWithMessage:(NSString *)message {
    LNNotification *notification = [LNNotification notificationWithMessage:message];
    [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"rivet"];
}

+ (RealtimeConnection *)realtimeConnection {
    if (!_realtimeConnection) {
        _realtimeConnection = [[RealtimeConnection alloc] initWithDelegate:nil];
    }
    return _realtimeConnection;
}

+ (ConversationListener *)delegate {
    if (!_delegate) {
        _delegate = [[ConversationListener alloc] init];
    }
    return _delegate;
}

@end