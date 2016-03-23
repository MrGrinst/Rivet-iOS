#import <Foundation/Foundation.h>
#import "UserState.h"

@interface NewUser : NSObject

@property (nonatomic) NSInteger          userId;
@property (strong, nonatomic) NSString  *authToken;
@property (strong, nonatomic) UserState *userState;

- (id)initWithDto:(NSDictionary *)dto;

@end