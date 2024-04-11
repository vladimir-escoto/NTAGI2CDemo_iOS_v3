//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import <CoreNFC/CoreNFC.h>
#import "NSData+FastHex.h"
#import "NTAG_I2C_LIB.h"
@interface AboutUseCase : NSObject

+ (AboutUseCase *) sharedInstance;

/*!
@abstract  This method retreives the information for the about view.
*/
- (void) SetBoardVersion:(void (^)(NSData *aData, int type, NSString * str) )success  onFailure : (void(^)(AuthStatus status))failure;

@end
