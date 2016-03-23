#import "LocationUtil.h"
#import <Crashlytics/Crashlytics.h>
#import "EventTrackingUtil.h"

NSInteger const kErrorCode_couldNotFindLocation = 535353;

@interface LocationUtil()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL                       sentLocationToServer;
@property (strong, nonatomic) void (^successHandler)(CLLocation *);
@property (strong, nonatomic) void (^failureHandler)(NSError *);

@end

@implementation LocationUtil

#pragma mark - Location Updating

- (void)getLocationWithSuccessHandler:(void(^)(CLLocation *))successHandler
                   withFailureHandler:(void(^)(NSError *))failureHandler {
    self.sentLocationToServer = NO;
    self.successHandler = successHandler;
    self.failureHandler = failureHandler;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - LocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    __weak LocationUtil *weakSelf = self;
    [manager stopUpdatingLocation];
    if (!self.sentLocationToServer) {
        self.sentLocationToServer = YES;
        //GATECH
        //double latitude = 33.777;
        //double longitude = -84.391;
        double latitude = ((CLLocation *)[locations firstObject]).coordinate.latitude;
        double longitude = ((CLLocation *)[locations firstObject]).coordinate.longitude;
        if (weakSelf.successHandler) {
            weakSelf.successHandler([[CLLocation alloc] initWithLatitude:latitude
                                                               longitude:longitude]);
        }
        weakSelf.successHandler = nil;
        weakSelf.failureHandler = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [manager stopUpdatingLocation];
    if (self.failureHandler) {
        self.failureHandler([[NSError alloc] initWithDomain:@"fakedomain" code:kErrorCode_couldNotFindLocation userInfo:nil]);
        self.failureHandler = nil;
        self.successHandler = nil;
    }
    [EventTrackingUtil logError:@{@"Location Error":error.description}];
    CLSNSLog(@"Error retrieving location: %@", error.description);
}

- (void)dealloc {
    _locationManager.delegate = nil;
}

@end