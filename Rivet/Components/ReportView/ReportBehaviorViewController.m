#import "ReportBehaviorViewController.h"
#import "RoundedRectView.h"
#import "UIColor+Rivet.h"
#import "NSString+FontAwesome.h"
#import "UILabel+Rivet.h"
#import "HexagonWithBorderView.h"
#import "RivetAlertViewViewController.h"
#import "OmniBar.h"
#import "ConstUtil.h"
#import "ReportBehaviorRepository.h"
#import "UIFont+Rivet.h"

NSString *const kReportBehaviorViewControllerTag = @"ReportBehaviorViewController";

@interface ReportBehaviorViewController ()

@property (strong, nonatomic) IBOutlet UILabel                    *inappropriateMessagesIcon;
@property (strong, nonatomic) IBOutlet UILabel                    *targetsSomeoneIcon;
@property (strong, nonatomic) IBOutlet UILabel                    *otherIcon;
@property (strong, nonatomic) IBOutlet UIView                     *inappropriateMessagesRow;
@property (strong, nonatomic) IBOutlet UIView                     *targetsSomeoneRow;
@property (strong, nonatomic) IBOutlet UIView                     *otherRow;
@property (strong, nonatomic) IBOutlet RoundedRectView            *cancelRow;
@property (strong, nonatomic) IBOutlet UIView                     *modalView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *generalLabels;
@property (strong, nonatomic) IBOutlet UILabel                    *cancelLabel;
@property (strong, nonatomic) IBOutlet UILabel                    *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel                    *exclamationLabel;
@property (nonatomic) NSInteger                                    conversationId;

@end

@implementation ReportBehaviorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTouchGestureToView:self.view withSelector:@selector(cancel)];
    for (UILabel *label in self.generalLabels) {
        [label setExplanatoryFontWithDefaultFontSizeAndColor];
    }
}

#pragma mark - Setters

- (void)setExclamationLabel:(UILabel *)exclamationLabel {
    _exclamationLabel = exclamationLabel;
    _exclamationLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:46];
    _exclamationLabel.text = [NSString fontAwesomeIconStringForEnum:FAExclamationTriangle];
    _exclamationLabel.textColor = [UIColor rivetOrange];
}

- (void)setInappropriateMessagesIcon:(UILabel *)inappropriateMessagesIcon {
    _inappropriateMessagesIcon = inappropriateMessagesIcon;
    [_inappropriateMessagesIcon setToMediumFontAwesomeIcon:FAThumbsODown
                                                 withColor:[UIColor rivetOrange]];
}

- (void)setTargetsSomeoneIcon:(UILabel *)targetsSomeoneIcon {
    _targetsSomeoneIcon = targetsSomeoneIcon;
    [_targetsSomeoneIcon setToMediumFontAwesomeIcon:FAUser
                                          withColor:[UIColor rivetOrange]];
}

- (void)setOtherIcon:(UILabel *)otherIcon {
    _otherIcon = otherIcon;
    [_otherIcon setToMediumFontAwesomeIcon:FAEllipsisH
                                 withColor:[UIColor rivetOrange]];
}

- (void)setInappropriateMessagesRow:(UIView *)inappropriateMessagesRow {
    _inappropriateMessagesRow = inappropriateMessagesRow;
    [self addTouchGestureToView:_inappropriateMessagesRow withSelector:@selector(inappropriateMessagesRowTapped)];
}

- (void)setTargetsSomeoneRow:(UIView *)targetsSomeoneRow {
    _targetsSomeoneRow = targetsSomeoneRow;
    [self addTouchGestureToView:_targetsSomeoneRow withSelector:@selector(targetsSomeoneRowTapped)];
}

- (void)setOtherRow:(UIView *)otherRow {
    _otherRow = otherRow;
    [self addTouchGestureToView:_otherRow withSelector:@selector(otherRowTapped)];
}

- (void)setCancelRow:(RoundedRectView *)cancelRow {
    _cancelRow = cancelRow;
    [self addTouchGestureToView:_cancelRow withSelector:@selector(cancel)];
    [_cancelRow roundCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                  withRadius:7];
    _cancelRow.backgroundColor = [UIColor rivetOrange];
}

- (void)setModalView:(UIView *)modalView {
    _modalView = modalView;
    _modalView.layer.cornerRadius = 10;
}

- (void)setTitleLabel:(UILabel *)titleLabel {
    _titleLabel = titleLabel;
    [_titleLabel setExplanatoryFontWithSize:24 withColor:[UIColor rivetOrange]];
}

- (void)setCancelLabel:(UILabel *)cancelLabel {
    _cancelLabel = cancelLabel;
    [_cancelLabel setExplanatoryFontWithDefaultFontSizeWithColor:[UIColor whiteColor]];
}

#pragma mark - Tap Handlers

- (void)addTouchGestureToView:(UIView *)view withSelector:(SEL)selector {
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    uitgr.numberOfTapsRequired = 1;
    [view addGestureRecognizer:uitgr];
}

- (void)inappropriateMessagesRowTapped {
    __weak ReportBehaviorViewController *weakSelf = self;
    if (self.conversationId != -1) {
        [ReportBehaviorRepository reportBehavior:@"messages"
                                  onConversation:self.conversationId
                              withSuccessHandler:^{}
                              withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                         withTag:kReportBehaviorViewControllerTag];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          [weakSelf showSuccessfulReportingAlertView];
                                                      }];
}

- (void)targetsSomeoneRowTapped {
    __weak ReportBehaviorViewController *weakSelf = self;
    if (self.conversationId != -1) {
        [ReportBehaviorRepository reportBehavior:@"targets_someone"
                                  onConversation:self.conversationId
                              withSuccessHandler:^{}
                              withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                         withTag:kReportBehaviorViewControllerTag];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          [weakSelf showSuccessfulReportingAlertView];
                                                      }];
}

- (void)otherRowTapped {
    __weak ReportBehaviorViewController *weakSelf = self;
    if (self.conversationId != -1) {
        [ReportBehaviorRepository reportBehavior:@"other"
                                  onConversation:self.conversationId
                              withSuccessHandler:^{}
                              withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                         withTag:kReportBehaviorViewControllerTag];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          [weakSelf showSuccessfulReportingAlertView];
                                                      }];
}

- (void)showSuccessfulReportingAlertView {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_changeStatusBarColor
                                                        object:nil
                                                      userInfo:@{@"color":[UIColor rivetDarkBlue]}];
    [RivetAlertViewViewController showAlertViewWithMessage:NSLocalizedString(@"reportSuccessMessage", nil)
                                          withPositiveText:NSLocalizedString(@"Thanks!", nil)
                                                withTarget:self
                                         withOnCloseAction:nil];
}

- (void)cancel {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_changeStatusBarColor
                                                        object:nil
                                                      userInfo:@{@"color":[UIColor rivetDarkBlue]}];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

+ (void)showReportViewForConversation:(NSInteger)conversationId {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ReportView" bundle:nil];
    ReportBehaviorViewController *vc = [sb instantiateViewControllerWithIdentifier:kViewControllerIdentifier_reportDialogViewController];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.conversationId = conversationId;
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