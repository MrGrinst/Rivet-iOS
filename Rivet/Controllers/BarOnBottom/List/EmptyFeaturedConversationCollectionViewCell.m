#import "EmptyFeaturedConversationCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"
#import "DateUtil.h"
#import "FeaturedConversationCollectionViewController.h"

@interface EmptyFeaturedConversationCollectionViewCell()

@property (strong, nonatomic) UIView             *cardView;
@property (strong, nonatomic) UILabel            *noFeaturedConversationsLabel;
@property (strong, nonatomic) NSLayoutConstraint *cardViewHeightConstraint;


@end

@implementation EmptyFeaturedConversationCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.cardView];
        [self.cardView addSubview:self.noFeaturedConversationsLabel];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.cardViewHeightConstraint.constant = MIN(400, self.contentView.frame.size.height - 40);
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.noFeaturedConversationsLabel.preferredMaxLayoutWidth = self.contentView.bounds.size.width - 16;
}

#pragma mark - Getters

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.translatesAutoresizingMaskIntoConstraints = NO;
        _cardView.backgroundColor = [UIColor whiteColor];
        _cardView.layer.cornerRadius = 7;
        _cardView.clipsToBounds = YES;
    }
    return _cardView;
}

- (UILabel *)noFeaturedConversationsLabel {
    if (!_noFeaturedConversationsLabel) {
        _noFeaturedConversationsLabel = [[UILabel alloc] init];
        _noFeaturedConversationsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noFeaturedConversationsLabel.numberOfLines = 0;
        [_noFeaturedConversationsLabel setExplanatoryFontWithDefaultFontSizeAndColor];
        if ([self.collectionType isEqualToString:kCollectionType_global]) {
            _noFeaturedConversationsLabel.text = NSLocalizedString(@"NoFeaturedConversationsGlobal", nil);
        } else {
            _noFeaturedConversationsLabel.text = NSLocalizedString(@"NoFeaturedConversationsNearby", nil);
        }
        _noFeaturedConversationsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noFeaturedConversationsLabel;
}

#pragma mark - Setters

- (void)setCollectionType:(NSString *)collectionType {
    _collectionType = collectionType;
    if ([collectionType isEqualToString:kCollectionType_global]) {
        self.noFeaturedConversationsLabel.text = NSLocalizedString(@"NoFeaturedConversationsGlobal", nil);
    } else {
        self.noFeaturedConversationsLabel.text = NSLocalizedString(@"NoFeaturedConversationsNearby", nil);
    }
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
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.noFeaturedConversationsLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.noFeaturedConversationsLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.noFeaturedConversationsLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:8]];
}

@end