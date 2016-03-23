#import "ListContainerViewController.h"
#import "ConstUtil.h"
#import "UIFont+Rivet.h"
#import "UIColor+Rivet.h"
#import "AppState.h"
#import "ConversationViewingViewController.h"
#import "FeaturedConversationViewingViewController.h"
#import "EventTrackingUtil.h"
#import "FeaturedConversationCollectionViewController.h"

CGFloat const topBarHeight = 44;
NSString *const kNotification_segueToFeaturedConversationViewing = @"segueToFeaturedConversationViewing";
NSString *const kNotification_showNearbyEligibleInterface = @"showNearbyEligibleInterface";
NSString *const kNotification_hideNearbyEligibleInterface = @"hideNearbyEligibleInterface";

@interface ListContainerViewController ()

@property (strong, nonatomic) UIView                                       *topBar;
@property (strong, nonatomic) UIView                                       *childContentView;
@property (strong, nonatomic) UISegmentedControl                           *segmentedControl;
@property (strong, nonatomic) FeaturedConversationCollectionViewController *nearbyConversationCollectionViewController;
@property (strong, nonatomic) FeaturedConversationCollectionViewController *globalConversationCollectionViewController;
@property (strong, nonatomic) ConversationSummary                          *segueingConversation;
@property (strong, nonatomic) NSLayoutConstraint                           *constraintForNoTopBar;

@end

@implementation ListContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.childContentView];
    self.navigationController.navigationBar.barTintColor = [UIColor rivetDarkBlue];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont rivetNavigationBarHeaderFont]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self showGlobalConversationCollectionViewController];
    [self setupConstraints];
    if ([AppState userState].isNearbyEligible) {
        [self showNearbyEligibleInterface];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_updateChatButtonText object:nil];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_changeStatusBarColor
                                                        object:nil
                                                      userInfo:@{@"color": [UIColor rivetDarkBlue]}];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObservers];
}

- (void)setupConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.childContentView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.childContentView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
    self.constraintForNoTopBar = [NSLayoutConstraint constraintWithItem:self.childContentView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0];
    [self.view addConstraint:self.constraintForNoTopBar];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.childContentView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
}

#pragma mark - Getters

- (UIView *)topBar {
    if (!_topBar) {
        _topBar = [[UIView alloc] init];
        _topBar.translatesAutoresizingMaskIntoConstraints = NO;
        _topBar.backgroundColor = [UIColor rivetDarkBlue];
        [_topBar addSubview:self.segmentedControl];
        [self.segmentedControl setSelectedSegmentIndex:[AppState selectedSegmentIndexOnConversationListView].intValue];
    }
    return _topBar;
}

- (UIView *)childContentView {
    if (!_childContentView) {
        _childContentView = [[UIView alloc] init];
        _childContentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _childContentView;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Featured", nil), NSLocalizedString(@"Nearby", nil)]];
        _segmentedControl.frame = CGRectMake(8, 8, [ConstUtil screenWidth] - 16, topBarHeight - 16);
        [_segmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont rivetExplantoryTextFontWithSize:12]} forState:UIControlStateNormal];
        _segmentedControl.tintColor = [UIColor whiteColor];
        [_segmentedControl addTarget:self action:@selector(changedFilter:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (FeaturedConversationCollectionViewController *)nearbyConversationCollectionViewController {
    if (!_nearbyConversationCollectionViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
        _nearbyConversationCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_featuredConversationCollectionViewController];
        _nearbyConversationCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        _nearbyConversationCollectionViewController.collectionType = kCollectionType_nearby;
    }
    return _nearbyConversationCollectionViewController;
}

- (FeaturedConversationCollectionViewController *)globalConversationCollectionViewController {
    if (!_globalConversationCollectionViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
        _globalConversationCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_featuredConversationCollectionViewController];
        _globalConversationCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        _globalConversationCollectionViewController.collectionType = kCollectionType_global;
    }
    return _globalConversationCollectionViewController;
}

#pragma mark - Observers

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(segueToFeaturedConversationViewing:)
                                                 name:kNotification_segueToFeaturedConversationViewing
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNearbyEligibleInterface)
                                                 name:kNotification_showNearbyEligibleInterface
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideNearbyEligibleInterface)
                                                 name:kNotification_hideNearbyEligibleInterface
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_segueToFeaturedConversationViewing
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_showNearbyEligibleInterface
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_hideNearbyEligibleInterface
                                                  object:nil];
}

