#import "ParentConversationDetailsHeaderCell.h"
#import "ConstUtil.h"
#import "UIColor+Rivet.h"
#import "UILabel+Rivet.h"

static ParentConversationDetailsHeaderCell *_sizingCell;

@interface ParentConversationDetailsHeaderCell()

@property (strong, nonatomic) UILabel *headlineLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;

@end

@implementation ParentConversationDetailsHeaderCell

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.bounds = CGRectMake(0, 0, [ConstUtil screenWidth], 99999);
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.headlineLabel];
        [self.contentView addSubview:self.descriptionLabel];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.headlineLabel.preferredMaxLayoutWidth = 270 - 16;
    self.descriptionLabel.preferredMaxLayoutWidth = 270 - 32;
}
#pragma mark - Setup Constraints

- (void)setupConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.headlineLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:8]];
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
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.descriptionLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8]];
}

#pragma mark - Getters

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
    }
    return _descriptionLabel;
}

+ (ParentConversationDetailsHeaderCell *)sizingCell {
    if (!_sizingCell) {
        _sizingCell = [[ParentConversationDetailsHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fake"];
    }
    return _sizingCell;
}

#pragma mark - Setters

- (void)setParentConversation:(ParentConversation *)parentConversation {
    _parentConversation = parentConversation;
    self.headlineLabel.text = parentConversation.headline;
    self.descriptionLabel.text = parentConversation.desc;
}

#pragma mark - Height

+ (CGFloat)heightWithParentConversation:(ParentConversation *)parentConversation {
    [self sizingCell].parentConversation = parentConversation;
    [[self sizingCell] setNeedsLayout];
    [[self sizingCell] layoutIfNeeded];
    CGSize size = [[self sizingCell].contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

@end