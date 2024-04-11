//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ntag_Get_Version.h"
#import "NTAG_I2C_LIB.h"
#import "ResetOperationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RWConfigRegisters: NSObject

typedef enum ConfigPlusRegTypes
{
    AUTH0 = 0xE3,
    ACCESS = 0xE4,
    PTI2C = 0xE7
} ConfigPlusReg;

+ (RWConfigRegisters *) sharedInstance;

/*!
@abstract  This method reads the config registers and returns the response to the Read & Write Config Registers view.
*/
- (void) readConfigRegisters:(void (^)(NSDictionary * dictionary) )success  onFailure : (void(^)(AuthStatus status))failure;

/*!
@abstract  This method writes the config registers and returns the response to the Read & Write Config Registers view.
*/
- (void) writeConfigRegisters:(NSDictionary *) dataToWrite onSuccess: (void (^)(NSDictionary * dictionary) )success  onFailure : (void(^)(AuthStatus status))failure;

@end

NS_ASSUME_NONNULL_END
