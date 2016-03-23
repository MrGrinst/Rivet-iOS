#import "ParentConversationTableViewCell.h"
#import "ConstUtil.h"
#import "UIColor+Rivet.h"
#import "UIFont+Rivet.h"
#import "UILabel+Rivet.h"
#import "ParentConversation.h"
#import "SortUtil.h"
#import "ParentConversationDetailsModal.h"

static ParentConversationTableViewCell *_sizingCell;

@interface ParentConversationTableViewCell()

@property (strong, nonatomic) UILabel        *nowTalkingLabel;
@property (strong, nonatomic) UILabel        *firstParentIntroduction;
@property (strong, nonatomic) UILabel        *firstParentHeadline;
@property (strong, nonatomic) UILabel        *firstParentChevron;
@property (strong, nonatomic) UIView         *firstParentBox;
@property (strong, nonatomic) UILabel        *secondParentIntroduction;
@property (strong, nonatomic) UILabel        *secondParentHeadline;
@property (strong, nonatomic) UILabel        *secondParentChevron;
@property (strong, nonatomic) UIView         *secondParentBox;
@property (strong, nonatomic) NSMutableArray *secondParentVerticalSpacingConstraints;
@property (strong, nonatomic) NSMutableArray *nowTalkingLabelVerticalSpacingConstraints;

@end

@implementation ParentConversationTableViewCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.bounds = CGRectMake(0, 0, [ConstUtil screenWidth], 99999);
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        [self.contentView addSubview:self.nowTalkingLabel];
        [self.contentView addSubview:self.firstParentIntroduction];
        [self.contentView addSubview:self.firstParentBox];
        [self.firstParentBox addSubview:self.firstParentHeadline];
        [self.firstParentBox addSubview:self.firstParentChevron];
        [self.contentView addSubview:self.secondParentIntroduction];
        [self.contentView addSubview:self.secondParentBox];
        [self.secondParentBox addSubview:self.secondParentHeadline];
        [self.secondParentBox addSubview:self.secondParentChevron];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.nowTalkingLabel.preferredMaxLayoutWidth = [ConstUtil screenWidth] - 32;
    self.firstParentHeadline.preferredMaxLayoutWidth = [ConstUtil screenWidth] - 76;
    self.firstParentIntroduction.preferredMaxLayoutWidth = [ConstUtil screenWidth] - 16;
    self.secondParentHeadline.preferredMaxLayoutWidth = [ConstUtil screenWidth] - 76;
    self.secondParentIntroduction.preferredMaxLayoutWidth = [ConstUtil screenWidth] - 16;
}

#pragma mark - Getters

- (UILabel *)nowTalkingLabel {
    if (!_nowTalkingLabel) {
        _nowTalkingLabel = [[UILabel alloc] init];
        _nowTalkingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nowTalkingLabel.numberOfLines = 0;
        _nowTalkingLabel.textAlignment = NSTextAlignmentCenter;
        [_nowTalkingLabel setExplanatoryFontWithDefaultFontSizeWithColor:[UIColor rivetDarkGray]];
    }
    return _nowTalkingLabel;
}

- (UIView *)firstParentBox {
    if (!_firstParentBox) {
        _firstParentBox = [[UIView alloc] init];
        _firstParentBox.translatesAutoresizingMaskIntoConstraints = NO;
        _firstParentBox.layer.cornerRadius = 7;
        _firstParentBox.backgroundColor = [UIColor rivetOffWhite];
        _firstParentBox.userInteractionEnabled = YES;
        UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firstParentTapped)];
        uitgr.numberOfTapsRequired = 1;
        [_firstParentBox addGestureRecognizer:uitgr];
    }
    return _firstParentBox;
}

