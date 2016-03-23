#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CachedConversationSummary.h"

@interface ConversationSummary : NSObject

@property (nonatomic, retain) NSDate   *endTime;
@property (nonatomic, strong) NSString *headline;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *pictureUrl;
@property (nonatomic, strong) NSString *lastMessageSentByMe;
@property (nonatomic, strong) UIImage  *picture;
@property (nonatomic) NSInteger         conversationId;
@property (nonatomic) NSInteger         messageCount;
@property (nonatomic) NSInteger         score;
@property (nonatomic) NSInteger         myCurrentVote;
@property (nonatomic) BOOL              isFeatured;

- (id)initWithCachedConversationSummary:(CachedConversationSummary *)cachedConversationSummary;
- (id)initWithDto:(NSDictionary *)dto;

@end