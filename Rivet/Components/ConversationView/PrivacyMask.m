#import "PrivacyMask.h"
#import "UIColor+Rivet.h"
#import "ConstUtil.h"

NSString *const kNotification_privacyMaskSlidLeft = @"PrivacyMaskSlidLeft";
NSString *const kNotification_privacyMaskSlidRight = @"PrivacyMaskSlidRight";
CGFloat const tabWidth = 16;
CGFloat const tabHeight = 55;
CGFloat const hitBoxWidth = 20;
static CGFloat tabHeightOffset = -1;
CGFloat hitBoxHeight = 0;

@interface PrivacyMask()

@property (strong, nonatomic) NSMutableArray         *cellsWithMask;
@property (strong, nonatomic) UIPanGestureRecognizer *uipgr;
@property (strong, nonatomic) CAShapeLayer           *rightTabShapeLayer;
@property (strong, nonatomic) CAShapeLayer           *leftTabShapeLayer;
@property (nonatomic) CGFloat                         maxTransformDistanceLeft;
@property (nonatomic) CGFloat                         maxTransformDistanceRight;
@property (nonatomic) BOOL                            isDrawnOnRight;
@property (strong, nonatomic) NSTimer                *bounceTimer;
@property (strong, nonatomic) UIView                 *privacyMaskGlass;

@end

@implementation PrivacyMask

int defaultSteps = 5;
int currentSteps = 0;
CGFloat amountPerStep = 0;

#pragma mark - Init

- (id)init {
    if (self = [super init]) {
        hitBoxHeight = [ConstUtil screenHeight] - tabHeight - [PrivacyMask tabHeightOffset];
        _isOnRight = YES;
        self.isDrawnOnRight = YES;
        [self setupMask:YES];
        self.layer.mask = self.rightTabShapeLayer;
        self.frame = CGRectMake([ConstUtil screenWidth] - tabWidth - (hitBoxWidth - tabWidth), [PrivacyMask tabHeightOffset], hitBoxWidth, hitBoxHeight);
        self.backgroundColor = [UIColor rivetOffBlack];
        self.uipgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.maxTransformDistanceLeft = [ConstUtil screenWidth];
        self.maxTransformDistanceRight = 0;
        [self addGestureRecognizer:self.uipgr];
    }
    return self;
}

- (void)setupMask:(BOOL)onRight {
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    CGRect maskRect = CGRectMake(onRight ? [ConstUtil screenWidth] : 0, 0, [ConstUtil screenWidth], [ConstUtil screenHeight]);
    CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
    mask.path = path;
    self.mask = mask;
    CGPathRelease(path);
}

#pragma mark - Constants

+ (CGFloat)tabHeightOffset {
    if (tabHeightOffset == -1) {
        tabHeightOffset = 0;
    }
    return tabHeightOffset;
}

#pragma mark - Getters

- (CAShapeLayer *)rightTabShapeLayer {
    if (!_rightTabShapeLayer) {
        CGRect frame = CGRectMake(0, 0, tabWidth, tabHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame
                                                       byRoundingCorners:UIRectCornerBottomLeft
                                                             cornerRadii:CGSizeMake(5, 5)];
        frame.origin.x = hitBoxWidth - tabWidth;
        _rightTabShapeLayer = [CAShapeLayer layer];
        _rightTabShapeLayer.frame = frame;
        _rightTabShapeLayer.path = maskPath.CGPath;
    }
    return _rightTabShapeLayer;
}

- (CAShapeLayer *)leftTabShapeLayer {
    if (!_leftTabShapeLayer) {
        CGRect frame = CGRectMake(0, 0, tabWidth, tabHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame
                                                       byRoundingCorners:UIRectCornerBottomRight
                                                             cornerRadii:CGSizeMake(5, 5)];
        _leftTabShapeLayer = [CAShapeLayer layer];
        _leftTabShapeLayer.frame = frame;
        _leftTabShapeLayer.path = maskPath.CGPath;
    }
    return _leftTabShapeLayer;
}

- (NSMutableArray *)cellsWithMask {
    if (!_cellsWithMask) {
        _cellsWithMask = [[NSMutableArray alloc] init];
    }
    return _cellsWithMask;
}

- (UIView *)backgroundMaskView {
    if (!_backgroundMaskView) {
        _backgroundMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [ConstUtil screenWidth], [ConstUtil screenHeight])];
        [_backgroundMaskView addSubview:self.privacyMaskGlass];
    }
    return _backgroundMaskView;
}

- (UIView *)privacyMaskGlass {
    if (!_privacyMaskGlass) {
        _privacyMaskGlass = [[UIView alloc] initWithFrame:CGRectMake([ConstUtil screenWidth], 0, [ConstUtil screenWidth], [ConstUtil screenHeight])];
        _privacyMaskGlass.backgroundColor = [UIColor colorWithHexCode:@"CCCCCC"];
    }
    return _privacyMaskGlass;
}

#pragma mark - Setters

- (void)setIsOnRight:(BOOL)isOnRight {
    if (isOnRight) {
        [self slideCompletelyRight];
    } else {
        [self slideCompletelyLeft];
    }
}

