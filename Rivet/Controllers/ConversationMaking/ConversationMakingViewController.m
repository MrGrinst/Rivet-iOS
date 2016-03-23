#import "ConversationMakingViewController.h"
#import "UIColor+Rivet.h"
#import "BarOnBottomController.h"
#import "Conversation.h"
#import "ConversationTableViewCellFactory.h"
#import "SortUtil.h"
#import "ConversationRepository.h"
#import "NSDictionary+Rivet.h"
#import "StartNewConversationButton.h"
#import "ConstUtil.h"
#import "PrivacyMaskAfterSlideTutorialView.h"
#import "PrivacyMaskBeforeSlideTutorialView.h"
#import "AppState.h"
#import "RealtimeConnection.h"
#import "RivetUserDefaults.h"
#import "RivetAlertViewViewController.h"
#import "EventTrackingUtil.h"
#import "SharingImageCreator.h"
#import "ConversationListener.h"
#import "ReportBehaviorViewController.h"
#import "SearchHeartbeatGenerator.h"
#import "UIButton+Rivet.h"
#import "UIFont+Rivet.h"
#import "UILabel+Rivet.h"

NSString *const kConversationMakingViewControllerTag = @"ConversationMakingViewController";

@interface ConversationMakingViewController()

@property (strong, nonatomic) UIView                             *waitingView;
@property (strong, nonatomic) RealtimeConnection                 *realtimeConnection;
@property (strong, nonatomic) PrivacyMask                        *privacyMask;
@property (strong, nonatomic) NSMutableDictionary                *cachedCellHeights;
@property (strong, nonatomic) NSMutableDictionary                *cachedTextSizes;
@property (strong, nonatomic) PrivacyMaskAfterSlideTutorialView  *privacyMaskTutorialView;
@property (strong, nonatomic) PrivacyMaskBeforeSlideTutorialView *privacyMaskBeforeSlideTutorialView;
@property (strong, nonatomic) NSTimer                            *typingTimer;
@property (strong, nonatomic) NSDate                             *lastTypingEventSent;
@property (strong, nonatomic) StartNewConversationButton         *startNewConversationButton;
@property (strong, nonatomic) UIActivityIndicatorView            *searchingSpinner;
@property (strong, nonatomic) UILabel                            *conversationButtonLabel;
@property (strong, nonatomic) UIBarButtonItem                    *endConversationButton;
@property (strong, nonatomic) UIBarButtonItem                    *reportButton;
@property (strong, nonatomic) UIBarButtonItem                    *firstSpacer;
//There could be issues with this in the future. It's a hacky fix and certain steps may result in leaking Pusher connections or Pusher connections not being created
@property (nonatomic) BOOL                                        isShowingEndConversationDialog;

@end

@implementation ConversationMakingViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.inverted = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.privacyMask.isOnRight = ![RivetUserDefaults isPrivacyTabOnLeft];
    self.tableView.backgroundView = self.privacyMask.backgroundMaskView;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ConversationListener stopListeningToEverything];
    [self resetModeToCurrentMode];
    if (self.parentConversationId > 0 && ![AppState waitForMatchChannel] && ![AppState activeConversation]) {
        [self startOrStopSearchingIfNotificationsEnabled];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isShowingEndConversationDialog) {
        [self addObservers];
        [self loadUpdatedConversation];
        [self addConversationObservers];
    } else {
        [self loadUpdatedConversation];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [BaseRepository cancelRequestsWithTag:kConversationMakingViewControllerTag];
    if (!self.isShowingEndConversationDialog) {
        [self removeConversationObservers];
        [self.typingTimer invalidate];
        [self removeObservers];
        [AppState saveConversationDataToUserDefaults];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self dismissKeyboard];
    if (self.isMovingFromParentViewController) {
        [self resetConversationVariablesIfInActive];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_updateChatButtonText object:nil];
}

#pragma mark - One Time Setup

- (void)setupNavigationBar {
    self.navigationController.navigationBar.barTintColor = [UIColor rivetDarkBlue];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont rivetNavigationBarHeaderFont]};
    self.firstSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                      target:nil
                                                                      action:nil];
    self.firstSpacer.width = -12;
}

#pragma mark - SLK Messaging Methods

- (id)init {
    return [super initWithTableViewStyle:UITableViewStylePlain];
}

