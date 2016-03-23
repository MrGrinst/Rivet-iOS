#import "BarOnBottomController.h"
#import "ListContainerViewController.h"
#import "ConversationMakingViewController.h"
#import "NSDictionary+Rivet.h"
#import "ConstUtil.h"
#import "LNNotificationsUI_iOS7.1.h"
#import "EventTrackingUtil.h"
#import "ConversationListener.h"
#import "FeaturedConversationViewingViewController.h"

NSString *const kNotification_setCurrentFeaturedConversation = @"setCurrentFeaturedConversation";

@interface BarOnBottomController()

@property (nonatomic) NSInteger currentFeaturedConversationId;

@end

@implementation BarOnBottomController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildViewController:self.actualNavigationController];
    [self.view addSubview:self.actualNavigationController.view];
    [self.view addSubview:self.omniBar];
    [self.actualNavigationController didMoveToParentViewController:self];
    self.currentFeaturedConversationId = -1;
    self.title = @"";
    [self setupConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ConversationListener ifNotificationsNotEnabledListenToActiveConversationOrWaitForMatchChannel];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.presentedViewController.isBeingPresented) {
        self.navigationController.navigationBar.hidden = NO;
    } else {
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    for (UIViewController *vc in self.actualNavigationController.viewControllers) {
        if (self.actualNavigationController.navigationBarHidden) {
            vc.view.frame = self.actualNavigationController.view.bounds;
        }
    }
}

- (void)setupConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.actualNavigationController.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.actualNavigationController.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.actualNavigationController.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.omniBar
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.actualNavigationController.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.omniBar
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.omniBar
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLayoutGuide
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.omniBar
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.omniBar
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:kOmniBarHeight]];
}

#pragma mark - Observers

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(segueToListView)
                                                 name:kNotification_chatButtonTapped
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationWasTapped)
                                                 name:LNNotificationWasTappedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeButtonTapped)
                                                 name:kNotification_closeButtonTapped
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setCurrentFeaturedConversation:)
                                                 name:kNotification_setCurrentFeaturedConversation
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_chatButtonTapped
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LNNotificationWasTappedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_closeButtonTapped
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_setCurrentFeaturedConversation
                                                  object:nil];
}

#pragma mark - Getters

- (OmniBar *)omniBar {
    if (!_omniBar) {
        _omniBar = [[OmniBar alloc] init];
    }
    return _omniBar;
}

- (UINavigationController *)actualNavigationController {
    if (!_actualNavigationController) {
        _actualNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_bottomBarNavigation];
        _actualNavigationController.navigationBarHidden = YES;
        _actualNavigationController.view.translatesAutoresizingMaskIntoConstraints = NO;
        _actualNavigationController.interactivePopGestureRecognizer.delegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    }
    return _actualNavigationController;
}

#pragma mark - Push Notification Handling

- (void)notificationWasTapped {
    __weak BarOnBottomController *weakSelf = self;
    [weakSelf performSegueWithIdentifier:kSegueIdentifier_conversationListToChat
                                  sender:weakSelf];
}

#pragma mark - Featured Conversation Segueing

- (void)setCurrentFeaturedConversation:(NSNotification *)notification {
    self.currentFeaturedConversationId = [notification.userInfo intOrZeroForKey:@"conversationId"];
}

#pragma mark - Segueing

- (void)segueToListView {
    [self performSegueWithIdentifier:kSegueIdentifier_conversationListToChat
                              sender:self];
}

- (void)closeButtonTapped {
    UIViewController *topController = self.actualNavigationController.topViewController;
    if (![topController isKindOfClass:[FeaturedConversationViewingViewController class]]) {
        for (UIViewController *vc in self.actualNavigationController.viewControllers) {
            if ([vc isKindOfClass:[ListContainerViewController class]]) {
                CATransition *transition = [CATransition animation];
                transition.duration = 0.35f;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                [self.actualNavigationController.view.layer addAnimation:transition forKey:nil];
                [self.actualNavigationController popToViewController:vc animated:NO];
                break;
            }
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifier_conversationListToChat]
        && [self.actualNavigationController.topViewController isKindOfClass:[FeaturedConversationViewingViewController class]]) {
        ((ConversationMakingViewController *)segue.destinationViewController).parentConversationId = self.currentFeaturedConversationId;
    }
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Dealloc

- (void)dealloc {
    [self removeObservers];
}

@end