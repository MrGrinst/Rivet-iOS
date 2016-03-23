#import "UIFont+Rivet.h"

NSInteger const kDefaultFontSizeExplanatoryText = 17;
NSInteger const kSmallIconFontSize = 13;
NSInteger const kMediumIconFontSize = 20;
NSInteger const kLargeIconFontSize = 27;

@implementation UIFont (Rivet)

+ (UIFont *)rivetBoldUserContentFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Roboto-Bold" size:size];
}

+ (UIFont *)rivetUserContentFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Roboto-Regular" size:size];
}

+ (UIFont *)rivetTutorialTextFont {
    return [UIFont fontWithName:@"Roboto-Regular" size:17];
}

+ (UIFont *)rivetMenuFont {
    return [UIFont fontWithName:@"Roboto-Regular" size:17];
}

+ (UIFont *)rivetNavigationBarHeaderFont {
    return [UIFont fontWithName:@"Roboto-Bold" size:19];
}

+ (UIFont *)rivetNumberFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Roboto-Regular" size:size];
}

+ (UIFont *)rivetExplantoryTextFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Roboto-Regular" size:size];
}

+ (UIFont *)rivetBoldExplantoryTextFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Roboto-Bold" size:size];
}

@end