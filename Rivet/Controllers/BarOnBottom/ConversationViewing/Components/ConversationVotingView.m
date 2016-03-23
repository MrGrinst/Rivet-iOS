#import "ConversationVotingView.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"

NSString *const kNotification_conversationViewingVotedOn = @"ConversationViewingVotedOn";

@interface ConversationVotingView()

@property (strong, nonatomic) UILabel *scoreLabel;
@property (strong, nonatomic) UILabel *upvoteButton;
@property (strong, nonatomic) UILabel *downvoteButton;

@end

@implementation ConversationVotingView

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor rivetOffWhite];
        [self roundCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                withRadius:7];
        [self addSubview:self.upvoteButton];
        [self addSubview:self.scoreLabel];
        [self addSubview:self.downvoteButton];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Getters

- (UILabel *)scoreLabel {
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] init];
        [_scoreLabel setExplanatoryFontWithDefaultFontSizeAndColor];
        _scoreLabel.textAlignment = NSTextAlignmentCenter;
        _scoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _scoreLabel;
}

- (UILabel *)upvoteButton {
    if (!_upvoteButton) {
        _upvoteButton = [[UILabel alloc] init];
        [_upvoteButton setToMediumFontAwesomeIcon:FAChevronUp withColor:[UIColor rivetGray]];
        _upvoteButton.userInteractionEnabled = YES;
        _upvoteButton.translatesAutoresizingMaskIntoConstraints = NO;
        _upvoteButton.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(upvoteButtonTapped)];
        uitgr.numberOfTapsRequired = 1;
        [_upvoteButton addGestureRecognizer:uitgr];
    }
    return _upvoteButton;
}

- (UILabel *)downvoteButton {
    if (!_downvoteButton) {
        _downvoteButton = [[UILabel alloc] init];
        [_downvoteButton setToMediumFontAwesomeIcon:FAChevronDown withColor:[UIColor rivetGray]];
        _downvoteButton.translatesAutoresizingMaskIntoConstraints = NO;
        _downvoteButton.textAlignment = NSTextAlignmentCenter;
        _downvoteButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downvoteButtonTapped)];
        uitgr.numberOfTapsRequired = 1;
        [_downvoteButton addGestureRecognizer:uitgr];
    }
    return _downvoteButton;
}

#pragma mark - Setters

- (void)setScore:(NSInteger)score {
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%li", (long)score];
}

- (void)setMyVoteValue:(NSInteger)myVoteValue {
    _myVoteValue = myVoteValue;
    if (myVoteValue == 0) {
        self.upvoteButton.textColor = [UIColor colorWithHexCode:@"DDDDDD"];
        self.downvoteButton.textColor = [UIColor colorWithHexCode:@"DDDDDD"];
    } else if (myVoteValue > 0) {
        self.upvoteButton.textColor = [UIColor rivetOffBlack];
        self.downvoteButton.textColor = [UIColor colorWithHexCode:@"DDDDDD"];
    } else {
        self.upvoteButton.textColor = [UIColor colorWithHexCode:@"DDDDDD"];
        self.downvoteButton.textColor = [UIColor rivetOffBlack];
    }
}

#pragma mark - Setup Constraints

- (void)setupConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:50]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.upvoteButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:34]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.upvoteButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:34]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.upvoteButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:4]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.upvoteButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:4]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.scoreLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.downvoteButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:4]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.upvoteButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.scoreLabel
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:4]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.downvoteButton
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.upvoteButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:4]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.scoreLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.downvoteButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:4]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.downvoteButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:34]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.downvoteButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:34]];
}

#pragma mark - Voting

- (void)upvoteButtonTapped {
    [self voteOnConversationWithValue:1];
}

- (void)downvoteButtonTapped {
    [self voteOnConversationWithValue:-1];
}

- (void)voteOnConversationWithValue:(NSInteger)voteValue {
    NSInteger newScore = self.score - self.myVoteValue + voteValue;
    if (newScore != self.score) {
        self.score = newScore;
        self.myVoteValue = voteValue;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_conversationViewingVotedOn
                                                            object:nil
                                                          userInfo:@{@"voteValue": @(self.myVoteValue), @"score": @(self.score)}];
    }
}

@end
