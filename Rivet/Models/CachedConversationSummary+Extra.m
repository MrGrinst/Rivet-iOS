#import "CachedConversationSummary+Extra.h"
#import "ConstUtil.h"
#import "UserProfile.h"
#import "ObjectiveRecord.h"
#import "NSDictionary+Rivet.h"
#import "DateUtil.h"
#import "Message.h"

NSString *const kConversationSummaryAttribute_conversationId = @"conversation_id";
NSString *const kConversationSummaryAttribute_endTime = @"end_time";
NSString *const kConversationSummaryAttribute_messageCount = @"message_count";
NSString *const kConversationSummaryAttribute_score = @"score";
NSString *const kConversationSummaryAttribute_myCurrentVote = @"my_current_vote";
NSString *const kConversationSummaryAttribute_isFeatured = @"is_featured";
NSString *const kConversationSummaryAttribute_headline = @"headline";
NSString *const kConversationSummaryAttribute_description = @"description";
NSString *const kConversationSummaryAttribute_lastMessageSentByMe = @"last_message_sent_by_me";
NSString *const kConversationSummaryAttribute_pictureUrl = @"picture_url";

@implementation CachedConversationSummary (Extra)

+ (CachedConversationSummary *)createWithDto:(NSDictionary *)dto withListType:(NSString *)listType {
    CachedConversationSummary *css = [CachedConversationSummary create];
    css.conversationId = [dto intOrZeroForKey:kConversationSummaryAttribute_conversationId];
    css.endTime = [DateUtil dateFromServerString: [dto objectOrNilForKey:kConversationSummaryAttribute_endTime]];
    css.messageCount = [dto intOrZeroForKey:kConversationSummaryAttribute_messageCount];
    css.score = [dto intOrZeroForKey:kConversationSummaryAttribute_score];
    css.myCurrentVote = [dto intOrZeroForKey:kConversationSummaryAttribute_myCurrentVote];
    css.headline = [dto objectOrNilForKey:kConversationSummaryAttribute_headline];
    css.isFeatured = [dto boolForKey:kConversationSummaryAttribute_isFeatured];
    css.pictureUrl = [dto objectOrNilForKey:kConversationSummaryAttribute_pictureUrl];
    css.lastMessageSentByMe = [dto objectOrNilForKey:kConversationSummaryAttribute_lastMessageSentByMe];
    css.desc = [dto objectOrNilForKey:kConversationSummaryAttribute_description];
    css.listType = listType;
    return css;
}

@end