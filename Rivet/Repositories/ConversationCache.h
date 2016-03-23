#import <Foundation/Foundation.h>

@interface ConversationCache : NSObject

+ (NSArray *)globalFeaturedConversationCache;
+ (NSArray *)nearbyFeaturedConversationCache;
+ (NSArray *)myConversationsCache;

@end
