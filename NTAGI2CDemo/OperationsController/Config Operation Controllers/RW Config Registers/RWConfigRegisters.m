//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "RWConfigRegisters.h"

@implementation RWConfigRegisters: NSObject

unsigned char NC_Reg            = 0;
unsigned char LD_Reg            = 0;
unsigned char SM_Reg            = 0;
unsigned char WD_LS_Reg         = 0;
unsigned char WD_MS_Reg         = 0;
unsigned char I2C_CLOCK_STR_Reg = 0;
unsigned char PLUS_AUTH0_Reg    = 0;
unsigned char PLUS_ACCESS_Reg   = 0;
unsigned char PLUS_PT_I2C_Reg   = 0;

NSInteger configRegAddr         = 0xE8;

#pragma mark - sharedInstance
+ (RWConfigRegisters *) sharedInstance{
    static RWConfigRegisters *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RWConfigRegisters alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Read Config Registers
- (void) readConfigRegisters:(void (^)(NSDictionary * dictionary) )success  onFailure : (void(^)(AuthStatus status))failure{
    
    Prod product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        
        NSInteger sector;
        
        Prod product = [[NTAG_I2C_LIB sharedInstance] getProduct];
        
        if (product == NTAG_I2C_1K || product == NTAG_I2C_1K_PLUS || product == NTAG_I2C_2K_PLUS || product == NTAG_I2C_1K_V || product == NTAG_I2C_2K_V)
            sector = 0;
        else if (product == NTAG_I2C_2K)
            sector = 1;
        else{
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:MSG_NOT_SUP_BOARD];
            return;
        }
        
        [[NTAG_I2C_LIB sharedInstance] SectorSelect:sector onSuccess:^(NSData *aData) {
            
        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
        }];
        
        [[NTAG_I2C_LIB sharedInstance]   read:configRegAddr onSuccess:^(NSData *aData) {
            
            success([self getConfigRegistersFromDataRead:aData]);
            
            [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {
                
            } onFailure:^(NSError *error) {
                [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
            }];
            
        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
        }];
        
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_AUTH_REQ];
        failure (status);
    }
}

#pragma mark - Write Config Registers
- (void) writeConfigRegisters:(NSDictionary *) dataToWrite onSuccess: (void (^)(NSDictionary * dictionary) )success  onFailure : (void(^)(AuthStatus status))failure{
    
    Prod product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        
        [self updateRegisters:dataToWrite];

        NSInteger sector;
        
        Prod product = [[NTAG_I2C_LIB sharedInstance] getProduct];
        
        if (product == NTAG_I2C_1K || product == NTAG_I2C_1K_PLUS || product == NTAG_I2C_2K_PLUS)
            sector = 0;
        else if (product == NTAG_I2C_2K)
            sector = 1;
        else{
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:@"Not supported board type!"];
            return;
        }
        
        [[NTAG_I2C_LIB sharedInstance] SectorSelect:sector onSuccess:^(NSData *aData) {
            
        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:@"Error during writing"];
        }];
        
        char bytesFirstBlock[4] = {NC_Reg, LD_Reg, SM_Reg, WD_LS_Reg};
        NSData * dataToWrite = [[NSData alloc] initWithBytes:bytesFirstBlock length:sizeof(bytesFirstBlock)];
        [[NTAG_I2C_LIB sharedInstance] write:configRegAddr data:dataToWrite onSuccess:^(NSData *aData) {
            
        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:@"Error during writing"];
        }];
        
        char bytesSecondBlock[4] = {WD_MS_Reg, I2C_CLOCK_STR_Reg, 0x00, 0x00};
        dataToWrite = [[NSData alloc] initWithBytes:bytesSecondBlock length:sizeof(bytesSecondBlock)];
        
        [[NTAG_I2C_LIB sharedInstance] write:configRegAddr + 1 data:dataToWrite onSuccess:^(NSData *aData) {
            
            if(product == NTAG_I2C_1K_PLUS || product == NTAG_I2C_2K_PLUS){
                [[ResetOperationController sharedInstance] writeAuthRegisters:PLUS_AUTH0_Reg ACCESS:PLUS_ACCESS_Reg PT_I2C:PLUS_PT_I2C_Reg onSuccess:^(NSData * _Nonnull aData) {
                    
                    [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {
                        
                    } onFailure:^(NSError *error) {
                        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
                    }];
                } onFailure:^(NSError * _Nonnull error) {
                }];
                
            } else {
                [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {
                    
                } onFailure:^(NSError *error) {
                    [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
                }];
            }
            
        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance] customErrorMessage:@"Error during writing"];
            return;
        }];
        
    } else{
        // Authentication required
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:@"Authentication Required"];
        failure (status);
    }
}

