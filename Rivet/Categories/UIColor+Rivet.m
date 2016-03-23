#import "UIColor+Rivet.h"

@implementation UIColor (Rivet)

+ (UIColor *)rivetOrange {
    return [self colorWithHexCode:@"F3A133"];
}

+ (UIColor *)rivetDarkBlue {
    return [self colorWithHexCode:@"4A7DA0"];
}

+ (UIColor *)rivetTextBlue {
    return [self colorWithHexCode:@"2D6D98"];
}

+ (UIColor *)rivetLightBlue {
    return [self colorWithHexCode:@"63A7D5"];
}

+ (UIColor *)rivetGray {
    return [self colorWithHexCode:@"AFAFAF"];
}

+ (UIColor *)rivetDarkGray {
    return [self colorWithHexCode:@"888888"];
}

+ (UIColor *)rivetOffBlack {
    return [self colorWithHexCode:@"444444"];
}

+ (UIColor *)rivetOffWhite {
    return [self colorWithHexCode:@"F2F2F2"];
}

+ (UIColor *)rivetLightGray {
    return [self colorWithHexCode:@"DFDFDF"];
}

+ (UIColor *)rivetOutgoingMessageBlue {
    return [self colorWithHexCode:@"3395FF"];
}

+ (UIColor *)rivetIncomingMessageGray {
    return [self colorWithHexCode:@"E5E5EA"];
}

+ (UIColor *)colorWithHexCode:(NSString *)hexCode {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexCode];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                           green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                            blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                           alpha:1.0];
}

@end