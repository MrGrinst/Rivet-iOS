#import "BarOnBottomNavigationDelegate.h"
#import "ListContainerViewController.h"
#import "FeaturedConversationViewingViewController.h"
#import "FeaturedConversationPopAnimator.h"

@interface BarOnBottomNavigationDelegate()

@property (strong, nonatomic) FeaturedConversationPopAnimator *transition;

@end

@implementation BarOnBottomNavigationDelegate

#pragma mark - Getters

- (FeaturedConversationPopAnimator *)transition {
    if (!_transition) {
        _transition = [[FeaturedConversationPopAnimator alloc] init];
    }
    return _transition;
}

#pragma mark - Transition Delegates

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    self.transition.cardViewFrame = self.cardViewFrame;
    self.transition.cardPictureFrame = self.cardPictureFrame;
    self.transition.cardHeadlineFrame = self.cardHeadlineFrame;
    self.transition.cardDescriptionFrame = self.cardDescriptionFrame;
    self.transition.picture = self.picture;
    self.transition.headline = self.headline;
    self.transition.desc = self.desc;
    if ([fromVC isKindOfClass:[ListContainerViewController class]] && [toVC isKindOfClass:[FeaturedConversationViewingViewController class]]) {
        FeaturedConversationViewingViewController *fvc = (FeaturedConversationViewingViewController *) toVC;
        self.transition.featuredPictureFrame = [fvc pictureFrame];
        self.transition.featuredHeadlineFrame = [fvc headlineFrame];
        self.transition.featuredDescriptionFrame = [fvc descriptionFrame];
        self.transition.presenting = YES;
        return self.transition;
    } else if ([fromVC isKindOfClass:[FeaturedConversationViewingViewController class]] && [toVC isKindOfClass:[ListContainerViewController class]]) {
        FeaturedConversationViewingViewController *fvc = (FeaturedConversationViewingViewController *) fromVC;
        self.transition.featuredPictureFrame = [fvc pictureFrame];
        self.transition.featuredHeadlineFrame = [fvc headlineFrame];
        self.transition.featuredDescriptionFrame = [fvc descriptionFrame];
        self.transition.presenting = NO;
        return self.transition;
    }
    return nil;
}

@end