#import <UIKit/UIKit.h>
#import "Conversation.h"

@interface ParentConversationTableViewCell : UITableViewCell

@property (strong, nonatomic) Conversation       *conversation;

+ (CGFloat)heightGivenConversation:(Conversation *)conversation;
    
@end