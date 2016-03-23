#import <Foundation/Foundation.h>

@interface SearchHeartbeatGenerator : NSObject

+ (void)startSendingHeartbeat;
+ (void)startSendingHeartbeatRightAway;
+ (void)stopSendingHeartbeat;

@end