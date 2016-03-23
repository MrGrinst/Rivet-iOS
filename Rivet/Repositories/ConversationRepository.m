#import <AFNetworking/AFNetworking.h>
#import "ConversationRepository.h"
#import "CachedConversationSummary.h"
#import "ConversationSummary.h"
#import "ObjectiveRecord.h"
#import "CachedConversationSummary+Extra.h"
#import "DateUtil.h"

static ConversationDetails *_wholeConversationTempConversationDetails;
static NSArray             *_wholeConversationTempMessages;
static ConversationDetails *_updateConversationTempConversationDetails;
static NSArray             *_updateConversationTempMessages;

@implementation ConversationRepository

+ (void)globalFeaturedConversationsWithSuccessHandler:(NetworkEventSuccessHandler)successHandler
                                   withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                              withTag:(NSString *)tag {
    [self performGETWithRelativeUrl:@"/conversation/featured"
                 withSuccessHandler:^(id response) {
                     [self clearCachedListOfType:@"FEATURED"];
                     NSMutableArray *output = [[NSMutableArray alloc] init];
                     for (NSDictionary *dto in (NSArray *)response) {
                         CachedConversationSummary *css = [CachedConversationSummary createWithDto:dto withListType:@"FEATURED"];
                         [output addObject:[[ConversationSummary alloc] initWithCachedConversationSummary:css]];
                     }
                     [[CoreDataManager sharedManager] saveContext];
                     successHandler(output);
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                            withTag:tag];
}

+ (void)nearbyFeaturedConversationsWithSuccessHandler:(NetworkEventSuccessHandler)successHandler
                                   withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                              withTag:(NSString *)tag {
    [self performGETWithRelativeUrl:@"/conversation/nearby"
                 withSuccessHandler:^(id response) {
                     [self clearCachedListOfType:@"NEARBY"];
                     NSMutableArray *output = [[NSMutableArray alloc] init];
                     for (NSDictionary *dto in (NSArray *)response) {
                         CachedConversationSummary *css = [CachedConversationSummary createWithDto:dto withListType:@"NEARBY"];
                         [output addObject:[[ConversationSummary alloc] initWithCachedConversationSummary:css]];
                     }
                     [[CoreDataManager sharedManager] saveContext];
                     successHandler(output);
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                            withTag:tag];
}

+ (void)clearCachedListOfType:(NSString *)listType {
    NSArray *summaries = [CachedConversationSummary where:[NSString stringWithFormat:@"listType == '%@'", listType]];
    for (CachedConversationSummary *css in summaries) {
        [css delete];
    }
}

+ (void)myConversationsWithSuccessHandler:(void (^)(NSArray *))successHandler
                       withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                  withTag:(NSString *)tag {
    [self performGETWithRelativeUrl:@"/conversation/me"
                 withSuccessHandler:^(id response) {
                     [self clearCachedListOfType:@"MY_CONVERSATIONS"];
                     NSMutableArray *allConversationSummaries = [[NSMutableArray alloc] init];
                     for (NSDictionary *dto in response) {
                         CachedConversationSummary *css = [CachedConversationSummary createWithDto:dto withListType:@"MY_CONVERSATIONS"];
                         [allConversationSummaries addObject:[[ConversationSummary alloc] initWithCachedConversationSummary:css]];
                     }
                     [[CoreDataManager sharedManager] saveContext];
                     successHandler(allConversationSummaries);
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                            withTag:tag];
}

+ (void)sendMessageWithText:(NSString *)text
                  isPrivate:(BOOL)isPrivate
             toConversation:(Conversation *)conversation
         withSuccessHandler:(void (^)(void))successHandler
         withFailureHandler:(NetworkEventFailureHandler)failureHandler
                    withTag:(NSString *)tag {
    NSDictionary *message = @{kMessageAttribute_text:text, kMessageAttribute_isPrivate:@(isPrivate)};
    [self performPOSTWithRelativeUrl:[NSString stringWithFormat:@"/conversation/%li/message", (long)conversation.conversationId]
                  withSuccessHandler:^(id response) {
                      successHandler();
                  }
                  withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                      failureHandler(operation, error);
                  }
                       withAuthToken:YES
                      withParameters:message
                             withTag:tag
        canQueueMultipleIfNoInternet:YES];
}

+ (void)wholeConversationForConversationId:(NSInteger)conversationId
                        withSuccessHandler:(void (^)(Conversation *))successHandler
                        withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                   withTag:(NSString *)tag {
    __block BOOL alreadyFailed;
    [self conversationDetailsForConversationId:conversationId
                            withSuccessHandler:^(ConversationDetails *conversationDetails) {
                                if (_wholeConversationTempMessages) {
                                    Conversation *conversation = [[Conversation alloc] initWithConversationDetails:conversationDetails
                                                                                                      withMessages:_wholeConversationTempMessages];
                                    _wholeConversationTempConversationDetails = nil;
                                    _wholeConversationTempMessages = nil;
                                    successHandler(conversation);
                                } else {
                                    _wholeConversationTempConversationDetails = conversationDetails;
                                }
                            }
                            withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                                if (!alreadyFailed) {
                                    alreadyFailed = YES;
                                    _wholeConversationTempConversationDetails = nil;
                                    _wholeConversationTempMessages = nil;
                                    failureHandler(operation, error);
                                }
                            }
                                       withTag:tag];
    [self messagesForConversationId:conversationId
                          sinceTime:[NSDate distantPast]
                 withSuccessHandler:^(NSArray *messages) {
                     if (_wholeConversationTempConversationDetails) {
                         Conversation *conversation = [[Conversation alloc] initWithConversationDetails:_wholeConversationTempConversationDetails
                                                                                           withMessages:messages];
                         _wholeConversationTempConversationDetails = nil;
                         _wholeConversationTempMessages = nil;
                         successHandler(conversation);
                     } else {
                         _wholeConversationTempMessages = messages;
                     }
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (!alreadyFailed) {
                         alreadyFailed = YES;
                         _wholeConversationTempConversationDetails = nil;
                         _wholeConversationTempMessages = nil;
                         failureHandler(operation, error);
                     }
                 }
                            withTag:tag];
}

+ (void)updateConversation:(Conversation *)conversation
        withSuccessHandler:(void (^)(void))successHandler
        withFailureHandler:(NetworkEventFailureHandler)failureHandler
                   withTag:(NSString *)tag {
    __block BOOL alreadyFailed;
    [self conversationDetailsForConversationId:conversation.conversationId
                            withSuccessHandler:^(ConversationDetails *conversationDetails) {
                                if (_updateConversationTempMessages) {
                                    [conversation updateWithConversationDetails:conversationDetails withMessages:_updateConversationTempMessages];
                                    _updateConversationTempConversationDetails = nil;
                                    _updateConversationTempMessages = nil;
                                    successHandler();
                                } else {
                                    _updateConversationTempConversationDetails = conversationDetails;
                                }
                            }
                            withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                                if (!alreadyFailed) {
                                    alreadyFailed = YES;
                                    _updateConversationTempConversationDetails = nil;
                                    _updateConversationTempMessages = nil;
                                    failureHandler(operation, error);
                                }
                            }
                                       withTag:tag];
    NSDate *lastSeenMessageTime = conversation.messages.count ? ((Message *)[conversation.messages objectAtIndex:(conversation.messages.count - 1)]).timestamp : [NSDate distantPast];
    [self messagesForConversationId:conversation.conversationId
                          sinceTime:lastSeenMessageTime
                 withSuccessHandler:^(NSArray *messages) {
                     if (_updateConversationTempConversationDetails) {
                         [conversation updateWithConversationDetails:_updateConversationTempConversationDetails withMessages:messages];
                         _updateConversationTempConversationDetails = nil;
                         _updateConversationTempMessages = nil;
                         successHandler();
                     } else {
                         _updateConversationTempMessages = messages;
                     }
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (!alreadyFailed) {
                         alreadyFailed = YES;
                         _updateConversationTempConversationDetails = nil;
                         _updateConversationTempMessages = nil;
                         failureHandler(operation, error);
                     }
                 }
                            withTag:tag];
}

