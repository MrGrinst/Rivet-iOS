#import <Foundation/Foundation.h>

@interface DateUtil : NSObject

+ (NSDate *)dateFromServerString:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)prettyStringFromDate:(NSDate *)date;
+ (NSString *)timeAgoWithDate:(NSDate *)startDate sinceDate:(NSDate *)date;

@end