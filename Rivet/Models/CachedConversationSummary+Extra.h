#import <Foundation/Foundation.h>
#import "CachedConversationSummary.h"

NSString *const kConversationSummaryAttribute_conversationId;
NSString *const kConversationSummaryAttribute_endTime;
NSString *const kConversationSummaryAttribute_messageCount;
NSString *const kConversationSummaryAttribute_score;
NSString *const kConversationSummaryAttribute_myCurrentVote;
NSString *const kConversationSummaryAttribute_isFeatured;
NSString *const kConversationSummaryAttribute_headline;
NSString *const kConversationSummaryAttribute_description;
NSString *const kConversationSummaryAttribute_lastMessageSentByMe;
NSString *const kConversationSummaryAttribute_pictureUrl;

@interface CachedConversationSummary (Extra)

+ (CachedConversationSummary *)createWithDto:(NSDictionary *)dto withListType:(NSString *)listType;

@end