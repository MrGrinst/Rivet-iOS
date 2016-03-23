#import <Foundation/Foundation.h>

@interface EventTrackingUtil : NSObject

+ (void)setUserId:(NSInteger)userId;
+ (void)logError:(NSDictionary *)errorInfo;
+ (void)openedApp;
+ (void)selectedConversationFromListView:(NSInteger)conversationId;
+ (void)selectedFeaturedConversationFromListView:(NSInteger)conversationId;
+ (void)viewedMoreConversationsAboutFeaturedConversationTopic:(NSInteger)conversationId;
+ (void)slidPrivacyMaskLeftForTheFirstTime;
+ (void)openedMenu;
+ (void)openedProfileModal;
+ (void)reportButtonTapped;
+ (void)shareButtonTapped;
+ (void)selectedMyConversations;
+ (void)nearbyFilterSelected;
+ (void)featuredFilterSelected;
+ (void)votedOnConversationInListView:(NSInteger)conversationId withVoteValue:(NSInteger)voteValue;
+ (void)votedWhileViewingConversation:(NSInteger)conversationId withVoteValue:(NSInteger)voteValue;
+ (void)tappedLaterNotificationPermission;
+ (void)tappedAllowNotificationPermission;
+ (void)conversationStarted;
+ (void)conversationEnded;
+ (void)startedSearchingFromWaitingView;
+ (void)startedSearchingAfterConversationEnd;
+ (void)stoppedSearching;

@end
