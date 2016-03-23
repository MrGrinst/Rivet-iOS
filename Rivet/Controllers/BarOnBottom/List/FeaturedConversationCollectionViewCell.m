#import "FeaturedConversationCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"
#import "DateUtil.h"
#import "ConstUtil.h"

NSString *const kNotification_featuredConversationSelected = @"kNotification_featuredConversationSelected";

@interface FeaturedConversationCollectionViewCell()

@property (strong, nonatomic) UIView             *cardView;
@property (strong, nonatomic) UIImageView        *pictureView;
@property (strong, nonatomic) UILabel            *headlineLabel;
@property (strong, nonatomic) UILabel            *descriptionLabel;
@property (strong, nonatomic) UILabel            *timestampLabel;
@property (strong, nonatomic) UILabel            *messageCountLabel;
@property (strong, nonatomic) NSLayoutConstraint *aspectRatioConstraint;
@property (strong, nonatomic) NSLayoutConstraint *cardViewHeightConstraint;


@end

@implementation FeaturedConversationCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.cardView];
        [self.cardView addSubview:self.pictureView];
        [self.cardView addSubview:self.headlineLabel];
        [self.cardView addSubview:self.descriptionLabel];
        [self.cardView addSubview:self.timestampLabel];
        [self.cardView addSubview:self.messageCountLabel];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.cardViewHeightConstraint.constant = MIN(400, self.contentView.frame.size.height - 40);
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.descriptionLabel.preferredMaxLayoutWidth = self.contentView.bounds.size.width - 40;
}

- (void)setConversation:(ConversationSummary *)conversation {
    _conversation = conversation;
    if (!conversation.picture) {
        conversation.picture = [UIImage imageNamed:@"placeholderImage"];
        conversation.picture.accessibilityIdentifier = @"placeholderImage";
    }
    __weak FeaturedConversationCollectionViewCell *weakSelf = self;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:conversation.pictureUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    [self.pictureView setImageWithURLRequest:imageRequest
                     placeholderImage:conversation.picture
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  weakSelf.conversation.picture = image;
                                  weakSelf.conversation.picture.accessibilityIdentifier = conversation.pictureUrl;
                                  weakSelf.pictureView.image = image;
                                  [weakSelf updateAspectRatioConstraint];
                              }
                              failure:nil];
    self.pictureView.image = conversation.picture;
    self.headlineLabel.text = conversation.headline;
    self.descriptionLabel.text = conversation.desc;
    self.messageCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"messageCount", nil), conversation.messageCount, conversation.messageCount == 1 ? @"" : @"s"];
    self.timestampLabel.text = [DateUtil prettyStringFromDate:conversation.endTime];
    [self updateAspectRatioConstraint];
}

#pragma mark - Getters

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.translatesAutoresizingMaskIntoConstraints = NO;
        _cardView.backgroundColor = [UIColor whiteColor];
        _cardView.userInteractionEnabled = YES;
        _cardView.layer.cornerRadius = 7;
        _cardView.clipsToBounds = YES;
        UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellSelected)];
        uitgr.numberOfTapsRequired = 1;
        [_cardView addGestureRecognizer:uitgr];
    }
    return _cardView;
}

- (UIImageView *)pictureView {
    if (!_pictureView) {
        _pictureView = [[UIImageView alloc] init];
        _pictureView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pictureView;
}

- (UILabel *)headlineLabel {
    if (!_headlineLabel) {
        _headlineLabel = [[UILabel alloc] init];
        _headlineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _headlineLabel.numberOfLines = 0;
        _headlineLabel.textAlignment = NSTextAlignmentCenter;
        [_headlineLabel setExplanatoryFontWithSize:20 withColor:[UIColor rivetLightBlue]];
    }
    return _headlineLabel;
}

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _descriptionLabel.numberOfLines = 0;
        [_descriptionLabel setExplanatoryFontWithDefaultFontSizeAndColor];
        [_descriptionLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        [_descriptionLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _descriptionLabel;
}

- (UILabel *)timestampLabel {
    if (!_timestampLabel) {
        _timestampLabel = [[UILabel alloc] init];
        _timestampLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_timestampLabel setExplanatoryFontWithSize:15 withColor:[UIColor rivetGray]];
    }
    return _timestampLabel;
}

- (UILabel *)messageCountLabel {
    if (!_messageCountLabel) {
        _messageCountLabel = [[UILabel alloc] init];
        _messageCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_messageCountLabel setExplanatoryFontWithSize:15 withColor:[UIColor rivetGray]];
    }
    return _messageCountLabel;
}

#pragma mark - Constraints

- (void)setupConstraints {
    self.cardViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1
                                                                  constant:400];
    [self.contentView addConstraint:self.cardViewHeightConstraint];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:4]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:4]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pictureView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pictureView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0.5
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pictureView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pictureView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pictureView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.headlineLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.pictureView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.headlineLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.headlineLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.headlineLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:4]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.descriptionLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:12]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:12]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageCountLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.timestampLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:4]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.timestampLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:12]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.timestampLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:self.descriptionLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.messageCountLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:12]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageCountLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:12]];
}

#pragma mark - Aspect Ratio Constraint

- (void)updateAspectRatioConstraint {
    [self.contentView removeConstraint:self.aspectRatioConstraint];
    CGFloat width = MIN([ConstUtil screenWidth] - 60, 320) - 8;
    CGFloat pictureHeightIfAspectFit = (self.pictureView.image.size.height / self.pictureView.image.size.width) * width;
    if (pictureHeightIfAspectFit < MIN(self.frame.size.height - 40, 400) / 2.0) {
        CGFloat aspect = self.pictureView.image.size.width / self.pictureView.image.size.height;
        self.aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self.pictureView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.pictureView
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:aspect
                                                              constant:0];
        [self.contentView addConstraint:self.aspectRatioConstraint];
        self.pictureView.contentMode = UIViewContentModeScaleAspectFit;
        self.pictureView.clipsToBounds = NO;
    } else {
        self.pictureView.contentMode = UIViewContentModeScaleAspectFill;
        self.pictureView.clipsToBounds = YES;
    }
}

#pragma mark - Selecting

- (void)cellSelected {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_featuredConversationSelected
                                                        object:self
                                                      userInfo:@{@"conversation": self.conversation}];
}

#pragma mark - Frames

- (CGRect)cardViewFrame {
    return [self.window.rootViewController.view convertRect:self.cardView.frame fromView:self.contentView];
}

- (CGRect)pictureFrame {
    return self.pictureView.frame;
}

- (CGRect)headlineFrame {
    return self.headlineLabel.frame;
}

- (CGRect)descriptionFrame {
    return self.descriptionLabel.frame;
}

@end