- (void)dismissKeyboard {
    [self dismissKeyboard:YES];
}

- (void)didPressRightButton:(id)sender {
    if ([AppState activeConversation].channel) {
        self.textView.text = [NSString stringWithFormat:@"%@ ", self.textView.text];
        self.textView.text = [self.textView.text substringToIndex:self.textView.text.length - 1];
        [ConversationRepository sendMessageWithText:[self.textView.text copy]
                                          isPrivate:!self.privacyMask.isOnRight
                                     toConversation:[AppState activeConversation]
                                 withSuccessHandler:^{}
                                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                            withTag:@"FAKE_SEND_MESSAGE_TAG"];
    }
    [super didPressRightButton:sender];
}

#pragma mark - Observers

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(privacyMaskSlidLeft)
                                                 name:kNotification_privacyMaskSlidLeft
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(privacyMaskSlidRight)
                                                 name:kNotification_privacyMaskSlidRight
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appIsInBackgroundOrInactive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appIsInBackgroundOrInactive:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissKeyboard)
                                                 name:kNotification_omniBarTapped
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startOrStopSearchingIfNotificationsEnabled)
                                                 name:kNotification_startOrStopSearchingButtonPressed
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_privacyMaskSlidLeft
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_privacyMaskSlidRight
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_omniBarTapped
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_startOrStopSearchingButtonPressed
                                                  object:nil];
}

#pragma mark - Application Delegate Methods

- (void)appIsInBackgroundOrInactive:(NSNotification *)notification {
    [AppState saveConversationDataToUserDefaults];
    [self removeConversationObservers];
    [BaseRepository cancelRequestsWithTag:kConversationMakingViewControllerTag];
    [self dismissKeyboard];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    [self resetModeToCurrentMode];
    [self loadUpdatedConversation];
    [self addConversationObservers];
}

- (void)appWillTerminate:(NSNotification *)notification {
    [self removeObservers];
    [AppState saveConversationDataToUserDefaults];
    [self resetConversationVariablesIfInActive];
    [self removeConversationObservers];
    [BaseRepository cancelRequestsWithTag:kConversationMakingViewControllerTag];
    [self dismissKeyboard];
}

#pragma mark - Set Modes

- (void)setModeToPreWaiting {
    [self.privacyMask removeFromSuperview];
    self.tableView.hidden = YES;
    [RivetUserDefaults setIsPrivacyTabOnLeft:NO];
    [self.view addSubview:self.waitingView];
    [self setupWaitingViewConstraints];
    self.privacyMask.isOnRight = YES;
    [self.searchingSpinner stopAnimating];
    self.conversationButtonLabel.hidden = NO;
    self.conversationButtonLabel.text = NSLocalizedString(@"StartConversation", nil);
    self.startNewConversationButton.isSearching = NO;
    self.navigationItem.rightBarButtonItems = @[];
    [AppState setConversationStatus:kConversationMode_PreWaiting];
    self.title = @"";
}

- (void)setModeToWaiting {
    [self.privacyMask removeFromSuperview];
    self.tableView.hidden = YES;
    [RivetUserDefaults setIsPrivacyTabOnLeft:NO];
    [self.view addSubview:self.waitingView];
    [self setupWaitingViewConstraints];
    self.privacyMask.isOnRight = YES;
    [self.searchingSpinner startAnimating];
    self.conversationButtonLabel.hidden = NO;
    self.conversationButtonLabel.text = NSLocalizedString(@"SearchingForSomeoneToTalkTo", nil);
    self.startNewConversationButton.isSearching = YES;
    self.navigationItem.rightBarButtonItems = @[];
    [AppState setConversationStatus:kConversationMode_Waiting];
    self.title = @"";
}

- (void)setModeToConversing {
    [self.waitingView removeFromSuperview];
    self.tableView.hidden = NO;
    [self.searchingSpinner stopAnimating];
    self.conversationButtonLabel.hidden = YES;
    self.startNewConversationButton.isSearching = NO;
    if ([AppState activeConversation].conversationId != 0 && [[AppState activeConversation] isActive]) {
        self.navigationItem.rightBarButtonItems = @[self.firstSpacer, self.endConversationButton, self.reportButton];
    } else {
        self.navigationItem.rightBarButtonItems = @[self.firstSpacer, self.reportButton];
    }
    self.textInputbar.textView.editable = YES;
    [AppState setConversationStatus:kConversationMode_Conversing];
    self.title = NSLocalizedString(@"yourConversation", nil);
}

