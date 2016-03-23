#import <UIKit/UIKit.h>
#import "Conversation.h"

@interface FeaturedConversationFooterCell : UITableViewCell

@property (strong, nonatomic) Conversation *conversation;

+ (CGFloat)heightWithConversation:(Conversation *)conversation;

@end