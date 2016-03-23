#import <Pusher/Pusher.h>
#import "RealtimeConnection.h"

#define pusherAuthURL [[NSBundle mainBundle] objectForInfoDictionaryKey:@"pusherAuthURL"]
#define pusherKey [[NSBundle mainBundle] objectForInfoDictionaryKey:@"pusherKey"]

NSString *const kRealtimeEventName_message = @"MESSAGE";
NSString *const kRealtimeEventName_matchFound = @"MATCH_FOUND";
NSString *const kRealtimeEventName_conversationEnded = @"CONVERSATION_END";
NSString *const kRealtimeEventName_conversationUpdated = @"CONVERSATION_UPDATED";
NSString *const kRealtimeEventName_typingEvent = @"client-TYPING";

@interface RealtimeConnection()

@property (strong, nonatomic) PTPusher            *pusher;
@property (strong, nonatomic) NSMutableDictionary *channelNamesToBindings;

@end

@implementation RealtimeConnection

#pragma mark - Init

- (id)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        self.pusher = [PTPusher pusherWithKey:pusherKey delegate:nil];
        self.pusher.authorizationURL = [NSURL URLWithString:pusherAuthURL];
        [self.pusher connect];
    }
    return self;
}

#pragma mark - Getters

- (NSMutableDictionary *)channelNamesToBindings {
    if (!_channelNamesToBindings) {
        _channelNamesToBindings = [[NSMutableDictionary alloc] init];
    }
    return _channelNamesToBindings;
}

#pragma mark - Channel Management

- (void)listenToChannel:(NSString *)channelName
          withEventName:(NSString *)eventName
           withDelegate:(NSObject<RealtimeChatDelegate> *)delegate
           withSelector:(SEL)selector {
    __weak id weakDelegate = delegate;
    PTPusherChannel *channel = [self.pusher channelNamed:channelName];
    if (!channel) {
        NSRange range = [channelName rangeOfString:@"private"];
        if (range.location != NSNotFound) {
            channel = [self.pusher subscribeToPrivateChannelNamed:[channelName stringByReplacingOccurrencesOfString:@"private-" withString:@""]];
        } else {
            channel = [self.pusher subscribeToChannelNamed:channelName];
        }
    }
    NSMutableArray *bindingsForChannel = [self.channelNamesToBindings objectForKey:channelName];
    if (!bindingsForChannel) {
        bindingsForChannel = [[NSMutableArray alloc] init];
    }
    PTPusherEventBinding *binding = [channel bindToEventNamed:eventName handleWithBlock:^(PTPusherEvent *event) {
        IMP imp = [weakDelegate methodForSelector:selector];
        void (*func)(id, SEL, NSDictionary *) = (void *)imp;
        func(weakDelegate, selector, event.data);
    }];
    [bindingsForChannel addObject:binding];
}

- (void)publishTypingEventToChannel:(NSString *)channelName
              withParticipantNumber:(NSInteger)participantNumber {
    if (channelName) {
        PTPusherPrivateChannel *channel = (PTPusherPrivateChannel *)[self.pusher channelNamed:channelName];
        [channel triggerEventNamed:kRealtimeEventName_typingEvent data:@{@"participant_number": @(participantNumber)}];
    }
}

- (void)stopListeningToChannel:(NSString *)channelName {
    if (channelName) {
        PTPusherChannel *channel = [self.pusher channelNamed:channelName];
        [channel unsubscribe];
        for (PTPusherEventBinding *binding in [self.channelNamesToBindings objectForKey:channelName]) {
            [self.pusher removeBinding:binding];
        }
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.pusher disconnect];
}

@end