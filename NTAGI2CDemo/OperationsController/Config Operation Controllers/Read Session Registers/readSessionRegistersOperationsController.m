//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "readSessionRegistersOperationsController.h"

@implementation readSessionRegistersOperationsController : NSObject

#pragma mark - sharedInstance
+ (readSessionRegistersOperationsController *) sharedInstance{
    static readSessionRegistersOperationsController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance                  = [[readSessionRegistersOperationsController alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Read session registers
- (void) readSessionRegisters:(void (^)(NSDictionary * dictionary) )success  onFailure : (void(^)(AuthStatus status))failure{
    
    Prod product = [[NTAG_I2C_LIB sharedInstance]getProduct];
    AuthStatus status = [[NTAG_I2C_LIB sharedInstance] obtainAuthStatus];
    
    if((product != NTAG_I2C_1K_PLUS && product != NTAG_I2C_2K_PLUS) || (status == DISABLED || status == UNPROTECTED || status == AUTHENTICATED)){
        
        NSInteger sector     = 3;
        NSInteger sessionReg = 0xF8;
        
        Prod product = [[NTAG_I2C_LIB sharedInstance] getProduct];
        
        if (product == NTAG_I2C_1K_PLUS || product == NTAG_I2C_2K_PLUS){
            sector           = 0;
            sessionReg       = 0xEC;
        }
        
        [[NTAG_I2C_LIB sharedInstance] SectorSelect:sector onSuccess:^(NSData *aData) {
            
        } onFailure:^(NSError *error) {
            [[NTAG_I2C_LIB sharedInstance]  closeWithCustomMessage:MSG_ERROR_TRANS];
        }];
        
        [[NTAG_I2C_LIB sharedInstance]   read:sessionReg onSuccess:^(NSData *aData) {
            success([self getSessionRegistersFromDataRead:aData]);
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

#pragma mark - Process FD OFF
- (char)ProcessFD_OFF:(NSString **)FD_OFFStr NC_Reg:(char)NC_Reg {
    char tmpReg = NC_Reg & FD_OFF;
    
    if (tmpReg == 0x30)
        *FD_OFFStr = @"11b";
    if (tmpReg == 0x20)
        *FD_OFFStr = @"10b";
    if (tmpReg == 0x10)
        *FD_OFFStr = @"01b";
    if (tmpReg == 0x00)
        *FD_OFFStr = @"00b";
    return tmpReg;
}

#pragma mark - Process FD ON
- (void)ProcessFD_ON:(NSString **)FD_ONStr NC_Reg:(char)NC_Reg tmpReg:(char *)tmpReg {
    *tmpReg = NC_Reg & FD_ON;
    
    if (*tmpReg == 0x0c)
        *FD_ONStr = @"11b";
    if (*tmpReg == 0x08)
        *FD_ONStr = @"10b";
    if (*tmpReg == 0x04)
        *FD_ONStr = @"01b";
    if (*tmpReg == 0x00)
        *FD_ONStr = @"00b";
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

#pragma mark - get Session Registers From Data Read
-(NSDictionary *) getSessionRegistersFromDataRead: (NSData *) dataRead{
    NSString * ICProductStr     = @"";
    NSString * UserMemoryStr    = @"";
    NSString * RSTStr           = @"";
    NSString * FD_OFFStr        = @"";
    NSString * FD_ONStr         = @"";
    NSString * LastNDEFStr      = @"";
    NSString * NDEFDataReadStr  = @"";
    NSString * RFFieldPresentStr = @"";
    NSString * PTStr            = @"";
    NSString * I2CLockedStr     = @"";
    NSString * RFLockedStr      = @"";
    NSString * SRAMI2CReadyStr  = @"";
    NSString * SRAMRFReadyStr   = @"";
    NSString * RFTOI2CStr       = @"";
    NSString * SRAMMirrorStr    = @"";
    NSString * SRAMMirrorBlockStr = @"";
    NSString * WD_LSStr         = @"";
    NSString * WD_MSStr         = @"";
    NSString * I2CClockStr      = @"";
    
    // Delete this line and add it on input
    Prod product = [[NTAG_I2C_LIB sharedInstance] getProduct];
    const char * bytes = [dataRead bytes];
    
    [self ProcessProductType:&ICProductStr UserMemoryStr:&UserMemoryStr product:product];
    
    // Check I2C_RST_ON_OFF
    char NC_Reg = bytes[NC_REG];
    
    if ((NC_Reg & I2C_RST_ON_OFF) == I2C_RST_ON_OFF)
        RSTStr = @"true";
    else
        RSTStr = @"false";

    // Check FD_OFF
    char tmpReg = [self ProcessFD_OFF:&FD_OFFStr NC_Reg:NC_Reg];
    
    // Check FD_ON
    [self ProcessFD_ON:&FD_ONStr NC_Reg:NC_Reg tmpReg:&tmpReg];
    
    // last NDEF Page
    unsigned char lasTNdefByte = 0xFF & bytes[LAST_NDEF_PAGE];
    LastNDEFStr = [NSString stringWithFormat:@"%d", lasTNdefByte];

    char NS_Reg = bytes[NS_REG];
    
    // Check NDWF_DATA_READ
    if ((NS_Reg & NDEF_DATA_READ) == NDEF_DATA_READ)
        NDEFDataReadStr = @"true";
    else
        NDEFDataReadStr = @"false";

    // Check RF_FIELD
    if ((NS_Reg & RF_FIELD_PRESENT) == RF_FIELD_PRESENT)
       RFFieldPresentStr = @"true";
    else
       RFFieldPresentStr = @"false";

    // Check PTHRU_ON_OFF
    if ((NC_Reg & PTHRU_ON_OFF) == PTHRU_ON_OFF)
        PTStr = @"true";
    else
        PTStr = @"false";
    
    // Check I2C_LOCKED
    if ((NS_Reg & I2C_LOCKED) == I2C_LOCKED)
        I2CLockedStr = @"true";
    else
        I2CLockedStr = @"false";
    
    // Check RF_LOCKED
    if ((NS_Reg & RF_LOCKED) == RF_LOCKED)
        RFLockedStr = @"true";
    else
        RFLockedStr = @"false";
    
    // Check SRAM_I2C_Ready
    if ((NS_Reg & SRAM_I2C_READY) == SRAM_I2C_READY)
        SRAMI2CReadyStr = @"true";
    else
        SRAMI2CReadyStr = @"false";
    
    // Check SRAM_RF_Ready
    if ((NS_Reg & SRAM_RF_READY) == SRAM_RF_READY)
        SRAMRFReadyStr = @"true";
    else
        SRAMRFReadyStr = @"false";
    
    // Check PTHRU_DIR
    tmpReg = (NC_Reg & 0x01);
    if (tmpReg == 0x01)
        RFTOI2CStr = @"true";
    else
        RFTOI2CStr = @"false";

    // SM_Reg
    unsigned char SMReg = 0xFF & bytes[SM_REG];
    SRAMMirrorBlockStr = [NSString stringWithFormat:@"%d", SMReg];
    
    // WD_LS_Reg
    unsigned char WDLSReg = 0xFF & bytes[WDT_LS];
    WD_LSStr = [NSString stringWithFormat:@"%d", WDLSReg];
    
    // WD_MS_Reg
    unsigned char WDMSReg = 0xFF & bytes[WDT_MS];
    WD_MSStr = [NSString stringWithFormat:@"%d", WDMSReg];
    
    // Check SRAM_MIRROR_ON_OFF
    if ((NC_Reg & SRAM_MIRROR_ON_OFF) == SRAM_MIRROR_ON_OFF)
        SRAMMirrorStr = @"true";
    else
        SRAMMirrorStr = @"false";
    
    // I2C_CLOCK_STR
    if(bytes[I2C_CLOCK_STR] == 1)
        I2CClockStr = @"true";
    else
        I2CClockStr = @"false";

    NSDictionary *dataForTesting = [[NSDictionary alloc] init];
    dataForTesting = @{
        TXT_IC_PROD: ICProductStr,
        TXT_USER_MEMORY: UserMemoryStr,
        TXT_RST_START: RSTStr,
        TXT_FD_OFF: FD_OFFStr,
        TXT_FD_ON: FD_ONStr,
        TXT_LAST_NDEF_BLOCK: LastNDEFStr,
        TXT_NDEF_DATA_READ: NDEFDataReadStr,
        TXT_RF_FIELD_PRESENT: RFFieldPresentStr,
        TXT_PT: PTStr,
        TXT_I2_LOCKED: I2CLockedStr,
        TXT_RF_LOCKED: RFLockedStr,
        TXT_SRAM_I2C_READY: SRAMI2CReadyStr,
        TXT_SRAM_RF_READY: SRAMRFReadyStr,
        TXT_RFTOI2C: RFTOI2CStr,
        TXT_SRAM_MIRROR: SRAMMirrorStr,
        TXT_SRAM_MIRROR_BLOCK: SRAMMirrorBlockStr,
        TXT_WD_LS: WD_LSStr,
        TXT_WD_MS: WD_MSStr,
        TXT_I2C_CLOCK: I2CClockStr
    };
    return dataForTesting;
}

@end
