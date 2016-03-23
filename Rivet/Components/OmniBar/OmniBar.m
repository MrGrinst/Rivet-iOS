#import "OmniBar.h"
#import "UIColor+Rivet.h"
#import "ConstUtil.h"
#import "NSString+FontAwesome.h"
#import "UILabel+Rivet.h"
#import "EventTrackingUtil.h"
#import "UIButton+Rivet.h"
#import "AppState.h"

NSString *const kNotification_changeStatusBarColor = @"ChangeStatusBarColor";
NSString *const kNotification_shareButtonTapped = @"shareButtonTapped";
NSString *const kNotification_chatButtonTapped = @"chatButtonTapped";
NSString *const kNotification_enableShareButton = @"enableShareButton";
NSString *const kNotification_disableShareButton = @"disableShareButton";
NSString *const kNotification_closeButtonTapped = @"closeButtonTapped";
NSString *const kNotification_showingFeaturedConversation = @"showingFeaturedConversation";
NSString *const kNotification_hidingFeaturedConversation = @"hidingFeaturedConversation";
NSString *const kNotification_showingConversation = @"showingConversation";
NSString *const kNotification_hidingConversation = @"hidingConversation";
NSString *const kNotification_showCloseButton = @"showCloseButton";
NSString *const kNotification_hideCloseButton = @"hideCloseButton";
NSString *const kNotification_omniBarTapped = @"kNotification_omniBarTapped";
NSString *const kNotification_updateChatButtonText = @"updateChatButtonText";
NSInteger const kOmniBarHeight = 44;

@interface OmniBar()

@property (strong, nonatomic) UIButton           *menuButton;
@property (strong, nonatomic) UIButton           *profileButton;
@property (strong, nonatomic) UIView             *chatButtonHolder;
@property (strong, nonatomic) UILabel            *chatButtonText;
@property (strong, nonatomic) UILabel            *chatButtonIcon;
@property (strong, nonatomic) UIButton           *closeButton;
@property (strong, nonatomic) UIButton           *shareButton;
@property (strong, nonatomic) UIView             *statusBarCoverer;
@property (strong, nonatomic) NSLayoutConstraint *buttonTextToHolderRightConstraint;


@end

@implementation OmniBar

#pragma mark - Init

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor rivetLightBlue];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.menuButton];
        [self addSubview:self.chatButtonHolder];
        [self.chatButtonHolder addSubview:self.chatButtonIcon];
        [self.chatButtonHolder addSubview:self.chatButtonText];
        [self addSubview:self.closeButton];
        [self addSubview:self.profileButton];
        [self addSubview:self.shareButton];
        [self setupConstraints];
        [UIApplication.sharedApplication.delegate.window.rootViewController.view addSubview:self.statusBarCoverer];
        [self addObservers];
        [self updateChatButtonText:nil];
    }
    return self;
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.menuButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.menuButton
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.menuButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:self.profileButton.imageView.image.size.height * .70]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:self.profileButton.imageView.image.size.width * .70]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:1]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.chatButtonHolder
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.chatButtonHolder
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.chatButtonIcon
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.chatButtonHolder
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:4]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.chatButtonHolder
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.chatButtonIcon
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:6]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.chatButtonIcon
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.chatButtonHolder
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.chatButtonText
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.chatButtonIcon
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.chatButtonHolder
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.chatButtonText
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    self.buttonTextToHolderRightConstraint = [NSLayoutConstraint constraintWithItem:self.chatButtonHolder
                                                                          attribute:NSLayoutAttributeRight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.chatButtonText
                                                                          attribute:NSLayoutAttributeRight
                                                                         multiplier:1
                                                                           constant:0];
    [self addConstraint:self.buttonTextToHolderRightConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.closeButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.closeButton
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.shareButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.shareButton
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
}

#pragma mark - Observers

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifiedToChangeStatusBarCovererColor:)
                                                 name:kNotification_changeStatusBarColor
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableShareButton)
                                                 name:kNotification_enableShareButton
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disableShareButton)
                                                 name:kNotification_disableShareButton
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateChatButtonText:)
                                                 name:kNotification_updateChatButtonText
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showingFeaturedConversation)
                                                 name:kNotification_showingFeaturedConversation
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hidingFeaturedConversation)
                                                 name:kNotification_hidingFeaturedConversation
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showingConversation)
                                                 name:kNotification_showingConversation
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hidingConversation)
                                                 name:kNotification_hidingConversation
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCloseButton)
                                                 name:kNotification_showCloseButton
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideCloseButton)
                                                 name:kNotification_hideCloseButton
                                                object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_changeStatusBarColor
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_enableShareButton
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_disableShareButton
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_updateChatButtonText
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_showingFeaturedConversation
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_hidingFeaturedConversation
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_showingConversation
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_hidingConversation
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_hideCloseButton
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_showCloseButton
                                                  object:nil];
}

#pragma mark - Getters

