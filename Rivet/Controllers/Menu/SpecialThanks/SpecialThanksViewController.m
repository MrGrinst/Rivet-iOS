#import "SpecialThanksViewController.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"
#import "LNNotificationsUI_iOS7.1.h"

@interface SpecialThanksViewController ()

@property (strong, nonatomic) IBOutlet UILabel *specialThanksTitle;
@property (strong, nonatomic) IBOutlet UITextView *specialThanksTextView;

@end

@implementation SpecialThanksViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat contentHeight = self.specialThanksTextView.contentSize.height;
    CGFloat offSet = self.specialThanksTextView.contentOffset.x;
    CGFloat contentOffset = contentHeight - offSet;
    self.specialThanksTextView.contentOffset = CGPointMake(0, -contentOffset);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObservers];
}

#pragma mark - Setters

- (void)setSpecialThanksTitle:(UILabel *)specialThanksTitle {
    _specialThanksTitle = specialThanksTitle;
    [_specialThanksTitle setExplanatoryFontWithSize:24
                                          withColor:[UIColor rivetDarkBlue]];
}

- (void)setSpecialThanksTextView:(UITextView *)specialThanksTextView {
    _specialThanksTextView = specialThanksTextView;
    _specialThanksTextView.textColor = [UIColor rivetOffBlack];
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

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

@end