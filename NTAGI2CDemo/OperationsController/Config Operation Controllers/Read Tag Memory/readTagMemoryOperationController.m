//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "readTagMemoryOperationController.h"

@implementation readTagMemoryOperationController: NSObject

#pragma mark - sharedInstance
+ (readTagMemoryOperationController *) sharedInstance{
    static readTagMemoryOperationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance                  = [[readTagMemoryOperationController alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Read tag memory
- (void) readTagMemory:(void (^)(float timeInterval, int bytesLen, NSString * dataStr) )success  onFailure : (void(^)(AuthStatus status))failure{
    __block Prod product;
    __block Ntag_Get_Version * version;
    
    product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        
        [[NTAG_I2C_LIB sharedInstance] setAlertMessage:TXT_READING_INFO];

        [[NTAG_I2C_LIB sharedInstance] getVersion:^(NSData *aData) {
            version = [[Ntag_Get_Version alloc] initWithData:aData];
            
            int absStart = 0;
            int absEnd = ([version getMemsize] + 16) / 4;
            __block float timeInterval;
            __block int bytesLen;
            
            NSTimeInterval start = CACurrentMediaTime();

            [[NTAG_I2C_LIB sharedInstance] readEEPROM:absStart absEnd:absEnd onSuccess:^(NSData *aData) {
                // Compute performance paramenters
                NSTimeInterval end = CACurrentMediaTime();
                timeInterval = 1000 * (end - start);
                bytesLen = aData.length;
                
                // Get formatted NSString from the NSData read
                NSString * dataStr = [self getStringFromDataRead:aData];
                success(timeInterval, bytesLen, dataStr);
                
                [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {
                } onFailure:^(NSError *error) {
                    [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
                    return;
                }];
            } onFailure:^(NSError *error) {
                [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
                return;
            }];
        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
            return;
        }];
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_AUTH_REQ];
        failure (status);
    }
}

#pragma mark - Get string from data read
- (NSString *) getStringFromDataRead: (NSData *) dataRead{
    
    NSMutableString * str  = [[NSMutableString alloc] init];
    
    NSString * line;
    NSString * hexIndex    = @"";
    NSString * hexValues   = @"";
    NSString * asciiValues = @"";
    
    int blockNr = 0;
    
    for (int i = 0; i < dataRead.length; i += 4){
        
        if (blockNr == 0xE2)
            blockNr = 0x100;
        
        // Get block number in hex
        hexIndex = [NSString stringWithFormat:@"%03X", blockNr];
        
        // Get hex value of bytes
        hexValues = [NtagUtils convertNSDataBytesToHexString:[dataRead subdataWithRange:NSMakeRange(i, 4)]];
        
        // Add separation
        NSString * firstByte  = [hexValues substringWithRange:NSMakeRange(0, 2)];
        NSString * secondByte = [hexValues substringWithRange:NSMakeRange(2, 2)];
        NSString * thirdByte  = [hexValues substringWithRange:NSMakeRange(4, 2)];
        NSString * fourthByte = [hexValues substringWithRange:NSMakeRange(6, 2)];

        hexValues = [NSString stringWithFormat:@"%@:%@:%@:%@",firstByte, secondByte, thirdByte, fourthByte];
        
        UInt8 *bytes = (UInt8 *)[dataRead subdataWithRange:(NSRange){i,4}].bytes;
        
        for (int i = 0; i < 4; i++){
            if (bytes[i] < 0x20 || bytes[i] > 0x70)
                bytes[i] = '.';
        }
        
        // Get ascii value of bytes
        asciiValues = [[NSString alloc]initWithBytes:bytes length:sizeof(bytes) encoding:NSASCIIStringEncoding];
        
        // Get line format
        if (blockNr > 3)
            line = [NSString stringWithFormat:@"[%@] %@ |%@|\n",hexIndex, hexValues, asciiValues];
        else
            line = [NSString stringWithFormat:@"[%@] %@ \n",hexIndex, hexValues];
        
        // Append line to str
        [str appendString:line];
        blockNr ++;
    }
    return str;
}

@end
