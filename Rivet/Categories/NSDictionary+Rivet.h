#import <Foundation/Foundation.h>

@interface NSDictionary (Rivet)

- (id)objectOrNilForKey:(NSString *)key;
- (NSInteger)intOrZeroForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

@end