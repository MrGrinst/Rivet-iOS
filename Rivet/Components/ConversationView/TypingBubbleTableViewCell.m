#import "TypingBubbleTableViewCell.h"
#import "ConstUtil.h"
#import <FLAnimatedImage/FLAnimatedImage.h>

static FLAnimatedImage *_leftTypingBubbleImage = nil;
static FLAnimatedImage *_rightTypingBubbleImage = nil;
CGFloat const padding = 18;

@interface TypingBubbleTableViewCell()

@property (strong, nonatomic) FLAnimatedImageView *typingBubbleImageView;

@end

@implementation TypingBubbleTableViewCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userInteractionEnabled = NO;
        [self.contentView addSubview:self.typingBubbleImageView];
        self.isOnLeft = YES;
    }
    return self;
}

#pragma mark - Getters

- (FLAnimatedImageView *)typingBubbleImageView {
    if (!_typingBubbleImageView) {
        _typingBubbleImageView = [[FLAnimatedImageView alloc] init];
    }
    return _typingBubbleImageView;
}

+ (FLAnimatedImage *)leftTypingBubbleImage {
    if (!_leftTypingBubbleImage) {
        NSString *fileName = [[NSBundle mainBundle] pathForResource:@"leftTypingBubble.gif" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:fileName];
        _leftTypingBubbleImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
    }
    return _leftTypingBubbleImage;
}

+ (FLAnimatedImage *)rightTypingBubbleImage {
    if (!_rightTypingBubbleImage) {
        NSString *fileName = [[NSBundle mainBundle] pathForResource:@"rightTypingBubble.gif" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:fileName];
        _rightTypingBubbleImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
    }
    return _rightTypingBubbleImage;
}

#pragma mark - Setters

- (void)setIsOnLeft:(BOOL)isOnLeft {
    if (isOnLeft != _isOnLeft) {
        if (isOnLeft) {
            CGSize size = CGSizeMake(85, 40);
            self.typingBubbleImageView.frame = CGRectMake(0.5 * padding, 0.25 * padding, size.width, size.height);
            self.typingBubbleImageView.animatedImage = [TypingBubbleTableViewCell leftTypingBubbleImage];
        } else {
            CGSize size = CGSizeMake(85, 40);
            self.typingBubbleImageView.frame = CGRectMake([ConstUtil screenWidth] - size.width - 0.73*padding - 13, padding * 0.25, size.width, size.height);
            self.typingBubbleImageView.animatedImage = [TypingBubbleTableViewCell rightTypingBubbleImage];
        }
    }
    _isOnLeft = isOnLeft;
}

#pragma mark - Cell Height

+ (CGFloat)height {
    return 50;
}

@end