#import "UIButton+Rivet.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"

@implementation UIButton (Rivet)

+ (UIButton *)whiteButtonWithFontSize:(CGFloat)fontSize withFontAwesomeIcon:(FAIcon)icon withTarget:(id)target withAction:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor rivetLightGray] forState:UIControlStateHighlighted];
    [button.titleLabel setToFontSize:fontSize withFontAwesomeIcon:icon withColor:[UIColor whiteColor]];
    [button setTitle:[NSString fontAwesomeIconStringForEnum:icon] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button sizeToFit];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)whiteButtonWithLargeFontAwesomeIcon:(FAIcon)icon withTarget:(id)target withAction:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor rivetLightGray] forState:UIControlStateHighlighted];
    [button.titleLabel setToLargeFontAwesomeIcon:icon withColor:[UIColor whiteColor]];
    [button setTitle:[NSString fontAwesomeIconStringForEnum:icon] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button sizeToFit];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)whiteButtonWithMediumFontAwesomeIcon:(FAIcon)icon withTarget:(id)target withAction:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor rivetLightGray] forState:UIControlStateHighlighted];
    [button.titleLabel setToMediumFontAwesomeIcon:icon withColor:[UIColor whiteColor]];
    [button setTitle:[NSString fontAwesomeIconStringForEnum:icon] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button sizeToFit];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)whiteButtonWithText:(NSString *)text withFontSize:(int)fontSize withTarget:(id)target withAction:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor rivetLightGray] forState:UIControlStateHighlighted];
    [button setTitle:text forState:UIControlStateNormal];
    [button.titleLabel setExplanatoryFontWithSize:fontSize withColor:[UIColor whiteColor]];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button sizeToFit];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end