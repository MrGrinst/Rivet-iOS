#import "ConversationViewingViewController.h"
#import "ConversationRepository.h"
#import "ConversationTableViewCellFactory.h"
#import "ConstUtil.h"
#import "UIColor+Rivet.h"
#import "UIFont+Rivet.h"
#import "WaitingForLoadView.h"
#import "ConversationVotingView.h"
#import "NSDictionary+Rivet.h"
#import "EventTrackingUtil.h"
#import "SharingImageCreator.h"
#import "ConversationCache.h"

NSString *const kConversationViewingViewControllerTag = @"ConversationViewingViewController";

@interface ConversationViewingViewController()

@property (strong, nonatomic) UITableView            *tableView;
@property (nonatomic) BOOL                            viewFinishedLoading;
@property (strong, nonatomic) WaitingForLoadView     *waitingForLoadView;
@property (strong, nonatomic) NSMutableDictionary    *cachedCellHeights;
@property (strong, nonatomic) NSMutableDictionary    *cachedTextSizes;
@property (strong, nonatomic) PrivacyMask            *privacyMask;
@property (strong, nonatomic) Conversation           *conversation;

@end

@implementation ConversationViewingViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"closedConversation", nil);
    self.navigationController.navigationBar.barTintColor = [UIColor rivetDarkBlue];
    if (!self.shouldAllowInteractivePopGesture) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont rivetNavigationBarHeaderFont]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.backgroundView = self.privacyMask.backgroundMaskView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.waitingForLoadView];
    [self setupConstraints];
    [self loadConversation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_showingConversation
                                                        object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewFinishedLoading = YES;
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_hidingConversation
                                                        object:nil];
    [BaseRepository cancelRequestsWithTag:kConversationViewingViewControllerTag];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObservers];
}

#pragma mark - System Events

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shareConversation)
                                                 name:kNotification_shareButtonTapped
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_shareButtonTapped
                                                  object:nil];
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

- (UIView *)waitingForLoadView {
    if (!_waitingForLoadView) {
        _waitingForLoadView = [[WaitingForLoadView alloc] init];
        _waitingForLoadView.loadingText = NSLocalizedString(@"loadingConversation", nil);
        _waitingForLoadView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _waitingForLoadView;
}

- (PrivacyMask *)privacyMask {
    if (!_privacyMask) {
        _privacyMask = [[PrivacyMask alloc] init];
        CGRect frame = _privacyMask.frame;
        frame.origin.y = 0;
        _privacyMask.frame = frame;
    }
    return _privacyMask;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _tableView;
}

#pragma mark - Setup Constraints

- (void)setupConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.tableView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.tableView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.tableView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.tableView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.waitingForLoadView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.waitingForLoadView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.waitingForLoadView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.waitingForLoadView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
}

#pragma mark - Load Conversation

- (void)loadConversation {
    __weak ConversationViewingViewController *weakSelf = self;
    [ConversationRepository wholeConversationForConversationId:self.conversationId
                                            withSuccessHandler:^(Conversation *conversation) {
                                                [weakSelf conversationFinishedLoading:conversation];
                                            }
                                            withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                       withTag:kConversationViewingViewControllerTag];
}

- (void)conversationFinishedLoading:(Conversation *)conversation {
    __weak ConversationViewingViewController *weakSelf = self;
    self.conversation = conversation;
    if (self.conversation.isFeatured && self.conversation.headline) {
        self.title = self.conversation.headline;
    }
    [self.tableView reloadData];
    [UIView animateWithDuration:0.5
                     animations:^{
                         weakSelf.waitingForLoadView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [weakSelf.waitingForLoadView removeFromSuperview];
                     }];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ConversationTableViewCellFactory numberOfRowsForConversation:self.conversation];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ConversationTableViewCellFactory heightForRowAtIndexPath:indexPath
                                                    withConversation:self.conversation
                                                withQuickLoadSummary:nil
                                                 withMessageViewList:self.conversation.messages
                                               withCachedCellHeights:self.cachedCellHeights
                                            isConversationMakingView:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ConversationTableViewCellFactory conversationTableViewCellForRowAtIndexPath:indexPath
                                                                           forTableView:tableView
                                                                       withConversation:self.conversation
                                                                   withQuickLoadSummary:nil
                                                               isConversationMakingView:NO
                                                                     withCachedTextSize:self.cachedTextSizes
                                                                        withPrivacyMask:self.privacyMask];
}

#pragma mark - Share Conversation

- (void)shareConversation {
    [EventTrackingUtil shareButtonTapped];
    UIImage *imageToShare = [SharingImageCreator createImageFromDescription:self.conversation.desc
                                                                   headline:self.conversation.headline
                                                                 isFeatured:self.conversation.isFeatured];
    if (imageToShare) {
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[imageToShare, [NSURL URLWithString:[NSString stringWithFormat:@"http://share.jumpintorivet.com/#conversation/%li/featured/%@", (long)(self.conversation.conversationId * 17), self.conversation.isFeatured ? @"true" : @"false"]]] applicationActivities:nil];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Dealloc

- (void)dealloc {
    [self removeObservers];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

@end