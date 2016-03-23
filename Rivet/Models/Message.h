#import <Foundation/Foundation.h>

NSString *const kMessageAttribute_messageId;
NSString *const kMessageAttribute_participantNumber;
NSString *const kMessageAttribute_timestamp;
NSString *const kMessageAttribute_text;
NSString *const kMessageAttribute_isPrivate;

@interface Message : NSObject

@property (nonatomic) NSInteger         messageId;
@property (nonatomic) NSInteger         participantNumber;
@property (strong, nonatomic) NSDate   *timestamp;
@property (nonatomic) BOOL              isPrivate;
@property (strong, nonatomic) NSString *text;

- (id)initWithDto:(NSDictionary *)dto;
- (BOOL)isFromMe:(NSInteger)myParticipantNumber;
- (BOOL)isOnLeftWithMyParticipantNumber:(NSInteger)myParticipantNumber;

@end