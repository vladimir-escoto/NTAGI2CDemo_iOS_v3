//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "AuthOperationController.h"

@implementation AuthOperationController: NSObject

char PWD1 [] = {0xFF, 0xFF, 0xFF, 0xFF};
char PWD2 [] = {0x55, 0x55, 0x55, 0x55};
char PWD3 [] = {0xAA, 0xAA, 0xAA, 0xAA};

#pragma mark - sharedInstance
+ ( AuthOperationController *) sharedInstance{
    static  AuthOperationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [[ AuthOperationController alloc] init]; });
    return sharedInstance;
}

#pragma mark - PWD auth
-(AuthStatus) pwdAuth: (Password) pwd authStatus: (AuthStatus *) authStatus onSuccess:(void (^)(NSString *protectionStatus))success  onFailure : (void (^)(void) )failure{
    
    __block AuthStatus status = authStatus;
    
    if( status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED){
        [self DoTagProtection:failure pwd:pwd success:success];
    } else {
        [self DoTagUnprotection:failure pwd:pwd success:success];
    }
    return status;
}

#pragma mark - get Protect Password Data
-(NSData *) getProtectPasswordData: (Password) pwd{
    char auth_cmd_bytes [4];
    if (pwd == PWD_SUN){
        auth_cmd_bytes[0] = PWD1[0];
        auth_cmd_bytes[1] = PWD1[1];
        auth_cmd_bytes[2] = PWD1[2];
        auth_cmd_bytes[3] = PWD1[3];
    }
    
    else if (pwd == PWD_STAR){
        auth_cmd_bytes[0] = PWD2[0];
        auth_cmd_bytes[1] = PWD2[1];
        auth_cmd_bytes[2] = PWD2[2];
        auth_cmd_bytes[3] = PWD2[3];
    }
    
    else if (pwd == PWD_MOON){
        auth_cmd_bytes[0] = PWD3[0];
        auth_cmd_bytes[1] = PWD3[1];
        auth_cmd_bytes[2] = PWD3[2];
        auth_cmd_bytes[3] = PWD3[3];
    }
    
    return [[NSData alloc]initWithBytes:auth_cmd_bytes length:sizeof(auth_cmd_bytes)];
}

#pragma mark - get Authenticate Password Data
-(NSData *) getAuthenticatePasswordData: (Password) pwd{
    char auth_cmd_bytes [5];
    auth_cmd_bytes[0] = 0x1B;
    if (pwd == PWD_SUN){
        auth_cmd_bytes[1] = PWD1[0];
        auth_cmd_bytes[2] = PWD1[1];
        auth_cmd_bytes[3] = PWD1[2];
        auth_cmd_bytes[4] = PWD1[3];
    }
    
    else if (pwd == PWD_STAR){
        auth_cmd_bytes[1] = PWD2[0];
        auth_cmd_bytes[2] = PWD2[1];
        auth_cmd_bytes[3] = PWD2[2];
        auth_cmd_bytes[4] = PWD2[3];
    }
    else if (pwd == PWD_MOON){
        auth_cmd_bytes[1] = PWD3[0];
        auth_cmd_bytes[2] = PWD3[1];
        auth_cmd_bytes[3] = PWD3[2];
        auth_cmd_bytes[4] = PWD3[3];
    }
    
    return [[NSData alloc]initWithBytes:auth_cmd_bytes length:sizeof(auth_cmd_bytes)];
}

#pragma mark - Do Tag Protection
- (void)DoTagProtection:(void (^ _Nonnull)(void))failure pwd:(Password)pwd success:(void (^ _Nonnull)(NSString *))success {
    // Proceed with the tag protection
    [[NTAG_I2C_LIB sharedInstance] protectPlus:[self getProtectPasswordData:pwd] startAddr:3 onSuccess:^(NSData *aData) {
        [[NTAG_I2C_LIB sharedInstance] closeWithCustomMessage:MSG_TAG_SUCCESS_PROTEC];
        success(MSG_TAG_PROTECTED);
    } onFailure:^(NSError *error) {
        failure();
    }];
}

#pragma mark - Do Tag Unprotection
- (void)DoTagUnprotection:(void (^ _Nonnull)(void))failure pwd:(Password)pwd success:(void (^ _Nonnull)(NSString *))success {
    // Proceed with the tag umprotection
    [[NTAG_I2C_LIB sharedInstance] sendMIFARECommand:[self getAuthenticatePasswordData:pwd] onSuccess:^(NSData *aData) {
        const char * respBytes = [aData bytes];
        if(aData.length == 2 && respBytes[0] == 0x00 && respBytes[1] == 0x00){
            [[NTAG_I2C_LIB sharedInstance] unprotectPlus:^(NSData *aData) {
                [[NTAG_I2C_LIB sharedInstance] closeWithCustomMessage:MSG_TAG_SUCCESS_UNPROTEC];
                success(MSG_TAG_UNPROTECTED);
            } onFailure:^(NSError *error) {
                failure();
            }];
        } else {
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_TAG_WRONGPASS];
            failure();
        }
    } onFailure:^(NSError *error) {
        failure();
    }];
}

@end