#pragma mark - Privacy Mask

- (void)addToCell:(MessageTableViewCell *)cell {
    if (![self.cellsWithMask containsObject:cell]) {
        [self.cellsWithMask addObject:cell];
    }
    cell.privacyMask = [PrivacyMask duplicateMask:self.mask];
}

- (void)setMask:(CAShapeLayer *)mask {
    _mask = mask;
    for (MessageTableViewCell *cell in self.cellsWithMask) {
        [cell updatePrivacyMask:[PrivacyMask duplicateMask:mask]];
    }
}

+ (CAShapeLayer *)duplicateMask:(CAShapeLayer *)mask {
    CAShapeLayer *duplicate = [[CAShapeLayer alloc] init];
    duplicate.path = mask.path;
    return duplicate;
}

#pragma mark - Tab Bounce Animation

- (void)startAnimatingBounce {
    self.bounceTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                        target:self
                                                      selector:@selector(animateBounce)
                                                      userInfo:nil
                                                       repeats:YES];
    self.isAnimatingBounce = YES;
}

- (void)animateBounce {
    CAKeyframeAnimation *animation = [PrivacyMask animateBounceToHeight:20];
    [self.layer addAnimation:animation forKey:@"jumping"];
    
}

+ (CAKeyframeAnimation *)animateBounceToHeight:(CGFloat)iconHeight {
    CGFloat factors[32] = {0, 32, 60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32,
        0, 24, 42, 54, 62, 64, 62, 54, 42, 24, 0, 18, 28, 32, 28, 18, 0};
    NSMutableArray *values = [NSMutableArray array];
    for (int i=0; i<32; i++) {
        CGFloat positionOffset = factors[i]/128.0f * iconHeight;
        CATransform3D transform = CATransform3DMakeTranslation(-positionOffset, 0, 0);
        [values addObject:[NSValue valueWithCATransform3D:transform]];
    }
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.repeatCount = 1;
    animation.duration = 32.0f/30.0f;
    animation.fillMode = kCAFillModeForwards;
    animation.values = values;
    animation.removedOnCompletion = YES;
    animation.autoreverses = NO;
    return animation;
}

#pragma mark - Tab Sliding

- (void)handlePan:(UIPanGestureRecognizer *)uipgr {
    __weak PrivacyMask *weakSelf = self;
    [self.bounceTimer invalidate];
    self.bounceTimer = nil;
    self.isAnimatingBounce = NO;
    CGPoint translation = [uipgr translationInView:self.superview];
    if (uipgr.state == UIGestureRecognizerStateEnded) {
        if (self.isOnRight) {
            if (translation.x < -(self.maxTransformDistanceLeft/2.0)) {
                CGAffineTransform theTransform = self.transform;
                theTransform.tx = -self.maxTransformDistanceLeft;
                [self animateMaskBy:theTransform.tx - self.transform.tx];
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     [weakSelf transformAnchorAndMaskAndGlass:theTransform shouldMoveMask: NO];
                                 }
                                 completion:^(BOOL finished) {
                                     [weakSelf slideCompletelyLeft];
                                 }];
            } else {
                CGAffineTransform theTransform = self.transform;
                theTransform.tx = self.maxTransformDistanceRight;
                [self animateMaskBy:theTransform.tx - self.transform.tx];
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     [weakSelf transformAnchorAndMaskAndGlass:theTransform shouldMoveMask: NO];
                                 }
                                 completion:nil];
            }
        } else {
            if (translation.x > self.maxTransformDistanceRight / 2.0) {
                CGAffineTransform theTransform = self.transform;
                theTransform.tx = self.maxTransformDistanceRight;
                [self animateMaskBy:theTransform.tx - self.transform.tx];
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     [weakSelf transformAnchorAndMaskAndGlass:theTransform shouldMoveMask: NO];
                                 }
                                 completion:^(BOOL finished) {
                                     [weakSelf slideCompletelyRight];
                                 }];
            } else {
                CGAffineTransform theTransform = self.transform;
                theTransform.tx = self.maxTransformDistanceLeft;
                [self animateMaskBy:theTransform.tx - self.transform.tx];
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     [weakSelf transformAnchorAndMaskAndGlass:theTransform shouldMoveMask: NO];
                                 }
                                 completion:nil];
            }
        }
    } else {
        CGAffineTransform theTransform = self.transform;
        if (translation.x < -self.maxTransformDistanceLeft) {
            theTransform.tx = -self.maxTransformDistanceLeft;
        } else if (translation.x >= self.maxTransformDistanceRight) {
            theTransform.tx = self.maxTransformDistanceRight;
        } else {
            theTransform.tx = translation.x;
        }
        [self transformAnchorAndMaskAndGlass:theTransform shouldMoveMask:YES];
        if (((theTransform.tx < -[ConstUtil screenWidth] / 2.0 + hitBoxWidth / 2.0 && self.isOnRight)
            || (theTransform.tx < [ConstUtil screenWidth] / 2.0 - hitBoxWidth / 2.0 && !self.isOnRight))
            && self.isDrawnOnRight) {
            [self putTabInLeftPosition];
        } else if (((theTransform.tx > -[ConstUtil screenWidth] / 2.0 + hitBoxWidth / 2.0 && self.isOnRight)
                   || (theTransform.tx > [ConstUtil screenWidth] / 2.0 - hitBoxWidth / 2.0 && !self.isOnRight))
                   && !self.isDrawnOnRight) {
            [self putTabInRightPosition];
        }
    }
}

