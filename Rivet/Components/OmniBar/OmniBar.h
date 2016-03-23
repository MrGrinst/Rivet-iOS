#import <UIKit/UIKit.h>
#import "MenuViewController.h"

NSString *const kNotification_changeStatusBarColor;
NSString *const kNotification_shareButtonTapped;
NSString *const kNotification_chatButtonTapped;
NSString *const kNotification_enableShareButton;
NSString *const kNotification_disableShareButton;
NSString *const kNotification_closeButtonTapped;
NSString *const kNotification_showingFeaturedConversation;
NSString *const kNotification_hidingFeaturedConversation;
NSString *const kNotification_showingConversation;
NSString *const kNotification_hidingConversation;
NSString *const kNotification_showCloseButton;
NSString *const kNotification_hideCloseButton;
NSString *const kNotification_omniBarTapped;
NSString *const kNotification_updateChatButtonText;
NSInteger const kOmniBarHeight;

@interface OmniBar : UIView

@end