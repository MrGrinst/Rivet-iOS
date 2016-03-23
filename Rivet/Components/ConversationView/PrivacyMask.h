#import <UIKit/UIKit.h>
#import "MessageTableViewCell.h"

NSString *const kNotification_privacyMaskSlidLeft;
NSString *const kNotification_privacyMaskSlidRight;
CGFloat const tabWidth;
CGFloat const tabHeight;
CGFloat const hitBoxWidth;

@interface PrivacyMask : UIView

@property (strong, nonatomic) CAShapeLayer *mask;
@property (nonatomic) BOOL                  isOnRight;
@property (nonatomic) BOOL                  isAnimatingBounce;
@property (strong, nonatomic) UIView       *backgroundMaskView;

+ (CGFloat)tabHeightOffset;
- (void)addToCell:(MessageTableViewCell *)cell;
- (void)startAnimatingBounce;
+ (CAShapeLayer *)duplicateMask:(CAShapeLayer *)mask;

@end