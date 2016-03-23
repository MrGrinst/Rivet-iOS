#import "FeaturedConversationFooterCell.h"
#import "StartNewConversationButton.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"
#import "OmniBar.h"
#import "ConstUtil.h"
#import "AppState.h"
#import "ShareButton.h"

static FeaturedConversationFooterCell *_sizingCell;

@interface FeaturedConversationFooterCell()

@property (strong, nonatomic) StartNewConversationButton *startNewConversationButton;
@property (strong, nonatomic) ShareButton                *shareButton;

@end

@implementation FeaturedConversationFooterCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.bounds = CGRectMake(0, 0, [ConstUtil screenWidth], 99999);
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        [self.contentView addSubview:self.shareButton];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

#pragma mark - Getters

- (StartNewConversationButton *)startNewConversationButton {
    if (!_startNewConversationButton) {
        _startNewConversationButton = [[StartNewConversationButton alloc] init];
        _startNewConversationButton.customText = NSLocalizedString(@"talkAboutThisMultiline", nil);
    }
    return _startNewConversationButton;
}

- (ShareButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [ShareButton buttonWithType:UIButtonTypeCustom];
        _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

+ (FeaturedConversationFooterCell *)sizingCell {
    if (!_sizingCell) {
        _sizingCell = [[FeaturedConversationFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fake"];
    }
    return _sizingCell;
}

#pragma mark - Setters

- (void)setConversation:(Conversation *)conversation {
    _conversation = conversation;
    if (![[AppState activeConversation] isActive] && ![AppState waitForMatchChannel]) {
        [self.contentView addSubview:self.startNewConversationButton];
        [self.startNewConversationButton setWidthConstraints];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.startNewConversationButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.shareButton
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:16]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.startNewConversationButton
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:16]];
    } else {
        [self.startNewConversationButton removeFromSuperview];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                        toItem:self.shareButton
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:16]];
    }
}

#pragma mark - Setup Constraints

- (void)setupConstraints {
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
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:8]];
}

#pragma mark - Share Button

- (void)shareButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_shareButtonTapped object:nil];
}

#pragma mark - Height

+ (CGFloat)heightWithConversation:(Conversation *)conversation {
    [self sizingCell].conversation = conversation;
    [[self sizingCell] setNeedsLayout];
    [[self sizingCell] layoutIfNeeded];
    CGSize size = [[self sizingCell].contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

@end