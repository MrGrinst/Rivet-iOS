#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Conversation.h"
#import "ConversationSummary.h"
#import "PrivacyMask.h"

@interface ConversationTableViewCellFactory : NSObject

+ (UITableViewCell *)conversationTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
                                                   forTableView:(UITableView *)tableView
                                               withConversation:(Conversation *)conversation
                                           withQuickLoadSummary:(ConversationSummary *)conversationSummary
                                       isConversationMakingView:(BOOL)isConversationMakingView
                                             withCachedTextSize:(NSMutableDictionary *)cachedTextSize
                                                withPrivacyMask:(PrivacyMask *)privacyMask;

+ (NSInteger)numberOfRowsForConversation:(Conversation *)conversation;

+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
                    withConversation:(Conversation *)conversation
                withQuickLoadSummary:(ConversationSummary *)conversationSummary
                 withMessageViewList:(NSArray *)messageViewList
               withCachedCellHeights:(NSMutableDictionary *)cachedCellHeights
            isConversationMakingView:(BOOL)isConversationMakingView;

@end