- (void)setupWaitingViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.waitingView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLayoutGuide
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.waitingView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.waitingView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.waitingView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
}

- (void)resetModeToCurrentMode {
    if (![AppState conversationStatus] || [[AppState conversationStatus] isEqualToString:kConversationMode_PreWaiting]) {
        [self setModeToPreWaiting];
    } else if ([[AppState conversationStatus] isEqualToString:kConversationMode_Waiting]) {
        [self setModeToWaiting];
    } else if ([[AppState conversationStatus] isEqualToString:kConversationMode_Conversing]) {
        [self setModeToConversing];
    }
}

#pragma mark - Getters

- (NSMutableDictionary *)cachedCellHeights {
    if (!_cachedCellHeights) {
        _cachedCellHeights = [[NSMutableDictionary alloc] init];
    }
    return _cachedCellHeights;
}

- (NSMutableDictionary *)cachedTextSizes {
    if (!_cachedTextSizes) {
        _cachedTextSizes = [[NSMutableDictionary alloc] init];
    }
    return _cachedTextSizes;
}

- (PrivacyMask *)privacyMask {
    if (!_privacyMask) {
        _privacyMask = [[PrivacyMask alloc] init];
    }
    return _privacyMask;
}

- (RealtimeConnection *)realtimeConnection {
    if (!_realtimeConnection) {
        _realtimeConnection = [[RealtimeConnection alloc] initWithDelegate:self];
    }
    return _realtimeConnection;
}

- (StartNewConversationButton *)startNewConversationButton {
    if (!_startNewConversationButton) {
        _startNewConversationButton = [[StartNewConversationButton alloc] init];
    }
    return _startNewConversationButton;
}

- (UIActivityIndicatorView *)searchingSpinner {
    if (!_searchingSpinner) {
        _searchingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _searchingSpinner.userInteractionEnabled = NO;
        _searchingSpinner.translatesAutoresizingMaskIntoConstraints = NO;
        _searchingSpinner.hidesWhenStopped = YES;
    }
    return _searchingSpinner;
}

- (UILabel *)conversationButtonLabel {
    if (!_conversationButtonLabel) {
        _conversationButtonLabel = [[UILabel alloc] init];
        _conversationButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_conversationButtonLabel setExplanatoryFontWithDefaultFontSizeAndColor];
        _conversationButtonLabel.textAlignment = NSTextAlignmentCenter;
        _conversationButtonLabel.numberOfLines = 0;
    }
    return _conversationButtonLabel;
}

- (UIView *)waitingView {
    if (!_waitingView) {
        _waitingView = [[UIView alloc] init];
        _waitingView.backgroundColor = [UIColor whiteColor];
        _waitingView.translatesAutoresizingMaskIntoConstraints = NO;
        [_waitingView addSubview:self.startNewConversationButton];
        [_waitingView addSubview:self.conversationButtonLabel];
        [_waitingView addSubview:self.searchingSpinner];
        [self.startNewConversationButton setWidthConstraints];
        [_waitingView addConstraint:[NSLayoutConstraint constraintWithItem:self.startNewConversationButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_waitingView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:-16]];
        [_waitingView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchingSpinner
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.startNewConversationButton
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0]];
        [_waitingView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationButtonLabel
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.startNewConversationButton
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0]];
        [_waitingView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationButtonLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.startNewConversationButton
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8]];
        [_waitingView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchingSpinner
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationButtonLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8]];
    }
    return _waitingView;
}

- (PrivacyMaskAfterSlideTutorialView *)privacyMaskTutorialView {
    if (!_privacyMaskTutorialView) {
        _privacyMaskTutorialView = [[PrivacyMaskAfterSlideTutorialView alloc] initWithFrame:CGRectMake(0, 0, [ConstUtil screenWidth], [ConstUtil screenHeight])];
    }
    return _privacyMaskTutorialView;
}

- (PrivacyMaskBeforeSlideTutorialView *)privacyMaskBeforeSlideTutorialView {
    if (!_privacyMaskBeforeSlideTutorialView) {
        _privacyMaskBeforeSlideTutorialView = [[PrivacyMaskBeforeSlideTutorialView alloc] initWithFrame:CGRectMake(0, 0, [ConstUtil screenWidth], [ConstUtil screenHeight])];
    }
    return _privacyMaskBeforeSlideTutorialView;
}