+ (void)conversationDetailsForConversationId:(NSInteger)conversationId
                          withSuccessHandler:(void (^)(ConversationDetails *))successHandler
                          withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                     withTag:(NSString *)tag {
    [self performGETWithRelativeUrl:[NSString stringWithFormat:@"/conversation/%li", (long)conversationId]
                 withSuccessHandler:^(id response) {
                     successHandler([[ConversationDetails alloc] initWithDto:response]);
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                            withTag:tag];
}

+ (void)messagesForConversationId:(NSInteger)conversationId
                        sinceTime:(NSDate *)mostRecentMessageTime
               withSuccessHandler:(void (^)(NSArray *))successHandler
               withFailureHandler:(NetworkEventFailureHandler)failureHandler
                          withTag:(NSString *)tag {
    [self performGETWithRelativeUrl:[NSString stringWithFormat:@"/conversation/%li/message?time=%@", (long)conversationId, [DateUtil stringFromDate:mostRecentMessageTime]]
                 withSuccessHandler:^(id response) {
                     NSMutableArray *messages = [[NSMutableArray alloc] init];
                     for (NSDictionary *dto in response) {
                         [messages addObject:[[Message alloc] initWithDto:dto]];
                     }
                     successHandler(messages);
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                            withTag:tag];
}

+ (void)queueStatusForChannelWithSuccessHandler:(void (^)(QueueStatus *))successHandler
                             withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                        withTag:(NSString *)tag {
    [self performGETWithRelativeUrl:@"/queue"
                 withSuccessHandler:^(NSDictionary *response) {
                     successHandler([[QueueStatus alloc] initWithDto:response]);
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                            withTag:tag];
}

+ (void)startNewConversationWithSuggestedParentConversationId:(NSInteger)conversationId
                                           withSuccessHandler:(void (^)(QueueStatus *))successHandler
                                           withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                                      withTag:(NSString *)tag {
    [self performPUTWithRelativeUrl:[NSString stringWithFormat:@"/queue/%li", (long)conversationId]
                 withSuccessHandler:^(id response) {
                     successHandler([[QueueStatus alloc] initWithDto:response]);
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                     withParameters:nil
                            withTag:tag];
}

+ (void)startNewConversationWithSuccessHandler:(void (^)(QueueStatus *))successHandler
                            withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                       withTag:(NSString *)tag {
    [self performPUTWithRelativeUrl:@"/queue"
                 withSuccessHandler:^(id response) {
                     successHandler([[QueueStatus alloc] initWithDto:response]);
                 }
                 withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failureHandler(operation, error);
                 }
                      withAuthToken:YES
                     withParameters:nil
                            withTag:tag];
}

+ (void)updateHeartbeatWithFailureHandler:(NetworkEventFailureHandler)failureHandler {
    [self performPATCHWithRelativeUrl:@"/queue"
                   withSuccessHandler:^(id response) {}
                   withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                       failureHandler(operation, error);
                   }
                        withAuthToken:YES
                       withParameters:nil
                              withTag:@"heartbeat"
         canQueueMultipleIfNoInternet:NO];
}

+ (void)leaveConversationQueueWithSuccessHandler:(void (^)(void))successHandler
                              withFailureHandler:(NetworkEventFailureHandler)failureHandler
                                         withTag:(NSString *)tag {
    [self performDELETEWithRelativeUrl:@"/queue"
                    withSuccessHandler:^(id response) {
                        successHandler();
                    }
                    withFailureHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                        failureHandler(operation, error);
                    }
                         withAuthToken:YES
                               withTag:tag];
}

+ (void)endConversation:(Conversation *)conversation
     withSuccessHandler:(void (^)(void))successHandler
     withFailureHandler:(NetworkEventFailureHandler)failureHandler
                withTag:(NSString *)tag {
    NSDictionary *params = @{@"status": @"completed"};
    [self performPATCHWithRelativeUrl:[NSString stringWithFormat:@"/conversation/%li", (long)conversation.conversationId]
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