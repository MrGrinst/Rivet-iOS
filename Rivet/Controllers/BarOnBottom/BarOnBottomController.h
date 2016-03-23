#import <UIKit/UIKit.h>
#import "OmniBar.h"

NSString *const kNotification_setCurrentFeaturedConversation;

@interface BarOnBottomController : UIViewController

@property (strong, nonatomic) OmniBar                *omniBar;
@property (strong, nonatomic) UINavigationController *actualNavigationController;

@end