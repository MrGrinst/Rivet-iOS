#import "UserState.h"
#import "NSDictionary+Rivet.h"

NSString *const kUserStateAttribute_isNearbyEligible = @"is_nearby_eligible";

@implementation UserState

- (instancetype)initWithDto:(NSDictionary *)dto {
    if (self = [super init]) {
        self.isNearbyEligible = [dto boolForKey: kUserStateAttribute_isNearbyEligible];
    }
    return self;
}

//Coder

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.isNearbyEligible = [decoder decodeBoolForKey:kUserStateAttribute_isNearbyEligible];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.isNearbyEligible forKey:kUserStateAttribute_isNearbyEligible];
}

@end