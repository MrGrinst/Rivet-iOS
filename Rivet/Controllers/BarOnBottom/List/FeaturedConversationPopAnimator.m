#import "FeaturedConversationPopAnimator.h"
#import "ConstUtil.h"
#import "OmniBar.h"
#import "UILabel+Rivet.h"
#import "UIColor+Rivet.h"
#import "FeaturedConversationHeaderCell.h"
#import "UIFont+Rivet.h"

NSTimeInterval const kDuration = 0.35;
static FeaturedConversationHeaderCell *_sizingCell;

@interface FeaturedConversationPopAnimator()

@property (strong, nonatomic) UIImageView *pictureView;
@property (strong, nonatomic) UILabel     *headlineLabel;
@property (strong, nonatomic) UILabel     *descriptionLabel;
@property (strong, nonatomic) UIView      *cardView;

@end

@implementation FeaturedConversationPopAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return kDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIView *toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    UIView *fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    UIView *featuredConversationView = self.presenting ? toView : [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    
    if (CGRectEqualToRect(self.cardViewFrame, CGRectZero)
        && CGRectEqualToRect(self.cardPictureFrame, CGRectZero)
        && CGRectEqualToRect(self.cardHeadlineFrame, CGRectZero)
        && CGRectEqualToRect(self.cardDescriptionFrame, CGRectZero)) {
        [containerView addSubview:toView];
        toView.alpha = 0;
        [UIView animateWithDuration:kDuration
                         animations:^{
                             toView.alpha = 1;
                             fromView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [containerView bringSubviewToFront:toView];
                             fromView.alpha = 1;
                             [transitionContext completeTransition:YES];
                         }];
    } else {
        CGRect featuredConversationViewFrame = featuredConversationView.frame;
        
//        if (self.presenting) {
//            featuredConversationViewFrame.size.height -= ([ConstUtil statusBarHeight] + kOmniBarHeight);
//        }
        
        if (CGRectEqualToRect(self.featuredPictureFrame, CGRectZero)
            && CGRectEqualToRect(self.featuredHeadlineFrame, CGRectZero)
            && CGRectEqualToRect(self.featuredDescriptionFrame, CGRectZero)) {
            
            CGFloat featuredPictureFrameHeight = self.picture.size.height / self.picture.size.width * [ConstUtil screenWidth];
            self.featuredPictureFrame = CGRectMake(0, 0, [ConstUtil screenWidth], featuredPictureFrameHeight);
            CGRect headlineRect = [self.headline boundingRectWithSize:CGSizeMake([ConstUtil screenWidth] - 16, 0)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName: [UIFont rivetExplantoryTextFontWithSize:20]}
                                                              context:nil];
            self.featuredHeadlineFrame = CGRectMake(8, self.featuredPictureFrame.origin.y + self.featuredPictureFrame.size.height + 8, [ConstUtil screenWidth] - 16, headlineRect.size.height);
            CGRect descriptionRect = [self.desc boundingRectWithSize:CGSizeMake([ConstUtil screenWidth] - 32, 0)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName: [UIFont rivetExplantoryTextFontWithSize:kDefaultFontSizeExplanatoryText]}
                                                              context:nil];
            self.featuredDescriptionFrame = CGRectMake(16, self.featuredHeadlineFrame.origin.y + self.featuredHeadlineFrame.size.height + 4, [ConstUtil screenWidth] - 32, descriptionRect.size.height);
        } else {
            self.featuredPictureFrame = CGRectOffset(self.featuredPictureFrame, 0, -[ConstUtil statusBarHeight]);
            self.featuredHeadlineFrame = CGRectOffset(self.featuredHeadlineFrame, 0, -[ConstUtil statusBarHeight]);
            self.featuredDescriptionFrame = CGRectOffset(self.featuredDescriptionFrame, 0, -[ConstUtil statusBarHeight]);
        }
        
        self.cardViewFrame = CGRectOffset(self.cardViewFrame, 0, -[ConstUtil statusBarHeight]);
        
        CGRect initialCardViewFrame = self.presenting ? self.cardViewFrame : featuredConversationViewFrame;
        CGRect finalCardViewFrame = !self.presenting ? self.cardViewFrame : featuredConversationViewFrame;
        
        CGRect initialPictureFrame = self.presenting ? self.cardPictureFrame : self.featuredPictureFrame;
        CGRect finalPictureFrame = !self.presenting ? self.cardPictureFrame : self.featuredPictureFrame;
        
        CGRect initialHeadlineFrame = self.presenting ? self.cardHeadlineFrame : self.featuredHeadlineFrame;
        CGRect finalHeadlineFrame = !self.presenting ? self.cardHeadlineFrame : self.featuredHeadlineFrame;
        
        CGRect initialDescriptionFrame = self.presenting ? self.cardDescriptionFrame : self.featuredDescriptionFrame;
        CGRect finalDescriptionFrame = !self.presenting ? self.cardDescriptionFrame : self.featuredDescriptionFrame;
        
        self.cardView.frame = initialCardViewFrame;
        self.pictureView.frame = initialPictureFrame;
        self.headlineLabel.frame = initialHeadlineFrame;
        self.descriptionLabel.frame = initialDescriptionFrame;
        
        if (!self.presenting) {
            [containerView addSubview:toView];
        }
        [containerView addSubview:self.cardView];
        [self.cardView addSubview:self.pictureView];
        [self.cardView addSubview:self.headlineLabel];
        [self.cardView addSubview:self.descriptionLabel];
        __weak FeaturedConversationPopAnimator *weakSelf = self;
        
        
        [UIView animateWithDuration:kDuration
                         animations:^{
                             weakSelf.cardView.frame = finalCardViewFrame;
                             weakSelf.pictureView.frame = finalPictureFrame;
                             weakSelf.headlineLabel.frame = finalHeadlineFrame;
                             weakSelf.descriptionLabel.frame = finalDescriptionFrame;
                             if (weakSelf.presenting)  {
                                 weakSelf.cardView.layer.cornerRadius = 0;
                             } else {
                                 weakSelf.cardView.layer.cornerRadius = 7;
                             }
                         }
                         completion:^(BOOL finished) {
                             if (weakSelf.presenting) {
                                 toView.alpha = 0;
                                 [containerView addSubview:toView];
                                 [UIView animateWithDuration:0.35
                                                  animations:^{
                                                      toView.alpha = 1;
                                                  }];
                             } else {
                                 [containerView bringSubviewToFront:toView];
                             }
                             [transitionContext completeTransition:YES];
                             weakSelf.cardView.transform = CGAffineTransformIdentity;
                             weakSelf.pictureView.transform = CGAffineTransformIdentity;
                             weakSelf.headlineLabel.transform = CGAffineTransformIdentity;
                             weakSelf.descriptionLabel.transform = CGAffineTransformIdentity;
                         }];
    }
}

