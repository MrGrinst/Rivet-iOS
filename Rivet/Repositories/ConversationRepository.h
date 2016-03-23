#import <Foundation/Foundation.h>
#import "BaseRepository.h"
#import "Conversation.h"
#import "ConversationDetails.h"
#import "Message.h"
#import "QueueStatus.h"

@interface ConversationRepository : BaseRepository

+ (void)globalFeaturedConversationsWithSuccessHandler:(NetworkEventSuccessHandler)successHandler
                                   withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                              withTag:(NSString *)tag;

+ (void)nearbyFeaturedConversationsWithSuccessHandler:(NetworkEventSuccessHandler)successHandler
                                   withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                              withTag:(NSString *)tag;

+ (void)myConversationsWithSuccessHandler:(void (^)(NSArray *))successHandler
                       withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                  withTag:(NSString *)tag;

+ (void)sendMessageWithText:(NSString *)text
                  isPrivate:(BOOL)isPrivate
             toConversation:(Conversation *)conversation
         withSuccessHandler:(void (^)(void))successHandler
         withFailureHandler:(NetworkEventFailureHandler)failureHandler
                    withTag:(NSString *)tag;

+ (void)wholeConversationForConversationId:(NSInteger)conversationId
                        withSuccessHandler:(void (^)(Conversation *))successHandler
                        withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                   withTag:(NSString *)tag;

+ (void)updateConversation:(Conversation *)conversation
        withSuccessHandler:(void (^)(void))successHandler
        withFailureHandler:(NetworkEventFailureHandler)failureHandler
                   withTag:(NSString *)tag;

+ (void)conversationDetailsForConversationId:(NSInteger)conversationId
                          withSuccessHandler:(void (^)(ConversationDetails *))successHandler
                          withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                     withTag:(NSString *)tag;

+ (void)messagesForConversationId:(NSInteger)conversationId
                        sinceTime:(NSDate *)mostRecentMessageTime
               withSuccessHandler:(void (^)(NSArray *))successHandler
               withFailureHandler:(NetworkEventFailureHandler)failureHandler
                          withTag:(NSString *)tag;

+ (void)queueStatusForChannelWithSuccessHandler:(void (^)(QueueStatus *))successHandler
                             withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                        withTag:(NSString *)tag;

+ (void)startNewConversationWithSuggestedParentConversationId:(NSInteger)conversationId
                                           withSuccessHandler:(void (^)(QueueStatus *))successHandler
                                           withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                                      withTag:(NSString *)tag;
                                                                       
+ (void)startNewConversationWithSuccessHandler:(void (^)(QueueStatus *))successHandler
                            withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                       withTag:(NSString *)tag;

+ (void)updateHeartbeatWithFailureHandler:(NetworkEventFailureHandler)failureHandler;

+ (void)leaveConversationQueueWithSuccessHandler:(void (^)(void))successHandler
                              withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                         withTag:(NSString *)tag;

+ (void)endConversation:(Conversation *)conversation
     withSuccessHandler:(void (^)(void))successHandler
     withFailureHandler:(NetworkEventFailureHandler)failureHandler
                withTag:(NSString *)tag;

@end