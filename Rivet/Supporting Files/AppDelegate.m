#import "AppDelegate.h"
#import "TutorialViewController.h"
#import "Authentication.h"
#import "ConstUtil.h"
#import "AppUnavailableViewController.h"
#import "BarOnBottomController.h"
#import "UserRepository.h"
#import "ConversationMakingViewController.h"
#import "LNNotificationsUI_iOS7.1.h"
#import "Mixpanel.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "RivetUserDefaults.h"
#import "AppState.h"
#import "ObjectiveRecord.h"
#import "EventTrackingUtil.h"
#import "ConversationListener.h"
#import "ConversationViewingViewController.h"
#import "ListContainerViewController.h"
#import "ConversationRepository.h"
#import "FeaturedConversationViewingViewController.h"

#define mixpanelToken [[NSBundle mainBundle] objectForInfoDictionaryKey:@"mixpanelToken"]
NSString *const kAppDelegateTag = @"AppDelegate";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [CoreDataManager sharedManager].databaseName = @"Rivet";
    [CoreDataManager sharedManager].modelName = @"Rivet";
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        AppUnavailableViewController *vc = [[AppUnavailableViewController alloc] initWithStatus:kAppUnavailableStatusLocationDenied];
        self.window.rootViewController = vc;
    } else {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        if (![RivetUserDefaults hasSeenLocationPermissionAlert] || ![Authentication isUserLoggedIn]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
            TutorialViewController *vc = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_tutorial];
            self.window.rootViewController = vc;
        } else {
            [self startAppFromBottomOrTopWithLaunchOptions:launchOptions];
        }
        [self.window makeKeyAndVisible];
    }
    [self setupInAppPushNotifications];
    [self startAnalytics];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    __weak AppDelegate *weakSelf = self;
    NSArray *components = url.pathComponents;
    if ([[components objectAtIndex:1] isEqualToString:@"conversation"]) {
        NSInteger conversationId = ((NSString *)[components objectAtIndex:2]).integerValue;
        if (conversationId % 17 == 0) {
            conversationId = conversationId / 17;
            if (components.count >= 5 && [[components objectAtIndex:3] isEqualToString:@"featured"]) {
                BOOL isFeatured = [[components objectAtIndex:4] isEqualToString:@"true"];
                [self segueToViewAfterOpeningURLWithConversationId:conversationId isFeatured:isFeatured];
            } else {
                [ConversationRepository conversationDetailsForConversationId:conversationId
                                                          withSuccessHandler:^(ConversationDetails *details) {
                                                              [weakSelf segueToViewAfterOpeningURLWithConversationId:conversationId isFeatured:details.isFeatured];
                                                          }
                                                          withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                              [weakSelf segueToViewAfterOpeningURLWithConversationId:conversationId isFeatured:NO];
                                                          }
                                                                     withTag:@"fake"];
            }
        }
    }
    return YES;
}

- (void)segueToViewAfterOpeningURLWithConversationId:(NSInteger)conversationId isFeatured:(BOOL)isFeatured {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_mainNavigationController];
    [AppState setSelectedSegmentIndexOnConversationListView:@(0)];
    BarOnBottomController *barOnBottom = [((UINavigationController *)self.window.rootViewController).childViewControllers firstObject];
    UIViewController *svc;
    if (isFeatured) {
        svc = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_featuredConversationViewingViewController];
        ConversationSummary *conversation = [[ConversationSummary alloc] init];
        conversation.conversationId = conversationId;
        conversation.isFeatured = YES;
        ((FeaturedConversationViewingViewController *)svc).conversationSummary = conversation;
    } else {
        svc = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_conversationViewingViewController];
        ((ConversationViewingViewController *)svc).conversationId = conversationId;
    }
    ListContainerViewController *vc = [((UINavigationController *)barOnBottom.actualNavigationController).viewControllers firstObject];
    vc.title = @"";
    [barOnBottom.actualNavigationController setViewControllers:@[vc, svc] animated:NO];
    [self.window makeKeyAndVisible];
}

