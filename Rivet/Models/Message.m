#import "Message.h"
#import <UIKit/UIKit.h>
#import "IOS8-3SpecificEmojis.h"
#import "NSDictionary+Rivet.h"
#import "DateUtil.h"

NSString *const kMessageAttribute_messageId = @"message_id";
NSString *const kMessageAttribute_participantNumber = @"participant_number";
NSString *const kMessageAttribute_timestamp = @"recorded_at";
NSString *const kMessageAttribute_isPrivate = @"is_private";
NSString *const kMessageAttribute_text = @"text";

@implementation Message

- (id)initWithDto:(NSDictionary *)dto {
    if ((self = [super init])) {
        self.messageId = [dto intOrZeroForKey:kMessageAttribute_messageId];
        self.participantNumber = [dto intOrZeroForKey:kMessageAttribute_participantNumber];
        self.timestamp = [DateUtil dateFromServerString:[dto objectOrNilForKey:kMessageAttribute_timestamp]];
        self.isPrivate = NO;
        self.text = [dto objectOrNilForKey:kMessageAttribute_text];
    }
    return self;
}

#pragma mark - Getters

- (BOOL)isFromMe:(NSInteger)myParticipantNumber {
    return self.participantNumber == myParticipantNumber;
}

#pragma mark - Setters

- (void)setText:(NSString *)text {
    _text = text;
    NSString *reqSysVer = @"8.3";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending) {
        for (NSString *ios83Emoji in [IOS8_3SpecificEmojis ios83SpecificEmojis]) {
            _text = [_text stringByReplacingOccurrencesOfString:ios83Emoji  withString:@""];
        }
    }
}

- (BOOL)isOnLeftWithMyParticipantNumber:(NSInteger)myParticipantNumber {
    BOOL messageIsFromMe = myParticipantNumber == self.participantNumber;
    BOOL selfParticipated = myParticipantNumber != -1;
    return (selfParticipated && !messageIsFromMe)
           || (!selfParticipated && self.participantNumber == 1);
}


#pragma mark - Encode/Decode

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.messageId = ((NSNumber *)[decoder decodeObjectForKey:kMessageAttribute_messageId]).integerValue;
        self.text = [decoder decodeObjectForKey:kMessageAttribute_text];
        self.participantNumber = ((NSNumber *)[decoder decodeObjectForKey:kMessageAttribute_participantNumber]).integerValue;
        self.timestamp = [decoder decodeObjectForKey:kMessageAttribute_timestamp];
        self.isPrivate = ((NSNumber *)[decoder decodeObjectForKey:kMessageAttribute_isPrivate]).boolValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:@(self.messageId) forKey:kMessageAttribute_messageId];
    [encoder encodeObject:self.text forKey:kMessageAttribute_text];
    [encoder encodeObject:@(self.participantNumber) forKey:kMessageAttribute_participantNumber];
    [encoder encodeObject:self.timestamp forKey:kMessageAttribute_timestamp];
    [encoder encodeObject:@(self.isPrivate) forKey:kMessageAttribute_isPrivate];
}

@end