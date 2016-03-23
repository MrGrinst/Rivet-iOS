#import "MenuViewController.h"
#import "ConstUtil.h"
#import "UIColor+Rivet.h"
#import "AppDelegate.h"
#import "UIFont+Rivet.h"
#import "LNNotificationsUI_iOS7.1.h"
#import "TutorialViewController.h"
#import "AppState.h"
#import "RivetUserDefaults.h"
#import "ConversationListener.h"
#import "UILabel+Rivet.h"
#import "OmniBar.h"
#import "MenuHeaderView.h"

#define isProduction [[NSBundle mainBundle] objectForInfoDictionaryKey:@"isProduction"]

NSString *const kMenuViewControllerTag = @"MenuViewController";

@interface MenuViewController()<UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableViewCell            *shareRow;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *menuTextLabels;
@property (strong, nonatomic) IBOutlet UITableViewCell            *contactUsRow;
@property (strong, nonatomic) IBOutlet UITableViewCell            *rateUsRow;
@property (strong, nonatomic) IBOutlet UITableViewCell            *likeOnFacebookRow;
@property (strong, nonatomic) IBOutlet UITableViewCell            *followOnTwitterRow;
@property (strong, nonatomic) IBOutlet UITableViewCell            *followOnInstagramRow;
@property (strong, nonatomic) MenuHeaderView                      *sizingCell;

@end

@implementation MenuViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 44;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissModal)];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont rivetNavigationBarHeaderFont]};
    self.navigationController.navigationBar.barTintColor = [UIColor rivetLightBlue];
    self.navigationController.navigationBar.translucent = NO;
    for (UILabel *label in self.menuTextLabels) {
        [label setExplanatoryFontWithDefaultFontSizeAndColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ConversationListener ifNotificationsNotEnabledListenToActiveConversationOrWaitForMatchChannel];
    self.title = NSLocalizedString(@"Menu", nil);
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

- (void)setShareRow:(UITableViewCell *)shareRow {
    _shareRow = shareRow;
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(share)];
    uitgr.numberOfTapsRequired = 1;
    [_shareRow addGestureRecognizer:uitgr];
}

- (void)setContactUsRow:(UITableViewCell *)contactUsRow {
    _contactUsRow = contactUsRow;
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contactUs)];
    uitgr.numberOfTapsRequired = 1;
    [_contactUsRow addGestureRecognizer:uitgr];
}

- (void)setRateUsRow:(UITableViewCell *)rateUsRow {
    _rateUsRow = rateUsRow;
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateUs)];
    uitgr.numberOfTapsRequired = 1;
    [_rateUsRow addGestureRecognizer:uitgr];
}

- (void)setLikeOnFacebookRow:(UITableViewCell *)likeOnFacebookRow {
    _likeOnFacebookRow = likeOnFacebookRow;
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeOnFacebook)];
    uitgr.numberOfTapsRequired = 1;
    [_likeOnFacebookRow addGestureRecognizer:uitgr];
}

- (void)setFollowOnTwitterRow:(UITableViewCell *)followOnTwitterRow {
    _followOnTwitterRow = followOnTwitterRow;
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followOnTwitter)];
    uitgr.numberOfTapsRequired = 1;
    [_followOnTwitterRow addGestureRecognizer:uitgr];
}

- (void)setFollowOnInstagramRow:(UITableViewCell *)followOnInstagramRow {
    _followOnInstagramRow = followOnInstagramRow;
    UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followOnInstagram)];
    uitgr.numberOfTapsRequired = 1;
    [_followOnInstagramRow addGestureRecognizer:uitgr];
}

#pragma mark - Settings Actions

- (IBAction)resetTutorialToTutorialScreen:(id)sender {
    [RivetUserDefaults setHasRegisteredPushNotificationToken:NO];
    [RivetUserDefaults setHasSlidPrivacyMaskLeft:NO];
    [RivetUserDefaults setHasSeenLocationPermissionAlert:NO];
    [AppState setSelectedSegmentIndexOnConversationListView:nil];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    TutorialViewController *vc = [appDelegate.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_tutorial];
    appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    appDelegate.window.rootViewController = vc;
    [appDelegate.window makeKeyAndVisible];
}

#pragma mark - Share

- (void)share {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[NSLocalizedString(@"shareMessage", nil)] applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Contact Us

- (void)contactUs {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://jumpintorivet.com/support"]];
}

#pragma mark - Rate Us

- (void)rateUs {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id981016676"]];
}

#pragma mark - Like on Facebook

- (void)likeOnFacebook {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://page?id=431429777004747"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/pages/Rivet/431429777004747"]];
    }
}

#pragma mark - Follow on Twitter

- (void)followOnTwitter {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=TheRivetApp"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/TheRivetApp"]];
    }
}

#pragma mark - Follow on Instagram

- (void)followOnInstagram {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"instagram://user?username=therivetapp"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://instagram.com/therivetapp/"]];
    }
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

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MenuHeaderView *cell = [[MenuHeaderView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"none"];
    if (section == 0) {
        cell.title = NSLocalizedString(@"JumpIn", nil);
    } else if (section == 1) {
        cell.title = NSLocalizedString(@"SocialMedia", nil);
    } else if (section == 2) {
        cell.title = NSLocalizedString(@"Legal", nil);
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        if (isProduction) {
            return 2;
        } else {
            return 3;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.sizingCell) {
        self.sizingCell = [[MenuHeaderView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"none"];
        self.sizingCell.title = NSLocalizedString(@"JumpIn", nil);
    }
    [self.sizingCell setNeedsLayout];
    [self.sizingCell layoutIfNeeded];
    CGSize size = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
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