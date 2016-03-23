#import "RoundedRectView.h"

NSString *const kNotification_conversationViewingVotedOn;

@interface ConversationVotingView : RoundedRectView

@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger myVoteValue;

@end
