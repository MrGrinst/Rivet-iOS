#import "DateUtil.h"

@implementation DateUtil

+ (NSDate *)dateFromServerString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    return [dateFormatter dateFromString:string];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)prettyStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yy"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)timeAgoWithDate:(NSDate *)startDate sinceDate:(NSDate *)date {
    double seconds = fabs([startDate timeIntervalSinceDate:date]);
    double minutes = seconds / 60;
    double hours = minutes / 60;
    double days = hours / 24;
    double weeks = days / 7;
    double months = days / 30;
    double years = days / 365;

    if (seconds < 45) {
        return [NSString stringWithFormat:NSLocalizedString(@"secondsAgo", nil), seconds];
    } else if (minutes < 45) {
        return [NSString stringWithFormat:NSLocalizedString(@"minutesAgo", nil), minutes];
    } else if (minutes < 90) {
        return NSLocalizedString(@"oneHourAgo", nil);
    } else if (hours < 24) {
        return [NSString stringWithFormat:NSLocalizedString(@"hoursAgo", nil), hours];
    } else if (hours < 42) {
        return NSLocalizedString(@"oneDayAgo", nil);
    } else if (days < 6) {
        return [NSString stringWithFormat:NSLocalizedString(@"daysAgo", nil), days];
    } else if (days < 10) {
        return NSLocalizedString(@"oneWeekAgo", nil);
    } else if (months < 6) {
        return [NSString stringWithFormat:NSLocalizedString(@"weeksAgo", nil), weeks];
    } else if (months < 18) {
        return NSLocalizedString(@"oneYearAgo", nil);
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"yearsAgo", nil), years];
    }
}

@end