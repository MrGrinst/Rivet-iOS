#import <UIKit/UIKit.h>
#import "OmniBar.h"
#import <Pusher/Pusher.h>
#import "RealtimeChatDelegate.h"
#import "ConversationSummary.h"

@interface FeaturedConversationViewingViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) ConversationSummary *conversationSummary;
@property (nonatomic) BOOL                         isMyConversationViewingView;

- (CGRect)pictureFrame;
- (CGRect)headlineFrame;
- (CGRect)descriptionFrame;

@end