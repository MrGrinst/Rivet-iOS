#import <Foundation/Foundation.h>

@interface SortUtil : NSObject

+ (NSArray *)sort:(NSArray *)array byAttribute:(NSString *)attribute ascending:(BOOL)ascending;

+ (NSArray *)sort:(NSArray *)array
      byAttribute:(NSString *)attribute1
        ascending:(BOOL)ascending1
  thenByAttribute:(NSString *)attribute2
        ascending:(BOOL)ascending2;

@end
