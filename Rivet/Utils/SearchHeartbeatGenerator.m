#import "SearchHeartbeatGenerator.h"
#import "ConversationRepository.h"

NSInteger const kHeartbeatInterval = 60 * 5 - 2;

static NSTimer *heartbeatTimer;
static NSDate  *lastHeartbeatSent;

@implementation SearchHeartbeatGenerator

+ (void)startSendingHeartbeat {
    if (!heartbeatTimer) {
        heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:kHeartbeatInterval
                                                          target:self
                                                        selector:@selector(sendHeartbeat)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

+ (void)startSendingHeartbeatRightAway {
    if (!heartbeatTimer) {
        [self sendHeartbeat];
        [self startSendingHeartbeat];
    }
}

+ (void)stopSendingHeartbeat {
    [heartbeatTimer invalidate];
    heartbeatTimer = nil;
    lastHeartbeatSent = nil;
}

+ (void)sendHeartbeat {
    NSTimeInterval timeSinceLastHeartbeat = [[NSDate date] timeIntervalSinceDate:lastHeartbeatSent];
    if (!lastHeartbeatSent || timeSinceLastHeartbeat <= kHeartbeatInterval + 0.5) {
        lastHeartbeatSent = [NSDate date];
        [ConversationRepository updateHeartbeatWithFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self stopSendingHeartbeat];
        }];
    } else {
        [self stopSendingHeartbeat];
    }
}

@end