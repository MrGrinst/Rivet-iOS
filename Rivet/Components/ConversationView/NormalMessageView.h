#import <UIKit/UIKit.h>
#import "Message.h"

@interface NormalMessageView : UIView

@property (strong, nonatomic) CAShapeLayer *privacyMask;
@property (strong, nonatomic) Message      *message;
@property (nonatomic) BOOL                  messageContentViewHidden;

- (id)initWithMaxWidth:(CGFloat)maxWidth;
- (void)setMessage:(Message *)message
       setIsOnLeft:(BOOL)isOnLeft
setMyParticipantNumber:(NSInteger)myParticipantNumber
    cachedTextSize:(NSMutableDictionary *)cachedTextSize;
- (void)updatePrivacyMask:(CAShapeLayer *)privacyMask;
+ (CGFloat)heightGivenMessage:(Message *)message maxWidth:(CGFloat)maxWidth;

@end