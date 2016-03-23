#import "ParentConversation.h"
#import "NSDictionary+Rivet.h"

NSString *const kParentConversationAttribute_conversationId = @"conversation_id";
NSString *const kParentConversationAttribute_headline = @"headline";
NSString *const kParentConversationAttribute_description = @"description";
NSString *const kParentConversationAttribute_participantNumber = @"participant_number";

@implementation ParentConversation

- (id)initWithDto:(NSDictionary *)dto {
    if (self = [self init]) {
        self.conversationId = [dto intOrZeroForKey:kParentConversationAttribute_conversationId];
        self.headline = [dto objectOrNilForKey:kParentConversationAttribute_headline];
        self.desc = [dto objectOrNilForKey:kParentConversationAttribute_description];
        self.participantNumber = [dto intOrZeroForKey:kParentConversationAttribute_participantNumber];
    }
    return self;
}

#pragma mark - Encode/Decode

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.conversationId forKey:kParentConversationAttribute_conversationId];
    [encoder encodeObject:self.headline forKey:kParentConversationAttribute_headline];
    [encoder encodeObject:self.desc forKey:kParentConversationAttribute_description];
    [encoder encodeInteger:self.participantNumber forKey:kParentConversationAttribute_participantNumber];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.conversationId = [decoder decodeIntegerForKey:kParentConversationAttribute_conversationId];
        self.headline = [decoder decodeObjectForKey:kParentConversationAttribute_headline];
        self.desc = [decoder decodeObjectForKey:kParentConversationAttribute_description];
        self.participantNumber = [decoder decodeIntegerForKey:kParentConversationAttribute_participantNumber];
    }
    return self;
}

@end