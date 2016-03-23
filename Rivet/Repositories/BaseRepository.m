#import "BaseRepository.h"
#import "Authentication.h"
#import "ConstUtil.h"
#import "AppDelegate.h"
#import "TutorialViewController.h"
#import "RivetUserDefaults.h"
#import "RivetReachability.h"
#import <Crashlytics/Crashlytics.h>
#import "UserRepository.h"
#import "QueuedRequest.h"
#import "EventTrackingUtil.h"

#define baseURL [[NSBundle mainBundle] objectForInfoDictionaryKey:@"baseURL"]

NSString *const authorizationHeaderName = @"Authorization";
static NSMutableArray *_queuedRequests;
static NSMutableSet *_queuedRequestUrls;
static NSTimer *noInternetAlertTimer;
static NSMutableDictionary *_taggedRequests;
static RivetReachability *_reachability;
static LocationUtil *_locationUtil;
static BOOL queueListenerIsSet;
static BOOL handling403;
static UIAlertView *_hostConnectionErrorAlertView;
static BOOL reachable = YES;

@implementation BaseRepository

+ (void)performGETWithRelativeUrl:(NSString *)relativeUrl
               withSuccessHandler:(NetworkEventSuccessHandler)successHandler
               withFailureHandler:(NetworkEventFailureHandler)failureHandler
                    withAuthToken:(BOOL)withAuthToken
                          withTag:(NSString *)tag {
    __block void (^weakRunBlock)();
    void (^runBlock)();
    weakRunBlock = runBlock = ^{
        NSString *urlString = [NSString stringWithFormat:@"%@%@", baseURL, relativeUrl];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        if (withAuthToken) {
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.baseAuthToken] forHTTPHeaderField:authorizationHeaderName];
        }
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        AFHTTPRequestOperation *op = [manager GET:urlString
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [self deleteOperation:operation withTag:tag];
                 successHandler(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [self deleteOperation:operation withTag:tag];
                 [self baseFailureHandler:operation
                                withError:error
                           withRetryBlock:weakRunBlock
                       withFailureHandler:failureHandler];
             }];
        [self saveOperation:op withTag:tag];
    };
    if (!reachable) {
        NSLog(@"Queueing request due to no network connection");
        QueuedRequest *queuedRequest = [[QueuedRequest alloc] init];
        queuedRequest.requestBlock = runBlock;
        queuedRequest.requestUrl = relativeUrl;
        [[self queuedRequests] addObject:queuedRequest];
        [self setQueueListener];
    } else {
        runBlock();
    }
}

+ (void)performPOSTWithRelativeUrl:(NSString *)relativeUrl
                withSuccessHandler:(NetworkEventSuccessHandler)successHandler
                withFailureHandler:(NetworkEventFailureHandler)failureHandler
                     withAuthToken:(BOOL)withAuthToken
                    withParameters:(NSDictionary *)parameters
                           withTag:(NSString *)tag
      canQueueMultipleIfNoInternet:(BOOL)canQueueMultipleIfNoInternet {
    __block void (^weakRunBlock)();
    void (^runBlock)();
    weakRunBlock = runBlock = ^{
        NSString *urlString = [NSString stringWithFormat:@"%@%@", baseURL, relativeUrl];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        if (withAuthToken) {
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.baseAuthToken] forHTTPHeaderField:authorizationHeaderName];
        }
        AFHTTPRequestOperation *op = [manager POST:urlString
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [self deleteOperation:operation withTag:tag];
                  successHandler(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [self deleteOperation:operation withTag:tag];
                  [self baseFailureHandler:operation
                                 withError:error
                            withRetryBlock:weakRunBlock
                        withFailureHandler:failureHandler];
              }];
        [self saveOperation:op withTag:tag];
    };
    if (!reachable) {
        if (![[self queuedRequestUrls] containsObject:relativeUrl] || canQueueMultipleIfNoInternet) {
            NSLog(@"Queueing request due to no network connection");
            QueuedRequest *queuedRequest = [[QueuedRequest alloc] init];
            queuedRequest.requestBlock = runBlock;
            queuedRequest.requestUrl = relativeUrl;
            [[self queuedRequests] addObject:queuedRequest];
            [[self queuedRequestUrls] addObject:relativeUrl];
            [self setQueueListener];
        }
    } else {
        runBlock();
    }
}

