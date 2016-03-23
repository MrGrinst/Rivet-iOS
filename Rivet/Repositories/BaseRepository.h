#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^NetworkEventSuccessHandler)(id response);
typedef void(^NetworkEventFailureHandler)(AFHTTPRequestOperation *operation, NSError *error);
FOUNDATION_EXPORT NSString *const baseURL;

@interface BaseRepository : NSObject

+ (void)performGETWithRelativeUrl:(NSString *)relativeUrl
               withSuccessHandler:(NetworkEventSuccessHandler)successHandler
               withFailureHandler:(NetworkEventFailureHandler)failureHandler
                    withAuthToken:(BOOL)withAuthToken
                          withTag:(NSString *)tag;

+ (void)performPOSTWithRelativeUrl:(NSString *)relativeUrl
                withSuccessHandler:(NetworkEventSuccessHandler)successHandler
                withFailureHandler:(NetworkEventFailureHandler)failureHandler
                     withAuthToken:(BOOL)withAuthToken
                    withParameters:(NSDictionary *)parameters
                           withTag:(NSString *)tag
      canQueueMultipleIfNoInternet:(BOOL)canQueueMultipleIfNoInternet;

+ (void)performDELETEWithRelativeUrl:(NSString *)relativeUrl
                  withSuccessHandler:(NetworkEventSuccessHandler)successHandler
                  withFailureHandler:(NetworkEventFailureHandler)failureHandler
                       withAuthToken:(BOOL)withAuthToken
                             withTag:(NSString *)tag;

+ (void)performPUTWithRelativeUrl:(NSString *)relativeUrl
               withSuccessHandler:(NetworkEventSuccessHandler)successHandler
               withFailureHandler:(NetworkEventFailureHandler)failureHandler
                    withAuthToken:(BOOL)withAuthToken
                   withParameters:(NSDictionary *)parameters
                          withTag:(NSString *)tag;

+ (void)performPATCHWithRelativeUrl:(NSString *)relativeUrl
                 withSuccessHandler:(NetworkEventSuccessHandler)successHandler
                 withFailureHandler:(NetworkEventFailureHandler)failureHandler
                      withAuthToken:(BOOL)withAuthToken
                     withParameters:(NSDictionary *)parameters
                            withTag:(NSString *)tag
       canQueueMultipleIfNoInternet:(BOOL)canQueueMultipleIfNoInternet;

+ (NSString *)baseAuthToken;
+ (void)cancelRequestsWithTag:(NSString *)tag;
+ (void)startListeningForReachability;
+ (void)invalidateNoInternetQueuedRequests;

@end