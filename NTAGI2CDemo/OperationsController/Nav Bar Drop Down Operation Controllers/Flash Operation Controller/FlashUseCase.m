//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "FlashUseCase.h"

@implementation FlashUseCase : NSObject

#pragma mark - sharedInstance
+ (FlashUseCase *) sharedInstance{
    static FlashUseCase *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance                  = [[FlashUseCase alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Flash
- (void) Flash:(void (^)(int step, NSString * dataStr) )success  onFailure : (void(^)(NSString * status))failure bytesToFlash:(NSData *) bytesToFlash {
    
    __block int steps = 0;
    int sectorSize    = PAGE_SIZE;
    __block NSMutableData * data;
    __block NSMutableData * flashData;
    
    dispatch_queue_t myQueue = dispatch_queue_create("Flash Thread", NULL);
    dispatch_async(myQueue ,^{
        @try {
            unsigned char *bytes_flash = (unsigned char *)[bytesToFlash bytes];
            char bytes[bytesToFlash.length];
            
            for (int i =0; i<bytesToFlash.length; i++){
                bytes[i] = bytes_flash[i];
            }
            
            int length = sizeof(bytes);
            int flashes = length / sectorSize + (length % sectorSize == 0 ? 0 : 1);
            
            int SRAMSize = [[NTAG_I2C_LIB sharedInstance] getSRAMSize];
            int blocks = (int) ceil(length / (float) SRAMSize);
            
            data = [[NSMutableData alloc] initWithLength:SRAMSize];
            
            // Set the number of writings
            success(1,  [NSString stringWithFormat:TXT_FLASH_IN_PROGRESS]);
            
            for (int i = 0; i < flashes; i++) {
                
                int flash_addr = 0x4000 + i * sectorSize;
                int flash_length = 0;
                
                // Process data to write
                [self ProcessDataToWrite:bytesToFlash flashData:&flashData flash_length:&flash_length i:i length:length sectorSize:sectorSize];
                [self SetDataValues:SRAMSize data:data flash_addr:flash_addr flash_length:flash_length];
                
                NSData * dat = [data subdataWithRange:NSMakeRange(0, data.length)];
                
                NSLog(@"Flashing to start");
                
                [[NTAG_I2C_LIB sharedInstance] writeSRAMBlock: dat onSuccess:^(NSData *aData) {
                    int tmpPos = (i + 1);
                    NSLog(@"Start Block write  %d out of %d", tmpPos, flashes);
                    
                    // Starting Block writing
                    success(1,  [NSString stringWithFormat:@"Writing Block  %d out of %d ...", tmpPos, flashes]);
                    
                    if (flashData.length < 1){
                        [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_FLASH];
                        return;
                    }
                    
                    // Write data into SRAM
                    [[NTAG_I2C_LIB sharedInstance] WriteSRAM:flashData onSuccess:^(NSData *aData) {
                        [NSThread sleepForTimeInterval:0.1f];
                        NSMutableArray * response = [[NSMutableArray alloc] init];
                        
                        [[NTAG_I2C_LIB sharedInstance] readSRAMBlock:^(NSData *aData) {
                            unsigned char *response_bytes = (unsigned char *)[aData bytes];
                            
                            for (int k =0; k<aData.length; k++){
                                [response addObject:[NSNumber numberWithInt:response_bytes[k]]];
                            }
                            
                            if (response.count < 1){
                                [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_FLASH];
                                return;
                            }
                            
                            // Check ACK/NACK
                            unsigned posA     = 0;
                            NSScanner * scanner_led = [NSScanner scannerWithString:@"0x41"]; // 'A'
                            [scanner_led scanHexInt:&posA];
                            
                            unsigned posC     = 0;
                            scanner_led = [NSScanner scannerWithString:@"0x43"]; // 'C'
                            [scanner_led scanHexInt:&posC];
                            
                            unsigned posK     = 0;
                            scanner_led = [NSScanner scannerWithString:@"0x4B"]; // 'K'
                            [scanner_led scanHexInt:&posK];
                            
                            for (int x = 0 ; x< response.count; x++){
                                NSLog(@"Response: %@", response[x]);
                            }
                            
                            if (response[SRAMSize - 4] != [NSNumber numberWithInt:65] || response[SRAMSize - 3] != [NSNumber numberWithInt:67]  || response[SRAMSize - 2]!= [NSNumber numberWithInt:75] ) {
                                NSLog(@"Was nak");
                                [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_FLASH];
                                return;
                            }
                            
                            steps = steps + 1;
                            
                        } onFailure:^(NSError *error) {
                            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_FLASH];
                            return;
                        }];
                        
                    } onFailure:^(NSError *error) {
                        [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_FLASH];
                        return;
                    }];
                    
                } onFailure:^(NSError *error) {
                    [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_FLASH];
                    return;
                }];
                NSTimeInterval start = CACurrentMediaTime();
                int savedstep = steps;
                while (true){
                    if(savedstep!=steps){
                        break;
                    }
                    if ( 1000 * (CACurrentMediaTime() - start) > 20000){
                        break;
                    }
                }
                NSLog(@"Inside While Step %d of %d", i + 1, flashes);
            }
            // Flash completed
            success(2, @"Flash completed");
            
            data = [[NSMutableData alloc] initWithLength:SRAMSize];
            
            [data replaceBytesInRange:NSMakeRange(SRAMSize - 4, 1) withBytes: [[@"F" dataUsingEncoding: NSASCIIStringEncoding] bytes] ];
            [data replaceBytesInRange:NSMakeRange(SRAMSize - 3, 1) withBytes: [[@"S" dataUsingEncoding: NSASCIIStringEncoding] bytes] ];
            
            NSData * dat = [data subdataWithRange:NSMakeRange(0, data.length)];
            
            // Write final message to SRAM
            [[NTAG_I2C_LIB sharedInstance] writeSRAMBlock:dat  onSuccess:^(NSData *aData) {
                [NSThread sleepForTimeInterval:1.0f];
                
                // Set the number of writings
                success(3, [NSString stringWithFormat:TXT_SUCCESS, blocks]);
            } onFailure:^(NSError *error) {
                [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_FLASH];
                return;
            }];
            
        }@catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_ERROR_FLASH];
            return;
        }
    });
}

