#import "WaitingForLoadView.h"
#import "UIFont+Rivet.h"
#import "ConstUtil.h"
#import "UIColor+Rivet.h"
#import "UILabel+Rivet.h"

@interface WaitingForLoadView()

@property (strong, nonatomic) UILabel                 *loadingLabel;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation WaitingForLoadView

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.loadingLabel];
        [self addSubview:self.spinner];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Getters

- (UILabel *)loadingLabel {
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] init];
        _loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_loadingLabel setExplanatoryFontWithDefaultFontSizeAndColor];
    }
    return _loadingLabel;
}

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.translatesAutoresizingMaskIntoConstraints = NO;
        _spinner.tintColor = [UIColor rivetOffBlack];
        [_spinner startAnimating];
    }
    return _spinner;
}

#pragma mark - Setters

- (void)setLoadingText:(NSString *)loadingText {
    _loadingText = loadingText;
    self.loadingLabel.text = loadingText;
}

#pragma mark - Setup Constraints

- (void)setupConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.loadingLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:4]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.loadingLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:4]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.spinner
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
}

@end