#import "NewUser.h"
#import "NSDictionary+Rivet.h"

NSString *const kNewUserAttribute_userId = @"app_user_id";
NSString *const kNewUserAttribute_authToken = @"auth_token";
NSString *const kNewUserAttribute_userState = @"user_state";

@implementation NewUser

- (id)initWithDto:(NSDictionary *)dto {
    if (self = [super init]) {
        self.userId = [dto intOrZeroForKey:kNewUserAttribute_userId];
        self.authToken = [dto objectOrNilForKey:kNewUserAttribute_authToken];
        self.userState = [[UserState alloc] initWithDto:[dto objectOrNilForKey:kNewUserAttribute_userState]];
    }
    return self;
}

@end