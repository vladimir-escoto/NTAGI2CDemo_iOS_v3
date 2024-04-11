//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "DemoUseCase.h"

@interface DemoUseCase ()

@end

@implementation DemoUseCase

NSData * Led;

double tempC = 0;
double tempF = 0;
double voltC = 0;

NSData * buttonStatus;

TransferDir transferDir = NO_TRANSFER;

NSString * TempStr;
NSString * TransferString;
NSString * VoltageString;

#pragma mark - sharedInstance
+ (DemoUseCase *) sharedInstance{
    static DemoUseCase *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DemoUseCase alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - LED Demo
- (void) LEDDemo:(bool) isTempEnabled isLCDEnabled: (bool) isLCDEnabled isScrollEnabled: (bool) isScrollEnabled LedStr: (NSString *) LedStr onSuccess: (void (^)(NSString *str1, NSString *str2, NSString *str3, NSData *buttonStatus)) success  onFailure : (void(^)(AuthStatus status))failure{
    
    Prod product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        
        dispatch_queue_t myQueue = dispatch_queue_create("Demo Tab Thread",NULL);
        dispatch_async(myQueue ,^{
            
            int SRAMSize = [[NTAG_I2C_LIB sharedInstance] getSRAMSize];
            NSMutableData * DataTx = [[NSMutableData alloc] initWithLength:SRAMSize];
            NSMutableData * DataRx = [[NSMutableData alloc] initWithLength:SRAMSize];
            Led = [LedStr dataUsingEncoding: NSASCIIStringEncoding];
            
            // Make sure Passthrough is activated
            NSTimeInterval start = CACurrentMediaTime();
            bool RTest = false;
            
            [[NTAG_I2C_LIB sharedInstance] setAlertMessage:@"Performing Demo..."];
            
            do{
                if([[NTAG_I2C_LIB sharedInstance] checkPTwritePossible])
                    break;
                
                long end = CACurrentMediaTime() - start;
                RTest = (end < 5000);
            }while(RTest);
            
            while ([[NTAG_I2C_LIB sharedInstance] isConnect]){
                // Write LED color into the block to be transmitted
                [DataTx replaceBytesInRange:NSMakeRange(SRAMSize - 4, 2) withBytes:[Led bytes]];
                
                // Indicate whether Temperature and LCD are enabled or not
                NSData * val = [@"E" dataUsingEncoding: NSASCIIStringEncoding];
                NSMutableData * zeroVal = [[NSMutableData alloc] initWithLength:1];
                
                if(isTempEnabled)
                    [DataTx replaceBytesInRange:NSMakeRange(SRAMSize - 9, 1) withBytes:[val bytes]];
                else
                    [DataTx replaceBytesInRange:NSMakeRange(SRAMSize - 9, 1) withBytes: [zeroVal bytes]];
                
                if(isLCDEnabled)
                    [DataTx replaceBytesInRange:NSMakeRange(SRAMSize - 10, 1) withBytes:[val bytes]];
                else
                    [DataTx replaceBytesInRange:NSMakeRange(SRAMSize - 10, 1) withBytes: [zeroVal bytes]];
                
                // NDEF Scrolling activation
                if(isScrollEnabled)
                    [DataTx replaceBytesInRange:NSMakeRange(SRAMSize - 11, 1) withBytes:[val bytes]];
                else
                    [DataTx replaceBytesInRange:NSMakeRange(SRAMSize - 11, 1) withBytes: [zeroVal bytes]];
                
                [self setTempData:DataTx tempC:tempC tempF:tempF];
                [self setVoltageData:DataTx voltD:voltC];
                
                [NSThread sleepForTimeInterval:0.1f];
                
                transferDir = DEVICE_TO_TAG;
                
                [[NTAG_I2C_LIB sharedInstance] writeSRAMBlock:DataTx onSuccess:^(NSData *aData) {
                    TransferString = @"Transfer: Device --> Tag";
                    success (TransferString, TempStr, VoltageString, nil);
                    
                } onFailure:^(NSError *error) {
                    [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
                }];
                
                [NSThread sleepForTimeInterval:0.1f];
                
                transferDir = TAG_TO_DEVICE;
                
                [[NTAG_I2C_LIB sharedInstance] readSRAMBlock:^(NSData *aData) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Update variables and UI with read data
                        [self updateData:aData isTempEnabled: isTempEnabled];
                        if ( aData.length == SRAMSize){
                            success (TransferString, TempStr, VoltageString, [aData subdataWithRange:NSMakeRange(SRAMSize - 2, 1)]);
                        }
                        else{
                            [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];
                            return;
                        }
                    });
        
                } onFailure:^(NSError *error) {
                    [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_TRANS];
                }];
            }
        });
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_AUTH_REQ];
        failure (status);
    }
}