#pragma mark - update Registers
- (void) updateRegisters: (NSDictionary *) dataToWrite{
        
    // Compute NC Reg
    if([[dataToWrite objectForKey:@"FD_OFF"]  isEqual: @"11"])
        NC_Reg = (NC_Reg | 0x30);
    if([[dataToWrite objectForKey:@"FD_OFF"]  isEqual: @"10"]){
        NC_Reg = (NC_Reg & 0xCF);
        NC_Reg = (NC_Reg | 0x20);
    }
    if([[dataToWrite objectForKey:@"FD_OFF"]  isEqual: @"01"]){
        NC_Reg = (NC_Reg & 0xCF);
        NC_Reg = (NC_Reg | 0x10);
    }
    if([[dataToWrite objectForKey:@"FD_OFF"]  isEqual: @"00"])
        NC_Reg = (NC_Reg & 0xCF);
    
    if([[dataToWrite objectForKey:@"FD_ON"]  isEqual: @"11"])
        NC_Reg = (NC_Reg | 0x0C);
    if([[dataToWrite objectForKey:@"FD_ON"]  isEqual: @"10"]){
        NC_Reg = (NC_Reg & 0xF3);
        NC_Reg = (NC_Reg | 0x08);
    }
    if([[dataToWrite objectForKey:@"FD_ON"]  isEqual: @"01"]){
        NC_Reg = (NC_Reg & 0xF3);
        NC_Reg = (NC_Reg & 0x04);
    }
    if([[dataToWrite objectForKey:@"FD_ON"]  isEqual: @"00"])
        NC_Reg = (NC_Reg & 0xF3);
    
    if([[dataToWrite objectForKey:@"PT"]  isEqual: @"true"])
        NC_Reg = (NC_Reg | 0x01);
    else
        NC_Reg = (NC_Reg & 0xFE);
    
    // LD Register
    LD_Reg = [[dataToWrite objectForKey:@"Last NDEF Block"] integerValue];
    
    // SM Register
    SM_Reg = [[dataToWrite objectForKey:@"SRAMMirrorBlock"] integerValue];
    
    // WD_LS
    WD_LS_Reg = [[dataToWrite objectForKey:@"WD_LS"] integerValue];
    
    // WD_MS
    WD_MS_Reg = [[dataToWrite objectForKey:@"WD_MS"] integerValue];
    
    // I2C_CLOCK_STR Register
    if([[dataToWrite objectForKey:@"I2CClockStretch"]  isEqual: @"true"])
        I2C_CLOCK_STR_Reg = 1;
    else
        I2C_CLOCK_STR_Reg = 0;
    
    if([[dataToWrite objectForKey:@"I2C_RST_ON_OFF"]  isEqual: @"true"])
        NC_Reg = (NC_Reg | 0x80);
    else
        NC_Reg = (NC_Reg & 0x7F);
    
    // PLUS_AUTH0 Register
    PLUS_AUTH0_Reg = [[dataToWrite objectForKey:@"Auth0"] integerValue];
    
    // PLUS_ACCESS Register
    if([[dataToWrite objectForKey:@"NFCProt"]  isEqual: @"true"])
        PLUS_ACCESS_Reg = (PLUS_ACCESS_Reg | 0x80);
    else
        PLUS_ACCESS_Reg = (PLUS_ACCESS_Reg & 0x7F);
    
    if([[dataToWrite objectForKey:@"NFC_DIS_SEC_1"]  isEqual: @"true"])
        PLUS_ACCESS_Reg = (PLUS_ACCESS_Reg | 0x20);
    else
        PLUS_ACCESS_Reg = (PLUS_ACCESS_Reg & 0xDF);

    PLUS_ACCESS_Reg |= [[dataToWrite objectForKey:@"AuthLIM"] integerValue];
    
    // PLUS_PT_I2C Register
    if([[dataToWrite objectForKey:@"Prot2k"]  isEqual: @"true"])
        PLUS_PT_I2C_Reg = (PLUS_PT_I2C_Reg | 0x08);
    else
        PLUS_PT_I2C_Reg = (PLUS_PT_I2C_Reg & 0xF7);
    
    if([[dataToWrite objectForKey:@"SRAMProt"]  isEqual: @"true"])
        PLUS_PT_I2C_Reg = (PLUS_PT_I2C_Reg | 0x04);
    else
        PLUS_PT_I2C_Reg = (PLUS_PT_I2C_Reg & 0xFB);
    
    PLUS_PT_I2C_Reg |= [[dataToWrite objectForKey:@"I2cProt"] integerValue];

}

