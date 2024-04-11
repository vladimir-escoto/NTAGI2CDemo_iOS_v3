//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTAG_I2C_LIB.h"

NS_ASSUME_NONNULL_BEGIN

@interface ResetOperationController: NSObject

+ (ResetOperationController *) sharedInstance;

/*!
@abstract  This method resets the tag's memory content to its default state by writing the tag memory and the configuration and auth registers. If the tag is protected, returns its status through the failure callback.
*/
- (void) resetTagMemory:(void (^)(float timeInterval, int bytesLen) )success  onFailure : (void(^)(AuthStatus status))failure;

/*!
@abstract  Writes the configuration tag memory to its default state for the Reset State
*/
- (void) writeDeliveryNDEF:(void (^)(int len) )success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  Writes the configuration registers of the tag to their default state for the Reset State
*/
- (void) writeConfigRegisters: (Byte) NC_R LD_R: (Byte) LD_R SM_R: (Byte) SM_R WD_LS_R: (Byte) WD_LS_R WD_MS_R: (Byte) WD_MS_R I2C_CLOCK_STR: (Byte) I2C_CLOCK_STR onSuccess: (void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  Writes the Authentication registers of the tag to their default state for the Reset State
*/
- (void) writeAuthRegisters: (Byte) AUTH0 ACCESS: (Byte) ACCESS PT_I2C: (Byte) PT_I2C onSuccess:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
