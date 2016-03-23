#import "StartNewConversationButton.h"
#import "UIColor+Rivet.h"
#import "ConstUtil.h"
#import "UIFont+Rivet.h"
#import "NSString+FontAwesome.h"

NSString *const kNotification_startOrStopSearchingButtonPressed = @"startOrStopSearchingButtonTapped";

@interface StartNewConversationButton()

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation StartNewConversationButton

#pragma mark - Init

- (id)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor clearColor];
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startOrStopSearchingButtonTapped)];
        self.tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:self.tapRecognizer];
    }
    return self;
}

#pragma mark - Setters

- (void)setIsSearching:(BOOL)isSearching {
    _isSearching = isSearching;
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

- (void)setCustomText:(NSString *)customText {
    _customText = customText;
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

#pragma mark - Send Notification

- (void)startOrStopSearchingButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_startOrStopSearchingButtonPressed
                                                        object:nil];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    if (self.isSearching) {
        [self drawSquareBorder];
        [self drawInnerSquare];
        [self drawText];
    } else {
        [self drawFullSquare];
        [self drawText];
    }
}

- (void)drawFullSquare {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width) cornerRadius:7];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor rivetDarkBlue].CGColor;
    layer.path = path.CGPath;
    [self.layer addSublayer:layer];
}

- (void)drawText {
    NSString *text;
    UIFont *font;
    CGColorRef color;
    CGFloat fontSize;
    if (self.customText) {
        fontSize = 17;
        text = self.customText;
        font = [UIFont rivetExplantoryTextFontWithSize:fontSize];
    } else if (self.isSearching) {
        fontSize = 40;
        text = [NSString fontAwesomeIconStringForEnum:FAPause];
        font = [UIFont fontWithName:kFontAwesomeFamilyName size:fontSize];
    } else {
        fontSize = 40;
        text = [NSString fontAwesomeIconStringForEnum:FAComment];
        font = [UIFont fontWithName:kFontAwesomeFamilyName size:fontSize];
    }
    if (self.isSearching) {
        color = [UIColor rivetDarkBlue].CGColor;
    } else {
        color = [UIColor rivetOffWhite].CGColor;
    }
    NSMutableParagraphStyle *ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    ps.alignment = NSTextAlignmentCenter;
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName:ps}];
    CGFloat xPos = (self.bounds.size.width - textSize.width) / 2.0;
    CGFloat yPos = (self.bounds.size.height - textSize.height) / 2.0;
    CGRect rect = CGRectMake(xPos, yPos, textSize.width + 2, textSize.height);
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.string = text;
    textLayer.foregroundColor = color;
    textLayer.font = (__bridge CFStringRef)font.fontName;
    textLayer.fontSize = fontSize;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.frame = rect;
    [self.layer addSublayer:textLayer];
}

- (void)drawSquareBorder {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width) cornerRadius:7];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor rivetDarkBlue].CGColor;
    layer.path = path.CGPath;
    [self.layer addSublayer:layer];
}

- (void)drawInnerSquare {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width - 16, self.bounds.size.width - 16) cornerRadius:7];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor rivetOffWhite].CGColor;
    layer.path = path.CGPath;
    layer.frame = CGRectMake(8, 8, self.bounds.size.width - 16, self.bounds.size.width - 16);
    [self.layer addSublayer:layer];
}

- (void)setWidthConstraints {
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.superview
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1
                                                                 constant:0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:100]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:100]];
}

@end