#import <Foundation/Foundation.h>
#import "UserProfile.h"
#import "NewUser.h"
#import "BaseRepository.h"
#import "LocationUtil.h"

@interface UserRepository : BaseRepository

+ (void)registerUserWithLocationUtil:(LocationUtil *)locationUtil
                  withSuccessHandler:(void (^)(void))successHandler
                  withFailureHandler:(NetworkEventFailureHandler)failureHandler;

+ (void)sendCurrentLocationWithLocationUtil:(LocationUtil *)locationUtil
                         withSuccessHandler:(void (^)(void))successHandler
                         withFailureHandler:(NetworkEventFailureHandler)failureHandler;

+ (void)updateAppStateWithSuccessHandler:(void (^)(void))successHandler
                      withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                 withTag:(NSString *)tag;

+ (void)updateUserProfileWithSuccessHandler:(void (^)(void))successHandler
                         withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                    withTag:(NSString *)tag;

+ (void)registerUserForPushNotificationsUsingDeviceToken:(NSString *)deviceToken
                                      withSuccessHandler:(void (^)(void))successHandler
                                      withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                                 withTag:(NSString *)tag;

@end