#import <UIKit/UIKit.h>
#import "FeaturedConversationCollectionViewCell.h"

@interface BarOnBottomNavigationDelegate : NSObject<UINavigationControllerDelegate>

@property (nonatomic) CGRect               cardViewFrame;
@property (strong, nonatomic) UIImage     *picture;
@property (strong, nonatomic) NSString    *headline;
@property (strong, nonatomic) NSString    *desc;
@property (nonatomic) CGRect               cardPictureFrame;
@property (nonatomic) CGRect               cardHeadlineFrame;
@property (nonatomic) CGRect               cardDescriptionFrame;

@end