#pragma mark - Getters

- (UIImageView *)pictureView {
    if (!_pictureView) {
        _pictureView = [[UIImageView alloc] init];
        _pictureView.image = self.picture;
        _pictureView.contentMode = UIViewContentModeScaleAspectFill;
        _pictureView.clipsToBounds = YES;
    }
    return _pictureView;
}

- (UILabel *)headlineLabel {
    if (!_headlineLabel) {
        _headlineLabel = [[UILabel alloc] init];
        [_headlineLabel setExplanatoryFontWithSize:20 withColor:[UIColor rivetLightBlue]];
        _headlineLabel.contentMode = UIViewContentModeCenter;
        _headlineLabel.textAlignment = NSTextAlignmentCenter;
        _headlineLabel.numberOfLines = 0;
        _headlineLabel.clipsToBounds = NO;
        _headlineLabel.text = self.headline;
    }
    return _headlineLabel;
}

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] init];
        [_descriptionLabel setExplanatoryFontWithDefaultFontSizeAndColor];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.contentMode = UIViewContentModeCenter;
        _descriptionLabel.text = self.desc;
        _descriptionLabel.clipsToBounds = NO;
    }
    return _descriptionLabel;
}

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [UIColor whiteColor];
        _cardView.clipsToBounds = YES;
    }
    return _cardView;
}

#pragma mark - Setters

- (void)setPicture:(UIImage *)picture {
    _picture = picture;
    self.pictureView.image = picture;
}

- (void)setHeadline:(NSString *)headline {
    _headline = headline;
    self.headlineLabel.text = headline;
    [self.headlineLabel sizeToFit];
}

- (void)setDesc:(NSString *)desc {
    _desc = desc;
    self.descriptionLabel.text = desc;
    [self.descriptionLabel sizeToFit];
}

#pragma mark - Sizing Cell

+ (FeaturedConversationHeaderCell *)sizingCell {
    if (!_sizingCell) {
        _sizingCell = [[FeaturedConversationHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                            reuseIdentifier:@"fake"];
    }
    return _sizingCell;
}

@end