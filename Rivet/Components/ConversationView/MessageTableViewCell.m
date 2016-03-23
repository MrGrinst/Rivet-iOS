#import "MessageTableViewCell.h"
#import "NormalMessageView.h"
#import "PrivacyMask.h"

@interface MessageTableViewCell()

@property (strong, nonatomic) NormalMessageView  *chatBubbleView;
@property (nonatomic) BOOL                        isOnLeft;
@property (nonatomic) CGFloat                     maxWidth;

@end

@implementation MessageTableViewCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           isOnLeft:(BOOL)isOnLeft
       withMaxWidth:(CGFloat)maxWidth {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.maxWidth = maxWidth;
        self.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.chatBubbleView];
        CGRect bubbleFrame = self.chatBubbleView.frame;
        self.isOnLeft = isOnLeft;
        bubbleFrame.origin.y += 3;
        self.chatBubbleView.frame = bubbleFrame;
    }
    return self;
}

#pragma mark - Getters

- (NormalMessageView *)chatBubbleView {
    if (!_chatBubbleView) {
        _chatBubbleView = [[NormalMessageView alloc] initWithMaxWidth:self.maxWidth];
    }
    return _chatBubbleView;
}

#pragma mark - Setters

- (void)setMessage:(Message *)message
       setIsOnLeft:(BOOL)isOnLeft
setMyParticipantNumber:(NSInteger)myParticipantNumber
    cachedTextSize:(NSMutableDictionary *)cachedTextSize {
    [self.chatBubbleView setMessage:message
                        setIsOnLeft:isOnLeft
             setMyParticipantNumber:myParticipantNumber
                     cachedTextSize:cachedTextSize];
    self.chatBubbleView.hidden = NO;
}

- (void)setPrivacyMask:(CAShapeLayer *)privacyMask {
    _privacyMask = privacyMask;
    self.chatBubbleView.privacyMask = [PrivacyMask duplicateMask:privacyMask];
}

- (void)setMessageContentViewHidden:(BOOL)messageContentViewHidden {
    _messageContentViewHidden = messageContentViewHidden;
    self.chatBubbleView.messageContentViewHidden = messageContentViewHidden;
}

#pragma mark - Privacy Mask

- (void)updatePrivacyMask:(CAShapeLayer *)privacyMask {
    [self.chatBubbleView updatePrivacyMask:[PrivacyMask duplicateMask:privacyMask]];
}

#pragma mark - Cell Height

+ (CGFloat)heightGivenMessage:(Message *)message withMaxWidth:(CGFloat)maxWidth {
    return [NormalMessageView heightGivenMessage:message maxWidth:maxWidth] + 6;
}

@end