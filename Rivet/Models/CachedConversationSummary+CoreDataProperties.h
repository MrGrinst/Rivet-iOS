#import "CachedConversationSummary.h"

NS_ASSUME_NONNULL_BEGIN

@interface CachedConversationSummary (CoreDataProperties)

@property (nonatomic) int64_t conversationId;
@property (nullable, nonatomic, retain) NSDate *endTime;
@property (nullable, nonatomic, retain) NSString *headline;
@property (nonatomic) BOOL isFeatured;
@property (nullable, nonatomic, retain) NSString *listType;
@property (nonatomic) int16_t messageCount;
@property (nonatomic) int16_t myCurrentVote;
@property (nonatomic) int16_t score;
@property (nullable, nonatomic, retain) NSString *pictureUrl;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSString *lastMessageSentByMe;

@end

NS_ASSUME_NONNULL_END
