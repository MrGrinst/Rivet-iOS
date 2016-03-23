#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

@interface UIButton (Rivet)

+ (UIButton *)whiteButtonWithFontSize:(CGFloat)fontSize withFontAwesomeIcon:(FAIcon)icon withTarget:(id)target withAction:(SEL)action;
+ (UIButton *)whiteButtonWithLargeFontAwesomeIcon:(FAIcon)icon withTarget:(id)target withAction:(SEL)action;
+ (UIButton *)whiteButtonWithMediumFontAwesomeIcon:(FAIcon)icon withTarget:(id)target withAction:(SEL)action;
+ (UIButton *)whiteButtonWithText:(NSString *)text withFontSize:(int)fontSize withTarget:(id)target withAction:(SEL)action;

@end