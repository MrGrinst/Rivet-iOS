#import <UIKit/UIScreen.h>
#import <UIKit/UIApplication.h>
#import "ConstUtil.h"
#import "RivetUserDefaults.h"

NSString *const kViewControllerIdentifier_tutorial = @"TutorialViewController";
NSString *const kViewControllerIdentifier_mainNavigationController = @"MainNavigationController";
NSString *const kViewControllerIdentifier_bottomBarNavigation = @"BottomBarNavigationController";
NSString *const kViewControllerIdentifier_conversationViewingViewController = @"ConversationViewingViewController";
NSString *const kViewControllerIdentifier_conversationMakingViewController = @"ConversationMakingViewController";
NSString *const kViewControllerIdentifier_reportDialogViewController = @"ReportDialogViewController";
NSString *const kViewControllerIdentifier_rivetAlertViewViewController = @"RivetAlertViewViewController";
NSString *const kViewControllerIdentifier_featuredConversationCollectionViewController = @"FeaturedConversationCollectionViewController";
NSString *const kViewControllerIdentifier_featuredConversationViewingViewController = @"FeaturedConversationViewingViewController";


NSString *const kSegueIdentifier_conversationListToChat = @"ListViewToChat";
NSString *const kSegueIdentifier_chatToConversationList = @"ChatToListView";
NSString *const kSegueIdentifier_myConversationsListToMyConversations = @"MyConversationsListToMyConversation";
NSString *const kSegueIdentifier_jumpIntoRivetToSpecialThanks = @"JumpIntoRivetToSpecialThanks";
NSString *const kSegueIdentifier_profileModalToMyConversations = @"ProfileModalToMyConversations";
NSString *const kSegueIdentifier_selectFeaturedConversation = @"SelectFeaturedConversation";

@implementation ConstUtil
static NSInteger screenWidth = -1;
static NSInteger screenHeight = -1;
static NSInteger statusBarHeight = -1;
static NSInteger userId = -1;

+ (NSInteger)screenWidth {
    if (screenWidth == -1) {
        screenWidth = [UIScreen mainScreen].bounds.size.width;
    }
    return screenWidth;
}

+ (NSInteger)screenHeight {
    if (screenHeight == -1) {
        screenHeight = [UIScreen mainScreen].bounds.size.height;
    }
    return screenHeight;
}

+ (NSInteger)statusBarHeight {
    if (statusBarHeight == -1) {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        if (statusBarHeight > 22) {
            statusBarHeight = 0;
        }
    }
    return statusBarHeight;
}

+ (NSInteger)userId {
    if (userId == -1) {
        userId = [RivetUserDefaults userId];
    }
    return userId;
}

@end