- (UILabel *)firstParentIntroduction {
    if (!_firstParentIntroduction) {
        _firstParentIntroduction = [[UILabel alloc] init];
        _firstParentIntroduction.textAlignment = NSTextAlignmentCenter;
        _firstParentIntroduction.translatesAutoresizingMaskIntoConstraints = NO;
        _firstParentIntroduction.numberOfLines = 0;
        [_firstParentIntroduction setExplanatoryFontWithDefaultFontSizeAndColor];
        [_firstParentIntroduction setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _firstParentIntroduction;
}

- (UILabel *)firstParentHeadline {
    if (!_firstParentHeadline) {
        _firstParentHeadline = [[UILabel alloc] init];
        _firstParentHeadline.translatesAutoresizingMaskIntoConstraints = NO;
        _firstParentHeadline.numberOfLines = 0;
        [_firstParentHeadline setExplanatoryFontWithSize:20 withColor:[UIColor rivetLightBlue]];
    }
    return _firstParentHeadline;
}

- (UILabel *)firstParentChevron {
    if (!_firstParentChevron) {
        _firstParentChevron = [[UILabel alloc] init];
        _firstParentChevron.translatesAutoresizingMaskIntoConstraints = NO;
        _firstParentChevron.font = [UIFont fontWithName:kFontAwesomeFamilyName size:kMediumIconFontSize];
        _firstParentChevron.textColor = [UIColor rivetGray];
        _firstParentChevron.text = [NSString fontAwesomeIconStringForEnum:FAChevronDown];
    }
    return _firstParentChevron;
}

- (UIView *)secondParentBox {
    if (!_secondParentBox) {
        _secondParentBox = [[UIView alloc] init];
        _secondParentBox.translatesAutoresizingMaskIntoConstraints = NO;
        _secondParentBox.layer.cornerRadius = 7;
        _secondParentBox.backgroundColor = [UIColor rivetOffWhite];
        _secondParentBox.userInteractionEnabled = YES;
        UITapGestureRecognizer *uitgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(secondParentTapped)];
        uitgr.numberOfTapsRequired = 1;
        [_secondParentBox addGestureRecognizer:uitgr];
    }
    return _secondParentBox;
}

- (UILabel *)secondParentIntroduction {
    if (!_secondParentIntroduction) {
        _secondParentIntroduction = [[UILabel alloc] init];
        _secondParentIntroduction.textAlignment = NSTextAlignmentCenter;
        _secondParentIntroduction.numberOfLines = 0;
        _secondParentIntroduction.translatesAutoresizingMaskIntoConstraints = NO;
        [_secondParentIntroduction setExplanatoryFontWithDefaultFontSizeAndColor];
        [_secondParentIntroduction setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _secondParentIntroduction;
}

- (UILabel *)secondParentHeadline {
    if (!_secondParentHeadline) {
        _secondParentHeadline = [[UILabel alloc] init];
        _secondParentHeadline.translatesAutoresizingMaskIntoConstraints = NO;
        _secondParentHeadline.numberOfLines = 0;
        [_secondParentHeadline setExplanatoryFontWithSize:20 withColor:[UIColor rivetLightBlue]];
    }
    return _secondParentHeadline;
}

- (UILabel *)secondParentChevron {
    if (!_secondParentChevron) {
        _secondParentChevron = [[UILabel alloc] init];
        _secondParentChevron.translatesAutoresizingMaskIntoConstraints = NO;
        _secondParentChevron.font = [UIFont fontWithName:kFontAwesomeFamilyName size:kMediumIconFontSize];
        _secondParentChevron.textColor = [UIColor rivetGray];
        _secondParentChevron.text = [NSString fontAwesomeIconStringForEnum:FAChevronDown];
    }
    return _secondParentChevron;
}

- (NSMutableArray *)secondParentVerticalSpacingConstraints {
    if (!_secondParentVerticalSpacingConstraints) {
        _secondParentVerticalSpacingConstraints = [[NSMutableArray alloc] init];
    }
    return _secondParentVerticalSpacingConstraints;
}

- (NSMutableArray *)nowTalkingLabelVerticalSpacingConstraints {
    if (!_nowTalkingLabelVerticalSpacingConstraints) {
        _nowTalkingLabelVerticalSpacingConstraints = [[NSMutableArray alloc] init];
    }
    return _nowTalkingLabelVerticalSpacingConstraints;
}

+ (ParentConversationTableViewCell *)sizingCell {
    if (!_sizingCell) {
        _sizingCell = [[ParentConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fake"];
    }
    return _sizingCell;
}

#pragma mark - Setters

- (void)setConversation:(Conversation *)conversation {
    _conversation = conversation;
    if (conversation.desc) {
        self.nowTalkingLabel.text = conversation.desc;
        for (NSLayoutConstraint *constraint in self.nowTalkingLabelVerticalSpacingConstraints) {
            constraint.constant = 16;
        }
    } else {
        if (conversation.myParticipantNumber != -1) {
            if ([conversation isActive]) {
                self.nowTalkingLabel.text = NSLocalizedString(@"nowTalkingTextConversationMaking", nil);
            } else {
                self.nowTalkingLabel.text = NSLocalizedString(@"nowViewingAsParticipant", nil);
            }
        } else {
            [self.nowTalkingLabel setText:NSLocalizedString(@"nowTalkingTextViewer", nil)];
        }
    }
    conversation.parentConversations = [SortUtil sort:conversation.parentConversations
                                          byAttribute:@"participantNumber"
                                            ascending:NO];
    [self hideSecondParent];
    self.firstParentBox.hidden = YES;
    self.firstParentIntroduction.hidden = YES;
    if (conversation.parentConversations.count) {
        if (conversation.isActive) {
            if (conversation.parentConversations.count == 1) {
                ParentConversation *parentConversation = (ParentConversation *) [conversation.parentConversations firstObject];
                [self hideSecondParent];
                self.firstParentBox.hidden = NO;
                self.firstParentIntroduction.hidden = NO;
                self.firstParentHeadline.text = parentConversation.headline;
                if (parentConversation.participantNumber == -1) {
                    self.firstParentIntroduction.text = NSLocalizedString(@"haveYouSeenTheFeaturedConversation", nil);
                } else if (parentConversation.participantNumber == conversation.myParticipantNumber) {
                    self.firstParentIntroduction.text = NSLocalizedString(@"talkAboutTheConversationYouRecentlyRead", nil);
                } else {
                    self.firstParentIntroduction.text = NSLocalizedString(@"theOtherUserRecentlyReadThisFeaturedConversation", nil);
                }
            } else if (((ParentConversation *)[conversation.parentConversations firstObject]).conversationId == ((ParentConversation *)[conversation.parentConversations objectAtIndex:1]).conversationId) {
                ParentConversation *parentConversation = (ParentConversation *) [conversation.parentConversations firstObject];
                [self hideSecondParent];
                self.firstParentBox.hidden = NO;
                self.firstParentIntroduction.hidden = NO;
                self.firstParentHeadline.text = parentConversation.headline;
                self.firstParentIntroduction.text = NSLocalizedString(@"youBothRecentlyRead", nil);
            } else {
                ParentConversation *firstParentConversation = (ParentConversation *) [conversation.parentConversations firstObject];
                ParentConversation *secondParentConversation = (ParentConversation *) [conversation.parentConversations objectAtIndex:1];
                [self showSecondParent];
                self.firstParentBox.hidden = NO;
                self.firstParentIntroduction.hidden = NO;
                self.firstParentHeadline.text = firstParentConversation.headline;
                self.secondParentHeadline.text = secondParentConversation.headline;
                if (firstParentConversation.participantNumber == conversation.myParticipantNumber) {
                    self.firstParentIntroduction.text = NSLocalizedString(@"talkAboutTheConversationYouRecentlyRead", nil);
                    if (secondParentConversation.participantNumber == -1 || secondParentConversation.participantNumber == conversation.myParticipantNumber) {
                        self.secondParentIntroduction.text = NSLocalizedString(@"sinceTheyRecentlyTalkedAboutThis", nil);
                    } else {
                        self.secondParentIntroduction.text = NSLocalizedString(@"theOtherUserRecentlyReadThisFeaturedConversation", nil);
                    }
                } else {
                    self.firstParentIntroduction.text = NSLocalizedString(@"theOtherUserRecentlyReadThisFeaturedConversation", nil);
                    if (secondParentConversation.participantNumber == -1 || secondParentConversation.participantNumber != conversation.myParticipantNumber) {
                        self.secondParentIntroduction.text = NSLocalizedString(@"sinceYouRecentlyTalkedAboutThis", nil);
                    } else {
                        self.secondParentIntroduction.text = NSLocalizedString(@"talkAboutTheConversationYouRecentlyRead", nil);
                    }
                }
            }
        } else {
            if (conversation.parentConversations.count == 1 || (((ParentConversation *)[conversation.parentConversations firstObject]).conversationId == ((ParentConversation *)[conversation.parentConversations objectAtIndex:1]).conversationId)) {
                ParentConversation *parentConversation = (ParentConversation *) [conversation.parentConversations firstObject];
                [self hideSecondParent];
                self.firstParentBox.hidden = NO;
                self.firstParentIntroduction.hidden = NO;
                self.firstParentHeadline.text = parentConversation.headline;
                self.firstParentIntroduction.text = NSLocalizedString(@"featuredConversationTopic", nil);
            } else {
                ParentConversation *firstParentConversation = (ParentConversation *) [conversation.parentConversations firstObject];
                ParentConversation *secondParentConversation = (ParentConversation *) [conversation.parentConversations objectAtIndex:1];
                [self showSecondParent];
                self.firstParentBox.hidden = NO;
                self.firstParentIntroduction.hidden = NO;
                self.firstParentHeadline.text = firstParentConversation.headline;
                self.firstParentIntroduction.text = NSLocalizedString(@"featuredConversationTopic", nil);
                self.secondParentHeadline.text = secondParentConversation.headline;
                self.secondParentIntroduction.text = NSLocalizedString(@"anotherTopic", nil);
            }
        }
    }
}

- (void)hideSecondParent {
    self.secondParentBox.hidden = YES;
    self.secondParentIntroduction.hidden = YES;
    self.secondParentIntroduction.text = @"";
    self.secondParentHeadline.text = @"";
    for (NSLayoutConstraint *constraint in self.secondParentVerticalSpacingConstraints) {
        constraint.constant = 0;
    }
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)showSecondParent {
    self.secondParentBox.hidden = NO;
    self.secondParentIntroduction.hidden = NO;
    for (NSLayoutConstraint *constraint in self.secondParentVerticalSpacingConstraints) {
        constraint.constant = 8;
    }
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

#pragma mark - Setup Constraints

- (void)setupConstraints {
    [self.nowTalkingLabelVerticalSpacingConstraints addObject:[NSLayoutConstraint constraintWithItem:self.nowTalkingLabel
                                                                                           attribute:NSLayoutAttributeTop
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.contentView
                                                                                           attribute:NSLayoutAttributeTop
                                                                                          multiplier:1.0
                                                                                            constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.nowTalkingLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nowTalkingLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.firstParentIntroduction
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.firstParentIntroduction
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.nowTalkingLabelVerticalSpacingConstraints addObject:[NSLayoutConstraint constraintWithItem:self.firstParentIntroduction
                                                                                           attribute:NSLayoutAttributeTop
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.nowTalkingLabel
                                                                                           attribute:NSLayoutAttributeBottom
                                                                                          multiplier:1.0
                                                                                            constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.firstParentBox
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.firstParentChevron
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.firstParentHeadline
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.firstParentBox
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.firstParentChevron
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:self.firstParentHeadline
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.firstParentChevron
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.firstParentBox
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.firstParentHeadline
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.firstParentBox
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.firstParentBox
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.firstParentHeadline
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.firstParentBox
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.firstParentBox
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.firstParentBox
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.firstParentIntroduction
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.secondParentVerticalSpacingConstraints addObject:[NSLayoutConstraint constraintWithItem:self.secondParentIntroduction
                                                                                        attribute:NSLayoutAttributeTop
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.firstParentBox
                                                                                        attribute:NSLayoutAttributeBottom
                                                                                       multiplier:1.0
                                                                                         constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.secondParentIntroduction
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.secondParentIntroduction
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.secondParentBox
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.secondParentChevron
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.secondParentHeadline
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.secondParentBox
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.secondParentChevron
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:self.secondParentHeadline
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.secondParentChevron
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.secondParentBox
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    [self.secondParentVerticalSpacingConstraints addObject:[NSLayoutConstraint constraintWithItem:self.secondParentHeadline
                                                                                        attribute:NSLayoutAttributeTop
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.secondParentBox
                                                                                        attribute:NSLayoutAttributeTop
                                                                                       multiplier:1.0
                                                                                         constant:8]];
    [self.secondParentVerticalSpacingConstraints addObject:[NSLayoutConstraint constraintWithItem:self.secondParentBox
                                                                                        attribute:NSLayoutAttributeBottom
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.secondParentHeadline
                                                                                        attribute:NSLayoutAttributeBottom
                                                                                       multiplier:1.0
                                                                                         constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.secondParentBox
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.secondParentBox
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:16]];
    [self.secondParentVerticalSpacingConstraints addObject:[NSLayoutConstraint constraintWithItem:self.secondParentBox
                                                                                        attribute:NSLayoutAttributeTop
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.secondParentIntroduction
                                                                                        attribute:NSLayoutAttributeBottom
                                                                                       multiplier:1.0
                                                                                         constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.secondParentBox
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:8]];
    [self.contentView addConstraints:self.secondParentVerticalSpacingConstraints];
    [self.contentView addConstraints:self.nowTalkingLabelVerticalSpacingConstraints];
}

#pragma mark - Tapped Parent Conversations

- (void)firstParentTapped {
    self.conversation.parentConversations = [SortUtil sort:self.conversation.parentConversations
                                               byAttribute:@"participantNumber"
                                                 ascending:NO];
    [ParentConversationDetailsModal showModalWithParentConversation:[self.conversation.parentConversations firstObject]];
}

- (void)secondParentTapped {
    self.conversation.parentConversations = [SortUtil sort:self.conversation.parentConversations
                                               byAttribute:@"participantNumber"
                                                 ascending:NO];
    [ParentConversationDetailsModal showModalWithParentConversation:[self.conversation.parentConversations objectAtIndex:1]];
}

#pragma mark - Cell Height

+ (CGFloat)heightGivenConversation:(Conversation *)conversation {
    [self sizingCell].conversation = conversation;
    [[self sizingCell] setNeedsLayout];
    [[self sizingCell] layoutIfNeeded];
    CGSize size = [[self sizingCell].contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

@end