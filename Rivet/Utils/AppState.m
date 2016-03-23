#import "AppState.h"
#import "RivetUserDefaults.h"

static NSString      *_conversationStatus;
static Conversation  *_activeConversation;
static NSString      *_waitForMatchChannel;
static NSNumber      *_selectedSegmentIndexOnConversationListView;
static NSDate        *_timestampOfLastListViewRefresh;
static BOOL           _justOpenedApp;
NSString *const kConversationMode_Waiting = @"Waiting";
NSString *const kConversationMode_PreWaiting = @"PreWaiting";
NSString *const kConversationMode_Conversing = @"Conversing";

@implementation AppState

+ (NSString *)conversationStatus {
    if (!_conversationStatus) {
        _conversationStatus = [RivetUserDefaults conversationStatus];
    }
    return _conversationStatus;
}

+ (void)setConversationStatus:(NSString *)conversationStatus {
    _conversationStatus = conversationStatus;
    [RivetUserDefaults setConversationStatus:conversationStatus];
}

+ (Conversation *)activeConversation {
    if (!_activeConversation) {
        _activeConversation = [RivetUserDefaults activeConversation];
    }
    return _activeConversation;
}

+ (void)setActiveConversation:(Conversation *)activeConversation {
    _activeConversation = activeConversation;
    [RivetUserDefaults setActiveConversation:activeConversation];
}

+ (void)saveConversationDataToUserDefaults {
    [self setActiveConversation:[self activeConversation]];
}

+ (NSString *)waitForMatchChannel {
    if (!_waitForMatchChannel) {
        _waitForMatchChannel = [RivetUserDefaults waitForMatchChannel];
    }
    return _waitForMatchChannel;
}

+ (void)setWaitForMatchChannel:(NSString *)waitForMatchChannel {
    _waitForMatchChannel = waitForMatchChannel;
    [RivetUserDefaults setWaitForMatchChannel:waitForMatchChannel];
}

+ (NSNumber *)selectedSegmentIndexOnConversationListView {
    return _selectedSegmentIndexOnConversationListView;
}

+ (void)setSelectedSegmentIndexOnConversationListView:(NSNumber *)selectedSegmentIndexOnConversationListView {
    _selectedSegmentIndexOnConversationListView = selectedSegmentIndexOnConversationListView;
}

+ (BOOL)justOpenedApp {
    return _justOpenedApp;
}

+ (void)setJustOpenedApp:(BOOL)justOpenedApp {
    _justOpenedApp = justOpenedApp;
}

+ (UserState *)userState {
    return [RivetUserDefaults userState];
}

+ (void)setUserState:(UserState *)userState {
    [RivetUserDefaults setUserState:userState];
}

+ (NSTimeInterval)timeSinceLastListViewRefresh {
    if (_timestampOfLastListViewRefresh) {
        return [[NSDate date] timeIntervalSinceDate:_timestampOfLastListViewRefresh];
    }
    return NSIntegerMax;
}

+ (void)setTimestampOfLastListViewRefresh:(NSDate *)timestampOfLastListViewRefresh {
    _timestampOfLastListViewRefresh = timestampOfLastListViewRefresh;
}

@end