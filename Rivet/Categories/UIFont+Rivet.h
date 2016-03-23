#import <UIKit/UIKit.h>

NSInteger const kDefaultFontSizeExplanatoryText;
NSInteger const kSmallIconFontSize;
NSInteger const kMediumIconFontSize;
NSInteger const kLargeIconFontSize;

@interface UIFont (Rivet)

+ (UIFont *)rivetBoldUserContentFontWithSize:(CGFloat)size;
+ (UIFont *)rivetUserContentFontWithSize:(CGFloat)size;
+ (UIFont *)rivetTutorialTextFont;
+ (UIFont *)rivetMenuFont;
+ (UIFont *)rivetNumberFontWithSize:(CGFloat)size;
+ (UIFont *)rivetNavigationBarHeaderFont;
+ (UIFont *)rivetExplantoryTextFontWithSize:(CGFloat)size;
+ (UIFont *)rivetBoldExplantoryTextFontWithSize:(CGFloat)size;

@end