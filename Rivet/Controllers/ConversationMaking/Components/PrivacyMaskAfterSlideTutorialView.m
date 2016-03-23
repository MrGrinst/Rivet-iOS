#import "PrivacyMaskAfterSlideTutorialView.h"
#import "TutorialLabel.h"

@interface PrivacyMaskAfterSlideTutorialView()

@property (strong, nonatomic) TutorialLabel *explanationLabel;

@end

@implementation PrivacyMaskAfterSlideTutorialView

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        [self addSubview:self.explanationLabel];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.explanationLabel
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.explanationLabel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:8]];
    }
    return self;
}

#pragma mark - Getters

- (TutorialLabel *)explanationLabel {
    if (!_explanationLabel) {
        _explanationLabel = [[TutorialLabel alloc] init];
        _explanationLabel.text = NSLocalizedString(@"privacyMaskExplanation", nil);
        _explanationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _explanationLabel;
}

#pragma mark - Click Through Handler

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

@end