#pragma mark - Process Access Register
- (void)ProcessAccessRegister:(NSString **)AuthLIMStr NFCDisSec1Str:(NSString **)NFCDisSec1Str NFCProtStr:(NSString **)NFCProtStr Prot2kStr:(NSString **)Prot2kStr ProtI2CStr:(NSString **)ProtI2CStr ProtSRAMStr:(NSString **)ProtSRAMStr accessBytes:(const char *)accessBytes pti2cBytes:(const char *)pti2cBytes {
    if((0x000080 & accessBytes[0]) >> NFC_PROT == 1)
        *NFCProtStr = @"true";
    else
        *NFCProtStr = @"false";
    
    if((0x000020 & accessBytes[0]) >> NFC_DIS_SEC1 == 1)
        *NFCDisSec1Str = @"true";
    else
        *NFCDisSec1Str = @"false";
    
    *AuthLIMStr = [NSString stringWithFormat:@"%d", (0x000007 & accessBytes[0])];
    
    // PT I2C Register
    if((0x000008 & pti2cBytes[0]) >> K2_PROT == 1)
        *Prot2kStr = @"true";
    else
        *Prot2kStr = @"false";
    
    if((0x000004 & pti2cBytes[0]) >> SRAM_PROT == 1)
        *ProtSRAMStr = @"true";
    else
        *ProtSRAMStr = @"false";
    
    *ProtI2CStr = [NSString stringWithFormat:@"%d", (0x000003 & pti2cBytes[0])];
}

#pragma mark - Check FD_OFF
- (char)CheckFD_OFF:(NSString **)FD_OFFStr {
    char tmpReg = NC_Reg & FD_OFF;
    
    if (tmpReg == 0x30)
        *FD_OFFStr = @"11";
    if (tmpReg == 0x20)
        *FD_OFFStr = @"10";
    if (tmpReg == 0x10)
        *FD_OFFStr = @"01";
    if (tmpReg == 0x00)
        *FD_OFFStr = @"00";
    return tmpReg;
}

#pragma mark - Check FD_ON
- (void)CheckFD_ON:(NSString **)FD_ONStr tmpReg:(char *)tmpReg {
    *tmpReg = NC_Reg & FD_ON;
    
    if (*tmpReg == 0x0c)
        *FD_ONStr = @"11";
    if (*tmpReg == 0x08)
        *FD_ONStr = @"10";
    if (*tmpReg == 0x04)
        *FD_ONStr = @"01";
    if (*tmpReg == 0x00)
        *FD_ONStr = @"00";
}