+ (void)performDELETEWithRelativeUrl:(NSString *)relativeUrl
                  withSuccessHandler:(NetworkEventSuccessHandler)successHandler
                  withFailureHandler:(NetworkEventFailureHandler)failureHandler
                       withAuthToken:(BOOL)withAuthToken
                             withTag:(NSString *)tag {
    __block void (^weakRunBlock)();
    void (^runBlock)();
    weakRunBlock = runBlock = ^{
        NSString *urlString = [NSString stringWithFormat:@"%@%@", baseURL, relativeUrl];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        if (withAuthToken) {
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.baseAuthToken] forHTTPHeaderField:authorizationHeaderName];
        }
        AFHTTPRequestOperation *op = [manager DELETE:urlString
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self deleteOperation:operation withTag:tag];
                    successHandler(responseObject);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self deleteOperation:operation withTag:tag];
                    [self baseFailureHandler:operation
                                   withError:error
                              withRetryBlock:weakRunBlock
                          withFailureHandler:failureHandler];
                }];
        [self saveOperation:op withTag:tag];
    };
    if (!reachable) {
        if (![[self queuedRequestUrls] containsObject:relativeUrl]) {
            NSLog(@"Queueing request due to no network connection");
            QueuedRequest *queuedRequest = [[QueuedRequest alloc] init];
            queuedRequest.requestBlock = runBlock;
            queuedRequest.requestUrl = relativeUrl;
            [[self queuedRequests] addObject:queuedRequest];
            [[self queuedRequestUrls] addObject:relativeUrl];
            [self setQueueListener];
        }
    } else {
        runBlock();
    }
}

+ (void)performPUTWithRelativeUrl:(NSString *)relativeUrl
               withSuccessHandler:(NetworkEventSuccessHandler)successHandler
               withFailureHandler:(NetworkEventFailureHandler)failureHandler
                    withAuthToken:(BOOL)withAuthToken
                   withParameters:(NSDictionary *)parameters
                          withTag:(NSString *)tag {
    __block void (^weakRunBlock)();
    void (^runBlock)();
    weakRunBlock = runBlock = ^{
        NSString *urlString = [NSString stringWithFormat:@"%@%@", baseURL, relativeUrl];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        if (withAuthToken) {
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.baseAuthToken] forHTTPHeaderField:authorizationHeaderName];
        }
        AFHTTPRequestOperation *op = [manager PUT:urlString
          parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [self deleteOperation:operation withTag:tag];
                 successHandler(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [self deleteOperation:operation withTag:tag];
                 [self baseFailureHandler:operation
                                withError:error
                           withRetryBlock:weakRunBlock
                       withFailureHandler:failureHandler];
             }];
        [self saveOperation:op withTag:tag];
    };
    if (!reachable) {
        NSLog(@"Queueing request due to no network connection");
        QueuedRequest *queuedRequest = [[QueuedRequest alloc] init];
        queuedRequest.requestBlock = runBlock;
        queuedRequest.requestUrl = relativeUrl;
        [[self queuedRequests] addObject:queuedRequest];
        [[self queuedRequestUrls] addObject:relativeUrl];
        [self setQueueListener];
    } else {
        runBlock();
    }
}

