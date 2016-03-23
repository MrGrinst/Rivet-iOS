#import "MyConversationViewController.h"
#import "Conversation.h"
#import "ConversationRepository.h"
#import "ConstUtil.h"
#import "ConversationTableViewCellFactory.h"
#import "WaitingForLoadView.h"
#import "SortUtil.h"
#import "ConversationViewingViewController.h"
#import "LNNotificationsUI_iOS7.1.h"

NSString *const kMyConversationViewControllerTag = @"MyConversationViewController";

@interface MyConversationViewController ()

@property (strong, nonatomic) ConversationViewingViewController *conversationViewingViewController;

@end

@implementation MyConversationViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildViewController:self.conversationViewingViewController];
    self.conversationViewingViewController.view.frame = self.view.frame;
    [self.view addSubview:self.conversationViewingViewController.view];
    [self.conversationViewingViewController didMoveToParentViewController:self];
    self.title = NSLocalizedString(@"closedConversation", nil);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BaseRepository cancelRequestsWithTag:kMyConversationViewControllerTag];
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

- (ConversationViewingViewController *)conversationViewingViewController {
    if (!_conversationViewingViewController) {
        _conversationViewingViewController = [[ConversationViewingViewController alloc] init];
        _conversationViewingViewController.shouldAllowInteractivePopGesture = YES;
        _conversationViewingViewController.conversationId = self.conversationId;
    }
    return _conversationViewingViewController;
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