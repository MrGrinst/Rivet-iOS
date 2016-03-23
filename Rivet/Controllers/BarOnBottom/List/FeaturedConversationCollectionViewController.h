#import <UIKit/UIKit.h>

NSString *const kCollectionType_global;
NSString *const kCollectionType_nearby;

@interface FeaturedConversationCollectionViewController : UIViewController<UINavigationControllerDelegate>

@property (strong, nonatomic) NSString *collectionType;

@end