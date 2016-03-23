#import "UILabel+Rivet.h"
#import "UIFont+Rivet.h"
#import "UIColor+Rivet.h"

@implementation UILabel (Rivet)

- (void)setExplanatoryFontWithDefaultFontSizeAndColor {
    [self setExplanatoryFontWithDefaultFontSizeWithColor:[UIColor rivetOffBlack]];
}

- (void)setExplanatoryFontWithDefaultFontSizeWithColor:(UIColor *)color {
    [self setExplanatoryFontWithSize:kDefaultFontSizeExplanatoryText
                           withColor:color];
}

- (void)setExplanatoryFontWithSize:(NSInteger)fontSize withColor:(UIColor *)color {
    self.font = [UIFont rivetExplantoryTextFontWithSize:fontSize];
    self.textColor = color;
}

- (void)setBoldExplanatoryFontWithSize:(NSInteger)fontSize withColor:(UIColor *)color {
    self.font = [UIFont rivetBoldExplantoryTextFontWithSize:fontSize];
    self.textColor = color;
}

- (void)setToFontSize:(CGFloat)fontSize withFontAwesomeIcon:(FAIcon)faIcon withColor:(UIColor *)color {
    [self setToFontAwesomeIcon:faIcon
                      withSize:fontSize
                     withColor:color];
}

- (void)setToSmallFontAwesomeIcon:(FAIcon)faIcon withColor:(UIColor *)color {
    [self setToFontAwesomeIcon:faIcon
                      withSize:kSmallIconFontSize
                     withColor:color];
}

- (void)setToMediumFontAwesomeIcon:(FAIcon)faIcon withColor:(UIColor *)color {
    [self setToFontAwesomeIcon:faIcon
                      withSize:kMediumIconFontSize
                     withColor:color];
}

- (void)setToLargeFontAwesomeIcon:(FAIcon)faIcon withColor:(UIColor *)color {
    [self setToFontAwesomeIcon:faIcon
                      withSize:kLargeIconFontSize
                     withColor:color];
}

- (void)setToFontAwesomeIcon:(FAIcon)faIcon
                    withSize:(NSInteger)size
                   withColor:(UIColor *)color {
    self.font = [UIFont fontWithName:kFontAwesomeFamilyName size:size];
    self.text = [NSString fontAwesomeIconStringForEnum:faIcon];
    self.textColor = color;
}

@end
