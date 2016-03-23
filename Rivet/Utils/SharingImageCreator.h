#import <UIKit/UIKit.h>

@interface SharingImageCreator : NSObject

+ (UIImage *)createImageFromDescription:(NSString *)description headline:(NSString *)headline isFeatured:(BOOL)isFeatured;

@end