- (UIBarButtonItem *)endConversationButton {
    if (!_endConversationButton) {
        UIView *view = [[UIView alloc] init];
        _endConversationButton = [[UIBarButtonItem alloc] initWithCustomView:view];
        UIButton *button = [UIButton whiteButtonWithLargeFontAwesomeIcon:FATimesCircleO withTarget:self withAction:@selector(confirmEndConversation)];
        [button sizeToFit];
        CGRect buttonFrame = button.frame;
        buttonFrame.size.width += 16;
        button.frame = buttonFrame;
        CGRect viewFrame = buttonFrame;
        viewFrame.origin.x += 8;
        view.frame = viewFrame;
        [view addSubview:button];
    }
    return _endConversationButton;
}

- (UIBarButtonItem *)reportButton {
    if (!_reportButton) {
        UIView *view = [[UIView alloc] init];
        _reportButton = [[UIBarButtonItem alloc] initWithCustomView:view];
        UIButton *button = [UIButton whiteButtonWithLargeFontAwesomeIcon:FAFlagO withTarget:self withAction:@selector(reportConversation)];
        [button sizeToFit];
        CGRect buttonFrame = button.frame;
        buttonFrame.size.width += 8;
        button.frame = buttonFrame;
        CGRect viewFrame = buttonFrame;
        viewFrame.origin.x += 4;
        view.frame = viewFrame;
        [view addSubview:button];
    }
    return _reportButton;
}

#pragma mark - Privacy Mask Tutorial

