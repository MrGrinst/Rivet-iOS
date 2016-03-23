#import "IOS8-3SpecificEmojis.h"

static NSArray *_ios83SpecificEmojis;

@implementation IOS8_3SpecificEmojis

+ (NSArray *)ios83SpecificEmojis {
    if (!_ios83SpecificEmojis) {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ios83specificemojis" ofType:@"txt"];
        NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
        for (NSString *string in lines) {
            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            NSString *convertedString = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            [temp addObject:convertedString];
        }
        _ios83SpecificEmojis = temp;
    }
    return _ios83SpecificEmojis;
}

@end