#import <Foundation/Foundation.h>

NSString *const kConversationAttribute_conversationId;
NSString *const kConversationAttribute_endTime;
NSString *const kConversationAttribute_isFeatured;
NSString *const kConversationAttribute_score;
NSString *const kConversationAttribute_myParticipantNumber;
NSString *const kConversationAttribute_channel;
NSString *const kConversationAttribute_participantNumberOfUserThatEnded;
NSString *const kConversationAttribute_description;
NSString *const kConversationAttribute_pictureUrl;
NSString *const kConversationAttribute_headline;
NSString *const kConversationAttribute_myCurrentVote;
NSString *const kConversationAttribute_parentConversations;
NSString *const kConversationAttribute_childConversationCount;

@interface ConversationDetails : NSObject

@property (nonatomic) NSInteger         conversationId;
@property (nonatomic) BOOL              isFeatured;
@property (nonatomic) NSInteger         score;
@property (nonatomic) NSInteger         myParticipantNumber;
@property (nonatomic) NSInteger         participantNumberOfUserThatEnded;
@property (nonatomic) NSInteger         childConversationCount;
@property (strong, nonatomic) NSDate   *endTime;
@property (strong, nonatomic) NSString *channel;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *pictureUrl;
@property (strong, nonatomic) NSString *headline;
@property (strong, nonatomic) NSArray  *parentConversations;
@property (nonatomic) NSInteger         myCurrentVote;

- (id)initWithDto:(NSDictionary *)dto;

@end