#pragma mark - set Temp Data
- (void) setTempData: (NSMutableData *) data tempC: (double) tempC tempF: (double) tempF{
    // Sets the previously read Temperature data to be written in the correct format
    int SRAMSize = [[NTAG_I2C_LIB sharedInstance] getSRAMSize];
    NSData * tempData;
    NSString * format;
    
    if (tempC > 0.0 && tempC < 75.0){
        format = [NSString stringWithFormat:@"%2.2f", tempC];
        TempStr = [NSString stringWithFormat:@"Temperature: %@°C ", format];
        format = [NSString stringWithFormat:@"%@%@", [format substringToIndex:2], [format substringFromIndex:3]];
        
        tempData = [format dataUsingEncoding:NSASCIIStringEncoding];
        
        [data replaceBytesInRange:NSMakeRange(SRAMSize - 24, 4) withBytes:[tempData bytes]];
    }
    
    if (tempF > 0.0 && tempF < 120.0){
        if (tempF > 0.0 && tempF < 10)
            format = [NSString stringWithFormat:@"00%3.2f", tempF];
        else if (tempF >= 10.0 && tempF < 100)
            format = [NSString stringWithFormat:@"0%3.2f", tempF];
        else
            format = [NSString stringWithFormat:@"%3.2f", tempF];
        
        TempStr = [NSString stringWithFormat:@"%@%@", TempStr, [NSString stringWithFormat:@"/ %3.2f°F"]];
        
        format = [NSString stringWithFormat:@"%@%@", [format substringToIndex:3], [format substringFromIndex:4]];
        
        tempData = [format dataUsingEncoding:NSASCIIStringEncoding];
        
        [data replaceBytesInRange:NSMakeRange(SRAMSize - 19, 5) withBytes:[tempData bytes]];
    }
}

#pragma mark - set Voltage Data
- (void) setVoltageData: (NSMutableData *) data voltD: (double) voltD{
    // Sets the previously read Voltage data to be written in the correct format
    int SRAMSize = [[NTAG_I2C_LIB sharedInstance] getSRAMSize];
    NSData *tempData;
    NSString * format;
    
    if (voltD > 0.0 && voltD < 5.0){
        VoltageString = [NSString stringWithFormat:@"Energy Harvesting Voltage: %1.1fV", voltD];
        format = [NSString stringWithFormat:@"%1.1f", voltD];
        format = [NSString stringWithFormat:@"%@%@", [format substringToIndex:1], [format substringFromIndex:2]];
        
        tempData = [format dataUsingEncoding:NSASCIIStringEncoding];
        
        if (tempData.length == 2 && data.length == SRAMSize)
            [data replaceBytesInRange:NSMakeRange(SRAMSize - 8, 2) withBytes:[tempData bytes]];
    }
    
}

#pragma mark - update Data
- (void) updateData: (NSData *) data isTempEnabled: (bool) isTempEnabled{
    int SRAMSize = [[NTAG_I2C_LIB sharedInstance] getSRAMSize];
    
    if(data.length != SRAMSize)
        return;
    
    // Setting direction in UI
    if(transferDir == NO_TRANSFER){
        TransferString = TXT_TRANS_NON;
    }else if (transferDir == DEVICE_TO_TAG){
        TransferString = TXT_TRANS_DEV_TAG;
    }else if (transferDir == TAG_TO_DEVICE){
        TransferString = TXT_TRANS_TAG_DEV;
    }
    
    // Processing Temperature Data
    int Temp = 0;
    const char * tempFirstByte = [[data subdataWithRange:NSMakeRange(SRAMSize - 5, 1)] bytes];
    const char * tempSecondByte = [[data subdataWithRange:NSMakeRange(SRAMSize - 6, 1)] bytes];
    
    Temp = ((tempFirstByte[0] >> 5 ) & 0x07);
    Temp |= ((tempSecondByte[0] << 3) & 0x07F8);
    
    // Process Voltage data
    int Voltage = 0;
    const char * voltageFirstByte = [[data subdataWithRange:NSMakeRange(SRAMSize - 7, 1)] bytes];
    const char * voltageSecondByte = [[data subdataWithRange:NSMakeRange(SRAMSize - 8, 1)] bytes];
    
    Voltage = ((voltageFirstByte[0] << 8) & 0xFF00) + (voltageSecondByte[0] & 0x00FF);
    
    // If Temp = 0, there is no Temperature sensor
    if (Temp != 0){} else {}
    
    if (isTempEnabled){
        [self calcTempCelsius:Temp];
        [self calcTempFarenheit:Temp];
    } else
        TempStr = TXT_TEMP_NOT_AVA;
    
    [self calcVoltage:Voltage];
}

#pragma mark - calc Temp Celsius
- (void) calcTempCelsius: (int) temp {
    double Temp_double = 0;
    
    //If the 11 Bit is 1 it is negative
    if ((temp & (1 << 11)) == (1 << 11)) {
        // Mask out the 11 Bit
        temp &= ~(1 << 11);
    }
    
    Temp_double = (double) 0.125 * temp;
    
    tempC = Temp_double;
}

#pragma mark - calc Temp Farenheit
- (void) calcTempFarenheit: (int) temp {
    double  Temp_double = 0;
    NSString * Temp_string = @"";
    
    //If the 11 Bit is 1 it is negative
    if ((temp & (1 << 11)) == (1 << 11)) {
        // Mask out the 11 Bit
        temp &= ~(1 << 11);
        Temp_string = [NSString stringWithFormat:@"%@%@", Temp_string, @"-"];
    }
    
    Temp_double = (double) 0.125 * temp;
    Temp_double = 32 + (1.8 * Temp_double);
    
    tempF = Temp_double;
}

#pragma mark - calc Voltage
- (void) calcVoltage: (int) volt {
    NSString * Volt_string = @"0.0";
    
    if (volt > 0){
        double Volt_double = round((0x3FF * 2.048) / volt);
        voltC = Volt_double;
    }
}


@end
