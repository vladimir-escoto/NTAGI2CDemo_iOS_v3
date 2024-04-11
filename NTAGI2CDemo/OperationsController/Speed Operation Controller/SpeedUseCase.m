//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "SpeedUseCase.h"

@interface SpeedUseCase ()

@end

@implementation SpeedUseCase

#pragma mark - sharedInstance
+ (SpeedUseCase *) sharedInstance{
    static SpeedUseCase *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance                  = [[SpeedUseCase alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - EEPROM Demo
- (void) EEPROMDemo:(NSString *) blockMulti onSuccess: (void (^)(NSString *str)) success  onFailure : (void(^)(AuthStatus status))failure{
    
    Prod product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        
        dispatch_queue_t myQueue = dispatch_queue_create("Speed Tab Thread",NULL);
        dispatch_async(myQueue ,^{
            
            [[NTAG_I2C_LIB sharedInstance] setAlertMessage:TXT_READING_INFO];
            
            __block float writeTimeInterval;
            __block int writeLen = 0;
            __block float readTimeInterval;
            __block int readLen = 0;
            
            // create message to write
            int chMultiplier = [self getchMultiplier:blockMulti];
            NSString * messageText = @"";
            for (int i = 0; i < chMultiplier; i++){
                messageText = [NSString stringWithFormat:@"%@ ", messageText];
            }
            
            __block Prod product;
            __block Ntag_Get_Version * version;
            
            [[NTAG_I2C_LIB sharedInstance] getVersion:^(NSData *aData) {
                version = [[Ntag_Get_Version alloc] initWithData:aData];
                product = [version getProdType];
                
                NSData* data = [messageText dataUsingEncoding:NSUTF8StringEncoding];
                if(data.length > [version getMemsize]){
                    [[NTAG_I2C_LIB sharedInstance]customErrorMessage:@"NDEF Message too long"];
                    return;
                }
            } onFailure:^(NSError *error) {
                [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                success(MSG_WRITING_PROCES);
            });
            
            [NSThread sleepForTimeInterval:0.1f];
            __block NSTimeInterval start = CACurrentMediaTime();
            
            NFCNDEFMessage * ndefMessage = [[Message alloc] createMessageWithTextRecord:messageText appendPackage: false];
            __block NSData *message = [self getNDEFMessageData:ndefMessage];
            
            [[NTAG_I2C_LIB sharedInstance] writeEEPROM:message onSuccess:^(NSData *aData) {
                NSTimeInterval end = CACurrentMediaTime();
                writeTimeInterval = 1000 * (end - start);
                writeLen = message.length - 3;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(@"Writing finished\nReading in process");
                });
                

                __block int NDEFsize;
                __block int TLVsize;
                __block int TLV_plus_NDEF;
                
                [[NTAG_I2C_LIB sharedInstance] readEEPROM:0x04 absEnd:0x07 onSuccess:^(NSData *aData) {
                    if(![[aData subdataWithRange:NSMakeRange(0, 1)] isEqualToData:[NSData dataWithHexString:@"03"]]){
                        [[NTAG_I2C_LIB sharedInstance] customErrorMessage:@"Format on Tag not supported"];
                    }
                    
                    if(![[aData subdataWithRange:NSMakeRange(1, 1)] isEqualToData:[NSData dataWithHexString:@"FF"]]){
                        char byte =[[aData subdataWithRange:NSMakeRange(1, 1)] bytes];
                        NDEFsize = byte & 0xFF;
                        TLVsize = 2;
                        TLV_plus_NDEF = TLVsize + NDEFsize;
                    } else {
                        
                        unsigned char *bytes = (unsigned char *)[aData bytes];
                        NDEFsize = (bytes[3] & 0xFF);
                        NDEFsize |= ((bytes[2] << 8) & 0xFF00);
                        TLVsize = 4;
                        TLV_plus_NDEF = TLVsize + NDEFsize;
                    }
                    
                    start = CACurrentMediaTime();
                    
                    [[NTAG_I2C_LIB sharedInstance] readEEPROM:0x04 absEnd:(4+(TLV_plus_NDEF/4)) onSuccess:^(NSData *aData) {
                        NSTimeInterval end = CACurrentMediaTime();
                        readTimeInterval = 1000 * (end - start);
                        readLen = ndefMessage.length;
                        
                        NSString * finalMessage = [self buildEEPROMDemoFinalString:writeLen readLen:readLen writeTimeInterval:writeTimeInterval readTimeInterval:readTimeInterval];
                        
                        success(finalMessage);

                        [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {
                            
                        } onFailure:^(NSError *error) {
                            [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];
                        }];
                        
                    } onFailure:^(NSError *error) {
                        
                    }];
                    
                    
                } onFailure:^(NSError *error) {
                    
                }];
                
                
            } onFailure:^(NSError *error) {
                [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];

            }];
        });
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_AUTH_REQ];
        failure (status);
    }
}

