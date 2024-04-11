//
//  DemoOperationController.h
//  NTAGI2C_Demo
//
//  Created by MK Develop on 04/10/2019.
//  Copyright © 2019 MK Develop. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Ntag_Get_Version.h"
#import "NTAG_I2C_LIB.h"

@interface DemoUseCase : NSObject

+ (DemoUseCase *) sharedInstance;

typedef enum TransferDirTypes
{
    DEVICE_TO_TAG = 1,
    TAG_TO_DEVICE = 2,
    NO_TRANSFER = 0,
    INVALID_TRANSFER = 4
} TransferDir;

- (void) LESDemo:(bool) isTempEnabled isLCDEnabled: (bool) isLCDEnabled isScrollEnabled: (bool) isScrollEnabled LedStr: (NSString *) LedStr onSuccess: (void (^)(NSString *str1, NSString *str2, NSString *str3, NSData *buttonStatus)) success  onFailure : (void(^)(AuthStatus status))failure;

@end
