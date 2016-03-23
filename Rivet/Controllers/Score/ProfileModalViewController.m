#import "ProfileModalViewController.h"
#import "HexagonWithBorderView.h"
#import "UserProfile.h"
#import "UIFont+Rivet.h"
#import "UIColor+Rivet.h"
#import "ConversationListener.h"
#import "UILabel+Rivet.h"
#import "RivetUserDefaults.h"
#import "UserRepository.h"
#import "LNNotificationsUI_iOS7.1.h"
#import "OmniBar.h"
#import "ConstUtil.h"
#import "EventTrackingUtil.h"

NSString *const kProfileModalViewControllerTag = @"ProfileModalViewController";

@interface ProfileModalViewController ()

@property (strong, nonatomic) UserProfile                         *userProfile;
@property (strong, nonatomic) IBOutlet UIView                     *myConversationsRow;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *defaultLabels;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray  *greenDividers;
@property (strong, nonatomic) IBOutlet UIView                     *mainView;
@property (strong, nonatomic) IBOutlet UIScrollView               *scrollView;
@property (strong, nonatomic) IBOutlet UILabel                    *conversationCountLabel;
@property (strong, nonatomic) IBOutlet UILabel                    *timeTalkingLabel;
@property (strong, nonatomic) IBOutlet UILabel                    *averageMessagesLabel;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray  *whiteTextLabels;
@property (strong, nonatomic) IBOutlet UILabel                    *myConversationsRightChevron;

@end

@implementation ProfileModalViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissModal)];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont rivetNavigationBarHeaderFont]};
    self.navigationController.navigationBar.barTintColor = [UIColor rivetLightBlue];
    self.navigationController.navigationBar.translucent = NO;
    [self updateUserProfileLabels];
    self.mainView.backgroundColor = [UIColor rivetOffWhite];
    for (UILabel *label in self.defaultLabels) {
        [label setExplanatoryFontWithDefaultFontSizeAndColor];
    }
    for (UIView *greenDivider in self.greenDividers) {
        greenDivider.backgroundColor = [UIColor rivetLightBlue];
    }
    for (UILabel *whiteTextLabel in self.whiteTextLabels) {
        [whiteTextLabel setExplanatoryFontWithDefaultFontSizeWithColor:[UIColor whiteColor]];
    }
    self.scrollView.backgroundColor = [UIColor rivetOffWhite];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ConversationListener ifNotificationsNotEnabledListenToActiveConversationOrWaitForMatchChannel];
    [self fetchUserProfile];
    self.title = NSLocalizedString(@"Profile", nil);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObservers];
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

#pragma mark - Setters

- (void)setMyConversationsRow:(UIView *)myConversationsRow {
    _myConversationsRow = myConversationsRow;
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToMyConversations)];
    uitgr.numberOfTapsRequired = 1;
    _myConversationsRow.userInteractionEnabled = YES;
    [_myConversationsRow addGestureRecognizer:uitgr];
}

- (void)setMyConversationsRightChevron:(UILabel *)myConversationsRightChevron {
    _myConversationsRightChevron = myConversationsRightChevron;
    [_myConversationsRightChevron setToSmallFontAwesomeIcon:FAChevronRight withColor:[UIColor colorWithHexCode:@"C7C7CC"]];
}

#pragma mark - User Profile

- (void)fetchUserProfile {
    __weak ProfileModalViewController *weakSelf = self;
    [UserRepository updateUserProfileWithSuccessHandler:^{
        [weakSelf updateUserProfileLabels];
    }
                                     withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}
                                                withTag:kProfileModalViewControllerTag];
}

- (void)updateUserProfileLabels {
    self.userProfile = [RivetUserDefaults userProfile];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 0;
    formatter.groupingSeparator = @",";
    formatter.groupingSize = 3;
    formatter.minimumIntegerDigits = 2;
    self.conversationCountLabel.text = [NSString stringWithFormat:@"%li", (long)self.userProfile.conversationCount];
    self.timeTalkingLabel.text = [NSString stringWithFormat:@"%li:%@:%@", (long)(self.userProfile.secondsInConversation/3600), [formatter stringFromNumber:@((self.userProfile.secondsInConversation % 3600)/60)], [formatter stringFromNumber:@(self.userProfile.secondsInConversation % 60)]];
    self.averageMessagesLabel.text = [NSString stringWithFormat:@"%li", (long)self.userProfile.medianMessagesPerConversation];
}

#pragma mark - Push Notification Handling

- (void)notificationWasTapped {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LNNotificationWasTappedNotification
                                                            object:nil];
    }];
}

#pragma mark - Modal Methods

- (void)dismissModal {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_changeStatusBarColor
                                                        object:nil
                                                      userInfo:@{@"color":[UIColor rivetDarkBlue], @"time":@(0.01)}];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segueing

- (void)segueToMyConversations {
    [self performSegueWithIdentifier:kSegueIdentifier_profileModalToMyConversations sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifier_profileModalToMyConversations]) {
        [EventTrackingUtil selectedMyConversations];
    }
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