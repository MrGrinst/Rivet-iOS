#import "CustomFadeInSegue.h"

@implementation CustomFadeInSegue

- (void)perform {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.35;
    transition.type = kCATransitionFade;
    [((UIViewController *)self.sourceViewController).navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [((UIViewController *)self.sourceViewController).navigationController pushViewController:self.destinationViewController animated:NO];
}

@end