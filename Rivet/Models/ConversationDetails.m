#import "ConversationDetails.h"
#import "DateUtil.h"
#import "NSDictionary+Rivet.h"
#import "ParentConversation.h"

NSString *const kConversationAttribute_conversationId = @"conversation_id";
NSString *const kConversationAttribute_endTime = @"end_time";
NSString *const kConversationAttribute_isFeatured = @"is_featured";
NSString *const kConversationAttribute_score = @"score";
NSString *const kConversationAttribute_myParticipantNumber = @"my_participant_number";
NSString *const kConversationAttribute_channel = @"channel";
NSString *const kConversationAttribute_participantNumberOfUserThatEnded = @"ended_by_participant_number";
NSString *const kConversationAttribute_description = @"description";
NSString *const kConversationAttribute_pictureUrl = @"picture_url";
NSString *const kConversationAttribute_headline = @"headline";
NSString *const kConversationAttribute_myCurrentVote = @"my_current_vote";
NSString *const kConversationAttribute_parentConversations = @"parent_conversations";
NSString *const kConversationAttribute_childConversationCount = @"child_conversation_count";

@implementation ConversationDetails

- (id)initWithDto:(NSDictionary *)dto {
    if (self = [self init]) {
        self.conversationId = [dto intOrZeroForKey:kConversationAttribute_conversationId];
        self.isFeatured = [dto boolForKey:kConversationAttribute_isFeatured];
        self.score = [dto intOrZeroForKey:kConversationAttribute_score];
        self.myParticipantNumber = [dto intOrZeroForKey:kConversationAttribute_myParticipantNumber];
        self.channel = [dto objectOrNilForKey:kConversationAttribute_channel];
        self.participantNumberOfUserThatEnded = [dto intOrZeroForKey:kConversationAttribute_participantNumberOfUserThatEnded];
        self.desc = [dto objectOrNilForKey:kConversationAttribute_description];
        self.pictureUrl = [dto objectOrNilForKey:kConversationAttribute_pictureUrl];
        self.headline = [dto objectOrNilForKey:kConversationAttribute_headline];
        self.myCurrentVote = [dto intOrZeroForKey:kConversationAttribute_myCurrentVote];
        self.endTime = [DateUtil dateFromServerString:[dto objectOrNilForKey:kConversationAttribute_endTime]];
        self.childConversationCount = [dto intOrZeroForKey:kConversationAttribute_childConversationCount];
        NSMutableArray *tempParents = [[NSMutableArray alloc] init];
        NSArray *parentConversations = [dto objectOrNilForKey:kConversationAttribute_parentConversations];
        for (NSDictionary *dto in parentConversations) {
            [tempParents addObject:[[ParentConversation alloc] initWithDto:dto]];
        }
        self.parentConversations = tempParents;
    }
    return self;
}

@end