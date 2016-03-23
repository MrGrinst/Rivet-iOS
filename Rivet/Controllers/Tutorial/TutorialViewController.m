#import "TutorialViewController.h"
#import "UIColor+Rivet.h"
#import "ConversationRepository.h"
#import "ConstUtil.h"
#import "LocationUtil.h"
#import "RivetUserDefaults.h"
#import "UILabel+Rivet.h"
#import "UserRepository.h"

NSString *const kTutorialViewControllerTag = @"TutorialViewControllerTag";

@interface TutorialViewController()

@property (strong, nonatomic) UIImageView  *backgroundView;
@property (strong, nonatomic) LocationUtil *locationUtil;
@property (strong, nonatomic) UIView       *allowButton;
@property (strong, nonatomic) UILabel      *allowButtonLabel;
@property (nonatomic) NSInteger             allowButtonYPos;
@property (nonatomic) BOOL                  alreadyAllowedLocation;

@end

@implementation TutorialViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.allowButton];
    [self setupConstraints];
}

#pragma mark - Getters

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        NSString *launchImageName;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if ([UIScreen mainScreen].bounds.size.height == 480) { // iPhone 4/4s, 3.5 inch screen
                launchImageName = @"LocationPermissionImage";
                self.allowButtonYPos = 340;
            } else if ([UIScreen mainScreen].bounds.size.height == 568) { // iPhone 5/5s, 4.0 inch screen
                launchImageName = @"LocationPermissionImage-568h@2x";
                self.allowButtonYPos = 400;
            } else if ([UIScreen mainScreen].bounds.size.height == 667) { // iPhone 6, 4.7 inch screen
                launchImageName = @"LocationPermissionImage-667h@2x";
                self.allowButtonYPos = 470;
            } else if ([UIScreen mainScreen].bounds.size.height == 736) { // iPhone 6+, 5.5 inch screen
                launchImageName = @"LocationPermissionImage-736h@3x";
                self.allowButtonYPos = 520;
            }
        }
        NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:launchImageName ofType:@"png"]];
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
        _backgroundView.contentMode = UIViewContentModeScaleAspectFit;
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _backgroundView;
}

- (LocationUtil *)locationUtil {
    if (!_locationUtil) {
        _locationUtil = [[LocationUtil alloc] init];
    }
    return _locationUtil;
}

- (UIView *)allowButton {
    if (!_allowButton) {
        _allowButton = [[UIView alloc] init];
        _allowButton.backgroundColor = [UIColor whiteColor];
        _allowButton.layer.cornerRadius = 7;
        [_allowButton addSubview:self.allowButtonLabel];
        _allowButton.translatesAutoresizingMaskIntoConstraints = NO;
        _allowButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(allowLocationAccess)];
        uitgr.numberOfTapsRequired = 1;
        [_allowButton addGestureRecognizer:uitgr];
    }
    return _allowButton;
}

- (UILabel *)allowButtonLabel {
    if (!_allowButtonLabel) {
        _allowButtonLabel = [[UILabel alloc] init];
        _allowButtonLabel.text = NSLocalizedString(@"Okay!", nil);
        [_allowButtonLabel setExplanatoryFontWithSize:24 withColor:[UIColor rivetDarkBlue]];
        _allowButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _allowButtonLabel;
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.allowButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.allowButtonLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.allowButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.allowButtonLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.allowButtonLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.allowButton
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:16]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.allowButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.allowButtonLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:16]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.allowButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:220]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.allowButton
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.allowButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:self.allowButtonYPos]];
}

#pragma mark - Segueing

- (void)allowLocationAccess {
    __weak TutorialViewController *weakSelf = self;
    if (!self.alreadyAllowedLocation) {
        self.allowButtonLabel.text = NSLocalizedString(@"Loading...", nil);
        [UserRepository registerUserWithLocationUtil:self.locationUtil
                                  withSuccessHandler:^{
                                      [weakSelf segueToConversationList];
                                  }
                                  withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (error.code == kErrorCode_couldNotFindLocation) {
                                          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorFindingLocationTitle", nil)
                                                                      message:NSLocalizedString(@"ErrorFindingLocationMessage", nil)
                                                                     delegate:nil
                                                            cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                            otherButtonTitles:nil] show];
                                      }
                                  }];
    }
    self.alreadyAllowedLocation = YES;
}

- (void)segueToConversationList {
    [ConversationRepository globalFeaturedConversationsWithSuccessHandler:^(NSArray *newConversations) {}
                                                       withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                                  withTag:kTutorialViewControllerTag];
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    UINavigationController *nc = [window.rootViewController.storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_mainNavigationController];
    window.rootViewController = nc;
    [RivetUserDefaults setHasSeenLocationPermissionAlert:YES];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end