//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTAG_I2C_LIB.h"
#import "Ntag_Get_Version.h"
NS_ASSUME_NONNULL_BEGIN

@interface readSessionRegistersOperationsController : NSObject

+ (readSessionRegistersOperationsController *) sharedInstance;

/*!
@abstract  This method reads the session Registers and provides via its success callback a NSDictionary with all its fields to be shown in the application UI. If the tag is protected, returns its status through the failure callback.
*/
- (void) readSessionRegisters:(void (^)(NSDictionary * dictionary) )success  onFailure : (void(^)(AuthStatus status))failure;

/*!
@abstract  Parses through the read data to build up the NSDictionary
*/
-(NSDictionary *) getSessionRegistersFromDataRead: (NSData *) dataRead;

@end


NS_ASSUME_NONNULL_END
