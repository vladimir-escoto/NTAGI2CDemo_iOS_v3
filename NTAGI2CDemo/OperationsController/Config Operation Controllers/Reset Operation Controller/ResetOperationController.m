//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "ResetOperationController.h"

@implementation ResetOperationController: NSObject

#pragma mark - sharedInstance
+ (ResetOperationController *) sharedInstance{
    static ResetOperationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance                  = [[ResetOperationController alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Reset tag memory
- (void) resetTagMemory:(void (^)(float timeInterval, int bytesLen) )success  onFailure : (void(^)(AuthStatus status))failure{
    
    Prod product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
            
        [[NTAG_I2C_LIB sharedInstance] setAlertMessage:TXT_FORMATTING];

        __block float timeInterval;
        __block int bytesLen;

        NSTimeInterval start = CACurrentMediaTime();

        [self writeDeliveryNDEF:^(int len) {
            
            NSTimeInterval end = CACurrentMediaTime();
            timeInterval = 1000 * (end - start);
            bytesLen = len;
            
            // Set and write config registers
            Byte NC_REG = 0x01;
            Byte LD_Reg = 0x00;
            Byte SM_Reg = 0xF8;
            Byte WD_LS_Reg = 0x48;
            Byte WD_MS_Reg = 0x08;
            Byte I2C_CLOCK_STR = 0x01;
            
            [self writeConfigRegisters:NC_REG LD_R:LD_Reg SM_R:SM_Reg WD_LS_R:WD_LS_Reg WD_MS_R:WD_MS_Reg I2C_CLOCK_STR:I2C_CLOCK_STR onSuccess:^(NSData * _Nonnull aData) {
                
            } onFailure:^(NSError * _Nonnull error) {
                [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
            }];
            
            Prod product = [[NTAG_I2C_LIB sharedInstance] getProduct];
            
            if (product == NTAG_I2C_1K_PLUS || product == NTAG_I2C_2K_PLUS){
                Byte AUTH0 = 0xFF;
                Byte ACCESS = 0x00;
                Byte PT_I2C = 0x00;
                
                [self writeAuthRegisters:AUTH0 ACCESS:ACCESS PT_I2C:PT_I2C onSuccess:^(NSData * _Nonnull aData) {
                    [[NTAG_I2C_LIB sharedInstance] closeWithCustomMessage:TXT_RES_COMPLETE];
                    success(timeInterval, bytesLen);
                } onFailure:^(NSError * _Nonnull error) {
                    [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
                }];
            }
        } onFailure:^(NSError * _Nonnull error) {
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
        }];
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_AUTH_REQ];
        failure (status);
    }
}

#pragma mark - write Delivery NDEF
- (void) writeDeliveryNDEF:(void (^)(int len) )success  onFailure : (void(^)(NSError *error))failure{
    
    int index = 0;
    char dataBytes [4] = {0x00, 0x00, 0x00, 0x00};
    NSInteger blockNum;
    
    [[NTAG_I2C_LIB sharedInstance] SectorSelect:0 onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        
    }];
    
    Prod product = [[NTAG_I2C_LIB sharedInstance] getProduct];
    
    if(product == NTAG_I2C_1K_PLUS){
        // CC for NTAG 1K
        dataBytes[index++] = 0xE1;
        dataBytes[index++] = 0x10;
        dataBytes[index++] = 0x6D;
        dataBytes[index++] = 0x00;
    }
    else if(product == NTAG_I2C_1K_PLUS){
        // CC for NTAG 2K
        dataBytes[index++] = 0xE1;
        dataBytes[index++] = 0x10;
        dataBytes[index++] = 0xEA;
        dataBytes[index++] = 0x00;
    }
    
    // Convert CC bytes to NSData
    NSData * data = [NSData dataWithBytes:dataBytes length:sizeof(dataBytes)];

    // Write CC
    blockNum = 3;
    [[NTAG_I2C_LIB sharedInstance] write:&blockNum data:data onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
    }];
    
    // Check if CC are set correctly
    [[NTAG_I2C_LIB sharedInstance] read:&blockNum onSuccess:^(NSData *aData) {
        
        const char * respBytes = [aData bytes];
        const char * dataBytes = [data bytes];
        
        if(aData.length == 0){
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_RST];
        }
        
        if (!(respBytes[0] == dataBytes[0] && respBytes[1] == dataBytes[1]) && respBytes[2] == dataBytes[2] && respBytes[2] == dataBytes[3]){
            NSError * error = [[NSError alloc] initWithDomain:@"" code:0 userInfo:MSG_CAP_CON_WRONG];
            failure (error);
        }
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
    }];
    
    // Check static lock bits
    blockNum = 2;
    [[NTAG_I2C_LIB sharedInstance] read:2 onSuccess:^(NSData *aData) {
        
    const char * bytes = [aData bytes];

    if (!(bytes[2] == 0 && bytes[3] == 0)){
        NSError * error = [[NSError alloc] initWithDomain:@"" code:0 userInfo:@"Static Lock bits set, cannot reset" ];
        failure (error);
    }

    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
    }];

    // Add delay so previous operations are finished
    [NSThread sleepForTimeInterval:0.1f];
    
    // Check dynamic Lock bits
    int block = 0;
    
    if (product == NTAG_I2C_1K || product == NTAG_I2C_1K_PLUS || product  == NTAG_I2C_2K_PLUS)
        block = 0xE2;
    else if (product == NTAG_I2C_2K){
        block = 0xE0;
        [[NTAG_I2C_LIB sharedInstance] SectorSelect:1 onSuccess:^(NSData *aData) {
            
        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
        }];
    }
    
    if (block != 0){
        [[NTAG_I2C_LIB sharedInstance] read:block onSuccess:^(NSData *aData) {
            const char * bytes = [aData bytes];
            if (!(bytes[0] == 0 && bytes[1] == 0) && bytes[2] == 0){
                NSError * error = [[NSError alloc] initWithDomain:@"" code:0 userInfo:MSG_DYN_LOCK_BITS];
                failure (error);
            }

            } onFailure:^(NSError *error) {
                [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
        }];
    }
    
    // Write all zeros
    __block Ntag_Get_Version * version;
    
    [[NTAG_I2C_LIB sharedInstance] getVersion:^(NSData *aData) {
        version = [[Ntag_Get_Version alloc] initWithData:aData];
        NSData * data = [[NSMutableData alloc] initWithLength:[version getMemsize]];
        
        [[NTAG_I2C_LIB sharedInstance] writeEEPROM:data onSuccess:^(NSData *aData) {
            // Write default NDEF Message
            [[NTAG_I2C_LIB sharedInstance] writeDefaultNDEF:^(NSData *aData) {
                success([version getMemsize]);
            } onFailure:^(NSError *error) {
                 [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
            }];
        } onFailure:^(NSError *error) {
             [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
        }];
    } onFailure:^(NSError *error) {
         [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
    }];
}

#pragma mark - Write config registers
- (void) writeConfigRegisters: (Byte) NC_R LD_R: (Byte) LD_R SM_R: (Byte) SM_R WD_LS_R: (Byte) WD_LS_R WD_MS_R: (Byte) WD_MS_R I2C_CLOCK_STR: (Byte) I2C_CLOCK_STR onSuccess: (void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    
    char dataBytes [4];
    
    NSData * data;
    int sector;
    
    Prod product = [[NTAG_I2C_LIB sharedInstance] getProduct];

    if(product == NTAG_I2C_1K || product == NTAG_I2C_1K_PLUS || product == NTAG_I2C_2K_PLUS)
        sector = 0;
    else if (product == NTAG_I2C_2K)
        sector = 1;
    else{
        [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_FORMAT];
        return;
    }
    
    [[NTAG_I2C_LIB sharedInstance] SectorSelect:sector onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
         [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
    }];
    
    dataBytes[0] = NC_R;
    dataBytes[1] = LD_R;
    dataBytes[2] = SM_R;
    dataBytes[3] = WD_LS_R;
    data = [[NSData alloc] initWithBytes:dataBytes length:sizeof(dataBytes)];
    [[NTAG_I2C_LIB sharedInstance] write:0xE8 data:data onSuccess:^(NSData *aData) {
        int i = 0;
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    dataBytes[0] = WD_MS_R;
    dataBytes[1] = I2C_CLOCK_STR;
    dataBytes[2] = 0x00;
    dataBytes[3] = 0x00;
    data = [[NSData alloc] initWithBytes:dataBytes length:sizeof(dataBytes)];
    [[NTAG_I2C_LIB sharedInstance] write:(0xE8 + 1) data:data onSuccess:^(NSData *aData) {
        int a = 0;
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
}

#pragma mark - Write auth registers
- (void) writeAuthRegisters: (Byte) AUTH0 ACCESS: (Byte) ACCESS PT_I2C: (Byte) PT_I2C onSuccess:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    
    char dataBytes[4];
    NSData * data;

    [[NTAG_I2C_LIB sharedInstance] SectorSelect:0 onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    // Write ACCESS configuration
    dataBytes[0] = ACCESS;
    dataBytes[1] = 0x00;
    dataBytes[2] = 0x00;
    dataBytes[3] = 0x00;
    data = [[NSData alloc] initWithBytes:dataBytes length:sizeof(dataBytes)];
    [[NTAG_I2C_LIB sharedInstance] write:0xE4 data:data onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    // Write PT_I2C configuration
    dataBytes[0] = PT_I2C;
    dataBytes[1] = 0x00;
    dataBytes[2] = 0x00;
    dataBytes[3] = 0x00;
    data = [[NSData alloc] initWithBytes:dataBytes length:sizeof(dataBytes)];
    [[NTAG_I2C_LIB sharedInstance] write:0xE7 data:data onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    // set Passwords to FFs
    dataBytes[0] = 0xFF;
    dataBytes[1] = 0xFF;
    dataBytes[2] = 0xFF;
    dataBytes[3] = 0xFF;
    data = [[NSData alloc] initWithBytes:dataBytes length:sizeof(dataBytes)];
    [[NTAG_I2C_LIB sharedInstance] write:0xE5 data:data onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    // set pack to 00s
    dataBytes[0] = 0x00;
    dataBytes[1] = 0x00;
    dataBytes[2] = 0x00;
    dataBytes[3] = 0x00;
    data = [[NSData alloc] initWithBytes:dataBytes length:sizeof(dataBytes)];
    [[NTAG_I2C_LIB sharedInstance] write:0xE6 data:data onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    dataBytes[0] = 0x00;
    dataBytes[1] = 0x00;
    dataBytes[2] = 0x00;
    dataBytes[3] = AUTH0;
    data = [[NSData alloc] initWithBytes:dataBytes length:sizeof(dataBytes)];
    [[NTAG_I2C_LIB sharedInstance] write:0xE3 data:data onSuccess:^(NSData *aData) {
        success(aData);
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
}


@end