#pragma mark - SRAM Demo
- (void) SRAMDemo:(NSString *) blockMulti onSuccess: (void (^)(NSString *str)) success  onFailure : (void(^)(AuthStatus status))failure{
    
    Prod product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        
        dispatch_queue_t myQueue = dispatch_queue_create("Speed Tab Thread",NULL);
        dispatch_async(myQueue ,^{
            
            int chMultiplier = [self getchMultiplier:blockMulti];
            __block NSString * writePublishMessage;
            __block NSString * readPublishMessage;
            
            __block float writeTimeInterval;
            __block int writeLen = 0;
            __block float readTimeInterval;
            __block int readLen = 0;
            __block bool isValidFirmware;
            __block bool isValidRxData;
            __block bool isValidTxData;
            
            Prod product = [[NTAG_I2C_LIB sharedInstance] getProduct];
            
            // AUTHENTICATION CHECK!!!!!!!!!!!!!
            [[NTAG_I2C_LIB sharedInstance] setAlertMessage:TXT_READING_INFO];
            
            NSTimeInterval start = CACurrentMediaTime();
            
            while (true){
                if ([[NTAG_I2C_LIB sharedInstance] checkPTwritePossible]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(@"Pass Through Mode is ON");
                    });
                    break;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(@"Pass Through Mode is OFF");
                    });
                }
                if ( 1000 * (CACurrentMediaTime() - start) > 500){
                    // send failute timeout error
                    [[NTAG_I2C_LIB sharedInstance] closeWithCustomMessage:@"PassThrough Mode was OFF, ERROR time out"];
                    return;
                }
            }
            
            int SRAMSize = [[NTAG_I2C_LIB sharedInstance] getSRAMSize];
            NSMutableData * data = [[NSMutableData alloc] initWithLength:SRAMSize];
            NSData * byte = [@"S" dataUsingEncoding: NSASCIIStringEncoding];
            [data replaceBytesInRange:NSMakeRange(SRAMSize - 4, 1) withBytes:[byte bytes]];
            
            [[NTAG_I2C_LIB sharedInstance] writeSRAMBlock:data onSuccess:^(NSData *aData) {
                
            } onFailure:^(NSError *error) {
                [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];
            }];
            
            // Begin to transmit Data (RF --> I2C)
            data = [[NSMutableData alloc] initWithLength:(chMultiplier * SRAMSize)];
            byte = [@"finish_S_" dataUsingEncoding: NSASCIIStringEncoding];
            [data replaceBytesInRange:NSMakeRange(data.length - SRAMSize, byte.length) withBytes:[byte bytes]];
            
            data = [self appendCRC32:data];
            
            [NSThread sleepForTimeInterval:0.1f];
            
            // Start timing writing process
            start = CACurrentMediaTime();
            
            int blocks = ceil(data.length/SRAMSize);
            for(int i= 0; i < blocks; i++){
                NSMutableData * dataBlock = [[NSMutableData alloc] initWithLength:SRAMSize];
                if(data.length - (i+1) * SRAMSize < 0){
                    dataBlock = [data subdataWithRange:NSMakeRange(i*SRAMSize, data.length % SRAMSize)];
                } else {
                    dataBlock = [data subdataWithRange:NSMakeRange(i*SRAMSize, SRAMSize)];
                }
                [[NTAG_I2C_LIB sharedInstance] writeSRAMBlock:dataBlock onSuccess:^(NSData *aData) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // publish results with success callback
                        writeLen = (i + 1) * SRAMSize;
                        writePublishMessage = [NSString stringWithFormat:@"%0d Bytes written", writeLen];
                        success(writePublishMessage);
                        
                    });
                    
                } onFailure:^(NSError *error) {
                    [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];
                }];
                
                [NSThread sleepForTimeInterval:0.1f];
            }
            
            NSTimeInterval end = CACurrentMediaTime();
            writeTimeInterval = 1000 * (end - start);
            
            // Start timing reading process
            start = CACurrentMediaTime();
            
            // Begin to Read data (I2C --> RF)
            __block NSMutableData * response = [[NSMutableData alloc] init];
            
            for (int i = 0; i < chMultiplier; i++){
                
                [[NTAG_I2C_LIB sharedInstance] readSRAMBlock:^(NSData *aData) {
                    // Append read block to the full response
                    [response appendData:aData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // publish results with success callback
                        readLen = (i + 1) * SRAMSize;
                        readPublishMessage = [NSString stringWithFormat:@"%@\n%0d Bytes read",writePublishMessage, readLen];
                        success(readPublishMessage);
                        
                    });
                    
                } onFailure:^(NSError *error) {
                    [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];
                }];
                [NSThread sleepForTimeInterval:0.1f];
            }
            end = CACurrentMediaTime();
            readTimeInterval = 1000 * (end - start);
            
            const char * respBytes = [response bytes];
            if(respBytes[SRAMSize - 5] == 0x01)
                isValidTxData = false;
            else
                isValidTxData = true;
            
            isValidFirmware = [self isCRC32Appended:response];
            if (isValidFirmware)
                isValidRxData = [self isValidCRC32:response];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString * finalMessage = [self buildSRAMDemoFinalString:writeLen readLen:readLen writeTimeInterval:writeTimeInterval readTimeInterval:readTimeInterval isValidFirmware:isValidFirmware isValidTxData:isValidTxData isValidRxData:isValidRxData];
                
                success(finalMessage);
                
            });
            
            [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {
                
            } onFailure:^(NSError *error) {
                [[NTAG_I2C_LIB sharedInstance]customErrorMessage:MSG_ERROR_TRANS];
            }];
        });
        
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_AUTH_REQ];
        failure (status);
    }
}