#pragma mark - Nearby Eligible

- (void)showNearbyEligibleInterface {
    [self.view removeConstraint:self.constraintForNoTopBar];
    [self.view addSubview:self.topBar];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topBar
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.childContentView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topBar
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topBar
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:topBarHeight]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topBar
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topBar
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
}

- (void)hideNearbyEligibleInterface {
    [self.topBar removeFromSuperview];
    [self.view addConstraint:self.constraintForNoTopBar];
}

#pragma mark - Manage Children View Controllers

- (void)showNearbyConversationCollectionViewController {
    [self removeCurrentChildViewController];
    [self addChildViewController:self.nearbyConversationCollectionViewController];
    [self.childContentView addSubview:self.nearbyConversationCollectionViewController.view];
    [self.childContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.childContentView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.nearbyConversationCollectionViewController.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:0]];
    [self.childContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.childContentView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.nearbyConversationCollectionViewController.view
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1
                                                                       constant:0]];
    [self.childContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.childContentView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.nearbyConversationCollectionViewController.view
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:0]];
    [self.childContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.childContentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.nearbyConversationCollectionViewController.view
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:0]];
    [self.nearbyConversationCollectionViewController didMoveToParentViewController:self];
}

- (void)showGlobalConversationCollectionViewController {
    [self removeCurrentChildViewController];
    [self addChildViewController:self.globalConversationCollectionViewController];
    [self.childContentView addSubview:self.globalConversationCollectionViewController.view];
    [self.childContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.childContentView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.globalConversationCollectionViewController.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:0]];
    [self.childContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.childContentView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.globalConversationCollectionViewController.view
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1
                                                                       constant:0]];
    [self.childContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.childContentView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.globalConversationCollectionViewController.view
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:0]];
    [self.childContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.childContentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.globalConversationCollectionViewController.view
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:0]];
    [self.globalConversationCollectionViewController didMoveToParentViewController:self];
}

- (void)removeCurrentChildViewController {
    if (_nearbyConversationCollectionViewController) {
        [_nearbyConversationCollectionViewController willMoveToParentViewController:nil];
        [_nearbyConversationCollectionViewController.view removeFromSuperview];
        [_nearbyConversationCollectionViewController removeFromParentViewController];
        _nearbyConversationCollectionViewController = nil;
    }
    if (_globalConversationCollectionViewController) {
        [_globalConversationCollectionViewController willMoveToParentViewController:nil];
        [_globalConversationCollectionViewController.view removeFromSuperview];
        [_globalConversationCollectionViewController removeFromParentViewController];
        _globalConversationCollectionViewController = nil;
    }
}

#pragma mark - UI Segmented Control Changing

- (void)changedFilter:(UISegmentedControl *)sc {
    int oldSelectedIndex = [AppState selectedSegmentIndexOnConversationListView].intValue;
    [AppState setSelectedSegmentIndexOnConversationListView:@(sc.selectedSegmentIndex)];
    if (sc.selectedSegmentIndex != oldSelectedIndex) {
        if (sc.selectedSegmentIndex == 0) {
            [self showGlobalConversationCollectionViewController];
        } else if (sc.selectedSegmentIndex == 1) {
            [self showNearbyConversationCollectionViewController];
        }
    }
    if (sc.selectedSegmentIndex == 0) {
        [EventTrackingUtil featuredFilterSelected];
    } else if (sc.selectedSegmentIndex == 1) {
        [EventTrackingUtil nearbyFilterSelected];
    }
}

#pragma mark - Segueing

- (void)segueToFeaturedConversationViewing:(NSNotification *)notification {
    self.segueingConversation = (ConversationSummary *)[notification.userInfo objectForKey:@"conversation"];
    [self performSegueWithIdentifier:kSegueIdentifier_selectFeaturedConversation sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifier_selectFeaturedConversation]) {
        FeaturedConversationViewingViewController *vc = segue.destinationViewController;
        vc.conversationSummary = self.segueingConversation;
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
