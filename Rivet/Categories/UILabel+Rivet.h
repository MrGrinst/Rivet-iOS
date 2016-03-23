#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

@interface UILabel (Rivet)

- (void)setExplanatoryFontWithDefaultFontSizeAndColor;
- (void)setExplanatoryFontWithDefaultFontSizeWithColor:(UIColor *)color;
- (void)setExplanatoryFontWithSize:(NSInteger)fontSize withColor:(UIColor *)color;
- (void)setBoldExplanatoryFontWithSize:(NSInteger)fontSize withColor:(UIColor *)color;

- (void)setToFontSize:(CGFloat)fontSize withFontAwesomeIcon:(FAIcon)faIcon withColor:(UIColor *)color;
- (void)setToSmallFontAwesomeIcon:(FAIcon)faIcon withColor:(UIColor *)color;
- (void)setToMediumFontAwesomeIcon:(FAIcon)faIcon withColor:(UIColor *)color;
- (void)setToLargeFontAwesomeIcon:(FAIcon)faIcon withColor:(UIColor *)color;

@end
