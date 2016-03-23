#import "ConversationEndedTableViewCell.h"
#import "StartNewConversationButton.h"
#import "UILabel+Rivet.h"
#import "OmniBar.h"
#import "ConstUtil.h"
#import "ShareButton.h"

@interface ConversationEndedTableViewCell()

@property (strong, nonatomic) StartNewConversationButton *startNewConversationButton;
@property (strong, nonatomic) ShareButton                *shareButton;
@property (strong, nonatomic) UILabel                    *userLeftLabel;

@end

@implementation ConversationEndedTableViewCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
isConversationMakingView:(BOOL)isConversationMakingView {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.bounds = CGRectMake(0, 0, [ConstUtil screenWidth], 99999);
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        [self.contentView addSubview:self.userLeftLabel];
        [self setupConstraints];
        if (isConversationMakingView) {
            [self.contentView addSubview:self.startNewConversationButton];
            [self.startNewConversationButton setWidthConstraints];
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.startNewConversationButton
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.userLeftLabel
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1
                                                                          constant:8]];
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.startNewConversationButton
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1
                                                                          constant:8]];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.userLeftLabel.preferredMaxLayoutWidth = [ConstUtil screenWidth] - 16;
}

#pragma mark - Setup Constraints

- (void)setupConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.userLeftLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.userLeftLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.userLeftLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:self.userLeftLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8]];
}

#pragma mark - Getters

- (StartNewConversationButton *)startNewConversationButton {
    if (!_startNewConversationButton) {
        _startNewConversationButton = [[StartNewConversationButton alloc] init];
    }
    return _startNewConversationButton;
}

- (UILabel *)userLeftLabel {
    if (!_userLeftLabel) {
        _userLeftLabel = [[UILabel alloc] init];
        _userLeftLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _userLeftLabel.numberOfLines = 0;
        _userLeftLabel.textAlignment = NSTextAlignmentCenter;
        [_userLeftLabel setExplanatoryFontWithDefaultFontSizeAndColor];
    }
    return _userLeftLabel;
}

- (ShareButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [ShareButton buttonWithType:UIButtonTypeCustom];
        _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

#pragma mark - Setters

- (void)setIsConversationMakingView:(BOOL)isConversationMakingView {
    _isConversationMakingView = isConversationMakingView;
    self.startNewConversationButton.hidden = !isConversationMakingView;
}

- (void)setConversation:(Conversation *)conversation {
    if (conversation.myParticipantNumber != -1) {
        if (conversation.myParticipantNumber == conversation.participantNumberOfUserThatEnded) {
            self.userLeftLabel.text = NSLocalizedString(@"youEndedTheConversation", nil);
        } else {
            self.userLeftLabel.text = NSLocalizedString(@"theOtherUserEndedTheConversation", nil);
        }
    } else {
        self.userLeftLabel.text = NSLocalizedString(@"oneOfTheUsersEndedTheConversation", nil);
    }
    if (conversation.desc) {
        [self.contentView addSubview:self.shareButton];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shareButton
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shareButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.userLeftLabel
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:8]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.shareButton
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:8]];
    }
}

#pragma mark - Share Button

- (void)shareButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_shareButtonTapped object:nil];
}

#pragma mark - Height

+ (CGFloat)heightWithConversation:(Conversation *)conversation
           isConversationMakingView:(BOOL)isConversationMakingView {
    ConversationEndedTableViewCell *cell = [[ConversationEndedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                                 reuseIdentifier:@"fake"
                                                                        isConversationMakingView:isConversationMakingView];
    cell.conversation = conversation;
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

@end