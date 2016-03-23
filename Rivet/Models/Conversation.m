#import "Conversation.h"
#import "SortUtil.h"
#import "Message.h"

NSString *const kConversationAttribute_messages = @"messages";

@implementation Conversation

- (id)init {
    if (self = [super init]) {
        self.messages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithConversationDetails:(ConversationDetails *)conversationDetails
                     withMessages:(NSArray *)messages {
    if (self = [self init]) {
        self.conversationId = conversationDetails.conversationId;
        self.myParticipantNumber = conversationDetails.myParticipantNumber;
        self.channel = conversationDetails.channel;
        self.isFeatured = conversationDetails.isFeatured;
        self.headline = conversationDetails.headline;
        self.parentConversations = conversationDetails.parentConversations;
        self.desc = conversationDetails.desc;
        self.pictureUrl = conversationDetails.pictureUrl;
        self.childConversationCount = conversationDetails.childConversationCount;
        [self updateWithConversationDetails:conversationDetails withMessages:messages];
    }
    return self;
}

- (void)updateWithConversationDetails:(ConversationDetails *)conversationDetails
                         withMessages:(NSArray *)messages {
    self.endTime = conversationDetails.endTime;
    self.score = conversationDetails.score;
    self.participantNumberOfUserThatEnded = conversationDetails.participantNumberOfUserThatEnded;
    self.myCurrentVote = conversationDetails.myCurrentVote;
    for (Message *m in messages) {
        if (![self messageAlreadyExists:m]) {
            [self.messages addObject:m];
        }
    }
    self.messages = [SortUtil sort:self.messages byAttribute:@"timestamp" ascending:YES].mutableCopy;
    if (!self.channel && conversationDetails.channel) {
        self.channel = conversationDetails.channel;
    }
}

- (BOOL)messageAlreadyExists:(Message *)message {
    Message *existingMessage;
    for (int i = (int)self.messages.count - 1; i >= 0; i--) {
        Message *m = [self.messages objectAtIndex:i];
        if (message.messageId == m.messageId) {
            existingMessage = m;
            break;
        }
    }
    return existingMessage != nil;
}

- (BOOL)isActive {
    return self.endTime == nil;
}

#pragma mark - Encode/Decode

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.conversationId forKey:kConversationAttribute_conversationId];
    [encoder encodeBool:self.isFeatured forKey:kConversationAttribute_isFeatured];
    [encoder encodeInteger:self.score forKey:kConversationAttribute_score];
    [encoder encodeInteger:self.myParticipantNumber forKey:kConversationAttribute_myParticipantNumber];
    [encoder encodeInteger:self.participantNumberOfUserThatEnded forKey:kConversationAttribute_participantNumberOfUserThatEnded];
    [encoder encodeObject:self.channel forKey:kConversationAttribute_channel];
    [encoder encodeObject:self.endTime forKey:kConversationAttribute_endTime];
    [encoder encodeObject:self.messages forKey:kConversationAttribute_messages];
    [encoder encodeObject:self.headline forKey:kConversationAttribute_headline];
    [encoder encodeObject:self.pictureUrl forKey:kConversationAttribute_pictureUrl];
    [encoder encodeObject:self.desc forKey:kConversationAttribute_description];
    [encoder encodeObject:self.parentConversations forKey:kConversationAttribute_parentConversations];
    [encoder encodeInteger:self.myCurrentVote forKey:kConversationAttribute_myCurrentVote];
    [encoder encodeInteger:self.childConversationCount forKey:kConversationAttribute_childConversationCount];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.conversationId = [decoder decodeIntegerForKey:kConversationAttribute_conversationId];
        self.isFeatured = [decoder decodeBoolForKey:kConversationAttribute_isFeatured];
        self.score = [decoder decodeIntegerForKey:kConversationAttribute_score];
        self.myParticipantNumber = [decoder decodeIntegerForKey:kConversationAttribute_myParticipantNumber];
        self.participantNumberOfUserThatEnded = [decoder decodeIntegerForKey:kConversationAttribute_participantNumberOfUserThatEnded];
        self.endTime = [decoder decodeObjectForKey:kConversationAttribute_endTime];
        self.channel = [decoder decodeObjectForKey:kConversationAttribute_channel];
        self.messages = [decoder decodeObjectForKey:kConversationAttribute_messages];
        self.headline = [decoder decodeObjectForKey:kConversationAttribute_headline];
        self.pictureUrl = [decoder decodeObjectForKey:kConversationAttribute_pictureUrl];
        self.desc = [decoder decodeObjectForKey:kConversationAttribute_description];
        self.parentConversations = [decoder decodeObjectForKey:kConversationAttribute_parentConversations];
        self.myCurrentVote = [decoder decodeIntegerForKey:kConversationAttribute_myCurrentVote];
        self.childConversationCount = [decoder decodeIntegerForKey:kConversationAttribute_childConversationCount];
    }
    return self;
}

@end