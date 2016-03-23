#import "ConversationTableViewCell.h"
#import "ConstUtil.h"
#import "UIColor+Rivet.h"
#import "NSString+FontAwesome.h"
#import "UIFont+Rivet.h"
#import "UITableViewCell+Rivet.h"
#import "DateUtil.h"
#import "UILabel+Rivet.h"
#import "MarqueeLabel.h"

NSString *const kNotification_conversationVotedOn = @"conversationVotedOn";
static NSInteger const messageBoxPaddingTopBottom = 8;
static NSInteger const messageBoxPaddingLeftRight = 16;

@interface ConversationTableViewCell()

@property (strong, nonatomic) UIView             *messageBoxTab;
@property (strong, nonatomic) UIView             *spacerView;
@property (strong, nonatomic) UILabel            *descriptionLabel;
@property (strong, nonatomic) UILabel            *timestampLabel;
@property (strong, nonatomic) UILabel            *messageCountLabel;
@property (strong, nonatomic) MarqueeLabel       *headlineLabel;
@property (strong, nonatomic) NSLayoutConstraint *featuredConversationCenterMessageCount;
@property (strong, nonatomic) NSLayoutConstraint *timestampLabelSpacerHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *boxTabTimestampLabelConstraint;
@property (strong, nonatomic) NSLayoutConstraint *boxTabMessageCountLabelConstraint;

@end

@implementation ConversationTableViewCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.bounds = CGRectMake(0, 0, self.bounds.size.width, 99999);
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        [self.contentView addSubview:self.messageBoxTab];
        [self.contentView addSubview:self.timestampLabel];
        [self.contentView addSubview:self.spacerView];
        [self.contentView addSubview:self.headlineLabel];
        [self.contentView addSubview:self.messageCountLabel];
        [self.messageBoxTab addSubview:self.descriptionLabel];
        [self setupConstraints];
        [self setSeparatorFullWidth];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.descriptionLabel.preferredMaxLayoutWidth = [ConstUtil screenWidth] - messageBoxPaddingLeftRight * 2 - 16;
}

#pragma mark - Getters

- (UIView *)spacerView {
    if (!_spacerView) {
        _spacerView = [[UIView alloc] init];
        _spacerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _spacerView;
}

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.numberOfLines = 3;
        _descriptionLabel.font = [UIFont rivetUserContentFontWithSize:17];
        _descriptionLabel.textColor = [UIColor rivetOffBlack];
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _descriptionLabel;
}

- (UIView *)messageBoxTab {
    if (!_messageBoxTab) {
        _messageBoxTab = [[UIView alloc] init];
        _messageBoxTab.backgroundColor = [UIColor rivetLightGray];
        _messageBoxTab.translatesAutoresizingMaskIntoConstraints = NO;
        _messageBoxTab.layer.cornerRadius = 7;
    }
    return _messageBoxTab;
}

- (UILabel *)timestampLabel {
    if (!_timestampLabel) {
        _timestampLabel = [[UILabel alloc] init];
        _timestampLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_timestampLabel setExplanatoryFontWithDefaultFontSizeAndColor];
    }
    return _timestampLabel;
}

- (UILabel *)messageCountLabel {
    if (!_messageCountLabel) {
        _messageCountLabel = [[UILabel alloc] init];
        _messageCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_messageCountLabel setExplanatoryFontWithDefaultFontSizeAndColor];
    }
    return _messageCountLabel;
}

- (MarqueeLabel *)headlineLabel {
    if (!_headlineLabel) {
        _headlineLabel = [[MarqueeLabel alloc] init];
        _headlineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _headlineLabel.font = [UIFont rivetBoldUserContentFontWithSize:17];
        _headlineLabel.textColor = [UIColor rivetLightBlue];
        _headlineLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _headlineLabel;
}

#pragma mark - Setters

- (void)setConversationSummary:(ConversationSummary *)conversationSummary {
    _conversationSummary = conversationSummary;
    if (conversationSummary.desc) {
        self.descriptionLabel.text = conversationSummary.desc;
    } else {
        self.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"lastMessageSent", nil), conversationSummary.lastMessageSentByMe];
    }
    self.timestampLabel.hidden = conversationSummary.isFeatured;
    if (conversationSummary.isFeatured) {
        [self.contentView addConstraint:self.featuredConversationCenterMessageCount];
        self.headlineLabel.hidden = NO;
        self.headlineLabel.text = conversationSummary.headline;
        [self.headlineLabel restartLabel];
        self.timestampLabelSpacerHeightConstraint.constant = 16;
        self.boxTabTimestampLabelConstraint.constant = 8;
        self.boxTabMessageCountLabelConstraint.constant = 8;
    } else {
        [self.contentView removeConstraint:self.featuredConversationCenterMessageCount];
        self.headlineLabel.hidden = YES;
        self.timestampLabelSpacerHeightConstraint.constant = 8;
        self.boxTabTimestampLabelConstraint.constant = 4;
        self.boxTabMessageCountLabelConstraint.constant = 4;
    }
    NSString *pluralizedMessage = NSLocalizedString(@"messages", nil);
    if (conversationSummary.messageCount == 1) {
        pluralizedMessage = NSLocalizedString(@"message", nil);
    }
    self.messageCountLabel.text = [NSString stringWithFormat:@"%li %@", (long)conversationSummary.messageCount, pluralizedMessage];
    self.timestampLabel.text = [DateUtil timeAgoWithDate:[NSDate date] sinceDate:conversationSummary.endTime];
}

#pragma mark - Constraints

- (void)setupConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.spacerView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.spacerView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:0]];
    self.timestampLabelSpacerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.spacerView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.timestampLabel
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1
                                                      constant:8];
    [self.contentView addConstraint:self.timestampLabelSpacerHeightConstraint];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:messageBoxPaddingTopBottom]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.descriptionLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:messageBoxPaddingTopBottom]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:messageBoxPaddingLeftRight]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.descriptionLabel
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:messageBoxPaddingLeftRight]];
    self.boxTabTimestampLabelConstraint = [NSLayoutConstraint constraintWithItem:self.timestampLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:4];
    [self.contentView addConstraint:self.boxTabTimestampLabelConstraint];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.timestampLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.timestampLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:0]];
    self.boxTabMessageCountLabelConstraint = [NSLayoutConstraint constraintWithItem:self.messageCountLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:4];
    [self.contentView addConstraint:self.boxTabMessageCountLabelConstraint];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                        toItem:self.messageCountLabel
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:8]];
    self.featuredConversationCenterMessageCount = [NSLayoutConstraint constraintWithItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageCountLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.headlineLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.headlineLabel
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.headlineLabel
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBoxTab
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.headlineLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
}

#pragma mark - Marquee

- (void)restartMarquee {
    if (_headlineLabel && !_headlineLabel.hidden) {
        [_headlineLabel restartLabel];
    }
}

#pragma mark - Cell Height

+ (CGFloat)heightGivenConversationSummary:(ConversationSummary *)conversationSummary
                           withSizingCell:(ConversationTableViewCell *)sizingCell {
    sizingCell.conversationSummary = conversationSummary;
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

@end