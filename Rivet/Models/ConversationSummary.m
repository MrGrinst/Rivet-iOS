#import "ConversationSummary.h"
#import "NSDictionary+Rivet.h"
#import "Message.h"
#import "DateUtil.h"
#import "CachedConversationSummary+Extra.h"
#import "SortUtil.h"

@implementation ConversationSummary

- (id)initWithCachedConversationSummary:(CachedConversationSummary *)cachedConversationSummary {
    if (self = [super init]) {
        self.conversationId = (long)cachedConversationSummary.conversationId;
        self.endTime = cachedConversationSummary.endTime;
        self.messageCount = cachedConversationSummary.messageCount;
        self.score = cachedConversationSummary.score;
        self.myCurrentVote = cachedConversationSummary.myCurrentVote;
        self.headline = cachedConversationSummary.headline;
        self.isFeatured = cachedConversationSummary.isFeatured;
        self.desc = cachedConversationSummary.desc;
        self.pictureUrl = cachedConversationSummary.pictureUrl;
        self.lastMessageSentByMe = cachedConversationSummary.lastMessageSentByMe;
    }
    return self;
}

- (id)initWithDto:(NSDictionary *)dto {
    if (self = [super init]) {
        self.conversationId = [dto intOrZeroForKey:kConversationSummaryAttribute_conversationId];
        self.endTime = [DateUtil dateFromServerString: [dto objectOrNilForKey:kConversationSummaryAttribute_endTime]];
        self.messageCount = [dto intOrZeroForKey:kConversationSummaryAttribute_messageCount];
        self.score = [dto intOrZeroForKey:kConversationSummaryAttribute_score];
        self.myCurrentVote = [dto intOrZeroForKey:kConversationSummaryAttribute_myCurrentVote];
        self.headline = [dto objectForKey:kConversationSummaryAttribute_headline];
        self.isFeatured = [dto boolForKey:kConversationSummaryAttribute_isFeatured];
        self.pictureUrl = [dto objectOrNilForKey:kConversationSummaryAttribute_pictureUrl];
        self.lastMessageSentByMe = [dto objectOrNilForKey:kConversationSummaryAttribute_lastMessageSentByMe];
        self.desc = [dto objectOrNilForKey:kConversationSummaryAttribute_description];
    }
    return self;
}

@end