#import "ConversationTableViewCellFactory.h"
#import "ConversationEndedTableViewCell.h"
#import "ParentConversationTableViewCell.h"
#import "ConstUtil.h"
#import "TypingBubbleTableViewCell.h"
#import "FeaturedConversationHeaderCell.h"
#import "FeaturedConversationFooterCell.h"

NSString *const messageCellIdentifier = @"messageTableViewCell";
NSString *const userLeftCellIdentifier = @"userLeftTableViewCell";
NSString *const parentConversationCellIdentifier = @"parentConversationCellIdentifier";
NSString *const featuredConversationHeaderCellIdentifier = @"featuredConversationHeaderIdentifier";
NSString *const featuredConversationFooterCellIdentifier = @"featuredConversationFooterCellIdentifier";
NSString *const typingMessageCellIdentifier = @"typingMessageCellIdentifier";

@implementation ConversationTableViewCellFactory

+ (UITableViewCell *)conversationTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
                                                   forTableView:(UITableView *)tableView
                                               withConversation:(Conversation *)conversation
                                           withQuickLoadSummary:(ConversationSummary *)conversationSummary
                                       isConversationMakingView:(BOOL)isConversationMakingView
                                             withCachedTextSize:(NSMutableDictionary *)cachedTextSize
                                                withPrivacyMask:(PrivacyMask *)privacyMask {
    if (indexPath.row == 0) {
        if (conversation.isFeatured) {
            FeaturedConversationHeaderCell *cell = (FeaturedConversationHeaderCell *)[tableView dequeueReusableCellWithIdentifier:featuredConversationHeaderCellIdentifier];
            if (!cell) {
                cell = [[FeaturedConversationHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:featuredConversationHeaderCellIdentifier];
            }
            cell.conversation = conversationSummary;
            return cell;
        } else {
            ParentConversationTableViewCell *cell = (ParentConversationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:parentConversationCellIdentifier];
            if (!cell) {
                cell = [[ParentConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:parentConversationCellIdentifier];
            }
            cell.conversation = conversation;
            return cell;
        }
    } else if (indexPath.row >= conversation.messages.count + 1) {
        if ([conversation isActive]) {
            TypingBubbleTableViewCell *cell = (TypingBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:typingMessageCellIdentifier];
            if (!cell) {
                cell = [[TypingBubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:typingMessageCellIdentifier];
            }
            cell.isOnLeft = YES;
            return cell;
        } else if (conversation.isFeatured) {
            FeaturedConversationFooterCell *cell = (FeaturedConversationFooterCell *)[tableView dequeueReusableCellWithIdentifier:featuredConversationFooterCellIdentifier];
            if (!cell) {
                cell = [[FeaturedConversationFooterCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                             reuseIdentifier:featuredConversationFooterCellIdentifier];
            }
            cell.conversation = conversation;
            return cell;
        } else {
            ConversationEndedTableViewCell *cell = (ConversationEndedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:userLeftCellIdentifier];
            if (!cell) {
                cell = [[ConversationEndedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                             reuseIdentifier:userLeftCellIdentifier
                                                    isConversationMakingView:isConversationMakingView];
            }
            cell.isConversationMakingView = isConversationMakingView;
            cell.conversation = conversation;
            return cell;
        }
    } else {
        id obj = [conversation.messages objectAtIndex:indexPath.row - 1];
        if ([obj isKindOfClass:[Message class]]) {
            Message *message = obj;
            MessageTableViewCell *cell = (MessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:messageCellIdentifier];
            BOOL isOnLeft = [message isOnLeftWithMyParticipantNumber:conversation.myParticipantNumber];
            if (!cell) {
                cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:messageCellIdentifier
                                                          isOnLeft:isOnLeft
                                                      withMaxWidth:[ConstUtil screenWidth]];
            }
            [cell setMessage:message
                 setIsOnLeft:isOnLeft
      setMyParticipantNumber:conversation.myParticipantNumber
              cachedTextSize:cachedTextSize];
            if (privacyMask) {
                [privacyMask addToCell:cell];
            } else if (message.isPrivate) {
                cell.messageContentViewHidden = YES;
            }
            return cell;
        }
    }
    return nil;
}

+ (NSInteger)numberOfRowsForConversation:(Conversation *)conversation {
    if (conversation) {
        if (![conversation isActive] || conversation.otherUserTyping) {
            return conversation.messages.count + 2;
        }
        return conversation.messages.count + 1;
    }
    return 0;
}

+ (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
                    withConversation:(Conversation *)conversation
                withQuickLoadSummary:(ConversationSummary *)conversationSummary
                 withMessageViewList:(NSArray *)messageViewList
               withCachedCellHeights:(NSMutableDictionary *)cachedCellHeights
            isConversationMakingView:(BOOL)isConversationMakingView {
    if (indexPath.row == 0) {
        if (conversation.isFeatured) {
            return [FeaturedConversationHeaderCell heightWithConversation:conversationSummary];
        } else if (conversation) {
            return [ParentConversationTableViewCell heightGivenConversation:conversation];
        }
        return 0;
    } else if (indexPath.row - 1 >= messageViewList.count) {
        if ([conversation isActive]) {
            return [TypingBubbleTableViewCell height];
        } else if (conversation.isFeatured) {
            return [FeaturedConversationFooterCell heightWithConversation:conversation];
        } else {
            return [ConversationEndedTableViewCell heightWithConversation:conversation
                                                 isConversationMakingView:isConversationMakingView];
        }
    } else {
        id obj = [messageViewList objectAtIndex:indexPath.row - 1];
        if ([obj isKindOfClass:[Message class]]) {
            Message *message = obj;
            NSNumber *cachedCellHeight = [cachedCellHeights objectForKey:@(message.messageId)];
            if (cachedCellHeight) {
                return cachedCellHeight.integerValue;
            } else {
                NSInteger height = [MessageTableViewCell heightGivenMessage:message withMaxWidth:[ConstUtil screenWidth]];
                [cachedCellHeights setObject:@(height) forKey:@(message.messageId)];
                return height;
            }
        }
    }
    return 0;
}

@end