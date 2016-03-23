#import <UIKit/UIKit.h>
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "LocationUtil.h"
#import "NewUser.h"

@interface Authentication : NSObject

+ (BOOL)isUserLoggedIn;
+ (void)saveNewUser:(NewUser *)newUser;
+ (void)resetCredentials;

@end