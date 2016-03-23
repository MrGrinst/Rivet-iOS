#import "UserRepository.h"
#import "RivetUserDefaults.h"
#import "Authentication.h"
#import "AppState.h"
#import "UserState.h"
#import "ListContainerViewController.h"

@implementation UserRepository

+ (void)registerUserWithLocationUtil:(LocationUtil *)locationUtil
                  withSuccessHandler:(void (^)(void))successHandler
                  withFailureHandler:(NetworkEventFailureHandler)failureHandler {
    if (![Authentication isUserLoggedIn]) {
        [locationUtil getLocationWithSuccessHandler:^(CLLocation *location) {
            NSDictionary *params = @{@"latitude":@(location.coordinate.latitude), @"longitude":@(location.coordinate.longitude)};
            [self performPOSTWithRelativeUrl:@"/register"
                          withSuccessHandler:^(id response) {
                              NewUser *newUser = [[NewUser alloc] initWithDto:response];
                              [Authentication saveNewUser:newUser];
                              [AppState setUserState:newUser.userState];
                              if (newUser.userState.isNearbyEligible) {
                                  [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_showNearbyEligibleInterface object:nil];
                              } else {
                                  [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_hideNearbyEligibleInterface object:nil];
                              }
                              successHandler();
                          }
                          withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                             failureHandler(operation, error);
                          }
                               withAuthToken:NO
                              withParameters:params
                                     withTag:@"faketag"
                canQueueMultipleIfNoInternet:NO];
        }
                                 withFailureHandler:^(NSError *error){
                                     failureHandler(nil, error);
                                 }];
    } else {
        successHandler();
    }
}

+ (void)sendCurrentLocationWithLocationUtil:(LocationUtil *)locationUtil
                         withSuccessHandler:(void (^)(void))successHandler
                         withFailureHandler:(NetworkEventFailureHandler)failureHandler {
    [locationUtil getLocationWithSuccessHandler:^(CLLocation *location) {
        NSDictionary *dto = @{@"latitude": @(location.coordinate.latitude), @"longitude": @(location.coordinate.longitude)};
        [self performPUTWithRelativeUrl:@"/location"
                     withSuccessHandler:^(NSDictionary *dto) {
                         UserState *userState = [[UserState alloc] initWithDto:dto];
                         [AppState setUserState:userState];
                         if (userState.isNearbyEligible) {
                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_showNearbyEligibleInterface object:nil];
                         } else {
                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_hideNearbyEligibleInterface object:nil];
                         }
                         successHandler();
                     }
                     withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                         failureHandler(operation, error);
                     }
                          withAuthToken:YES
                         withParameters:dto
                                withTag:@"faketag"];
    }
                             withFailureHandler:^(NSError *error){
                                 failureHandler(nil, error);
                             }];
}

+ (void)updateUserProfileWithSuccessHandler:(void (^)(void))successHandler
                         withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                    withTag:(NSString *)tag {
    [self performGETWithRelativeUrl:@"/profile"
                 withSuccessHandler:^(id response) {
                     [RivetUserDefaults setUserProfile:[[UserProfile alloc] initWithDto:response]];
                     successHandler();
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                            withTag:tag];
}

+ (void)updateAppStateWithSuccessHandler:(void (^)(void))successHandler
                      withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                 withTag:(NSString *)tag {
    [self performGETWithRelativeUrl:@"/state"
                 withSuccessHandler:^(NSDictionary *dto) {
                     UserState *userState = [[UserState alloc] initWithDto:dto];
                     if (userState.isNearbyEligible) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_showNearbyEligibleInterface object:nil];
                     } else {
                         [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_hideNearbyEligibleInterface object:nil];
                     }
                     [AppState setUserState:userState];
                     successHandler();
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                            withTag:tag];
}

+ (void)registerUserForPushNotificationsUsingDeviceToken:(NSString *)deviceToken
                                      withSuccessHandler:(void (^)(void))successHandler
                                      withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                                 withTag:(NSString *)tag {
    [self performPUTWithRelativeUrl:@"/push"
                 withSuccessHandler:^(id response) {
                     successHandler();
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                     withParameters:@{@"token": deviceToken, @"device_type":@"ios"}
                            withTag:tag];
}

@end