- (NSData *) getNDEFMessageData: (NFCNDEFMessage *) message{
    
    NSMutableData *finalMessage;
    
    NFCNDEFPayload *payload = [message records].firstObject;
    
    char header[7] = {0xc1, 0x01, 0x00, 0x00, 0x02, 0x83, 0x54};
    NSData * dataHeader = [[NSData alloc] initWithBytes:header length:sizeof(header)];
    
    NSMutableData *ndefMessageData = [dataHeader mutableCopy];
    [ndefMessageData appendData:payload.payload];

    if(ndefMessageData.length < 0xFF){
        finalMessage = [[NSMutableData alloc] initWithLength:ndefMessageData.length + 3];
        int TLV_size = [ndefMessageData length];
        TLV_size = 0;
        
        int lastByte = 0xFE;
        NSMutableData *byte = [[NSMutableData alloc] init];
        [byte appendBytes:&lastByte length:1];
        char addBytes[2] = {0x03, TLV_size };
        [finalMessage replaceBytesInRange:NSMakeRange(0, 2) withBytes:addBytes];
        [finalMessage replaceBytesInRange:NSMakeRange(ndefMessageData.length - 1, 1) withBytes:[byte bytes]];
        [finalMessage replaceBytesInRange:NSMakeRange(2, ndefMessageData.length) withBytes:[ndefMessageData bytes]];
        
    } else {
        finalMessage = [[NSMutableData alloc] initWithLength:ndefMessageData.length + 5];
        int TLV_size = [ndefMessageData length];
        TLV_size |= 0xFF0000;
        
        int lastByte = 0xFE;
        NSMutableData *byte = [[NSMutableData alloc] init];
        [byte appendBytes:&lastByte length:1];
        char addBytes[4] = {0x03, ((TLV_size >> 16) & 0xFF), ((TLV_size >> 8) & 0xFF), (TLV_size & 0xFF)};
        [finalMessage replaceBytesInRange:NSMakeRange(0, 4) withBytes:addBytes];
        [finalMessage replaceBytesInRange:NSMakeRange(ndefMessageData.length - 1, 1) withBytes:[byte bytes]];
        [finalMessage replaceBytesInRange:NSMakeRange(4, ndefMessageData.length) withBytes:[ndefMessageData bytes]];
    }
    
    return finalMessage;
}

#pragma mark - getch Multiplier
-(int) getchMultiplier: (NSString *) blockMulti{
    // Retrieves the chMultiplier assigned corresp
    int chMultiplier = 1;
    
    NSData * chMultiHexBytes = [NtagUtils dataFromHexString: blockMulti];
    int chMultiLength = chMultiHexBytes.length;
    
    if(chMultiLength == 0)
        chMultiplier = 1;
    else
        chMultiplier = [blockMulti intValue];
    
    return chMultiplier;
}

