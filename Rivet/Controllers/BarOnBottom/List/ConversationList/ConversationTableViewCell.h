#import <UIKit/UIKit.h>
#import "Message.h"
#import "ConversationSummary.h"

NSString *const kNotification_conversationVotedOn;

@interface ConversationTableViewCell : UITableViewCell

@property (nonatomic) BOOL                       notification;
@property (strong, nonatomic) ConversationSummary *conversationSummary;

- (void)restartMarquee;

+ (CGFloat)heightGivenConversationSummary:(ConversationSummary *)conversationSummary
                           withSizingCell:(ConversationTableViewCell *)sizingCell;

@end