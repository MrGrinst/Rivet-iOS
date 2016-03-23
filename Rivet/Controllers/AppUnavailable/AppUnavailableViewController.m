#import "AppUnavailableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "TutorialViewController.h"
#import "ConstUtil.h"

NSString *const kAppUnavailableStatusLocationDenied = @"LocationDenied";
NSString *const kAppUnavailableStatusGeofenced = @"Geofenced";

@interface AppUnavailableViewController()

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSTimer  *segueToSettingsTimer;

@end

@implementation AppUnavailableViewController

#pragma mark - Init

- (id)initWithStatus:(NSString *)status {
    self.status = status;
    if ([status isEqualToString:kAppUnavailableStatusLocationDenied]) {
        self = [super initWithNibName:@"LocationPermissionDenied" bundle:[NSBundle mainBundle]];
    } else if ([status isEqualToString:kAppUnavailableStatusGeofenced]) {
        self = [super initWithNibName:@"InsideGeofencedArea" bundle:[NSBundle mainBundle]];
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber10_8) {
        self.segueToSettingsTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                     target:self
                                                                   selector:@selector(segueToSettings)
                                                                   userInfo:nil
                                                                    repeats:NO];
    }
    [self addObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.segueToSettingsTimer invalidate];
    [self removeObservers];
}

#pragma mark - Observers

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

#pragma mark - Application Delegate Methods

- (void)appDidBecomeActive:(NSNotification *)notification {
    if ([self.status isEqualToString:kAppUnavailableStatusLocationDenied]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status != kCLAuthorizationStatusDenied) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            TutorialViewController *vc = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_tutorial];
            appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            appDelegate.window.rootViewController = vc;
            [appDelegate.window makeKeyAndVisible];
        }
    } else if ([self.status isEqualToString:kAppUnavailableStatusGeofenced]) {
        //Recheck location
    }
}

#pragma mark - Segueing

- (void)segueToSettings {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
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