#import <Foundation/Foundation.h>

@interface UserState : NSObject

@property (nonatomic) BOOL isNearbyEligible;

- (instancetype)initWithDto:(NSDictionary *)dto;

@end