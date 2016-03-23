#import <Foundation/Foundation.h>
#import "ConversationDetails.h"

@interface Conversation : NSObject

@property (nonatomic) NSInteger               conversationId;
@property (nonatomic) BOOL                    isFeatured;
@property (nonatomic) NSInteger               score;
@property (nonatomic) NSInteger               myParticipantNumber;
@property (nonatomic) NSInteger               participantNumberOfUserThatEnded;
@property (strong, nonatomic) NSString       *channel;
@property (nonatomic) NSInteger               childConversationCount;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSDate         *endTime;
@property (strong, nonatomic) NSString       *desc;
@property (strong, nonatomic) NSString       *pictureUrl;
@property (strong, nonatomic) NSString       *headline;
@property (strong, nonatomic) NSArray        *parentConversations;
@property (nonatomic) NSInteger               myCurrentVote;
@property (nonatomic) BOOL                    otherUserTyping;

- (id)initWithConversationDetails:(ConversationDetails *)conversationDetails
                     withMessages:(NSArray *)messages;
- (void)updateWithConversationDetails:(ConversationDetails *)conversationDetails
                         withMessages:(NSArray *)messages;
- (BOOL)isActive;

@end