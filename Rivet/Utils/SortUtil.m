#import "SortUtil.h"

@implementation SortUtil

+ (NSArray *)sort:(NSArray *)array byAttribute:(NSString *)attribute ascending:(BOOL)ascending {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:ascending];
    NSArray *descriptors = [NSArray arrayWithObject: descriptor];
    return [array sortedArrayUsingDescriptors:descriptors];
}

+ (NSArray *)sort:(NSArray *)array
      byAttribute:(NSString *)attribute1
        ascending:(BOOL)ascending1
  thenByAttribute:(NSString *)attribute2
        ascending:(BOOL)ascending2 {
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:attribute1 ascending:ascending1];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:attribute2 ascending:ascending2];
    NSArray *descriptors = [NSArray arrayWithObjects: descriptor1, descriptor2, nil];
    return [array sortedArrayUsingDescriptors:descriptors];
}

@end
