#import <UIKit/UIKit.h>

@interface RivetAlertViewViewController : UIViewController

+ (void)showAlertViewWithMessage:(NSString *)message
                withPositiveText:(NSString *)positiveText
                      withTarget:(id)target
               withOnCloseAction:(SEL)selector;

+ (void)showAlertViewWithMessage:(NSString *)message
                withPositiveText:(NSString *)positiveText
                withNegativeText:(NSString *)negativeText
                      withTarget:(id)target
            withOnPositiveAction:(SEL)positiveSelector
            withOnNegativeAction:(SEL)negativeSelector;

@end