#pragma mark - build SRAM Demo Final String
- (NSString *) buildSRAMDemoFinalString: (int) writeLen readLen: (int) readLen writeTimeInterval: (float) writeTimeInterval readTimeInterval: (float) readTimeInterval isValidFirmware: (bool) isValidFirmware isValidTxData: (bool) isValidTxData isValidRxData: (bool) isValidRxData{
    NSString * TxIntegrity;
    NSString * RxIntegrity;
    
    if(isValidTxData)
        TxIntegrity = @"OK";
    else
        TxIntegrity = @"Error";
    
    if(isValidRxData)
        RxIntegrity = @"OK";
    else
        RxIntegrity = @"Error";
    
    float TxSpeed = writeLen/(writeTimeInterval/1000);
    float RxSpeed = readLen/(readTimeInterval/1000);
    
    NSString * str = [NSString stringWithFormat:@"Integrity of the Send data: %@\nIntegrity of the Received data: %@\nTransfer NFC device to MCU\nSpeed (%d Bytes / %.0f ms): %.0f Bytes/s\nTransfer MCU to NFC device\nSpeed (%d Bytes / %.0f ms): %.0f Bytes/s", TxIntegrity, RxIntegrity, writeLen, writeTimeInterval, TxSpeed, readLen, readTimeInterval, RxSpeed];
    
    return str;
}

#pragma mark - build EEPROM Demo Final String
- (NSString *) buildEEPROMDemoFinalString: (int) writeLen readLen: (int) readLen writeTimeInterval: (float) writeTimeInterval readTimeInterval: (float) readTimeInterval{
    
    float TxSpeed = writeLen/(writeTimeInterval/1000);
    float RxSpeed = readLen/(readTimeInterval/1000);
    
    NSString * str = [NSString stringWithFormat:@"Transfer NFC device to MCU\nSpeed (%d Bytes / %.0f ms): %.0f Bytes/s\nTransfer MCU to NFC device\nSpeed (%d Bytes / %.0f ms): %.0f Bytes/s", writeLen, writeTimeInterval, TxSpeed, readLen, readTimeInterval, RxSpeed];
    
    return str;
}

#pragma mark - append CRC32
- (NSMutableData *) appendCRC32:(NSData *) data {
    
    NSMutableData * temp = [data subdataWithRange:NSMakeRange(0, data.length - 4)];
    
    // call crc calculator which returns nsdata to be appended to b
    NSData * crc = [self CRC32:temp];
    
    NSMutableData * finalData = [[NSMutableData alloc] init];
    [finalData appendData:data];
    [finalData replaceBytesInRange:NSMakeRange(data.length - 4, 4) withBytes:[crc bytes]];
    
    return finalData;
}
#pragma mark - CRC32
- (NSData *)CRC32:(NSData *) arg {
    int crc = 0xFFFFFFFF; // initial contents of LFBSR
    int poly = 0xEDB88320; // reverse polynomial
    
    const char * argBytes = [arg bytes];
    char b[arg.length];
    for (int i=0; i<arg.length; i++){
        b[i] = argBytes[i];
    }
    
    for (int i = 0; i < sizeof(b); i++){
        int temp = (crc ^ b[i]) & 0xFF;
        
        // read 8 bits one at a time
        for (int j = 0; j < 8; j++){
            if ((temp & 1) == 1)
                temp = [self unsignedRightBitShiftOperator:temp rhs:1] ^ poly;
            else
                temp = [self unsignedRightBitShiftOperator:temp rhs:1];
        }
        crc = [self unsignedRightBitShiftOperator:crc rhs:8] ^ temp;
    }
    return [self integerToByteArray:crc];
}

#pragma mark - is Valid CRC32
- (bool) isValidCRC32: (NSData *) data{
    NSData * receivedCRC = [data subdataWithRange:NSMakeRange(data.length - 4, 4)];
    NSData * temp = [data subdataWithRange:NSMakeRange(0, data.length - 4)];
    NSData * calculatedCRC = [self CRC32:temp];
    
    return [receivedCRC isEqualToData:calculatedCRC];
}

#pragma mark - unsigned Right Bit Shift Operator
- (int) unsignedRightBitShiftOperator:(int)lhs rhs:(int) rhs {
    if (lhs >= 0) {
        return (lhs >> rhs);
    } else {
        return (INT_MAX + lhs + 1) >> rhs | (1 << (63-rhs));
    }
}

#pragma mark - integer To Byte Array
- (NSData *)integerToByteArray:(int) i {
    char result [4];
    
    result[3] = i >> 24;
    result[2] = i >> 16;
    result[1] = i >> 8;
    result[0] = i >> 0;
    
    NSData * resultData = [[NSData alloc] initWithBytes:result length:sizeof(result)];
    
    return resultData;
}

#pragma mark - is CRC32 Appended
- (bool) isCRC32Appended:(NSData *) data {
    const char * bytes = [data bytes];
    
    for (int i = data.length - 4; i < data.length; i++){
        if (bytes[i] != 0x00)
            return true;
    }
    return false;
}

@end
