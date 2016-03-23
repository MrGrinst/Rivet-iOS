#import "PrivacyPolicyViewController.h"
#import "UIColor+Rivet.h"
#import "LNNotificationsUI_iOS7.1.h"

@interface PrivacyPolicyViewController()

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation PrivacyPolicyViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.textColor = [UIColor rivetOffBlack];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObservers];
}

#pragma mark - Observers

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationWasTapped)
                                                 name:LNNotificationWasTappedNotification
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LNNotificationWasTappedNotification
                                                  object:nil];
}

#pragma mark - Push Notification Handling

- (void)notificationWasTapped {
    [self.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LNNotificationWasTappedNotification
                                                            object:nil];
    }];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [self.textView setContentOffset:CGPointZero animated:NO];
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

@end