#import <UIKit/UIKit.h>
#import "OmniBar.h"
#import <Pusher/Pusher.h>
#import "RealtimeChatDelegate.h"

@interface ConversationViewingViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSInteger conversationId;
@property (nonatomic) BOOL      shouldAllowInteractivePopGesture;

@end