- (void)startAppFromBottomOrTopWithLaunchOptions:(NSDictionary *)launchOptions {
    [AppState setJustOpenedApp:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSString *appSection = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey][@"app_section"];
        if ([appSection isEqualToString:@"conversation"]) {
            ConversationMakingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_conversationMakingViewController];
            self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_mainNavigationController];
            ((UINavigationController *)self.window.rootViewController).topViewController.title = @"";
            [((UINavigationController *)self.window.rootViewController) pushViewController:vc animated:NO];
        } else if ([appSection isEqualToString:@"conversation_list"]) {
            if ([appSection isEqualToString:@"conversation_list"]) {
                [AppState setSelectedSegmentIndexOnConversationListView:@(0)];
            }
            self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_mainNavigationController];
        }
    } else {
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_mainNavigationController];
    }
}

- (void)startAnalytics {
    if (mixpanelToken) {
        [Mixpanel sharedInstanceWithToken:mixpanelToken];
        if ([ConstUtil userId] != -1) {
            [EventTrackingUtil setUserId:[ConstUtil userId]];
            [EventTrackingUtil openedApp];
        }
        [Fabric with:@[CrashlyticsKit]];
        if ([ConstUtil userId] != -1) {
            [CrashlyticsKit setUserIdentifier:[NSString stringWithFormat:@"%li", (long)[ConstUtil userId]]];
        }
    }
}

- (void)setupInAppPushNotifications {
    [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"rivet" name:@"Rivet" icon:[UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]  firstObject]] defaultSettings:LNNotificationDefaultAppSettings];
    [[LNNotificationCenter defaultCenter] setNotificationsBannerStyle:LNNotificationBannerStyleLight];
}

- (void)resetOldPushNotifications {
    if ([RivetUserDefaults hasRegisteredPushNotificationToken]) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    NSString *appSection = userInfo[@"app_section"];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground ||
        [UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
        if ([appSection isEqualToString:@"conversation"]) {
            ConversationMakingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_conversationMakingViewController];
            self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_mainNavigationController];
            ((UINavigationController *)self.window.rootViewController).topViewController.title = @"";
            [((UINavigationController *)self.window.rootViewController) pushViewController:vc animated:NO];
        } else if ([appSection isEqualToString:@"conversation_list"]) {
            if ([appSection isEqualToString:@"conversation_list"]) {
                [AppState setSelectedSegmentIndexOnConversationListView:@(0)];
            }
            self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_mainNavigationController];
        }
    } else {
        if (![((UINavigationController *)self.window.rootViewController).visibleViewController isKindOfClass:[ConversationMakingViewController class]]
            && [appSection isEqualToString:@"conversation"]) {
            LNNotification *notification = [LNNotification notificationWithMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
            [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"rivet"];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [UserRepository registerUserForPushNotificationsUsingDeviceToken:token
                                                  withSuccessHandler:^{
                                                      [RivetUserDefaults setHasRegisteredPushNotificationToken:YES];
                                                  }
                                                  withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                             withTag:kAppDelegateTag];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [EventTrackingUtil logError:@{@"Remote Notification Registration Error": error.description, @"Error Code": @(error.code)}];
    CLSNSLog(@"Error registering for remote notifications: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [ConversationListener stopListeningToEverything];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [ConversationListener stopListeningToEverything];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        AppUnavailableViewController *vc = [[AppUnavailableViewController alloc] initWithStatus:kAppUnavailableStatusLocationDenied];
        self.window.rootViewController = vc;
    }
    [self resetOldPushNotifications];
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]
        && ![((UINavigationController *)self.window.rootViewController).visibleViewController isKindOfClass:[ConversationMakingViewController class]]) {
        [ConversationListener ifNotificationsNotEnabledListenToActiveConversationOrWaitForMatchChannel];
    }
    [BaseRepository startListeningForReachability];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[CoreDataManager sharedManager] saveContext];
    [ConversationListener stopListeningToEverything];
}

@end