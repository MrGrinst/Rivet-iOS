#import <Foundation/Foundation.h>

@interface QueuedRequest : NSObject

@property (nonatomic, copy) void (^requestBlock)(void);
@property (strong, nonatomic) NSString *requestUrl;

@end