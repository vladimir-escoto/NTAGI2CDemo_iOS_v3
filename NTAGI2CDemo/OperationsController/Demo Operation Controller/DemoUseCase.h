//  Copyright 2019 mobileknowledge. All rights reserved.
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

/*!
@abstract  This method performs the LED demo on the application from the Demo Tab
 @param isTempEnabled indicated wheter Temperature sensor  is enabled or not
 @param isLCDEnabled indicated wheter LCD is enabled or not
 @param isScrollEnabled indicated wheter NDEF Message is enabled or not
 @param LedStr indicated the LED color to start the demo with
*/
- (void) LEDDemo:(bool) isTempEnabled isLCDEnabled: (bool) isLCDEnabled isScrollEnabled: (bool) isScrollEnabled LedStr: (NSString *) LedStr onSuccess: (void (^)(NSString *str1, NSString *str2, NSString *str3, NSData *buttonStatus)) success  onFailure : (void(^)(AuthStatus status))failure;

@end
