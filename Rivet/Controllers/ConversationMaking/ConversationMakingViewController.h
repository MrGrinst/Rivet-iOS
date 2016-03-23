#import <UIKit/UIKit.h>
#import "SLKTextViewController.h"
#import "RealtimeChatDelegate.h"

@interface ConversationMakingViewController : SLKTextViewController<UITableViewDelegate, UITableViewDataSource, RealtimeChatDelegate>

@property (nonatomic) NSInteger parentConversationId;

@end