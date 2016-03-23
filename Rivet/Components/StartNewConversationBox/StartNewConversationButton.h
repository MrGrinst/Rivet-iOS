#import <UIKit/UIKit.h>

NSString *const kNotification_startOrStopSearchingButtonPressed;

@interface StartNewConversationButton : UIView

@property (nonatomic) BOOL              isSearching;
@property (strong, nonatomic) NSString *customText;

- (void)setWidthConstraints;

@end