#pragma mark - Process Product Type
- (void)ProcessProductType:(NSString **)ICProductStr UserMemoryStr:(NSString **)UserMemoryStr product:(Prod)product {
    if (product != UNKNOWN){
        if (product == NTAG_I2C_1K)
            *ICProductStr = @"NXP NTAG I2C 1K";
        else if (product == NTAG_I2C_2K)
            *ICProductStr = @"NXP NTAG I2C 2K";
        else if (product == NTAG_I2C_1K_PLUS)
            *ICProductStr = @"NXP NTAG I2C 1K Plus";
        else if (product == NTAG_I2C_2K_PLUS)
            *ICProductStr = @"NXP NTAG I2C 2K Plus";
        
        *UserMemoryStr = [NSString stringWithFormat:@"%d Bytes", [[Ntag_Get_Version alloc] getMemsize:product]];
    }
}

#pragma mark - get Config Registers From Data Read
-(NSDictionary *) getConfigRegistersFromDataRead: (NSData *) dataRead
{
    // General Chip Information Parameters
    NSString * ICProductStr  = @"";
    NSString * UserMemoryStr = @"";
    
    // Field detection Parameters
    NSString * FD_OFFStr     = @"";
    NSString * FD_ONStr      = @"";
    
    //PassThrough Parameters
    NSString * PTStr         = @"";
    NSString * RFTOI2CStr    = @"";
    
    // SRAM Memory Settings
    NSString * LastNDEFBlockStr   = @"";
    NSString * SRAMMirrorBlockStr = @"";
    
    // I2C Settings
    NSString * WD_LSStr     = @"";
    NSString * WD_MSStr     = @"";
    NSString * I2CClocStretchkStr = @"";
    NSString * I2CRstOnStartStr   = @"";
    
    // I2C Settings
    NSString * Auth0Str         = @"";
    NSString * NFCProtStr       = @"";
    NSString * NFCDisSec1Str    = @"";
    NSString * AuthLIMStr       = @"";
    NSString * Prot2kStr        = @"";
    NSString * ProtSRAMStr      = @"";
    NSString * ProtI2CStr       = @"";
    
    // Delete this line and add it on input
    Prod product = [[NTAG_I2C_LIB sharedInstance] getProduct];
    
    const char * bytes = [dataRead bytes];
    
    [self ProcessProductType:&ICProductStr UserMemoryStr:&UserMemoryStr product:product];
    
    // Check I2C_RST_ON_OFF
    NC_Reg = bytes[NC_REG];
    
    // Check FD_OFF
    char tmpReg = [self CheckFD_OFF:&FD_OFFStr];
    
    // Check FD_ON
    [self CheckFD_ON:&FD_ONStr tmpReg:&tmpReg];

    //char NS_Reg = bytes[NS_REG];

    // Check PTHRU_ON_OFF
    if ((NC_Reg & PTHRU_ON_OFF) == PTHRU_ON_OFF)
        PTStr = @"true";
    else
        PTStr = @"false";
    
    // Check PTHRU_DIR
    tmpReg = (NC_Reg & 0x01);
    if (tmpReg == 0x01)
        RFTOI2CStr = @"true";
    else
        RFTOI2CStr = @"false";
    
    // last NDEF Block
    unsigned char lasTNdefByte = 0xFF & bytes[LAST_NDEF_PAGE];
    LastNDEFBlockStr = [NSString stringWithFormat:@"%d", lasTNdefByte];
    
    // SM_Reg
    unsigned char SMReg = 0xFF & bytes[SM_REG];
    SRAMMirrorBlockStr = [NSString stringWithFormat:@"%d", SMReg];
    
    // WD_LS_Reg
    unsigned char WDLSReg = 0xFF & bytes[WDT_LS];
    WD_LSStr = [NSString stringWithFormat:@"%d", WDLSReg];

    // WD_MS_Reg
    unsigned char WDMSReg = 0xFF & bytes[WDT_MS];
    WD_MSStr = [NSString stringWithFormat:@"%d", WDMSReg];
    
    // I2C_CLOCK_STR
    if(bytes[I2C_CLOCK_STR] == 1)
        I2CClocStretchkStr = @"true";
    else
        I2CClocStretchkStr = @"false";
    
    if((NC_Reg & I2C_RST_ON_OFF) == I2C_RST_ON_OFF)
        I2CRstOnStartStr = @"true";
    else
        I2CRstOnStartStr = @"false";
        
    // Get Plus Registers if NTAG Plus
    if (product == NTAG_I2C_1K_PLUS || product == NTAG_I2C_2K_PLUS){
        NSData * Auth0Reg = [self getAuthRegister];
        NSData * AccessReg = [self getAccessRegister];
        NSData * PTI2CReg = [self getPTI2CRegister];
        
        const char * auth0Bytes = [Auth0Reg bytes];
        const char * accessBytes = [AccessReg bytes];
        const char * pti2cBytes = [PTI2CReg bytes];
        
        // AUTH0 Register
        Auth0Str = [NSString stringWithFormat:@"%d", (0x0000FF & auth0Bytes[3])];
        
        // ACCESS Register
        [self ProcessAccessRegister:&AuthLIMStr NFCDisSec1Str:&NFCDisSec1Str NFCProtStr:&NFCProtStr Prot2kStr:&Prot2kStr ProtI2CStr:&ProtI2CStr ProtSRAMStr:&ProtSRAMStr accessBytes:accessBytes pti2cBytes:pti2cBytes];
    }
    
    NSDictionary *dataForTesting = [[NSDictionary alloc] init];

    dataForTesting = @{
        TXT_IC_PROD:     ICProductStr,
        TXT_USER_MEMORY: UserMemoryStr,
        TXT_FD_OFF:      FD_OFFStr,
        TXT_FD_ON:       FD_ONStr,
        TXT_PT:          RFTOI2CStr,
        TXT_RFTOI2C:     RFTOI2CStr,
        TXT_LAST_NDEF_BLOCK:    LastNDEFBlockStr,
        TXT_SRAM_MIRROR_BLOCK:  SRAMMirrorBlockStr,
        TXT_WD_LS:       WD_LSStr,
        TXT_WD_MS:       WD_MSStr,
        TXT_I2C_CLOCK:   I2CClocStretchkStr,
        TXT_I2C_RST:     I2CRstOnStartStr,
        TXT_AUTH0:       Auth0Str,
        TXT_NFC_PROT:    NFCProtStr,
        TXT_NFC_DIS_SEC1:NFCDisSec1Str,
        TXT_AUTH_LIM:    AuthLIMStr,
        TXT_PROT2K:      Prot2kStr,
        TXT_SRAMPROT:    ProtSRAMStr,
        TXT_I2CPROT:     ProtI2CStr
    };

    return dataForTesting;
}

