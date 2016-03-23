#import "MenuHeaderView.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"
#import "ConstUtil.h"

@interface MenuHeaderView()

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation MenuHeaderView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        self.contentView.backgroundColor = [UIColor rivetOffWhite];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.titleLabel.preferredMaxLayoutWidth = [ConstUtil screenWidth];
}

- (void)setupConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:18]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.titleLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:6]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:8]];
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_titleLabel setBoldExplanatoryFontWithSize:15 withColor:[UIColor rivetOffBlack]];
    }
    return _titleLabel;
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

@end