- (void)animateMaskBy:(CGFloat)tx {
    NSTimer *timer;
    currentSteps = defaultSteps;
    amountPerStep = tx / defaultSteps;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2 / defaultSteps
                                             target:self
                                           selector:@selector(stepMaskAnimation:)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)stepMaskAnimation:(NSTimer *)timer {
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform.tx = amountPerStep;
    CAShapeLayer *mask = self.mask;
    CGPathRef pathRef = CGPathCreateCopyByTransformingPath(mask.path, &transform);
    mask.path = pathRef;
    self.mask = mask;
    CGPathRelease(pathRef);
    currentSteps--;
    if (currentSteps < 1) {
        [timer invalidate];
    }
}

- (void)putTabInLeftPosition {
    CGRect frame = self.privacyMaskGlass.frame;
    frame.origin.x -= hitBoxWidth;
    self.privacyMaskGlass.frame = frame;
    CGAffineTransform transform = self.privacyMaskGlass.transform;
    transform.tx += hitBoxWidth;
    self.privacyMaskGlass.transform = transform;
    self.layer.mask = self.leftTabShapeLayer;
    self.maxTransformDistanceLeft -= hitBoxWidth;
    self.maxTransformDistanceRight += hitBoxWidth;
    transform = CGAffineTransformIdentity;
    transform.tx -= hitBoxWidth;
    CAShapeLayer *mask = self.mask;
    CGPathRef pathRef = CGPathCreateCopyByTransformingPath(mask.path, &transform);
    mask.path = pathRef;
    self.mask = mask;
    CGPathRelease(pathRef);
    self.isDrawnOnRight = NO;
}

- (void)putTabInRightPosition {
    CGRect frame = self.privacyMaskGlass.frame;
    frame.origin.x += hitBoxWidth;
    self.privacyMaskGlass.frame = frame;
    CGAffineTransform transform = self.privacyMaskGlass.transform;
    transform.tx -= hitBoxWidth;
    self.privacyMaskGlass.transform = transform;
    self.layer.mask = self.rightTabShapeLayer;
    self.maxTransformDistanceLeft += hitBoxWidth;
    self.maxTransformDistanceRight -= hitBoxWidth;
    transform = CGAffineTransformIdentity;
    transform.tx += hitBoxWidth;
    CAShapeLayer *mask = self.mask;
    CGPathRef pathRef = CGPathCreateCopyByTransformingPath(mask.path, &transform);
    mask.path = pathRef;
    self.mask = mask;
    CGPathRelease(pathRef);
    self.isDrawnOnRight = YES;
}

- (void)slideCompletelyLeft {
    _isOnRight = NO;
    self.isDrawnOnRight = NO;
    self.transform = CGAffineTransformIdentity;
    self.privacyMaskGlass.transform = CGAffineTransformIdentity;
    self.layer.mask = self.leftTabShapeLayer;
    CGRect frame = self.frame;
    frame.origin.x = 0;
    self.frame = frame;
    frame = self.privacyMaskGlass.frame;
    frame.origin = CGPointMake(0, 0);
    self.privacyMaskGlass.frame = frame;
    self.maxTransformDistanceLeft = 0;
    self.maxTransformDistanceRight = [ConstUtil screenWidth];
    [self setupMask:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_privacyMaskSlidLeft object:nil];
}

- (void)slideCompletelyRight {
    _isOnRight = YES;
    self.isDrawnOnRight = YES;
    self.transform = CGAffineTransformIdentity;
    self.privacyMaskGlass.transform = CGAffineTransformIdentity;
    self.layer.mask = self.rightTabShapeLayer;
    CGRect frame = self.frame;
    frame.origin.x = [ConstUtil screenWidth] - hitBoxWidth;
    self.frame = frame;
    frame = self.privacyMaskGlass.frame;
    frame.origin = CGPointMake([ConstUtil screenWidth], 0);
    self.privacyMaskGlass.frame = frame;
    self.maxTransformDistanceLeft = [ConstUtil screenWidth];
    self.maxTransformDistanceRight = 0;
    [self setupMask:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_privacyMaskSlidRight object:nil];
}

- (void)transformAnchorAndMaskAndGlass:(CGAffineTransform)theTransform shouldMoveMask:(BOOL)shouldMoveMask {
    CGAffineTransform maskTransform = CGAffineTransformIdentity;
    maskTransform.tx = theTransform.tx - self.transform.tx;
    self.transform = theTransform;
    self.privacyMaskGlass.transform = theTransform;
    if (shouldMoveMask) {
        CAShapeLayer *mask = self.mask;
        CGPathRef pathRef = CGPathCreateCopyByTransformingPath(mask.path, &maskTransform);
        mask.path = pathRef;
        self.mask = mask;
        CGPathRelease(pathRef);
    }
}

@end