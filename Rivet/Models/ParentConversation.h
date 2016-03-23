#import <Foundation/Foundation.h>

@interface ParentConversation : NSObject

@property (nonatomic) NSInteger         conversationId;
@property (strong, nonatomic) NSString *headline;
@property (strong, nonatomic) NSString *desc;
@property (nonatomic) NSInteger         participantNumber;

- (id)initWithDto:(NSDictionary *)dto;

@end