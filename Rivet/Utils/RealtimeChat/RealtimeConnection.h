#import <Foundation/Foundation.h>
#import <Pusher/Pusher.h>
#import "RealtimeChatDelegate.h"

NSString *const kRealtimeEventName_message;
NSString *const kRealtimeEventName_matchFound;
NSString *const kRealtimeEventName_conversationEnded;
NSString *const kRealtimeEventName_conversationUpdated;
NSString *const kRealtimeEventName_typingEvent;

@interface RealtimeConnection : NSObject<PTPusherDelegate>

- (id)initWithDelegate:(id)delegate;

- (void)listenToChannel:(NSString *)channelName
          withEventName:(NSString *)eventName
           withDelegate:(NSObject<RealtimeChatDelegate> *)delegate
           withSelector:(SEL)selector;

- (void)stopListeningToChannel:(NSString *)channelName;

- (void)publishTypingEventToChannel:(NSString *)channelName
              withParticipantNumber:(NSInteger)participantNumber;

@end