#pragma mark - Process Data To Write
- (void)ProcessDataToWrite:(NSData *)bytesToFlash flashData:(NSMutableData **)flashData flash_length:(int *)flash_length i:(int)i length:(int)length sectorSize:(int)sectorSize {
    if (length - (i + 1) * sectorSize < 0) {
        int calc = length % sectorSize;
        *flash_length = [self roundUp:calc];
        *flashData = [[NSMutableData alloc]  initWithLength:*flash_length];
        NSData * dataToCopy = [bytesToFlash subdataWithRange:NSMakeRange(i*sectorSize, length % sectorSize)];
        [*flashData replaceBytesInRange:NSMakeRange(0, length % sectorSize) withBytes:[dataToCopy bytes]];
    }else{
        *flash_length = sectorSize;
        *flashData = [[NSMutableData alloc] initWithLength:*flash_length];
        NSData * dataToCopy = [bytesToFlash subdataWithRange:NSMakeRange(i*sectorSize, sectorSize)];
        [*flashData replaceBytesInRange:NSMakeRange(0, sectorSize) withBytes:[dataToCopy bytes]];
    }
}

#pragma mark - Set Data Values
- (void)SetDataValues:(int)SRAMSize data:(NSMutableData *)data flash_addr:(int)flash_addr flash_length:(int)flash_length {
    [data replaceBytesInRange:NSMakeRange(SRAMSize - 4, 1) withBytes: [[@"F" dataUsingEncoding: NSASCIIStringEncoding] bytes] ];
    [data replaceBytesInRange:NSMakeRange(SRAMSize - 3, 1) withBytes: [[@"P" dataUsingEncoding: NSASCIIStringEncoding] bytes] ];
    
    int val = (flash_length >> 24 & 0xFF);
    NSMutableData *byteData = [NSMutableData new];
    [byteData appendBytes:&val length:1];
    
    [data replaceBytesInRange:NSMakeRange(SRAMSize - 8, 1) withBytes: [byteData bytes] ];
    
    val = (flash_length >> 16 & 0xFF);
    byteData = [NSMutableData new];
    [byteData appendBytes:&val length:1];
    
    [data replaceBytesInRange:NSMakeRange(SRAMSize - 7, 1) withBytes: [byteData bytes] ];
    
    val = (flash_length >> 8 & 0xFF);
    byteData = [NSMutableData new];
    [byteData appendBytes:&val length:1];
    
    [data replaceBytesInRange:NSMakeRange(SRAMSize - 6, 1) withBytes: [byteData bytes] ];
    
    val = (flash_length & 0xFF);
    byteData = [NSMutableData new];
    [byteData appendBytes:&val length:1];
    
    [data replaceBytesInRange:NSMakeRange(SRAMSize - 5, 1) withBytes: [byteData bytes] ];
    
    val = (flash_addr >> 24 & 0xFF);
    byteData = [NSMutableData new];
    [byteData appendBytes:&val length:1];
    
    [data replaceBytesInRange:NSMakeRange(SRAMSize - 12, 1) withBytes: [byteData bytes] ];
    
    val = (flash_addr >> 16 & 0xFF);
    byteData = [NSMutableData new];
    [byteData appendBytes:&val length:1];
    
    [data replaceBytesInRange:NSMakeRange(SRAMSize - 11, 1) withBytes: [byteData bytes] ];
    
    val = (flash_addr >> 8 & 0xFF);
    byteData = [NSMutableData new];
    [byteData appendBytes:&val length:1];
    
    [data replaceBytesInRange:NSMakeRange(SRAMSize - 10, 1) withBytes: [byteData bytes] ];
    
    val = (flash_addr & 0xFF);
    byteData = [NSMutableData new];
    [byteData appendBytes:&val length:1];
    
    [data replaceBytesInRange:NSMakeRange(SRAMSize - 9, 1) withBytes: [byteData bytes] ];
}

#pragma mark - Round Up
- (int) roundUp: (int) num{
    if (num <= 256)
        return 256;
    else if (num > 256 && num <= 512)
        return 512;
    else if (num > 512 && num <= 1024)
        return 1024;
    else
        return 4096;
}

@end
