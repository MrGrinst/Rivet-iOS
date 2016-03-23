#import <UIKit/UIKit.h>
#import "ConversationSummary.h"

NSString *const kNotification_featuredConversationSelected;

@interface FeaturedConversationCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) ConversationSummary *conversation;

- (CGRect)cardViewFrame;
- (CGRect)pictureFrame;
- (CGRect)headlineFrame;
- (CGRect)descriptionFrame;

@end