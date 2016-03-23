#import "FeaturedConversationHeaderCell.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"
#import "UIImageView+AFNetworking.h"
#import "ConstUtil.h"
#import "OmniBar.h"
#import "ShareButton.h"

static FeaturedConversationHeaderCell *_sizingCell;

@interface FeaturedConversationHeaderCell()

@property (strong, nonatomic) UIImageView        *pictureView;
@property (strong, nonatomic) UILabel            *headlineLabel;
@property (strong, nonatomic) UILabel            *descriptionLabel;
@property (strong, nonatomic) ShareButton        *shareButton;
@property (strong, nonatomic) NSLayoutConstraint *aspectConstraint;

@end

@implementation FeaturedConversationHeaderCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.bounds = CGRectMake(0, 0, [ConstUtil screenWidth], 99999);
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.pictureView];
        [self.contentView addSubview:self.headlineLabel];
        [self.contentView addSubview:self.descriptionLabel];
        [self.contentView addSubview:self.shareButton];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.headlineLabel.preferredMaxLayoutWidth = [ConstUtil screenWidth] - 16;
    self.descriptionLabel.preferredMaxLayoutWidth = [ConstUtil screenWidth] - 32;
}

- (void)setupConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.pictureView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.pictureView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.pictureView
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
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.pictureView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1
                                                                  constant:[ConstUtil screenWidth]]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.headlineLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
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
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.descriptionLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shareButton
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.descriptionLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shareButton
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.shareButton
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8]];
}

#pragma mark - Getters

- (UIImageView *)pictureView {
    if (!_pictureView) {
        _pictureView = [[UIImageView alloc] init];
        _pictureView.translatesAutoresizingMaskIntoConstraints = NO;
        _pictureView.image = [UIImage imageNamed:@"placeholderImage"];
        _pictureView.image.accessibilityIdentifier = @"placeholderImage";
        _pictureView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _pictureView;
}

- (ShareButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [ShareButton buttonWithType:UIButtonTypeCustom];
        _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

- (UILabel *)headlineLabel {
    if (!_headlineLabel) {
        _headlineLabel = [[UILabel alloc] init];
        _headlineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _headlineLabel.textAlignment = NSTextAlignmentCenter;
        _headlineLabel.numberOfLines = 0;
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
    }
    return _descriptionLabel;
}

+ (FeaturedConversationHeaderCell *)sizingCell {
    if (!_sizingCell) {
        _sizingCell = [[FeaturedConversationHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                            reuseIdentifier:@"fake"];
    }
    return _sizingCell;
}

#pragma mark - Setters

- (void)setConversation:(ConversationSummary *)conversation {
    _conversation = conversation;
    UIImage *placeholder = [UIImage imageNamed:@"placeholderImage"];
    placeholder.accessibilityIdentifier = @"placeholderImage";
    self.pictureView.image = conversation.picture ? conversation.picture : placeholder;
    self.headlineLabel.text = conversation.headline;
    self.descriptionLabel.text = conversation.desc;
    [self updateAspectRatioConstraint];
    if (!conversation.picture || [conversation.picture.accessibilityIdentifier isEqualToString:@"placeholderImage"]) {
        __weak FeaturedConversationHeaderCell *weakSelf = self;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:conversation.pictureUrl]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        [self.pictureView setImageWithURLRequest:imageRequest
                         placeholderImage:placeholder
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      weakSelf.conversation.picture = image;
                                      weakSelf.conversation.picture.accessibilityIdentifier = conversation.pictureUrl;
                                      weakSelf.pictureView.image = image;
                                      [weakSelf updateAspectRatioConstraint];
                                  }
                                  failure:nil];
    }
}

#pragma mark - Update Aspect Ratio Constraint

- (void)updateAspectRatioConstraint {
    [self.contentView removeConstraint:self.aspectConstraint];
    CGFloat aspect = self.pictureView.image.size.width / self.pictureView.image.size.height;
    self.aspectConstraint = [NSLayoutConstraint constraintWithItem:self.pictureView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.pictureView
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:aspect
                                                          constant:0];
    [self.contentView addConstraint:self.aspectConstraint];
}

#pragma mark - Share Button

- (void)shareButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_shareButtonTapped object:nil];
}

#pragma mark - Frames

- (CGRect)pictureFrame {
    return [self.window.rootViewController.view convertRect:self.pictureView.frame fromView:self.contentView];
}

- (CGRect)headlineFrame {
    return [self.window.rootViewController.view convertRect:self.headlineLabel.frame fromView:self.contentView];
}

- (CGRect)descriptionFrame {
    return [self.window.rootViewController.view convertRect:self.descriptionLabel.frame fromView:self.contentView];
}


#pragma mark - Height

+ (CGFloat)heightWithConversation:(ConversationSummary *)conversation {
    [self sizingCell].conversation = conversation;
    [[self sizingCell] setNeedsLayout];
    [[self sizingCell] layoutIfNeeded];
    CGSize size = [[self sizingCell].contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

@end