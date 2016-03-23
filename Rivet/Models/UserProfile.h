#import <Foundation/Foundation.h>

@interface UserProfile : NSObject

@property (nonatomic) NSInteger         conversationCount;
@property (nonatomic) NSInteger         conversationsScore;
@property (nonatomic) NSInteger         secondsInConversation;
@property (nonatomic) NSInteger         medianMessagesPerConversation;

- (id)initWithDto:(NSDictionary *)dto;

@end