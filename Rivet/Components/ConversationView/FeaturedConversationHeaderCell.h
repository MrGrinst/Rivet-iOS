#import <UIKit/UIKit.h>
#import "ConversationSummary.h"

@interface FeaturedConversationHeaderCell : UITableViewCell

@property (strong, nonatomic) ConversationSummary *conversation;

+ (CGFloat)heightWithConversation:(ConversationSummary *)conversation;

- (CGRect)pictureFrame;
- (CGRect)headlineFrame;
- (CGRect)descriptionFrame;

@end