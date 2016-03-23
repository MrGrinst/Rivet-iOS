#import "NSDictionary+Rivet.h"

@implementation NSDictionary (Rivet)

- (id)objectOrNilForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([obj isEqual:[NSNull null]]) return nil;
    return obj;
}

- (NSInteger)intOrZeroForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([obj isEqual:[NSNull null]]) return 0;
    return ((NSNumber *)obj).intValue;
}

- (BOOL)boolForKey:(NSString *)key {
    return ((NSNumber *)[self objectForKey:key]).boolValue;
}

@end