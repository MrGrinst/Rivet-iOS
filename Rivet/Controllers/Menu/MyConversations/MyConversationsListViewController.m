#import "MyConversationsListViewController.h"
#import "ConversationSummary.h"
#import "ConversationRepository.h"
#import "ConstUtil.h"
#import "ConversationTableViewCell.h"
#import "MyConversationViewController.h"
#import "ConversationCache.h"
#import "UILabel+Rivet.h"
#import "UITableViewCell+Rivet.h"
#import "LNNotificationsUI_iOS7.1.h"
#import "SortUtil.h"

static NSString *const conversationCellIdentifier = @"conversationCellIdentifier";
NSString *const kMyConversationListViewControllerTag = @"MyConversationListViewControllerTag";

@interface MyConversationsListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray                   *conversationSummaries;
@property (strong, nonatomic) UITableView               *tableView;
@property (strong, nonatomic) ConversationTableViewCell *sizingCell;

@end

@implementation MyConversationsListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self setupConstraints];
    [self fetchConversations];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadCachedConversations];
    self.title = NSLocalizedString(@"MyConversations", nil);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BaseRepository cancelRequestsWithTag:kMyConversationListViewControllerTag];
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

#pragma mark - Getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _tableView;
}

#pragma mark - Setup Constraints

- (void)setupConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
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

#pragma mark - Fetch Conversations

- (void)fetchConversations {
    __weak MyConversationsListViewController *weakSelf = self;
    [ConversationRepository myConversationsWithSuccessHandler:^(NSArray *conversationSummaries) {
        [weakSelf conversationsLoaded:conversationSummaries];
    }
                                           withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                      withTag:kMyConversationListViewControllerTag];
}

- (void)loadCachedConversations {
    [self conversationsLoaded:[ConversationCache myConversationsCache]];
}

- (void)conversationsLoaded:(NSArray *)conversationSummaries {
    self.conversationSummaries = [SortUtil sort:conversationSummaries
                                    byAttribute:@"endTime"
                                      ascending:NO];
    [self.tableView reloadData];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.conversationSummaries.count == 0) {
        return 1;
    }
    return self.conversationSummaries.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.conversationSummaries.count > 0) {
        [self performSegueWithIdentifier:kSegueIdentifier_myConversationsListToMyConversations sender:self];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.conversationSummaries.count > 0) {
        ConversationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:conversationCellIdentifier];
        if (!cell) {
            cell = [[ConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:conversationCellIdentifier];
        }
        cell.conversationSummary = [self.conversationSummaries objectAtIndex:indexPath.row];
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyListCell"];
        [cell setSeparatorFullWidth];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = NSLocalizedString(@"YouHaveNotBeenInAnyConversationsYet", nil);
        [cell.textLabel setExplanatoryFontWithDefaultFontSizeAndColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.conversationSummaries.count > 0) {
        if (!self.sizingCell) {
            self.sizingCell = [[ConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                               reuseIdentifier:@"SizingCell"];
        }
        ConversationSummary *row = [self.conversationSummaries objectAtIndex:indexPath.row];
        return [ConversationTableViewCell heightGivenConversationSummary:row
                                                        withSizingCell:self.sizingCell];
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyListCell"];
        cell.textLabel.text = NSLocalizedString(@"YouHaveNotBeenInAnyConversationsYet", nil);
        [cell.textLabel setExplanatoryFontWithDefaultFontSizeAndColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        CGSize size = [cell sizeThatFits:CGSizeMake([ConstUtil screenWidth], 0)];
        return size.height;
    }
}

#pragma mark - Segueing

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifier_myConversationsListToMyConversations]) {
        ConversationSummary *row = [self.conversationSummaries objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        MyConversationViewController *vc = segue.destinationViewController;
        vc.conversationId = row.conversationId;
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