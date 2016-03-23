#import <UIKit/UIKit.h>
#import "Conversation.h"

@interface ConversationEndedTableViewCell : UITableViewCell

@property (nonatomic) BOOL                  isConversationMakingView;
@property (strong, nonatomic) Conversation *conversation;

-      (id)initWithStyle:(UITableViewCellStyle)style
         reuseIdentifier:(NSString *)reuseIdentifier
isConversationMakingView:(BOOL)isConversationMakingView;

+ (CGFloat)heightWithConversation:(Conversation *)conversation
           isConversationMakingView:(BOOL)isConversationMakingView;

@end