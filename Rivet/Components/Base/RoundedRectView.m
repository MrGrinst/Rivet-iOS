#import "RoundedRectView.h"

@interface RoundedRectView()

@property (nonatomic) UIRectCorner corners;
@property (nonatomic) NSInteger    radius;

@end

@implementation RoundedRectView

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.radius) {
        [self roundCorners:self.corners withRadius:self.radius];
    }
}

- (void)roundCorners:(UIRectCorner)corners withRadius:(NSInteger)radius {
    self.corners = corners;
    self.radius = radius;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end
