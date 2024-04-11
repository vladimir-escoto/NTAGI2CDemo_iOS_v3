//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTAG_I2C_LIB.h"
#import "Message.h"
#import "UriRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface NDEFOperationController: NSObject

+ ( NDEFOperationController *) sharedInstance;

/*!
@abstract  This method performs the read of the NDEF Message
*/
- (void) readNDEFMessage: (void (^)(Message *message)) success  onFailure : (void(^)(AuthStatus status))failure;

/*!
@abstract  This method performs the write of an NDEF Message
 @param NFCNDEFMessage the ndef message
*/
- (void) writeNDEF: (NFCNDEFMessage *) NFCNDEFMessage onSuccess:(void (^)(Message *message))success  onFailure : (void(^)(AuthStatus status))failure;

/*!
@abstract  This method performs thewritre of the default NDEF Message
*/
- (void) writeDefaultNDEF:(void (^)(float timeInterval, int bytesLen) )success onFailure : (void(^)(AuthStatus status))failure;

@end

NS_ASSUME_NONNULL_END
