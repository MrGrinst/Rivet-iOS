#import "ShareButton.h"

@interface ShareButton()

@property (strong, nonatomic) UIButton *facebookButton;
@property (strong, nonatomic) UIButton *twitterButton;
@property (strong, nonatomic) UIButton *smsButton;

@end

#pragma mark - Lifecycle

@implementation ShareButton

- (id)init {
    if (self = [super init]) {
        [self addSubview:self.facebookButton];
        [self addSubview:self.twitterButton];
        [self addSubview:self.smsButton];
        [self setupConstraints];
    }
    return self;
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    return [[self alloc] init];
}

#pragma mark - Getters

- (UIButton *)facebookButton {
    if (!_facebookButton) {
        _facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_facebookButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        _facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _facebookButton;
}

- (UIButton *)twitterButton {
    if (!_twitterButton) {
        _twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_twitterButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        _twitterButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _twitterButton;
}

- (UIButton *)smsButton {
    if (!_smsButton) {
        _smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_smsButton setImage:[UIImage imageNamed:@"iMessage"] forState:UIControlStateNormal];
        _smsButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _smsButton;
}

#pragma mark - Setup Constraints

- (void)setupConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.twitterButton
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.twitterButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.facebookButton
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.facebookButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.smsButton
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.smsButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.twitterButton
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.facebookButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.twitterButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:6]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.smsButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.facebookButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:6]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.smsButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:0]];
}

#pragma mark - Button Methods

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self.facebookButton addTarget:target action:action forControlEvents:controlEvents];
    [self.twitterButton addTarget:target action:action forControlEvents:controlEvents];
    [self.smsButton addTarget:target action:action forControlEvents:controlEvents];
}

@end
