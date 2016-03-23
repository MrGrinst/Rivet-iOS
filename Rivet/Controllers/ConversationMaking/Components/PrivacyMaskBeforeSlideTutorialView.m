#import "PrivacyMaskBeforeSlideTutorialView.h"
#import "TutorialLabel.h"
#import "PrivacyMask.h"
#import "ConstUtil.h"

@interface PrivacyMaskBeforeSlideTutorialView()

@property (strong, nonatomic) TutorialLabel *explanationLabel;

@end

@implementation PrivacyMaskBeforeSlideTutorialView

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self setupMask:frame];
        [self addSubview:self.explanationLabel];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.explanationLabel
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.explanationLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
    }
    return self;
}

#pragma mark - Mask

- (void)setupMask:(CGRect)frame {
    CGPathRef mask = CGPathCreateWithRect(frame, &CGAffineTransformIdentity);
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathAddRect(maskPath, NULL, CGRectMake([ConstUtil screenWidth] - tabWidth - 8, [PrivacyMask tabHeightOffset] - 8, tabWidth + 8, tabHeight + 16));
    CGPathAddPath(maskPath, nil, mask);
    [maskLayer setPath:maskPath];
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    CGPathRelease(maskPath);
    CGPathRelease(mask);
    self.layer.mask = maskLayer;
}

#pragma mark - Getters

- (TutorialLabel *)explanationLabel {
    if (!_explanationLabel) {
        _explanationLabel = [[TutorialLabel alloc] init];
        _explanationLabel.text = NSLocalizedString(@"privacyMaskExplanationReceiveMessage", nil);
        _explanationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _explanationLabel;
}

#pragma mark - Allow Click Through

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect allowedClickRect = CGRectMake([ConstUtil screenWidth] - tabWidth - 8, [PrivacyMask tabHeightOffset] - 8, tabWidth + 8, tabHeight + 16);
    return !(point.x < allowedClickRect.origin.x + allowedClickRect.size.width
            && point.x > allowedClickRect.origin.x
            && point.y < allowedClickRect.origin.y + allowedClickRect.size.height
            && point.y > allowedClickRect.origin.y);
}

@end