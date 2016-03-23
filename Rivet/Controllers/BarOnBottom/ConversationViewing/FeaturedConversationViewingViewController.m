#import "FeaturedConversationViewingViewController.h"
#import "ConversationRepository.h"
#import "ConversationTableViewCellFactory.h"
#import "ConstUtil.h"
#import "SharingImageCreator.h"
#import "FeaturedConversationHeaderCell.h"
#import "StartNewConversationButton.h"
#import "FeaturedConversationFooterCell.h"
#import "BarOnBottomController.h"
#import "EventTrackingUtil.h"

NSString *const kFeaturedConversationViewingViewControllerTag = @"FeaturedConversationViewingViewController";

@interface FeaturedConversationViewingViewController()

@property (strong, nonatomic) UITableView         *tableView;
@property (strong, nonatomic) NSMutableDictionary *cachedCellHeights;
@property (strong, nonatomic) NSMutableDictionary *cachedTextSizes;
@property (strong, nonatomic) Conversation        *conversation;

@end

@implementation FeaturedConversationViewingViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self setupConstraints];
    [self loadConversation];
    self.title = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_showingFeaturedConversation
                                                        object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_updateChatButtonText
                                                        object:nil
                                                      userInfo:@{@"talkAboutThis": @(YES)}];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_setCurrentFeaturedConversation
                                                        object:nil
                                                      userInfo:@{@"conversationId": @(self.conversationSummary.conversationId)}];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_hidingFeaturedConversation
                                                        object:nil];
    [BaseRepository cancelRequestsWithTag:kFeaturedConversationViewingViewControllerTag];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeConversation)
                                                 name:kNotification_closeButtonTapped
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startConversation)
                                                 name:kNotification_startOrStopSearchingButtonPressed
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_shareButtonTapped
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_closeButtonTapped
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotification_startOrStopSearchingButtonPressed
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

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (Conversation *)conversation {
    if (!_conversation) {
        _conversation = [[Conversation alloc] init];
    }
    return _conversation;
}

#pragma mark - Setters

- (void)setConversationSummary:(ConversationSummary *)conversationSummary {
    _conversationSummary = conversationSummary;
    self.conversation.isFeatured = conversationSummary.isFeatured;
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
}

#pragma mark - Load Conversation

- (void)loadConversation {
    __weak FeaturedConversationViewingViewController *weakSelf = self;
    [ConversationRepository wholeConversationForConversationId:self.conversationSummary.conversationId
                                            withSuccessHandler:^(Conversation *conversation) {
                                                [weakSelf conversationFinishedLoading:conversation];
                                            }
                                            withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                       withTag:kFeaturedConversationViewingViewControllerTag];
}

- (void)conversationFinishedLoading:(Conversation *)conversation {
    self.conversation = conversation;
    self.conversationSummary.headline = conversation.headline;
    self.conversationSummary.desc = conversation.desc;
    self.conversationSummary.pictureUrl = conversation.pictureUrl;
    [self.tableView reloadData];
}

#pragma mark - Close Conversation

- (void)closeConversation {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Start Conversation

- (void)startConversation {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_chatButtonTapped object:nil];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ConversationTableViewCellFactory numberOfRowsForConversation:self.conversation];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ConversationTableViewCellFactory heightForRowAtIndexPath:indexPath
                                                    withConversation:self.conversation
                                                withQuickLoadSummary:self.conversationSummary
                                                 withMessageViewList:self.conversation.messages
                                               withCachedCellHeights:self.cachedCellHeights
                                            isConversationMakingView:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ConversationTableViewCellFactory conversationTableViewCellForRowAtIndexPath:indexPath
                                                                           forTableView:tableView
                                                                       withConversation:self.conversation
                                                                   withQuickLoadSummary:self.conversationSummary
                                                               isConversationMakingView:NO
                                                                     withCachedTextSize:self.cachedTextSizes
                                                                        withPrivacyMask:nil];
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

#pragma mark - Frames

- (CGRect)pictureFrame {
    if (_tableView) {
        FeaturedConversationHeaderCell *headerCell = (FeaturedConversationHeaderCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        return [headerCell pictureFrame];
    }
    return CGRectZero;
}

- (CGRect)headlineFrame {
    if (_tableView) {
        FeaturedConversationHeaderCell *headerCell = (FeaturedConversationHeaderCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        return [headerCell headlineFrame];
    }
    return CGRectZero;
}

- (CGRect)descriptionFrame {
    if (_tableView) {
        FeaturedConversationHeaderCell *headerCell = (FeaturedConversationHeaderCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        return [headerCell descriptionFrame];
    }
    return CGRectZero;
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