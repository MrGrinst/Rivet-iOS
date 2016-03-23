#import "QueueStatus.h"
#import "NSDictionary+Rivet.h"
#import "ConversationDetails.h"
#import "ParentConversation.h"

NSString *const kQueueResponseAttribute_channel = @"channel";
NSString *const kQueueResponseAttribute_conversationDetails = @"conversation_details";
NSString *const kQueueResponseAttribute_parentConversations = @"parent_conversations";
NSString *const kQueueResponseAttribute_isInQueue = @"is_in_queue";
NSString *const kQueueResponseAttribute_matchFound = @"match_found";

@implementation QueueStatus

- (id)initWithDto:(NSDictionary *)dto {
    if (self = [super init]) {
        self.channel = [dto objectOrNilForKey:kQueueResponseAttribute_channel];
        self.isInQueue = [dto boolForKey:kQueueResponseAttribute_isInQueue];
        self.matchFound = [dto boolForKey:kQueueResponseAttribute_matchFound];
        NSMutableArray *tempParents = [[NSMutableArray alloc] init];
        NSArray *parentConversations = [dto objectOrNilForKey:kConversationAttribute_parentConversations];
        for (NSDictionary *dto in parentConversations) {
            [tempParents addObject:[[ParentConversation alloc] initWithDto:dto]];
        }
        self.conversationDetails = [[ConversationDetails alloc] initWithDto:[dto objectOrNilForKey:kQueueResponseAttribute_conversationDetails]];
        self.conversationDetails.parentConversations = tempParents;
    }
    return self;
}

@end