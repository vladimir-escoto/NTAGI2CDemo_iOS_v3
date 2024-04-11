//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "AboutUseCase.h"

@interface AboutUseCase ()
@end

@implementation AboutUseCase

#pragma mark - sharedInstance
+ (AboutUseCase *) sharedInstance{
    static AboutUseCase *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance                  = [[AboutUseCase alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - set board version
- (void) SetBoardVersion:(void (^)(NSData *aData, int type, NSString * str) )success  onFailure : (void(^)(AuthStatus status))failure{
    Prod product      = [[NTAG_I2C_LIB sharedInstance] getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        [[NTAG_I2C_LIB sharedInstance] setAlertMessage:TXT_READING_INFO];
        
        int SRAMSize = [[NTAG_I2C_LIB sharedInstance] getSRAMSize];
        
        NSMutableData * dataTX = [[NSMutableData alloc] initWithLength:SRAMSize];
        
        [dataTX replaceBytesInRange:NSMakeRange(SRAMSize - 4, 1) withBytes: [[@"V" dataUsingEncoding: NSASCIIStringEncoding] bytes] ];
        
        //Write to SRAM
        [[NTAG_I2C_LIB sharedInstance] WriteSRAM: dataTX onSuccess:^(NSData *aData) {

            [[NTAG_I2C_LIB sharedInstance] readSRAMBlock:^(NSData *aData) {

                if(aData.length == 0){
                    [[NTAG_I2C_LIB sharedInstance] customErrorMessage:TXT_NO_BOARD_ATTACHED];
                    return;
                }

                unsigned char *auth0Bytes = (unsigned char *)[aData bytes];

                NSString * boardVersion   = @"";
                NSString * boardFWVersion = @"";

                // Check if Data was send, else it is a ExplorerBoard FW
                if ( auth0Bytes[DATA_SEND_BYTE] == 0) {
                    int value1 = ((auth0Bytes[VERSION_BYTE]  >> LAST_FOUR_BYTES) & 0x0F);
                    int value2 = (auth0Bytes[VERSION_BYTE] &  0x0F);

                    NSString * version = [self hexFromInt:value1];
                    [NSString stringWithFormat: @"%@%@%@", version, @".", [self hexFromInt:value2]];

                    boardVersion = version;
                    boardFWVersion = version;
                    
                } else {
                    for (int i = 0 ; i < THREE_BYTES; i++){
                        boardVersion = [NSString stringWithFormat: @"%@%@", boardVersion, [self hexFromInt:auth0Bytes[GET_VERSION_NR + i]]];
                    }

                    for (int i = 0 ; i < THREE_BYTES; i++){
                        boardFWVersion = [NSString stringWithFormat: @"%@%@", boardFWVersion, [self hexFromInt:auth0Bytes[GET_FW_NR + i]]];
                    }
                }

                boardVersion   = [boardVersion stringByReplacingOccurrencesOfString:@"0x" withString:@""];
                boardFWVersion = [boardFWVersion stringByReplacingOccurrencesOfString:@"0x" withString:@""];

                boardVersion   = [self hexToString:boardVersion];
                boardFWVersion = [self hexToString:boardFWVersion];

                boardVersion   = [NSString stringWithFormat: @"Board Version: %@", boardVersion];
                boardFWVersion = [NSString stringWithFormat: @"Board FW Version: %@", boardFWVersion];

                success(nil, 0, boardVersion);
                success(nil, 1, boardFWVersion);

                [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {

                } onFailure:^(NSError *error) {
                    [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
                    failure (status);
                }];

            } onFailure:^(NSError *error) {
                [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
                failure (status);
            }];

        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
            failure (status);
        }];
        
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_AUTH_REQ];
        failure (status);
    }
}

#pragma mark - hex from int
- (NSString *)hexFromInt:(NSInteger)val {
    return [NSString stringWithFormat:@"0x%X", val];
}

#pragma mark - hex to String
- (NSString *)hexToString:(NSString *)string {
    NSMutableString *_string = [NSMutableString string];
    
    for (int i=0;i<string.length;i+=2) {
        
        NSString *charValue = [string substringWithRange:NSMakeRange(i,2)];
        unsigned int _byte;
        
        [[NSScanner scannerWithString:charValue] scanHexInt: &_byte];
        
        if (_byte >= 32 && _byte < 127) {
            [_string appendFormat:@"%c", _byte];
        } else {
            [_string appendFormat:@"[%d]", _byte];
        }
    }
    return _string;
}

@end

