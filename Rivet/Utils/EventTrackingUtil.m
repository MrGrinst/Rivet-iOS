#import "EventTrackingUtil.h"
#import "Mixpanel.h"
#import "ConstUtil.h"

#define mixpanelToken [[NSBundle mainBundle] objectForInfoDictionaryKey:@"mixpanelToken"]

@implementation EventTrackingUtil

+ (BOOL)shouldLog {
    return mixpanelToken != nil;
}

+ (void)setUserId:(NSInteger)userId {
    if ([self shouldLog]) {
        [[Mixpanel sharedInstance] identify:[NSString stringWithFormat:@"%li", (long)userId]];
        [[[Mixpanel sharedInstance] people] set:@{@"Internal ID": [NSString stringWithFormat:@"%li", (long)userId]}];
    }
}

+ (void)logError:(NSDictionary *)errorInfo {
    [self trackIfShouldLog:@"Error (Use Crashlytics soon)" withProperties:errorInfo];
}

+ (void)trackIfShouldLog:(NSString *)eventName {
    if ([self shouldLog]) {
        [[Mixpanel sharedInstance] track:eventName];
    }
}

+ (void)trackIfShouldLog:(NSString *)eventName withProperties:(NSDictionary *)properties {
    if ([self shouldLog]) {
        [[Mixpanel sharedInstance] track:eventName properties:properties];
    }
}

+ (void)openedApp {
    [self trackIfShouldLog:@"Opened App"];
}

+ (void)selectedConversationFromListView:(NSInteger)conversationId {
    [self trackIfShouldLog:@"Selected Conversation From List View" withProperties:@{@"conversationId":@(conversationId)}];
}

+ (void)selectedFeaturedConversationFromListView:(NSInteger)conversationId {
    [self trackIfShouldLog:@"Selected Featured Conversation From List View" withProperties:@{@"conversationId":@(conversationId)}];
}

+ (void)viewedMoreConversationsAboutFeaturedConversationTopic:(NSInteger)conversationId {
    [self trackIfShouldLog:@"Viewed More Conversations About Topic" withProperties:@{@"conversationId":@(conversationId)}];
}

+ (void)slidPrivacyMaskLeftForTheFirstTime {
    [self trackIfShouldLog:@"Slid Privacy Mask Left For The First Time"];
}

+ (void)openedMenu {
    [self trackIfShouldLog:@"Opened Menu"];
}

+ (void)openedProfileModal {
    [self trackIfShouldLog:@"Opened Profile Modal"];
}

+ (void)reportButtonTapped {
    [self trackIfShouldLog:@"Tapped Report Button"];
}

+ (void)shareButtonTapped {
    [self trackIfShouldLog:@"Tapped Share Button"];
}

+ (void)selectedMyConversations {
    [self trackIfShouldLog:@"Selected My Conversations"];
}

+ (void)nearbyFilterSelected {
    [self trackIfShouldLog:@"Nearby Filter Selected"];
}

+ (void)featuredFilterSelected {
    [self trackIfShouldLog:@"Featured Filter Selected"];
}

+ (void)votedOnConversationInListView:(NSInteger)conversationId withVoteValue:(NSInteger)voteValue {
    [self trackIfShouldLog:@"Voted on Conversation in List View" withProperties:@{@"conversationId":@(conversationId), @"voteValue":@(voteValue)}];
}

+ (void)votedWhileViewingConversation:(NSInteger)conversationId withVoteValue:(NSInteger)voteValue {
    [self trackIfShouldLog:@"Voted While Viewing Conversation" withProperties:@{@"conversationId":@(conversationId), @"voteValue":@(voteValue)}];
}

+ (void)tappedLaterNotificationPermission {
    [self trackIfShouldLog:@"Tapped Later Notification Permission"];
}

+ (void)tappedAllowNotificationPermission {
    [self trackIfShouldLog:@"Tapped Allow Notification Permission"];
}

+ (void)conversationStarted {
    [self trackIfShouldLog:@"Conversation Started"];
}

+ (void)conversationEnded {
    [self trackIfShouldLog:@"Conversation Ended"];
}

+ (void)startedSearchingFromWaitingView {
    [self trackIfShouldLog:@"Started Searching From Waiting View"];
}

+ (void)startedSearchingAfterConversationEnd {
    [self trackIfShouldLog:@"Started Searching After Conversation End"];
}

+ (void)stoppedSearching {
    [self trackIfShouldLog:@"Stopped Searching"];
}

@end
