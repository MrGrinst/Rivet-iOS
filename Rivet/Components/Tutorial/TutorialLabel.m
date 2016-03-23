#import "TutorialLabel.h"
#import "UIFont+Rivet.h"
#import "UILabel+Rivet.h"

@implementation TutorialLabel

#pragma mark - Init

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 7;
        self.clipsToBounds = YES;
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentCenter;
        [self setExplanatoryFontWithDefaultFontSizeAndColor];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {5, 7, 5, 7};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (CGSize)intrinsicContentSize {
    CGSize contentSize = [super intrinsicContentSize];
    return CGSizeMake(contentSize.width + 14, contentSize.height + 10);
}

@end