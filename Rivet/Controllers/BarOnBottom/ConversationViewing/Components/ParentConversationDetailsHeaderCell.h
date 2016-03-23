#import <UIKit/UIKit.h>
#import "ParentConversation.h"

@interface ParentConversationDetailsHeaderCell : UITableViewCell

@property (strong, nonatomic) ParentConversation *parentConversation;

+ (CGFloat)heightWithParentConversation:(ParentConversation *)conversation;

@end