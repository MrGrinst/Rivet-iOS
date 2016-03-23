#import <UIKit/UIKit.h>

@interface ShareButton : UIView

+ (instancetype)buttonWithType:(UIButtonType)buttonType;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
