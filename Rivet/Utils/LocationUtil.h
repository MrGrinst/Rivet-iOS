#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NSInteger const kErrorCode_couldNotFindLocation;

@interface LocationUtil : NSObject

- (void)getLocationWithSuccessHandler:(void(^)(CLLocation *))successHandler
                   withFailureHandler:(void(^)(NSError *))failureHandler;

@end