//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "NTAG_I2C_LIB.h"
@interface FlashUseCase : NSObject

+ (FlashUseCase *) sharedInstance;

/*!
@abstract  This method flashes the information to the tag and returns the response to the Flash view.
*/
- (void) Flash:(void (^)(int step, NSString * dataStr) )success  onFailure : (void(^)(NSString * status))failure bytesToFlash:(NSData *) bytesToFlash;

@end