- (UIButton *)menuButton {
    if (!_menuButton) {
        _menuButton = [UIButton whiteButtonWithLargeFontAwesomeIcon:FABars withTarget:self withAction:@selector(openMenu)];
        _menuButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _menuButton;
}

- (UIButton *)profileButton {
    if (!_profileButton) {
        _profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_profileButton addTarget:self
                           action:@selector(openProfileModal)
                 forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [UIImage imageNamed:@"FrogIcon"];
        [_profileButton setImage:image forState:UIControlStateNormal];
        _profileButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _profileButton;
}

- (UILabel *)chatButtonIcon {
    if (!_chatButtonIcon) {
        _chatButtonIcon = [[UILabel alloc] init];
        [_chatButtonIcon setToLargeFontAwesomeIcon:FAComment withColor:[UIColor rivetLightBlue]];
        _chatButtonIcon.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _chatButtonIcon;
}

- (UIView *)chatButtonHolder {
    if (!_chatButtonHolder) {
        _chatButtonHolder = [[UIView alloc] init];
        _chatButtonHolder.translatesAutoresizingMaskIntoConstraints = NO;
        _chatButtonHolder.layer.cornerRadius = 3;
        _chatButtonHolder.userInteractionEnabled = YES;
        _chatButtonHolder.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(chatButtonTapped)];
        uitgr.numberOfTapsRequired = 1;
        [_chatButtonHolder addGestureRecognizer:uitgr];
    }
    return _chatButtonHolder;
}

- (UILabel *)chatButtonText {
    if (!_chatButtonText) {
        _chatButtonText = [[UILabel alloc] init];
        [_chatButtonText setExplanatoryFontWithDefaultFontSizeWithColor:[UIColor rivetLightBlue]];
        _chatButtonText.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _chatButtonText;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton whiteButtonWithLargeFontAwesomeIcon:FATimes withTarget:self withAction:@selector(closeButtonTapped)];
        _closeButton.hidden = YES;
        _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _closeButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton whiteButtonWithFontSize:22 withFontAwesomeIcon:FAShare withTarget:self withAction:@selector(shareButtonTapped)];
        _shareButton.hidden = YES;
        _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _shareButton;
}

- (UIView *)statusBarCoverer {
    if (!_statusBarCoverer) {
        _statusBarCoverer = [[UIView alloc] init];
        _statusBarCoverer.frame = CGRectMake(0, 0, [ConstUtil screenWidth], [ConstUtil statusBarHeight]);
        _statusBarCoverer.backgroundColor = [UIColor rivetDarkBlue];
    }
    return _statusBarCoverer;
}

#pragma mark - Setters

- (void)setShareButtonEnabled:(BOOL)shareButtonEnabled {
    self.shareButton.userInteractionEnabled = shareButtonEnabled;
    if (shareButtonEnabled) {
        self.shareButton.alpha = 1;
    } else {
        self.shareButton.alpha = 0.5;
    }
}

- (void)enableShareButton {
    self.shareButton.userInteractionEnabled = YES;
    self.shareButton.alpha = 1;
}

- (void)disableShareButton {
    self.shareButton.userInteractionEnabled = NO;
    self.shareButton.alpha = 0.5;
}

- (void)showingFeaturedConversation {
    self.closeButton.hidden = NO;
    self.shareButton.hidden = NO;
}

- (void)hidingFeaturedConversation {
    self.closeButton.hidden = YES;
    self.shareButton.hidden = YES;
}

- (void)showingConversation {
    self.closeButton.hidden = NO;
    self.shareButton.hidden = NO;
}

- (void)hidingConversation {
    self.closeButton.hidden = YES;
    self.shareButton.hidden = YES;
}

- (void)updateChatButtonText:(NSNotification *)notification {
    self.profileButton.hidden = NO;
    self.chatButtonText.text = @"";
    self.buttonTextToHolderRightConstraint.constant = 0;
    if ([AppState activeConversation]) {
        self.chatButtonText.text = NSLocalizedString(@"activeConversationChatButtonText", nil);
        self.buttonTextToHolderRightConstraint.constant = 8;
    } else if ([notification.userInfo objectForKey:@"talkAboutThis"] && ![AppState waitForMatchChannel]) {
        self.profileButton.hidden = YES;
        self.shareButton.hidden = YES;
        self.chatButtonText.text = NSLocalizedString(@"talkAboutThis", nil);
        self.buttonTextToHolderRightConstraint.constant = 8;
    }
}

#pragma mark - Button Handling

- (void)openMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_omniBarTapped object:nil];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Menu" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [rootViewController presentViewController:vc
                                     animated:YES
                                   completion:nil];
    [self changeStatusBarCovererColor:[UIColor clearColor] withTime:1.5];
    [EventTrackingUtil openedMenu];
}

- (void)openProfileModal {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_omniBarTapped object:nil];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProfileModal" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [rootViewController presentViewController:vc
                                     animated:YES
                                   completion:nil];
    [self changeStatusBarCovererColor:[UIColor clearColor] withTime:1.5];
    [EventTrackingUtil openedProfileModal];
}

- (void)shareButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_shareButtonTapped
                                                        object:nil];
}

- (void)chatButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_chatButtonTapped
                                                        object:nil];
}

- (void)closeButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_closeButtonTapped
                                                        object:nil];
}

- (void)showCloseButton {
    self.closeButton.hidden = NO;
}

- (void)hideCloseButton {
    self.closeButton.hidden = YES;
}

- (void)notifiedToChangeStatusBarCovererColor:(NSNotification *)notification {
    UIColor *color = [notification.userInfo objectForKey:@"color"];
    CGFloat time = ((NSNumber *)[notification.userInfo objectForKey:@"time"]).floatValue;
    if (time == 0) {
        time = 0.3;
    }
    [self changeStatusBarCovererColor:color withTime:time];
}

- (void)changeStatusBarCovererColor:(UIColor *)color withTime:(CGFloat)time {
    __weak OmniBar *weakSelf = self;
    [UIApplication.sharedApplication.delegate.window bringSubviewToFront:self.statusBarCoverer];
    [UIView animateWithDuration:time animations:^{
        weakSelf.statusBarCoverer.backgroundColor = color;
    }];
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.statusBarCoverer removeFromSuperview];
    [self removeObservers];
}

@end