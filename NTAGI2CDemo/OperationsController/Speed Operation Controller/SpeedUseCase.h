//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import <CoreNFC/CoreNFC.h>
#import "NSData+FastHex.h"
#import "Ntag_Get_Version.h"
#import "NTAG_I2C_LIB.h"
#import "Message.h"
@interface SpeedUseCase : NSObject

+ (SpeedUseCase *) sharedInstance;

typedef enum ResponseTypes
{
    UpdateAnswer,
    PreExecutionDone,
    DatarateAnswer,
    Continue,
    MessagePrint,
    ErrorPrint
} resTypes;

/*!
@abstract  This method performs the EEPROM demo on the application from the Speed Tab
 @param blockMulti the block multiplier
*/
- (void) EEPROMDemo:(NSString *) blockMulti onSuccess: (void (^)(NSString *str)) success  onFailure : (void(^)(AuthStatus status))failure;

/*!
@abstract  This method performs the SRAM demo on the application from the Speed Tab
 @param blockMulti the block multiplier
*/
- (void) SRAMDemo:(NSString *) blockMulti onSuccess: (void (^)(NSString *str)) success  onFailure : (void(^)(AuthStatus status))failure;

@end