- (void)privacyMaskSlidLeft {
    if (![RivetUserDefaults hasSlidPrivacyMaskLeft]) {
        [self.privacyMaskBeforeSlideTutorialView removeFromSuperview];
        [self.view insertSubview:self.privacyMaskTutorialView belowSubview:self.textInputbar];
        [RivetUserDefaults setHasSlidPrivacyMaskLeft:YES];
        [EventTrackingUtil slidPrivacyMaskLeftForTheFirstTime];
    }
    [RivetUserDefaults setIsPrivacyTabOnLeft:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)privacyMaskSlidRight {
    if (_privacyMaskTutorialView) {
        [self.privacyMaskTutorialView removeFromSuperview];
        _privacyMaskTutorialView = nil;
    }
    [RivetUserDefaults setIsPrivacyTabOnLeft:NO];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - Message Received

- (void)messageReceived:(NSDictionary *)messageDto {
    Message *message = [[Message alloc] initWithDto:messageDto];
    if (![self messageAlreadyExists:message]) {
        [[AppState activeConversation].messages addObject:message];
        if (![message isFromMe:[AppState activeConversation].myParticipantNumber]) {
            [AppState activeConversation].otherUserTyping = NO;
        }
        [self sortMessages];
        [self.tableView reloadData];
        [self scrollToBottomOfMessages:YES];
    }
}

- (BOOL)messageAlreadyExists:(Message *)message {
    Message *existingMessage;
    for (int i = (int)[AppState activeConversation].messages.count - 1; i >= 0; i--) {
        Message *m = [[AppState activeConversation].messages objectAtIndex:i];
        if (message.messageId == m.messageId) {
            existingMessage = m;
            break;
        }
    }
    return existingMessage != nil;
}

- (void)displayPrivacyTutorialIfNecessary {
    BOOL hasPrivateMessages = NO;
    for (Message *m in [AppState activeConversation].messages) {
        hasPrivateMessages = m.isPrivate;
        if (hasPrivateMessages) break;
    }
    if (hasPrivateMessages
        && ![RivetUserDefaults hasSlidPrivacyMaskLeft]
        && !_privacyMaskBeforeSlideTutorialView) {
        [self.view addSubview:self.privacyMaskBeforeSlideTutorialView];
        [self.privacyMask startAnimatingBounce];
        [self dismissKeyboard];
    }
}

- (void)bouncePrivacyTabIfNecessary {
    if ([AppState activeConversation].messages.count >= 10
        && ![RivetUserDefaults hasSlidPrivacyMaskLeft]
        && !_privacyMaskBeforeSlideTutorialView
        && !self.privacyMask.isAnimatingBounce) {
        [self.privacyMask startAnimatingBounce];
    }
}

- (void)sortMessages {
    [AppState activeConversation].messages = [[SortUtil sort:[AppState activeConversation].messages byAttribute:@"timestamp" ascending:YES] mutableCopy];
}

#pragma mark - Match Found

- (void)matchFoundLater:(NSDictionary *)queueStatusDto {
    QueueStatus *queueStatus = [[QueueStatus alloc] initWithDto:queueStatusDto];
    [self matchFound:queueStatus.conversationDetails];
    [SearchHeartbeatGenerator stopSendingHeartbeat];
}

- (void)matchFound:(ConversationDetails *)conversationDetails {
    [self.realtimeConnection stopListeningToChannel:[AppState waitForMatchChannel]];
    [EventTrackingUtil conversationStarted];
    [AppState setWaitForMatchChannel:nil];
    [AppState setActiveConversation:[[Conversation alloc] initWithConversationDetails:conversationDetails withMessages:nil]];
    [self setModeToConversing];
    [self.tableView reloadData];
    [self addConversationObservers];
}

#pragma mark - Conversation Listeners

- (void)addConversationObservers {
    if ([AppState waitForMatchChannel]) {
        [self.realtimeConnection listenToChannel:[AppState waitForMatchChannel]
                                   withEventName:kRealtimeEventName_matchFound
                                    withDelegate:self
                                    withSelector:@selector(matchFoundLater:)];
    } else if ([[AppState activeConversation] isActive]) {
        [self.realtimeConnection listenToChannel:[AppState activeConversation].channel
                                   withEventName:kRealtimeEventName_message
                                    withDelegate:self
                                    withSelector:@selector(messageReceived:)];
        [self.realtimeConnection listenToChannel:[AppState activeConversation].channel
                                   withEventName:kRealtimeEventName_conversationEnded
                                    withDelegate:self
                                    withSelector:@selector(conversationEnded:)];
        [self.realtimeConnection listenToChannel:[AppState activeConversation].channel
                                   withEventName:kRealtimeEventName_conversationUpdated
                                    withDelegate:self
                                    withSelector:@selector(conversationUpdated:)];
        [self.realtimeConnection listenToChannel:[AppState activeConversation].channel
                                   withEventName:kRealtimeEventName_typingEvent
                                    withDelegate:self
                                    withSelector:@selector(userTyped:)];
    } else if ([AppState activeConversation] && ![[AppState activeConversation] isActive]) {
        [self addConversationUpdateObserver];
    }
}

- (void)removeConversationObservers {
    [self.realtimeConnection stopListeningToChannel:[AppState activeConversation].channel];
    [self.realtimeConnection stopListeningToChannel:[AppState waitForMatchChannel]];
}

#pragma mark - Update Conversation

- (void)loadUpdatedConversation {
    __weak ConversationMakingViewController *weakSelf = self;
    if ([AppState activeConversation] && [AppState activeConversation].conversationId == 0) {
        [weakSelf resetConversationVariables];
        [weakSelf setModeToPreWaiting];
    } else if ([[AppState activeConversation] isActive]) {
        [ConversationRepository updateConversation:[AppState activeConversation]
                                withSuccessHandler:^{
                                    if (![[AppState activeConversation] isActive]) {
                                        [EventTrackingUtil conversationEnded];
                                    }
                                    [AppState activeConversation].otherUserTyping = NO;
                                    [weakSelf changeUIIfInactiveConversation];
                                    [weakSelf.tableView reloadData];
                                    [weakSelf scrollToBottomOfMessages:NO];
                                }
                                withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (operation.response.statusCode == 404) {
                                        [AppState activeConversation].endTime = [[NSDate alloc] init];
                                        [AppState activeConversation].otherUserTyping = NO;
                                        [weakSelf changeUIIfInactiveConversation];
                                        [weakSelf.tableView reloadData];
                                        [weakSelf scrollToBottomOfMessages:NO];
                                    }
                                }
                                           withTag:kConversationMakingViewControllerTag];
    } else if (![AppState activeConversation] && [AppState waitForMatchChannel]) {
        [ConversationRepository queueStatusForChannelWithSuccessHandler:^(QueueStatus *queueStatus) {
                                       if (queueStatus.matchFound) {
                                           Conversation *conversation = [[Conversation alloc] initWithConversationDetails:queueStatus.conversationDetails withMessages:nil];
                                           [ConversationRepository messagesForConversationId:conversation.conversationId
                                                                                   sinceTime:[NSDate distantPast]
                                                                          withSuccessHandler:^(NSArray *messages) {
                                                                              conversation.messages = messages.mutableCopy;
                                                                              [AppState setActiveConversation:conversation];
                                                                              [AppState setWaitForMatchChannel:nil];
                                                                              [EventTrackingUtil conversationStarted];
                                                                              [weakSelf.tableView reloadData];
                                                                              [weakSelf scrollToBottomOfMessages:NO];
                                                                              [weakSelf addConversationObservers];
                                                                              [weakSelf setModeToConversing];
                                                                          }
                                                                          withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                                                     withTag:kConversationMakingViewControllerTag];
                                           [SearchHeartbeatGenerator stopSendingHeartbeat];
                                       } else if (!queueStatus.isInQueue) {
                                           [SearchHeartbeatGenerator stopSendingHeartbeat];
                                           [weakSelf resetAndSetModeToPreWaiting];
                                       } else if (queueStatus.isInQueue) {
                                           [SearchHeartbeatGenerator startSendingHeartbeatRightAway];
                                       }
                                   }
                                   withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                              withTag:kConversationMakingViewControllerTag];
    }
}


#pragma mark - Typing Events

- (void)textDidUpdate:(BOOL)animated {
    [super textDidUpdate:animated];
    if ([[AppState activeConversation] isActive]
        && (!self.lastTypingEventSent || [[NSDate date] timeIntervalSinceDate:self.lastTypingEventSent] > 3)) {
        [self.realtimeConnection publishTypingEventToChannel:[AppState activeConversation].channel
                                       withParticipantNumber:[AppState activeConversation].myParticipantNumber];
        self.lastTypingEventSent = [NSDate date];
    }
}

- (void)stopTypingIndicator {
    [AppState activeConversation].otherUserTyping = NO;
    [self.tableView reloadData];
}

- (void)userTyped:(NSDictionary *)dto {
    if ([dto intOrZeroForKey:@"participant_number"] != [AppState activeConversation].myParticipantNumber) {
        [self.typingTimer invalidate];
        self.typingTimer = nil;
        if (![AppState activeConversation].otherUserTyping) {
            [AppState activeConversation].otherUserTyping = YES;
        }
        BOOL scrolledToBottom = self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height);
        [self.tableView reloadData];
        if (scrolledToBottom) {
            [self scrollToBottomOfMessages:YES];
        }
        self.typingTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                         target:self
                                       selector:@selector(stopTypingIndicator)
                                       userInfo:nil
                                        repeats:NO];
    }
}

