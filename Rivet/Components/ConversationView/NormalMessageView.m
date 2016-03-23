#import "NormalMessageView.h"
#import "ClickThroughUIImageView.h"
#import "UIFont+Rivet.h"
#import "UIColor+Rivet.h"

static CGFloat const messagePadding = 18;
static CGFloat const minimumBubbleWidth = 52;
static CGFloat const minimumBubbleHeight = 41;
static UIImage *_leftBubbleImage = nil;
static UIImage *_rightBubbleImage = nil;

@interface NormalMessageView()<UITextViewDelegate>

@property (nonatomic) CGFloat maxWidth;
@property (strong, nonatomic) UIImageView                  *bgImageView;
@property (strong, nonatomic) ClickThroughUIImageView      *privacyFilterSecondaryBubble;
@property (nonatomic)         BOOL                          isOnLeft;
@property (nonatomic)         NSInteger                     myParticipantNumber;
@property (strong, nonatomic) UITextView                   *messageContentView;

@end

@implementation NormalMessageView

#pragma mark - Init

- (id)initWithMaxWidth:(CGFloat)maxWidth {
    if (self = [super init]) {
        self.maxWidth = maxWidth;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgImageView];
        [self addSubview:self.messageContentView];
        CGRect frame = self.frame;
        frame.size.width = maxWidth;
        self.frame = frame;
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark - Getters

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *uilpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionMenu:)];
        uilpgr.minimumPressDuration = .4;
        [_bgImageView addGestureRecognizer:uilpgr];
    }
    return _bgImageView;
}

- (UITextView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[UITextView alloc] init];
        _messageContentView.backgroundColor = [UIColor clearColor];
        _messageContentView.editable = NO;
        _messageContentView.scrollEnabled = NO;
        _messageContentView.font = [UIFont rivetUserContentFontWithSize:17];
        _messageContentView.textContainerInset = UIEdgeInsetsZero;
        _messageContentView.dataDetectorTypes = UIDataDetectorTypeLink;
        UILongPressGestureRecognizer *uilpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionMenu:)];
        uilpgr.minimumPressDuration = .4;
        [_messageContentView addGestureRecognizer:uilpgr];
        _messageContentView.delegate = self;
    }
    return _messageContentView;
}

