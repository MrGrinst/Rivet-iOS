#import "JumpIntoRivetViewController.h"
#import "ConstUtil.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"
#import "LNNotificationsUI_iOS7.1.h"

@interface JumpIntoRivetViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *frogImage;
@property (strong, nonatomic) IBOutlet UILabel *rulesLabel;
@property (strong, nonatomic) IBOutlet UILabel *rulesTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *jumpInTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *topTextLabel;

@end

@implementation JumpIntoRivetViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"JumpIntoRivet", nil);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
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

- (void)setRulesLabel:(UILabel *)rulesLabel {
    _rulesLabel = rulesLabel;
    _rulesLabel.numberOfLines = 0;
    [_rulesLabel setExplanatoryFontWithDefaultFontSizeAndColor];
}

- (void)setRulesTitleLabel:(UILabel *)rulesTitleLabel {
    _rulesTitleLabel = rulesTitleLabel;
    [_rulesTitleLabel setExplanatoryFontWithSize:24
                                       withColor:[UIColor rivetDarkBlue]];
}

- (void)setTopTextLabel:(UILabel *)topTextLabel {
    _topTextLabel = topTextLabel;
    _topTextLabel.numberOfLines = 0;
    [_topTextLabel setExplanatoryFontWithDefaultFontSizeAndColor];
}

- (void)setJumpInTitleLabel:(UILabel *)jumpInTitleLabel {
    _jumpInTitleLabel = jumpInTitleLabel;
    _jumpInTitleLabel.numberOfLines = 0;
    [_jumpInTitleLabel setExplanatoryFontWithSize:24
                                       withColor:[UIColor rivetDarkBlue]];
}

- (void)setFrogImage:(UIImageView *)frogImage {
    _frogImage = frogImage;
    _frogImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToSpecialThanks)];
    uitgr.numberOfTapsRequired = 3;
    [_frogImage addGestureRecognizer:uitgr];
}

- (void)segueToSpecialThanks {
    [self performSegueWithIdentifier:kSegueIdentifier_jumpIntoRivetToSpecialThanks sender:self];
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

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Push Notification Handling

- (void)notificationWasTapped {
    [self.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LNNotificationWasTappedNotification
                                                            object:nil];
    }];
}

@end