#pragma mark - Start New Conversation

- (void)startOrStopSearchingIfNotificationsEnabled {
    if (![[AppState conversationStatus] isEqualToString:kConversationMode_Waiting]
        && ([RivetUserDefaults buttonTapCountSinceLastNotificationPermissionRequest] <= 0
            || [RivetUserDefaults buttonTapCountSinceLastNotificationPermissionRequest] > 3)) {
        [self tryToEnablePushNotifications];
    } else {
        [self startOrStopSearchingAfterWait:0];
    }
}

- (void)startOrStopSearchingAfterWait:(NSInteger)wait {
    if ([[AppState conversationStatus] isEqualToString:kConversationMode_Waiting]) {
        [self leaveConversationQueue];
        [SearchHeartbeatGenerator stopSendingHeartbeat];
        [self resetConversationVariables];
        [self setModeToPreWaiting];
        [EventTrackingUtil stoppedSearching];
    } else {
        [self resetConversationVariables];
        [self setModeToWaiting];
        [NSTimer scheduledTimerWithTimeInterval:wait
                                         target:self
                                       selector:@selector(performNewConversationRequest)
                                       userInfo:nil
                                        repeats:NO];
        NSInteger count = [RivetUserDefaults buttonTapCountSinceLastNotificationPermissionRequest];
        if (count != -2) {
            [RivetUserDefaults setButtonTapCountSinceLastNotificationPermissionRequest:count + 1];
        }
        if ([[AppState conversationStatus] isEqualToString:kConversationMode_Conversing]) {
            [EventTrackingUtil startedSearchingAfterConversationEnd];
        } else {
            [EventTrackingUtil startedSearchingFromWaitingView];
        }
    }
}

