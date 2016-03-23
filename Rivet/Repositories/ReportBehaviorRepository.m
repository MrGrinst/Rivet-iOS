#import "ReportBehaviorRepository.h"

@implementation ReportBehaviorRepository

+ (void)reportBehavior:(NSString *)behaviorType
        onConversation:(NSInteger)conversationId
    withSuccessHandler:(void (^)(void))successHandler
    withFailureHandler:(NetworkEventFailureHandler)failureHandler
               withTag:(NSString *)tag {
    NSDictionary *params = @{@"behavior_type":behaviorType};
    [self performPOSTWithRelativeUrl:[NSString stringWithFormat:@"/conversation/%li/report", (long)conversationId]
                  withSuccessHandler:^(id response) {
                      successHandler();
                  }
                  withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                      failureHandler(operation, error);
                  }
                       withAuthToken:YES
                      withParameters:params
                             withTag:tag
        canQueueMultipleIfNoInternet:NO];
}

@end