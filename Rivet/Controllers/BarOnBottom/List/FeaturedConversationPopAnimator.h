#import <UIKit/UIKit.h>

@interface FeaturedConversationPopAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic) CGRect               cardViewFrame;
@property (nonatomic) BOOL                 presenting;
@property (strong, nonatomic) UIImage     *picture;
@property (strong, nonatomic) NSString    *headline;
@property (strong, nonatomic) NSString    *desc;
@property (nonatomic) CGRect               cardPictureFrame;
@property (nonatomic) CGRect               cardHeadlineFrame;
@property (nonatomic) CGRect               cardDescriptionFrame;
@property (nonatomic) CGRect               featuredPictureFrame;
@property (nonatomic) CGRect               featuredHeadlineFrame;
@property (nonatomic) CGRect               featuredDescriptionFrame;

@end