- (void)performNewConversationRequest {
    __weak ConversationMakingViewController *weakSelf = self;
    if (self.parentConversationId > 0) {
        [ConversationRepository startNewConversationWithSuggestedParentConversationId:self.parentConversationId
                                                                   withSuccessHandler:^(QueueStatus *queueStatus) {
            if (queueStatus.matchFound) {
                [weakSelf matchFound:queueStatus.conversationDetails];
            } else {
                [AppState setWaitForMatchChannel:queueStatus.channel];
                [weakSelf addConversationObservers];
                [SearchHeartbeatGenerator startSendingHeartbeat];
                [weakSelf performSelector:@selector(checkAgainForMatch) withObject:nil afterDelay:1];
            }
        }
                                                                   withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                                              withTag:kConversationMakingViewControllerTag];
    } else {
        [ConversationRepository startNewConversationWithSuccessHandler:^(QueueStatus *queueStatus) {
            if (queueStatus.matchFound) {
                [weakSelf matchFound:queueStatus.conversationDetails];
            } else {
                [AppState setWaitForMatchChannel:queueStatus.channel];
                [weakSelf addConversationObservers];
                [SearchHeartbeatGenerator startSendingHeartbeat];
                [weakSelf performSelector:@selector(checkAgainForMatch) withObject:nil afterDelay:1];
            }
        }
                                                    withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                               withTag:kConversationMakingViewControllerTag];
    }
}

- (void)checkAgainForMatch {
    __weak ConversationMakingViewController *weakSelf = self;
    if (![AppState activeConversation]) {
        [ConversationRepository queueStatusForChannelWithSuccessHandler:^(QueueStatus *queueStatus) {
            if (queueStatus.matchFound) {
                [weakSelf matchFound:queueStatus.conversationDetails];
            }
        }
                                                     withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                                withTag:kConversationMakingViewControllerTag];
    }
}

- (void)tryToEnablePushNotifications {
    if (![RivetUserDefaults hasSeenSystemNotificationPermissionAlert]) {
        [RivetAlertViewViewController showAlertViewWithMessage:NSLocalizedString(@"allowNotificationsMessage", nil)
                                              withPositiveText:NSLocalizedString(@"Allow", nil)
                                              withNegativeText:NSLocalizedString(@"Later", nil)
                                                    withTarget:self
                                          withOnPositiveAction:@selector(tappedAllow)
                                          withOnNegativeAction:@selector(tappedLater)];
        [RivetUserDefaults setButtonTapCountSinceLastNotificationPermissionRequest:0];
    } else {
        [self registerToReceivePushNotificationsAndStartSearching];
    }
}

- (void)tappedLater {
    [self startOrStopSearchingAfterWait:0];
    [EventTrackingUtil tappedLaterNotificationPermission];
}

- (void)tappedAllow {
    [self registerToReceivePushNotificationsAndStartSearching];
    [EventTrackingUtil tappedAllowNotificationPermission];
}

- (void)registerToReceivePushNotificationsAndStartSearching {
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        }
    #else
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    #endif
    if ([RivetUserDefaults hasSeenSystemNotificationPermissionAlert]) {
        [self startOrStopSearchingAfterWait:0];
    } else {
        [self startOrStopSearchingAfterWait:5];
    }
    [RivetUserDefaults setButtonTapCountSinceLastNotificationPermissionRequest:-2];
    [RivetUserDefaults setHasSeenSystemNotificationPermissionAlert:YES];
}


- (void)leaveConversationQueue {
    [ConversationRepository leaveConversationQueueWithSuccessHandler:^{}
                                                  withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                             withTag:kConversationMakingViewControllerTag];
    [self.realtimeConnection stopListeningToChannel:[AppState waitForMatchChannel]];
    [self resetConversationVariables];
}

#pragma mark - End Conversation

- (void)confirmEndConversation {
    self.isShowingEndConversationDialog = YES;
    [RivetAlertViewViewController showAlertViewWithMessage:NSLocalizedString(@"confirmEndConversationMessage", nil)
                                          withPositiveText:NSLocalizedString(@"yes", nil)
                                          withNegativeText:NSLocalizedString(@"no", nil)
                                                withTarget:self
                                      withOnPositiveAction:@selector(endConversation)
                                      withOnNegativeAction:@selector(dontEndConversation)];
}

