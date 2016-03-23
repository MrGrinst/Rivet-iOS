#import <UIKit/UIKit.h>

NSString *const kAppUnavailableStatusLocationDenied;
NSString *const kAppUnavailableStatusGeofenced;

@interface AppUnavailableViewController : UIViewController

- (id)initWithStatus:(NSString *)status;
    
@end