+ (void)performPATCHWithRelativeUrl:(NSString *)relativeUrl
                 withSuccessHandler:(NetworkEventSuccessHandler)successHandler
                 withFailureHandler:(NetworkEventFailureHandler)failureHandler
                      withAuthToken:(BOOL)withAuthToken
                     withParameters:(NSDictionary *)parameters
                            withTag:(NSString *)tag
       canQueueMultipleIfNoInternet:(BOOL)canQueueMultipleIfNoInternet {
    __block void (^weakRunBlock)();
    void (^runBlock)();
    weakRunBlock = runBlock = ^{
        NSString *urlString = [NSString stringWithFormat:@"%@%@", baseURL, relativeUrl];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        if (withAuthToken) {
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.baseAuthToken] forHTTPHeaderField:authorizationHeaderName];
        }
        AFHTTPRequestOperation *op = [manager PATCH:urlString
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [self deleteOperation:operation withTag:tag];
                  successHandler(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [self deleteOperation:operation withTag:tag];
                  [self baseFailureHandler:operation
                                 withError:error
                            withRetryBlock:weakRunBlock
                        withFailureHandler:failureHandler];
              }];
        [self saveOperation:op withTag:tag];
    };
    if (!reachable) {
        if (![[self queuedRequestUrls] containsObject:relativeUrl] || canQueueMultipleIfNoInternet) {
            NSLog(@"Queueing request due to no network connection");
            QueuedRequest *queuedRequest = [[QueuedRequest alloc] init];
            queuedRequest.requestBlock = runBlock;
            queuedRequest.requestUrl = relativeUrl;
            [[self queuedRequests] addObject:queuedRequest];
            [[self queuedRequestUrls] addObject:relativeUrl];
            [self setQueueListener];
        }
    } else {
        runBlock();
    }
}

+ (void)cancelRequestsWithTag:(NSString *)tag {
    NSMutableArray *ops = [[self taggedRequests] objectForKey:tag];
    [ops makeObjectsPerformSelector:@selector(cancel)];
    [ops removeAllObjects];
}

+ (void)cancelAllRequests {
    for (NSString *key in [self taggedRequests]) {
        NSMutableArray *ops = [[self taggedRequests] objectForKey:key];
        [ops makeObjectsPerformSelector:@selector(cancel)];
        [ops removeAllObjects];
    }
}

+ (void)saveOperation:(AFHTTPRequestOperation *)operation withTag:(NSString *)tag {
    NSMutableArray *ops = [[self taggedRequests] objectForKey:tag];
    if (!ops) {
        ops = [[NSMutableArray alloc] initWithObjects:operation, nil];
        [[self taggedRequests] setObject:ops forKey:tag];
    } else {
        [ops addObject:operation];
    }
}

+ (void)deleteOperation:(AFHTTPRequestOperation *)operation withTag:(NSString *)tag {
    NSMutableArray *ops = [[self taggedRequests] objectForKey:tag];
    [ops removeObject:operation];
}

+ (RivetReachability *)reachability {
    [self startListeningForReachability];
    return _reachability;
}

+ (void)startListeningForReachability {
    if (!_reachability) {
        _reachability = [RivetReachability reachabilityWithHostname:@"www.google.com"];
        _reachability.unreachableBlock = ^(RivetReachability *reachability) {
            reachable = NO;
        };
    }
    [_reachability stopNotifier];
    reachable = YES;
    [_reachability startNotifier];
}

+ (NSString *)baseAuthToken {
    return [RivetUserDefaults authToken];
}

+ (NSMutableArray *)queuedRequests {
    if (!_queuedRequests) {
        _queuedRequests = [[NSMutableArray alloc] init];
    }
    return _queuedRequests;
}

+ (NSMutableSet *)queuedRequestUrls {
    if (!_queuedRequestUrls) {
        _queuedRequestUrls = [[NSMutableSet alloc] init];
    }
    return _queuedRequestUrls;
}

+ (NSMutableDictionary *)taggedRequests {
    if (!_taggedRequests) {
        _taggedRequests = [[NSMutableDictionary alloc] init];
    }
    return _taggedRequests;
}

+ (void)invalidateNoInternetQueuedRequests {
    [[self queuedRequests] removeAllObjects];
    [[self queuedRequestUrls] removeAllObjects];
    [noInternetAlertTimer invalidate];
    noInternetAlertTimer = nil;
}