- (void)endConversation {
    __weak ConversationMakingViewController *weakSelf = self;
    self.isShowingEndConversationDialog = NO;
    [ConversationRepository endConversation:[AppState activeConversation]
                         withSuccessHandler:^{}
                         withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                             if (weakSelf.isViewLoaded && weakSelf.view.window) {
                                 [weakSelf removeConversationObservers];
                                 [weakSelf loadUpdatedConversation];
                             }
                         }
                                    withTag:kConversationMakingViewControllerTag];
}

- (void)dontEndConversation {
    self.isShowingEndConversationDialog = NO;
}

- (void)addConversationUpdateObserver {
    [self.realtimeConnection listenToChannel:[AppState activeConversation].channel
                               withEventName:kRealtimeEventName_conversationUpdated
                                withDelegate:self
                                withSelector:@selector(conversationUpdated:)];
}

#pragma mark - Reset Conversation

- (void)resetAndSetModeToPreWaiting {
    [self removeConversationObservers];
    [self resetConversationVariables];
    [self dismissKeyboard];
    [self setModeToPreWaiting];
}

- (void)resetConversationVariables {
    [AppState setActiveConversation:nil];
    [AppState setWaitForMatchChannel:nil];
}

- (void)resetConversationVariablesIfInActive {
    if (![[AppState activeConversation] isActive] && ![AppState waitForMatchChannel]) {
        [self resetConversationVariables];
        [AppState setConversationStatus:kConversationMode_PreWaiting];
    }
}

- (void)changeUIIfInactiveConversation {
    if (![[AppState activeConversation] isActive]) {
        self.textInputbar.textView.editable = NO;
        self.textInputbar.textView.text = @"";
        self.navigationItem.rightBarButtonItems = @[self.firstSpacer, self.reportButton];
    }
}

#pragma mark - Conversation Expiration

- (void)conversationEnded:(NSDictionary *)conversationDetailsDto {
    if ([[AppState activeConversation] isActive]) {
        [[AppState activeConversation] updateWithConversationDetails:[[ConversationDetails alloc] initWithDto:conversationDetailsDto]
                                                        withMessages:nil];
        [self changeUIIfInactiveConversation];
        [self.tableView reloadData];
        [self.realtimeConnection stopListeningToChannel:[AppState activeConversation].channel];
        [self addConversationUpdateObserver];
        [self scrollToBottomOfMessages:YES];
        [EventTrackingUtil conversationEnded];
    }
}

#pragma mark - Conversation Updated

- (void)conversationUpdated:(NSDictionary *)conversationDetailsDto {
    [[AppState activeConversation] updateWithConversationDetails:[[ConversationDetails alloc] initWithDto:conversationDetailsDto]
                                                    withMessages:nil];
    [self.tableView reloadData];
}

#pragma mark - Scrolling

- (void)scrollToBottomOfMessages:(BOOL)animated {
    NSIndexPath *index = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:index
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:animated];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ConversationTableViewCellFactory numberOfRowsForConversation:[AppState activeConversation]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ConversationTableViewCellFactory heightForRowAtIndexPath:indexPath
                                                    withConversation:[AppState activeConversation]
                                                withQuickLoadSummary:nil
                                                 withMessageViewList:[AppState activeConversation].messages
                                               withCachedCellHeights:self.cachedCellHeights
                                            isConversationMakingView:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ConversationTableViewCellFactory conversationTableViewCellForRowAtIndexPath:indexPath
                                                                           forTableView:tableView
                                                                       withConversation:[AppState activeConversation]
                                                                   withQuickLoadSummary:nil
                                                               isConversationMakingView:YES
                                                                     withCachedTextSize:self.cachedTextSizes
                                                                        withPrivacyMask:self.privacyMask];
}

#pragma mark - Report Conversation

- (void)reportConversation {
    [EventTrackingUtil reportButtonTapped];
    [ReportBehaviorViewController showReportViewForConversation:[AppState activeConversation].conversationId];
}

#pragma mark - Keyboard Methods


- (void)keyboardDidShow {
    [self scrollToBottomOfMessages:YES];
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