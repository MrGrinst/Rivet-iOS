#import "BaseRepository.h"

@interface ReportBehaviorRepository : BaseRepository

+ (void)reportBehavior:(NSString *)behaviorType
        onConversation:(NSInteger)conversationId
    withSuccessHandler:(void (^)(void))successHandler
    withFailureHandler:(NetworkEventFailureHandler)failureHandler
               withTag:(NSString *)tag;

@end