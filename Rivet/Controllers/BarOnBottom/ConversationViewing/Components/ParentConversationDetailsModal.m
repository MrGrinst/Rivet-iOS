#import "ParentConversationDetailsModal.h"
#import "UIColor+Rivet.h"
#import "OmniBar.h"
#import "Message.h"
#import "MessageTableViewCell.h"
#import "ParentConversationDetailsHeaderCell.h"
#import "ConversationRepository.h"
#import "SortUtil.h"

NSString *const kParentConversationDetailsModalTag = @"kParentConversationDetailsModalTag";

@interface ParentConversationDetailsModal ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView              *cardView;
@property (strong, nonatomic) UITableView         *tableView;
@property (strong, nonatomic) ParentConversation  *parentConversation;
@property (strong, nonatomic) NSArray             *messages;
@property (strong, nonatomic) NSMutableDictionary *cachedTextSize;

@end

@implementation ParentConversationDetailsModal

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    uitgr.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:uitgr];
    [self.view addSubview:self.cardView];
    [self.cardView addSubview:self.tableView];
    [self setupConstraints];
    [self loadMessages];
}

#pragma mark - Setup Constraints

- (void)setupConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cardView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cardView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:270]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:400]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cardView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cardView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cardView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cardView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
}

#pragma mark - Getters

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.translatesAutoresizingMaskIntoConstraints = NO;
        _cardView.layer.cornerRadius = 7;
        _cardView.backgroundColor = [UIColor whiteColor];
    }
    return _cardView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.layer.cornerRadius = 7;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableDictionary *)cachedTextSize {
    if (!_cachedTextSize) {
        _cachedTextSize = [[NSMutableDictionary alloc] init];
    }
    return _cachedTextSize;
}

#pragma mark - Messages

- (void)loadMessages {
    __weak ParentConversationDetailsModal *weakSelf = self;
    [ConversationRepository messagesForConversationId:self.parentConversation.conversationId
                                            sinceTime:[NSDate distantPast]
                                   withSuccessHandler:^(NSArray *messages) {
                                       weakSelf.messages = [SortUtil sort:messages
                                                              byAttribute:@"timestamp"
                                                                ascending:YES];
                                       [weakSelf.tableView reloadData];
                                   }
                                   withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                              withTag:kParentConversationDetailsModalTag];
}

#pragma mark - Tap Handlers

- (void)cancel {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_changeStatusBarColor
                                                        object:nil
                                                      userInfo:@{@"color":[UIColor rivetDarkBlue]}];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

#pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ParentConversationDetailsHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"header"];
        if (!cell) {
            cell = [[ParentConversationDetailsHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"header"];
        }
        cell.parentConversation = self.parentConversation;
        return cell;
    } else {
        Message *message = [self.messages objectAtIndex:indexPath.row - 1];
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message"];
        if (!cell) {
            cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"message"
                                                      isOnLeft:[message isOnLeftWithMyParticipantNumber:-1]
                                                  withMaxWidth:270];
        }
        [cell setMessage:message
             setIsOnLeft:[message isOnLeftWithMyParticipantNumber:-1]
        setMyParticipantNumber:-1
          cachedTextSize:self.cachedTextSize];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [ParentConversationDetailsHeaderCell heightWithParentConversation:self.parentConversation];
    } else {
        return [MessageTableViewCell heightGivenMessage:[self.messages objectAtIndex:indexPath.row - 1] withMaxWidth:270];
    }
}


#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Present

+ (void)showModalWithParentConversation:(ParentConversation *)parentConversation {
    ParentConversationDetailsModal *vc = [[ParentConversationDetailsModal alloc] init];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.parentConversation = parentConversation;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
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

@end