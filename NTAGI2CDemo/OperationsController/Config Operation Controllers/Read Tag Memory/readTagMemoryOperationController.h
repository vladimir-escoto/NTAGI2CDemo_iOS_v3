//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTAG_I2C_LIB.h"
#import "NtagUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface readTagMemoryOperationController: NSObject

+ (readTagMemoryOperationController *) sharedInstance;

/*!
@abstract  This method reads the tag's memory and provides the data read in a NSString  through the success caññback with the performance parameters.If the tag is protected, returns its status through the failure callback.
*/
- (void) readTagMemory:(void (^)(float timeInterval, int bytesLen, NSString * dataStr) )success  onFailure : (void(^)(AuthStatus status))failure;

/*!
@abstract  takes the data read from the tag's memory and returns a NSString to display it in the UI with the appropiate format
@param dataRead is the NSData containing the tag's memory content
*/
- (NSString *) getStringFromDataRead: (NSData *) dataRead;

@end

NS_ASSUME_NONNULL_END
