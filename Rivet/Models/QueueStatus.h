#import <Foundation/Foundation.h>
#import "ConversationDetails.h"

@interface QueueStatus : NSObject

@property (strong, nonatomic) NSString            *channel;
@property (strong, nonatomic) ConversationDetails *conversationDetails;
@property (nonatomic) BOOL                         isInQueue;
@property (nonatomic) BOOL                         matchFound;

- (id)initWithDto:(NSDictionary *)dto;

@end