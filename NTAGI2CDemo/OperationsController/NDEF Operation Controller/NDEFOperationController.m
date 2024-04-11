//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "NDEFOperationController.h"

@implementation NDEFOperationController: NSObject

#pragma mark - sharedInstance
+ ( NDEFOperationController *) sharedInstance{
    static  NDEFOperationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [[NDEFOperationController alloc] init]; });
    return sharedInstance;
}

#pragma mark - read NDEF
- (void) readNDEFMessage: (void (^)(Message *message)) success  onFailure : (void(^)(AuthStatus status))failure{
    
    Prod product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        
        [[NTAG_I2C_LIB sharedInstance] setAlertMessage:TXT_READING_NDEF];

        NSTimeInterval start = CACurrentMediaTime();
        
        [[NTAG_I2C_LIB sharedInstance] readNDEF:^(NFCNDEFMessage *NFCNDEFMessage) {
            NSTimeInterval end = CACurrentMediaTime();
            NSTimeInterval time_interval = 1000 * (end - start);
            
            Message * message = [[Message alloc] initWithNDEFMessage:NFCNDEFMessage];
            
            int len = NFCNDEFMessage.length;
            
            [message setLen:&len];
            [message setTimeInterval:&time_interval];
            
            success(message);
    
            [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {
                
            } onFailure:^(NSError *error) {
                [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];
            }];
            
        } onFailure:^(NSError *error) {
            failure(status);
        }];
        
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_AUTH_REQ];
        failure (status);
    }
}

#pragma mark - write NDEF
- (void) writeNDEF: (NFCNDEFMessage *) NFCNDEFMessage onSuccess:(void (^)(Message *message))success  onFailure : (void(^)(AuthStatus status))failure{
    
    Prod product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        
        [[NTAG_I2C_LIB sharedInstance] setAlertMessage:TXT_WRITING_NDEF];

        NSTimeInterval start = CACurrentMediaTime();
        
        [[NTAG_I2C_LIB sharedInstance] writeNDEF:NFCNDEFMessage onSuccess:^{
            NSTimeInterval end = CACurrentMediaTime();
            
            NSTimeInterval time_interval = 1000 * (end - start);
            
            int len = NFCNDEFMessage.length;
            
            Message * message = [[Message alloc] initWithNDEFMessage:NFCNDEFMessage];
            
            [message setLen:&len];
            [message setTimeInterval:&time_interval];
            
            success(message);
            
            [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
            
        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];
        }];
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_AUTH_REQ];
        failure (status);
    }
}

#pragma mark - write default NDEF
- (void) writeDefaultNDEF:(void (^)(float timeInterval, int bytesLen) )success onFailure : (void(^)(AuthStatus status))failure{
    
    Prod product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        
        [[NTAG_I2C_LIB sharedInstance] setAlertMessage:TXT_WRITING_NDEF];
        
        NSTimeInterval start = CACurrentMediaTime();
        
        [[NTAG_I2C_LIB sharedInstance] writeDefaultNDEF:^(NSData *aData) {
            NSTimeInterval end = CACurrentMediaTime();
            float timeInterval = 1000 * (end - start);
            int bytesLen = 95; // Number of bytes written in default NDEF
            
            success(timeInterval, bytesLen);
            
            [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
            
        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];
        }];
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_AUTH_REQ];
        failure (status);
    }
}

@end