#pragma mark - get Auth Register
- (NSData *) getAuthRegister{
    __block NSData * authReg = [[NSData alloc] init];

    [[NTAG_I2C_LIB sharedInstance] SectorSelect:0 onSuccess:^(NSData *aData) {
            
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    [[NTAG_I2C_LIB sharedInstance] read:AUTH0 onSuccess:^(NSData *aData) {
        authReg = aData;
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    [NSThread sleepForTimeInterval:0.1f];

    return authReg;
}

#pragma mark - get Access Register
- (NSData *) getAccessRegister{
    __block NSData * accessReg = [[NSData alloc] init];

    [[NTAG_I2C_LIB sharedInstance] SectorSelect:0 onSuccess:^(NSData *aData) {
            
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    [[NTAG_I2C_LIB sharedInstance] read:ACCESS onSuccess:^(NSData *aData) {
        accessReg = aData;
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    [NSThread sleepForTimeInterval:0.1f];

    return accessReg;
}

#pragma mark - get PT I2C Register
- (NSData *) getPTI2CRegister{
    __block NSData * pti2cReg = [[NSData alloc] init];

    [[NTAG_I2C_LIB sharedInstance] SectorSelect:0 onSuccess:^(NSData *aData) {
            
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    [[NTAG_I2C_LIB sharedInstance] read:PTI2C onSuccess:^(NSData *aData) {
        pti2cReg = aData;
    } onFailure:^(NSError *error) {
        [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
    }];
    
    [NSThread sleepForTimeInterval:0.1f];

    return pti2cReg;
}


@end
