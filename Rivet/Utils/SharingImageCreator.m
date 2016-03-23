#import "SharingImageCreator.h"
#import "UIFont+Rivet.h"
#import "UIColor+Rivet.h"

@implementation SharingImageCreator

+ (UIImage *)createImageFromDescription:(NSString *)description headline:(NSString *)headline isFeatured:(BOOL)isFeatured {
    if (isFeatured) {
        int topOfDrawableArea = 212;
        int totalHeightOfDrawableArea = 228;
        int maxTextWidth = 740;
        int maxHeadlineWidth = 520;
        int totalHeightOfDrawnContent = 0;
        NSData *baseImageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SharingImageFeatured" ofType:@"png"]];
        UIImage *startImage = [[UIImage imageWithData:baseImageData] resizableImageWithCapInsets:UIEdgeInsetsMake(418, 0, 83, 0)];
        int totalHeightNeededForImage = startImage.size.height;
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        UIFont *font = [UIFont rivetUserContentFontWithSize:34];
        NSMutableDictionary *textAttributes = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: [UIColor rivetLightBlue]}.mutableCopy;
        CGSize descriptionSize = [description boundingRectWithSize:CGSizeMake(maxTextWidth, 0)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:textAttributes
                                                             context:nil].size;
        totalHeightNeededForImage += descriptionSize.height;
        totalHeightOfDrawableArea += descriptionSize.height;
        totalHeightOfDrawnContent += descriptionSize.height;
        UIGraphicsBeginImageContext(CGSizeMake(startImage.size.width, totalHeightNeededForImage));
        [startImage drawInRect:CGRectMake(0, 0, startImage.size.width, totalHeightNeededForImage)];
        CGRect descriptionTextRect = CGRectMake((startImage.size.width - descriptionSize.width)/2.0, topOfDrawableArea + (totalHeightOfDrawableArea - totalHeightOfDrawnContent)/2.0, descriptionSize.width, descriptionSize.height);
        [textAttributes setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
        [textAttributes setObject:[UIFont rivetBoldUserContentFontWithSize:34] forKey:NSFontAttributeName];
        CGSize headlineSize = [headline boundingRectWithSize:CGSizeMake(maxHeadlineWidth, 0)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:textAttributes
                                                     context:nil].size;
        CGRect headlineTextRect = CGRectMake((startImage.size.width - headlineSize.width)/2.0, (descriptionTextRect.origin.y - topOfDrawableArea - headlineSize.height)/2.0 + topOfDrawableArea, headlineSize.width, headlineSize.height);
        [headline drawWithRect:CGRectIntegral(headlineTextRect)
                       options:NSStringDrawingUsesLineFragmentOrigin
                    attributes:textAttributes
                       context:nil];
        [textAttributes setObject:[UIColor rivetOffBlack] forKey:NSForegroundColorAttributeName];
        [textAttributes removeObjectForKey:NSUnderlineStyleAttributeName];
        [textAttributes setObject:[UIFont rivetUserContentFontWithSize:34] forKey:NSFontAttributeName];
        [description drawWithRect:CGRectIntegral(descriptionTextRect)
                             options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:textAttributes
                             context:nil];
        UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return output;
    } else {
        int topOfDrawableArea = 212;
        int totalHeightOfDrawableArea = 228;
        int maxTextWidth = 740;
        int totalHeightOfDrawnContent = 0;
        NSData *baseImageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SharingImage" ofType:@"png"]];
        UIImage *startImage = [[UIImage imageWithData:baseImageData] resizableImageWithCapInsets:UIEdgeInsetsMake(418, 0, 83, 0)];
        int totalHeightNeededForImage = startImage.size.height;
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        UIFont *font = [UIFont rivetUserContentFontWithSize:36];
        NSMutableDictionary *textAttributes = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: [UIColor rivetDarkBlue]}.mutableCopy;
        CGSize descriptionSize = [description boundingRectWithSize:CGSizeMake(maxTextWidth, 0)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:textAttributes
                                                             context:nil].size;
        totalHeightNeededForImage += descriptionSize.height;
        totalHeightOfDrawableArea += descriptionSize.height;
        totalHeightOfDrawnContent += descriptionSize.height;
        UIGraphicsBeginImageContext(CGSizeMake(startImage.size.width, totalHeightNeededForImage));
        [startImage drawInRect:CGRectMake(0, 0, startImage.size.width, totalHeightNeededForImage)];
        CGRect descriptionTextRect = CGRectMake((startImage.size.width - descriptionSize.width)/2.0, topOfDrawableArea + (totalHeightOfDrawableArea - totalHeightOfDrawnContent)/2.0, descriptionSize.width, descriptionSize.height);
        [description drawWithRect:CGRectIntegral(descriptionTextRect)
                             options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:textAttributes
                             context:nil];
        UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return output;
    }
}

@end