+ (UIImage *)leftBubbleImage {
    if (!_leftBubbleImage) {
        _leftBubbleImage = [[UIImage imageNamed:@"incomingMessageBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 29, 20, 22)];
    }
    return _leftBubbleImage;
}

+ (UIImage *)rightBubbleImage {
    if (!_rightBubbleImage) {
        _rightBubbleImage = [[UIImage imageNamed:@"outgoingMessageBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 22, 20, 29)];
    }
    return _rightBubbleImage;
}

#pragma mark - Setters

- (void)setMessage:(Message *)message
       setIsOnLeft:(BOOL)isOnLeft
setMyParticipantNumber:(NSInteger)myParticipantNumber
    cachedTextSize:(NSMutableDictionary *)cachedTextSize {
    self.myParticipantNumber = myParticipantNumber;
    self.isOnLeft = isOnLeft;
    self.message = message;
    self.messageContentView.hidden = NO;
    self.messageContentView.text = message.text;
    self.messageContentView.textColor = isOnLeft ? [UIColor rivetOffBlack] : [UIColor whiteColor];
    CGSize size;
    NSValue *obj = [cachedTextSize objectForKey:@(message.messageId)];
    if (obj) {
        size = obj.CGSizeValue;
    } else {
        size = [self.messageContentView sizeThatFits:CGSizeMake(self.maxWidth/1.4308, CGFLOAT_MAX)];
        [cachedTextSize setObject:[NSValue valueWithCGSize:size] forKey:@(message.messageId)];
    }
    CGFloat extraWidthPaddingIfSingleLine = 0;
    CGFloat extraHeightPaddingIfSingleLine = 0;
    if (size.width < minimumBubbleWidth - messagePadding) {
        size.width = minimumBubbleWidth - messagePadding;
    }
    if (size.height + messagePadding < minimumBubbleHeight) {
        size.height = minimumBubbleHeight - messagePadding;
        extraWidthPaddingIfSingleLine = -2;
        extraHeightPaddingIfSingleLine = 1;
    }
    
    if (!isOnLeft) {
        UIImage *bgImage = NormalMessageView.rightBubbleImage;
        [self.messageContentView setFrame:CGRectMake(self.maxWidth - size.width - messagePadding + extraWidthPaddingIfSingleLine,
                                                     messagePadding * 0.5 + extraHeightPaddingIfSingleLine,
                                                     size.width,
                                                     size.height)];
        [self.bgImageView setFrame:CGRectMake(self.messageContentView.frame.origin.x - messagePadding/2.0 - extraWidthPaddingIfSingleLine,
                                              self.messageContentView.frame.origin.y - messagePadding/2.0 - extraHeightPaddingIfSingleLine,
                                              size.width+messagePadding,
                                              size.height+messagePadding)];
        self.bgImageView.image = bgImage;
        self.messageContentView.tintColor = [UIColor rivetLightGray];
    } else {
        UIImage *bgImage = NormalMessageView.leftBubbleImage;
        [self.messageContentView setFrame:CGRectMake(messagePadding + (self.maxWidth/64.0) + extraWidthPaddingIfSingleLine,
                                                     messagePadding * 0.5 + extraHeightPaddingIfSingleLine,
                                                     size.width,
                                                     size.height)];
        [self.bgImageView setFrame:CGRectMake(self.messageContentView.frame.origin.x - messagePadding/2.0 - (self.maxWidth/64.0) - extraWidthPaddingIfSingleLine,
                                              self.messageContentView.frame.origin.y - messagePadding/2.0 - extraHeightPaddingIfSingleLine,
                                              size.width+messagePadding,
                                              size.height+messagePadding)];
        self.bgImageView.image = bgImage;
        self.messageContentView.tintColor = [UIColor rivetGray];
    }
    CGRect frame = self.frame;
    frame.size.height = self.bgImageView.frame.size.height;
    self.frame = frame;
}

- (void)setMessageContentViewHidden:(BOOL)messageContentViewHidden {
    _messageContentViewHidden = messageContentViewHidden;
    self.messageContentView.hidden = messageContentViewHidden;
}

- (void)setPrivacyMask:(CAShapeLayer *)privacyMask {
    CGAffineTransform adjustForBubblePosition = CGAffineTransformIdentity;
    if (self.message.isPrivate) {
        [self.privacyFilterSecondaryBubble removeFromSuperview];
        adjustForBubblePosition.tx = -self.messageContentView.frame.origin.x;
        CGPathRef pathRef = CGPathCreateCopyByTransformingPath(privacyMask.path, &adjustForBubblePosition);
        privacyMask.path = pathRef;
        _privacyMask = privacyMask;
        self.messageContentView.layer.mask = privacyMask;
        CGPathRelease(pathRef);
    } else {
        adjustForBubblePosition.tx = -self.bgImageView.frame.origin.x;
        CGPathRef pathRef = CGPathCreateCopyByTransformingPath(privacyMask.path, &adjustForBubblePosition);
        privacyMask.path = pathRef;
        _privacyMask = privacyMask;
        self.messageContentView.layer.mask = nil;
        [self.privacyFilterSecondaryBubble removeFromSuperview];
        self.privacyFilterSecondaryBubble = [[ClickThroughUIImageView alloc] initWithImage:self.bgImageView.image];
        self.privacyFilterSecondaryBubble.frame = self.bgImageView.frame;
        [self addSubview:self.privacyFilterSecondaryBubble];
        [self bringSubviewToFront:self.privacyFilterSecondaryBubble];
        self.privacyFilterSecondaryBubble.layer.mask = privacyMask;
        CGPathRelease(pathRef);
    }
}

#pragma mark - Privacy Mask

- (void)updatePrivacyMask:(CAShapeLayer *)privacyMask {
    CGAffineTransform adjustForBubblePosition = CGAffineTransformIdentity;
    if (self.message.isPrivate) {
        adjustForBubblePosition.tx = -self.messageContentView.frame.origin.x;
        CGPathRef pathRef = CGPathCreateCopyByTransformingPath(privacyMask.path, &adjustForBubblePosition);
        privacyMask.path = pathRef;
        self.messageContentView.layer.mask = privacyMask;
        CGPathRelease(pathRef);
    } else {
        adjustForBubblePosition.tx = -self.bgImageView.frame.origin.x;
        CGPathRef pathRef = CGPathCreateCopyByTransformingPath(privacyMask.path, &adjustForBubblePosition);
        privacyMask.path = pathRef;
        self.privacyFilterSecondaryBubble.layer.mask = privacyMask;
        CGPathRelease(pathRef);
    }
}

#pragma mark - Cell Height

+ (CGFloat)heightGivenMessage:(Message *)message maxWidth:(CGFloat)maxWidth {
    UITextView *textView = [[UITextView alloc] init];
    textView.text = message.text;
    textView.font = [UIFont rivetUserContentFontWithSize:17];
    textView.textContainerInset = UIEdgeInsetsZero;
    CGSize size = [textView sizeThatFits:CGSizeMake(maxWidth/1.4308, CGFLOAT_MAX)];
    CGFloat height = size.height;
    if (height + messagePadding < minimumBubbleHeight) {
        height = minimumBubbleHeight - messagePadding;
    }
    height += messagePadding;
    return height;
}

#pragma mark - Copy

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.message.text];
}

- (void)showActionMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan
        && !(self.message.isPrivate
        && self.myParticipantNumber == -1)) {
            [self.messageContentView becomeFirstResponder];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            [menuController setTargetRect:self.messageContentView.frame inView:self];
            [menuController setMenuVisible:YES animated:YES];
    }
}

#pragma mark - Selection Delegate

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (self.messageContentView.isFirstResponder) {
        textView.selectedTextRange = nil;
    }
}

@end