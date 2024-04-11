//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTAG_I2C_LIB.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum PasswordTypes
{
    PWD_SUN,
    PWD_STAR,
    PWD_MOON
} Password;

@interface AuthOperationController: NSObject

/*!
@abstract  This method handles the authentication functionalities of the tag by protecting it or unprotecting it depending on its AuthStatus
 @param pwd is the chosen password to set or authenticate with
 @param authStatus is the status of the tag regarding its protection
*/
-(AuthStatus) pwdAuth: (Password) pwd authStatus: (AuthStatus *) authStatus onSuccess:(void (^)(NSString *protectionStatus))success  onFailure : (void (^)(void) )failure;

@end

NS_ASSUME_NONNULL_END
