#import "HexagonWithBorderView.h"
#import "UIColor+Rivet.h"

@interface HexagonWithBorderView()

@property (strong, nonatomic) UIColor *color;
@property (nonatomic) NSInteger        borderWidth;

@end

@implementation HexagonWithBorderView

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_borderWidth) {
        [self actuallyDrawWithBorderWidth:_borderWidth];
    }
}

- (void)drawHexagonWithBorderWidth:(NSInteger)borderWidth withColor:(UIColor *)color {
    _borderWidth = borderWidth;
    _color = color;
}

- (void)actuallyDrawWithBorderWidth:(NSInteger)borderWidth {
    UIBezierPath *outerHexagonPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)
                                                               cornerRadius:7];
    CAShapeLayer *outerHexagonLayer = [[CAShapeLayer alloc] init];
    outerHexagonLayer.fillColor = _color.CGColor;
    outerHexagonLayer.path = outerHexagonPath.CGPath;
    [self.layer addSublayer:outerHexagonLayer];
    
    UIBezierPath *innerHexagonPath  = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.height - borderWidth * 2, self.frame.size.height - borderWidth * 2)
                                                               cornerRadius:7];
    CAShapeLayer *innerHexagonLayer = [[CAShapeLayer alloc] init];
    innerHexagonLayer.fillColor = [UIColor whiteColor].CGColor;
    innerHexagonLayer.path = innerHexagonPath.CGPath;
    innerHexagonLayer.frame = CGRectOffset(innerHexagonLayer.frame, borderWidth, borderWidth);
    [self.layer addSublayer:innerHexagonLayer];
}

@end
