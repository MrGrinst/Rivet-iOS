#import "UserProfile.h"
#import "NSDictionary+Rivet.h"

NSString *const kUserAttribute_conversationCount = @"conversations_count";
NSString *const kUserAttribute_conversationsScore = @"conversations_total_score";
NSString *const kUserAttribute_secondsInConversation = @"seconds_in_conversation";
NSString *const kUserAttribute_medianMessagesPerConversation = @"median_messages_per_conversation";

@implementation UserProfile

- (id)initWithDto:(NSDictionary *)dto {
    if (self = [super init]) {
        self.conversationCount = [dto intOrZeroForKey:kUserAttribute_conversationCount];
        self.conversationsScore = [dto intOrZeroForKey:kUserAttribute_conversationsScore];
        if (self.conversationsScore < 0) self.conversationsScore = 0;
        self.secondsInConversation = [dto intOrZeroForKey:kUserAttribute_secondsInConversation];
        self.medianMessagesPerConversation = [dto intOrZeroForKey:kUserAttribute_medianMessagesPerConversation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.conversationCount = ((NSNumber *)[decoder decodeObjectForKey:kUserAttribute_conversationCount]).integerValue;
        self.conversationsScore = ((NSNumber *)[decoder decodeObjectForKey:kUserAttribute_conversationsScore]).integerValue;
        self.secondsInConversation = ((NSNumber *)[decoder decodeObjectForKey:kUserAttribute_secondsInConversation]).integerValue;
        self.medianMessagesPerConversation = ((NSNumber *)[decoder decodeObjectForKey:kUserAttribute_medianMessagesPerConversation]).integerValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:@(self.conversationCount) forKey:kUserAttribute_conversationCount];
    [encoder encodeObject:@(self.conversationsScore) forKey:kUserAttribute_conversationsScore];
    [encoder encodeObject:@(self.secondsInConversation) forKey:kUserAttribute_secondsInConversation];
    [encoder encodeObject:@(self.medianMessagesPerConversation) forKey:kUserAttribute_medianMessagesPerConversation];
}

@end