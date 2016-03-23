#import "RivetAlertViewViewController.h"
#import "ConstUtil.h"
#import "RoundedRectView.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"
#import "OmniBar.h"

@interface RivetAlertViewViewController ()

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *positiveText;
@property (strong, nonatomic) NSString *negativeText;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *positiveLabel;
@property (strong, nonatomic) UILabel *negativeLabel;
@property (strong, nonatomic) IBOutlet RoundedRectView *positiveButton;
@property (strong, nonatomic) RoundedRectView *negativeButton;
@property (strong, nonatomic) IBOutlet UIView *modalView;
@property (nonatomic) SEL positiveSelector;
@property (nonatomic) SEL negativeSelector;
@property (weak, nonatomic) id delegate;

@end

@implementation RivetAlertViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(negativeAction)];
    uitgr.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:uitgr];
}

#pragma mark - Getters

- (UILabel *)negativeLabel {
    if (!_negativeLabel) {
        _negativeLabel = [[UILabel alloc] init];
        [_negativeLabel setExplanatoryFontWithDefaultFontSizeWithColor:[UIColor rivetOffBlack]];
        _negativeLabel.text = self.negativeText;
        _negativeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _negativeLabel;
}

- (RoundedRectView *)negativeButton {
    if (!_negativeButton) {
        _negativeButton = [[RoundedRectView alloc] init];
        _negativeButton.backgroundColor = [UIColor rivetLightGray];
        UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(negativeAction)];
        uitgr.numberOfTapsRequired = 1;
        [_negativeButton addGestureRecognizer:uitgr];
        [_negativeButton roundCorners:UIRectCornerBottomLeft
                           withRadius:7];
        _negativeButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _negativeButton;
}

#pragma mark - Setters

- (void)setModalView:(UIView *)modalView {
    _modalView = modalView;
    _modalView.layer.cornerRadius = 10;
}

- (void)setPositiveLabel:(UILabel *)dismissLabel {
    _positiveLabel = dismissLabel;
    [_positiveLabel setExplanatoryFontWithDefaultFontSizeWithColor:[UIColor whiteColor]];
    _positiveLabel.text = self.positiveText;
}

- (void)setPositiveText:(NSString *)positiveText {
    _positiveText = positiveText;
    self.positiveLabel.text = positiveText;
}

- (void)setNegativeText:(NSString *)negativeText {
    _negativeText = negativeText;
    self.negativeLabel.text = negativeText;
}

- (void)setMessageLabel:(UILabel *)messageLabel {
    _messageLabel = messageLabel;
    [_messageLabel setExplanatoryFontWithDefaultFontSizeAndColor];
    _messageLabel.numberOfLines = 0;
    _messageLabel.text = self.message;
}

- (void)setMessage:(NSString *)message {
    _message = message;
    self.messageLabel.text = message;
}

- (void)setPositiveButton:(RoundedRectView *)dismissRow {
    _positiveButton = dismissRow;
    _positiveButton.backgroundColor = [UIColor rivetLightBlue];
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(positiveAction)];
    uitgr.numberOfTapsRequired = 1;
    [_positiveButton addGestureRecognizer:uitgr];
    [_positiveButton roundCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                       withRadius:7];
}

#pragma mark - Dismiss

- (void)negativeAction {
    __weak RivetAlertViewViewController *weakSelf = self;
    [self.presentingViewController dismissViewControllerAnimated:YES
    completion:^{
        if (weakSelf.negativeSelector) {
            ((void (*)(id, SEL))[weakSelf.delegate methodForSelector:weakSelf.negativeSelector])(weakSelf.delegate, weakSelf.negativeSelector);
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_changeStatusBarColor
                                                        object:nil
                                                      userInfo:@{@"color":[UIColor rivetDarkBlue]}];
}

- (void)positiveAction {
    __weak RivetAlertViewViewController *weakSelf = self;
    [self.presentingViewController dismissViewControllerAnimated:YES
    completion:^{
        if (weakSelf.positiveSelector) {
            ((void (*)(id, SEL))[weakSelf.delegate methodForSelector:weakSelf.positiveSelector])(weakSelf.delegate, weakSelf.positiveSelector);
        } else if (weakSelf.negativeSelector) {
            ((void (*)(id, SEL))[weakSelf.delegate methodForSelector:weakSelf.negativeSelector])(weakSelf.delegate, weakSelf.negativeSelector);
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_changeStatusBarColor
                                                        object:nil
                                                      userInfo:@{@"color":[UIColor rivetDarkBlue]}];
}

#pragma mark - Set To Positive/Negative Type

- (void)setToPositiveNegativeType {
    [self.view addSubview:self.negativeButton];
    [self.negativeButton addSubview:self.negativeLabel];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.negativeButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.positiveButton
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.negativeButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.positiveButton
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.negativeButton
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.modalView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.negativeButton
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.positiveButton
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.negativeButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.positiveButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.negativeLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.negativeButton
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.negativeLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.negativeButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    [self.positiveButton roundCorners:UIRectCornerBottomRight
                           withRadius:7];
}

#pragma mark - Creation

+ (void)showAlertViewWithMessage:(NSString *)message
                withPositiveText:(NSString *)positiveText
                      withTarget:(id)target
               withOnCloseAction:(SEL)selector {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RivetAlertView" bundle:nil];
    RivetAlertViewViewController *vc = [sb instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rivetAlertViewViewController];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.message = message;
    vc.positiveText = positiveText;
    vc.negativeSelector = selector;
    vc.delegate = target;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIModalPresentationStyle oldStyle = rootViewController.modalPresentationStyle;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    } else {
        rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    [rootViewController presentViewController:vc
                                     animated:YES
                                   completion:^{
                                       rootViewController.modalPresentationStyle = oldStyle;
                                   }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_changeStatusBarColor
                                                        object:nil
                                                      userInfo:@{@"color":[UIColor rivetDarkBlue]}];
}

+ (void)showAlertViewWithMessage:(NSString *)message
                withPositiveText:(NSString *)positiveText
                withNegativeText:(NSString *)negativeText
                      withTarget:(id)target
            withOnPositiveAction:(SEL)positiveSelector
            withOnNegativeAction:(SEL)negativeSelector {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RivetAlertView" bundle:nil];
    RivetAlertViewViewController *vc = [sb instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rivetAlertViewViewController];
    [vc setToPositiveNegativeType];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.message = message;
    vc.positiveText = positiveText;
    vc.negativeText = negativeText;
    vc.negativeSelector = negativeSelector;
    vc.positiveSelector = positiveSelector;
    vc.delegate = target;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIModalPresentationStyle oldStyle = rootViewController.modalPresentationStyle;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    } else {
        rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    [rootViewController presentViewController:vc
                                     animated:YES
                                   completion:^{
                                       rootViewController.modalPresentationStyle = oldStyle;
                                   }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_changeStatusBarColor
                                                        object:nil
                                                      userInfo:@{@"color":[UIColor rivetDarkBlue]}];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end