+ (void)setQueueListener {
    if (!noInternetAlertTimer) {
        noInternetAlertTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                target:self
                                                              selector:@selector(showNoInternetAlert)
                                                              userInfo:nil
                                                               repeats:NO];
    }
    if (!queueListenerIsSet) {
        [self reachability].reachableBlock = ^(RivetReachability *reachability) {
            reachable = YES;
            while (self.queuedRequests.count > 0) {
                if (reachable) {
                    NSLog(@"Ran queued request");
                    [noInternetAlertTimer invalidate];
                    noInternetAlertTimer = nil;
                    QueuedRequest *queuedRequest = [self.queuedRequests firstObject];
                    queuedRequest.requestBlock();
                    [[self queuedRequests] removeObjectAtIndex:0];
                    if (![self queuedRequestsPresentForURL:queuedRequest.requestUrl]) {
                        [[self queuedRequestUrls] removeObject:queuedRequest.requestUrl];
                    }
                }
            }
        };
        queueListenerIsSet = YES;
    }
}

+ (BOOL)queuedRequestsPresentForURL:(NSString *)url {
    for (QueuedRequest *queuedRequest in [self queuedRequests]) {
        if ([queuedRequest.requestUrl isEqualToString:url]) {
            return YES;
        }
    }
    return NO;
}

+ (void)showNoInternetAlert {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noInternetAlertTitle", nil)
                                message:NSLocalizedString(@"noInternetAlertBody", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                      otherButtonTitles:nil] show];
}

+ (LocationUtil *)locationUtil {
    if (!_locationUtil) {
        _locationUtil = [[LocationUtil alloc] init];
    }
    return _locationUtil;
}

+ (void)baseFailureHandler:(AFHTTPRequestOperation *)operation
                 withError:(NSError *)error
            withRetryBlock:(void(^)(void))retryBlock
        withFailureHandler:(NetworkEventFailureHandler)failureHandler {
    if (error.code == NSURLErrorCannotConnectToHost
        || error.code == NSURLErrorTimedOut
        || operation.response.statusCode == 503) {
        if (!_hostConnectionErrorAlertView.isVisible) {
            [self cancelAllRequests];
            _hostConnectionErrorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"couldNotConnectToServerTitle", nil)
                                                                       message:NSLocalizedString(@"couldNotConnectToServerMessage", nil)
                                                                      delegate:nil
                                                             cancelButtonTitle:NSLocalizedString(@"gotcha", nil)
                                                             otherButtonTitles:nil];
            [_hostConnectionErrorAlertView show];
        }
        failureHandler(operation, error);
    } else if (operation.response.statusCode == 403 || operation.response.statusCode == 401) {
        if (!handling403) {
            handling403 = YES;
            [Authentication resetCredentials];
            [UserRepository registerUserWithLocationUtil:[self locationUtil]
                                      withSuccessHandler:^{
                                          handling403 = NO;
                                          AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                          TutorialViewController *vc = [appDelegate.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_tutorial];
                                          appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                                          appDelegate.window.rootViewController = vc;
                                          [appDelegate.window makeKeyAndVisible];
                                      }
                                      withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {}];
        }
    } else {
        failureHandler(operation, error);
    }
    
    if (error.code != NSURLErrorCancelled
        && operation.response.statusCode != 429
        && operation.response.statusCode != 503
        && error.code != NSURLErrorCannotConnectToHost
        && error.code != NSURLErrorNetworkConnectionLost
        && error.code != NSURLErrorNotConnectedToInternet
        && error.code != NSURLErrorTimedOut) {
        if (operation.request.HTTPMethod && operation.request.HTTPBody && operation.request.URL) {
            [EventTrackingUtil logError:@{@"NSURLErrorCode":@(error.code), @"Request Body":[[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSASCIIStringEncoding], @"Response Status":@(operation.response.statusCode), @"HTTP Action": operation.request.HTTPMethod, @"URL":operation.request.URL}];
        }
        CLSNSLog(@"Request failed.\nNSURLErrorCode: %li\nRequest Body:'%@'\nResponse Status: %li\nHTTP Action: %@\nURL: %@", (long)error.code, [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSASCIIStringEncoding], (long)operation.response.statusCode, operation.request.HTTPMethod, operation.request.URL);
    }
}

@end