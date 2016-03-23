#import "ConversationCache.h"
#import "ObjectiveRecord.h"
#import "ConversationSummary.h"

@implementation ConversationCache

+ (NSArray *)globalFeaturedConversationCache {
    NSMutableArray *summaries = [[NSMutableArray alloc] init];
    for (CachedConversationSummary *css in [CachedConversationSummary where:@"listType == 'FEATURED'"]) {
        [summaries addObject:[[ConversationSummary alloc] initWithCachedConversationSummary:css]];
    }
    return summaries;
}

+ (NSArray *)nearbyFeaturedConversationCache {
    NSMutableArray *summaries = [[NSMutableArray alloc] init];
    for (CachedConversationSummary *css in [CachedConversationSummary where:@"listType == 'NEARBY'"]) {
        [summaries addObject:[[ConversationSummary alloc] initWithCachedConversationSummary:css]];
    }
    return summaries;
}

+ (NSArray *)myConversationsCache {
    NSMutableArray *summaries = [[NSMutableArray alloc] init];
    for (CachedConversationSummary *css in [CachedConversationSummary where:@"listType == 'MY_CONVERSATIONS'"]) {
        [summaries addObject:[[ConversationSummary alloc] initWithCachedConversationSummary:css]];
    }
    return summaries;
}

@end