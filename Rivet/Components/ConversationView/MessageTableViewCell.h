#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageTableViewCell : UITableViewCell

@property (nonatomic) BOOL messageContentViewHidden;
@property (strong, nonatomic) CAShapeLayer *privacyMask;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           isOnLeft:(BOOL)isOnLeft
       withMaxWidth:(CGFloat)maxWidth;
- (void)setMessage:(Message *)message
       setIsOnLeft:(BOOL)isOnLeft
setMyParticipantNumber:(NSInteger)myParticipantNumber
    cachedTextSize:(NSMutableDictionary *)cachedTextSize;
- (void)updatePrivacyMask:(CAShapeLayer *)privacyMask;
+ (CGFloat)heightGivenMessage:(Message *)message withMaxWidth:(CGFloat)maxWidth;

@end