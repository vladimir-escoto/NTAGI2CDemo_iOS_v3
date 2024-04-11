//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "ReadWriteConfigurationRegistersViewController.h"
#import "FieldDetectionMenuTableCell.h"
#import "PassThroughSwitchesTableCell.h"
#import "SramMemoryTextTableCell.h"
#import "I2cSettingsTextTableCell.h"
#import "GeneralChipInfoTableCell.h"
#import "AccessConfigurationTableCell.h"
#import "AuthViewController.h"
#import "RWConfigRegisters.h"

@interface ReadWriteConfigurationRegistersViewController()
@end

@implementation ReadWriteConfigurationRegistersViewController

NSString * ICProductStr         = @"";
NSString * UserMemoryStr        = @"";
NSString * FD_OFFStr            = @"";
NSString * FD_ONStr             = @"";
NSString * PTStr                = @"";
NSString * RFTOI2CStr           = @"";
NSString * LastNDEFBlockStr     = @"";
NSString * SRAMMirrorBlockStr   = @"";
NSString * WD_LSStr             = @"";
NSString * WD_MSStr             = @"";
NSString * I2CClocStretchkStr   = @"";
NSString * I2CRstOnStartStr     = @"";
NSString * Auth0Str             = @"";
NSString * NFCProtStr           = @"";
NSString * NFCDisSec1Str        = @"";
NSString * AuthLIMStr           = @"";
NSString * Prot2kStr            = @"";
NSString * ProtSRAMStr          = @"";
NSString * ProtI2CStr           = @"";

bool afterRead = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SetUIViews];
}

- (IBAction)onCancelButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onReadConfigButtonClick:(id)sender {
    [[NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    NSLog(@"Waiting for connection...");
    while ([[NTAG_I2C_LIB sharedInstance] isConnect] == 0){}
    if([[NTAG_I2C_LIB sharedInstance]isConnect] == 3){
        NSLog(@"Connected!!!");
        [[RWConfigRegisters sharedInstance] readConfigRegisters:^(NSDictionary * _Nonnull dictionary) {
            afterRead = true;
            [self displayConfigRegisters:dictionary];
        } onFailure:^(AuthStatus status) {
            [self throwAuthController: &status];
        }];
    }else if([[NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
        [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    }
}

- (IBAction)onWriteConfigButonClick:(id)sender {
    if(![self checkInputs]){
        [self showAlertMessage];
        return;
    }
    
    [[NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    NSLog(@"Waiting for connection...");
    while ([[NTAG_I2C_LIB sharedInstance] isConnect] == 0){}
    if([[NTAG_I2C_LIB sharedInstance]isConnect] == 3){
        NSLog(@"Connected!!!");
        NSDictionary * dict = [self getParamsForWriting];
        [[RWConfigRegisters sharedInstance] writeConfigRegisters:dict onSuccess:^(NSDictionary * _Nonnull dictionary) {
        } onFailure:^(AuthStatus status) {
            [self throwAuthController: &status];
        }];
    }else if([[NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
        [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    }
}

- (NSDictionary *) getParamsForWriting{
    NSDictionary *dataForWriting = [[NSDictionary alloc] init];
    dataForWriting = @{
        TXT_IC_PROD:            ICProductStr,
        TXT_USER_MEMORY:        UserMemoryStr,
        TXT_FD_OFF:             FD_OFFStr,
        TXT_FD_ON:              FD_ONStr,
        TXT_PT:                 RFTOI2CStr,
        TXT_RFTOI2C:            RFTOI2CStr,
        TXT_LAST_NDEF_BLOCK:    LastNDEFBlockStr,
        TXT_SRAM_MIRROR_BLOCK:  SRAMMirrorBlockStr,
        TXT_WD_LS:              WD_LSStr,
        TXT_WD_MS:              WD_MSStr,
        TXT_I2C_CLOCK:          I2CClocStretchkStr,
        TXT_I2C_RST:            I2CRstOnStartStr,
        TXT_AUTH0:              Auth0Str,
        TXT_NFC_PROT:           NFCProtStr,
        TXT_NFC_DIS_SEC1:       NFCDisSec1Str,
        TXT_AUTH_LIM:           AuthLIMStr,
        TXT_PROT2K:             Prot2kStr,
        TXT_SRAMPROT:           ProtSRAMStr,
        TXT_I2CPROT:            ProtI2CStr
    };
    return dataForWriting;
}

/*
 *  Methods to control readSessionRegisters tableView
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier;
    if (indexPath.row == 0) {
        cellIdentifier = CHIP_INFO_CELLID;
        GeneralChipInfoTableCell *generalChipInfoTableCell = [self.configurationRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (generalChipInfoTableCell == nil) {
            generalChipInfoTableCell = [[GeneralChipInfoTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            generalChipInfoTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (afterRead){
            generalChipInfoTableCell.icProductValueLabel.text = [_configRegisters objectForKey:TXT_IC_PROD];
            generalChipInfoTableCell.userMemoryValueLabel.text = [_configRegisters objectForKey:TXT_USER_MEMORY];
        }
        return generalChipInfoTableCell;
    }else if (indexPath.row == 1) {
        cellIdentifier = FIELD_DETECTION_MENU_CELLID;
        FieldDetectionMenuTableCell *fieldDetectionMenuTableCell = [self.configurationRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (fieldDetectionMenuTableCell == nil){
            fieldDetectionMenuTableCell = [[FieldDetectionMenuTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            fieldDetectionMenuTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (afterRead){
            fieldDetectionMenuTableCell.FD_OFFTextField.text = [_configRegisters objectForKey:TXT_FD_OFF];
            fieldDetectionMenuTableCell.FD_ONTextField.text = [_configRegisters objectForKey:TXT_FD_ON];
        }
        [fieldDetectionMenuTableCell.FD_OFFTextField addTarget:self action:@selector(FD_OFFTextChanged:) forControlEvents:UIControlEventEditingChanged];
        [fieldDetectionMenuTableCell.FD_ONTextField addTarget:self action:@selector(FD_ONTextChanged:) forControlEvents:UIControlEventEditingChanged];
        return fieldDetectionMenuTableCell;
    }else if (indexPath.row == 2) {
        cellIdentifier = PASSTHROUGH_SWITCHES_CELLID;
        PassThroughSwitchesTableCell *passThroughSwitchesTableCell = [self.configurationRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (passThroughSwitchesTableCell == nil) {
            passThroughSwitchesTableCell = [[PassThroughSwitchesTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            passThroughSwitchesTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (afterRead){
            if ([[_configRegisters objectForKey:TXT_PT]  isEqual: @"false"])
                passThroughSwitchesTableCell.directionSegmentedControl.selectedSegmentIndex = 0;
            else
                passThroughSwitchesTableCell.directionSegmentedControl.selectedSegmentIndex = 1;

            if ([[_configRegisters objectForKey:TXT_RFTOI2C]  isEqual: @"false"])
                passThroughSwitchesTableCell.writeFromRfSegmentedControl.selectedSegmentIndex = 0;
            else
                passThroughSwitchesTableCell.writeFromRfSegmentedControl.selectedSegmentIndex = 1;
        }

        return passThroughSwitchesTableCell;
        
    }else if (indexPath.row == 3) {
        cellIdentifier = SRAM_MEMORY_CELLID;
        SramMemoryTextTableCell *sramMemoryTextTableCell = [self.configurationRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (sramMemoryTextTableCell == nil) {
            sramMemoryTextTableCell = [[SramMemoryTextTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            sramMemoryTextTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (afterRead){
            sramMemoryTextTableCell.lastBlockTextField.text  = [_configRegisters objectForKey:TXT_LAST_NDEF_BLOCK];
            sramMemoryTextTableCell.sramMirrorTextField.text = [_configRegisters objectForKey:TXT_SRAM_MIRROR_BLOCK];
        }
        [sramMemoryTextTableCell.lastBlockTextField  addTarget:self action:@selector(lastBlockTextChanged:)  forControlEvents:UIControlEventEditingChanged];
        [sramMemoryTextTableCell.sramMirrorTextField addTarget:self action:@selector(sramMemotyTextChanged:) forControlEvents:UIControlEventEditingChanged];
        
        return sramMemoryTextTableCell;
    }else if (indexPath.row == 4) {
        cellIdentifier = I2C_SETTINGS_TEXT_CELLID;
        I2cSettingsTextTableCell *i2cSettingsTextTableCell = [self.configurationRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (i2cSettingsTextTableCell == nil) {
            i2cSettingsTextTableCell = [[I2cSettingsTextTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            i2cSettingsTextTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (afterRead){
            i2cSettingsTextTableCell.wdLsTimerTextField.text = [_configRegisters objectForKey:TXT_WD_LS];
            i2cSettingsTextTableCell.wdMsTimerTextField.text = [_configRegisters objectForKey:TXT_WD_MS];
        
            if ([[_configRegisters objectForKey:TXT_I2C_CLOCK]  isEqual: @"false"])
                 i2cSettingsTextTableCell.i2cClockStretchSegmentedControl.selectedSegmentIndex = 0;
            else
                 i2cSettingsTextTableCell.i2cClockStretchSegmentedControl.selectedSegmentIndex = 1;
            if ([[_configRegisters objectForKey:TXT_I2C_RST]  isEqual: @"false"])
                 i2cSettingsTextTableCell.i2cRstSegmentedControl.selectedSegmentIndex = 0;
            else
                 i2cSettingsTextTableCell.i2cRstSegmentedControl.selectedSegmentIndex = 1;
        }

        [i2cSettingsTextTableCell.wdLsTimerTextField addTarget:self action:@selector(wdLsTimerTextChanged:) forControlEvents:UIControlEventEditingChanged];
        [i2cSettingsTextTableCell.wdMsTimerTextField addTarget:self action:@selector(wdMsTimerTextChanged:) forControlEvents:UIControlEventEditingChanged];
        
        return i2cSettingsTextTableCell;
        
    }else if (indexPath.row == 5) {
        
        cellIdentifier = ACCESS_CONFIGURATION_CELLID;
        AccessConfigurationTableCell *accessConfigurationTableCell =[self.configurationRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (accessConfigurationTableCell == nil) {
            accessConfigurationTableCell = [[AccessConfigurationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            accessConfigurationTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (afterRead){
            accessConfigurationTableCell.auth0TextField.text = [_configRegisters objectForKey:TXT_AUTH0];
            if ([[_configRegisters objectForKey:TXT_NFC_PROT]  isEqual: @"false"])
                accessConfigurationTableCell.nfcProtSegmentedControl.selectedSegmentIndex = 0;
            else
                accessConfigurationTableCell.nfcProtSegmentedControl.selectedSegmentIndex = 1;
            if ([[_configRegisters objectForKey:TXT_NFC_DIS_SEC1]  isEqual: @"false"])
                accessConfigurationTableCell.nfcDisSegmentedControl.selectedSegmentIndex = 0;
            else
                accessConfigurationTableCell.nfcDisSegmentedControl.selectedSegmentIndex = 1;
            accessConfigurationTableCell.authLimTextField.text = [_configRegisters objectForKey:TXT_AUTH_LIM];
            if ([[_configRegisters objectForKey:TXT_PROT2K]  isEqual: @"false"])
                accessConfigurationTableCell.twoKSegmentedControl.selectedSegmentIndex = 0;
            else
                accessConfigurationTableCell.twoKSegmentedControl.selectedSegmentIndex = 1;
            if ([[_configRegisters objectForKey:TXT_SRAMPROT]  isEqual: @"false"])
                accessConfigurationTableCell.sramProtSegmentedControl.selectedSegmentIndex = 0;
            else
                accessConfigurationTableCell.sramProtSegmentedControl.selectedSegmentIndex = 1;

            accessConfigurationTableCell.i2cProtTextField.text = [_configRegisters objectForKey:TXT_I2CPROT];
        }
        
        [accessConfigurationTableCell.auth0TextField   addTarget:self action:@selector(auth0TextChanged:)   forControlEvents:UIControlEventEditingChanged];
        [accessConfigurationTableCell.authLimTextField addTarget:self action:@selector(authLimTextChanged:) forControlEvents:UIControlEventEditingChanged];
        
        afterRead = false;
        return accessConfigurationTableCell;
    }
    else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_collapsedStatus[indexPath.row] boolValue]){
        return 40.0;
    }else{
        return [_expandedHeights[indexPath.row] floatValue];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (IBAction)onGeneralChipInfoCollapseButtonClicked:(id)sender {
    _collapsedStatus[0] = ([_collapsedStatus[0] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_configurationRegistersTableView reloadData];
}

- (IBAction)onFieldDetectionCollapseButtonClicked:(id)sender {
    _collapsedStatus[1] = ([_collapsedStatus[1] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_configurationRegistersTableView reloadData];
}

- (IBAction)onPassthroughCollapseButtonClicked:(id)sender {
    _collapsedStatus[2] = ([_collapsedStatus[2] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_configurationRegistersTableView reloadData];
}

- (IBAction)onSramMemoryCollapseButtonClicked:(id)sender {
    _collapsedStatus[3] = ([_collapsedStatus[3] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_configurationRegistersTableView reloadData];
}

- (IBAction)onI2cSettingsCollapseButtonClicked:(id)sender {
    _collapsedStatus[4] = ([_collapsedStatus[4] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_configurationRegistersTableView reloadData];
}

- (IBAction)onAccessControlCollapseButtonClicked:(id)sender {
    _collapsedStatus[5] = ([_collapsedStatus[5] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_configurationRegistersTableView reloadData];
}

- (void) updateParameters: (NSDictionary *) dataRead{
    ICProductStr        = [dataRead objectForKey:TXT_IC_PROD];
    UserMemoryStr       = [dataRead objectForKey:TXT_USER_MEMORY];
    FD_OFFStr           = [dataRead objectForKey:TXT_FD_OFF];
    FD_ONStr            = [dataRead objectForKey:TXT_FD_ON];
    PTStr               = [dataRead objectForKey:TXT_PT];
    RFTOI2CStr          = [dataRead objectForKey:TXT_RFTOI2C];
    LastNDEFBlockStr    = [dataRead objectForKey:TXT_LAST_NDEF_BLOCK];
    SRAMMirrorBlockStr  = [dataRead objectForKey:TXT_SRAM_MIRROR_BLOCK];
    WD_LSStr            = [dataRead objectForKey:TXT_WD_LS];
    WD_MSStr            = [dataRead objectForKey:TXT_WD_MS];
    I2CClocStretchkStr  = [dataRead objectForKey:TXT_I2C_CLOCK];
    I2CRstOnStartStr    = [dataRead objectForKey:TXT_I2C_RST];
    Auth0Str            = [dataRead objectForKey:TXT_AUTH0];
    NFCProtStr          = [dataRead objectForKey:TXT_NFC_PROT];
    NFCDisSec1Str       = [dataRead objectForKey:TXT_NFC_DIS_SEC1];
    AuthLIMStr          = [dataRead objectForKey:TXT_AUTH_LIM];
    Prot2kStr           = [dataRead objectForKey:TXT_PROT2K];
    ProtSRAMStr         = [dataRead objectForKey:TXT_SRAMPROT];
    ProtI2CStr          = [dataRead objectForKey:TXT_I2CPROT];
}

-(void)dismissKeyboard{
    [self.view endEditing:YES];
}

- (IBAction)writeFromRFChanged:(id)sender {
    if ([RFTOI2CStr  isEqual: @"true"]){
        PTStr = @"false";
        RFTOI2CStr = @"false";
    }
    else{
        PTStr = @"true";
        RFTOI2CStr = @"true";
    }
}

- (IBAction)directionPTChanged:(id)sender {
    if ([PTStr  isEqual: @"true"]){
        PTStr = @"false";
        RFTOI2CStr = @"false";
    }
    else{
        PTStr = @"true";
        RFTOI2CStr = @"true";
    }
}

- (IBAction)i2cClockStretchChanged:(id)sender {
    if ([I2CClocStretchkStr  isEqual: @"true"])
        I2CClocStretchkStr = @"false";
    else
        I2CClocStretchkStr = @"true";
}

- (IBAction)i2cRSTSOnStartChanged:(id)sender {
    if ([I2CRstOnStartStr  isEqual: @"true"])
        I2CRstOnStartStr = @"false";
    else
        I2CRstOnStartStr = @"true";
}

- (IBAction)NFCprotChanged:(id)sender {
    if ([NFCProtStr  isEqual: @"true"])
        NFCProtStr = @"false";
    else
        NFCProtStr = @"true";
}

- (IBAction)NFCDISSec1Changed:(id)sender {
    if ([NFCDisSec1Str  isEqual: @"true"])
        NFCDisSec1Str = @"false";
    else
        NFCDisSec1Str = @"true";
}

- (IBAction)k2ProtChanged:(id)sender {
    if ([Prot2kStr  isEqual: @"true"])
        Prot2kStr = @"false";
    else
        Prot2kStr = @"true";
}

- (IBAction)SRAMProtChanged:(id)sender {
    if ([ProtSRAMStr  isEqual: @"true"])
        ProtSRAMStr = @"false";
    else
        ProtSRAMStr = @"true";
}

- (void) lastBlockTextChanged:(UITextField *) textfield{
    LastNDEFBlockStr = textfield.text;
}

- (void) sramMemotyTextChanged:(UITextField *) textfield{
    SRAMMirrorBlockStr = textfield.text;
}

- (void) wdLsTimerTextChanged:(UITextField *) textfield{
    WD_LSStr = textfield.text;
}

- (void) wdMsTimerTextChanged:(UITextField *) textfield{
    WD_MSStr = textfield.text;
}

- (void) auth0TextChanged:(UITextField *) textfield{
    Auth0Str = textfield.text;
}

- (void) authLimTextChanged:(UITextField *) textfield{
    AuthLIMStr = textfield.text;
}

- (void) FD_OFFTextChanged:(UITextField *) textfield{
    FD_OFFStr = textfield.text;
}

- (void) FD_ONTextChanged:(UITextField *) textfield{
    FD_ONStr = textfield.text;
}

- (IBAction)scanButtonClick:(id)sender {
    [[NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    NSLog(@"Waiting for connection...");
    while ([[NTAG_I2C_LIB sharedInstance] isConnect] == 0){}
    if([[NTAG_I2C_LIB sharedInstance]isConnect] == 3){
        NSLog(@"Connected!!!");
        [[RWConfigRegisters sharedInstance] readConfigRegisters:^(NSDictionary * _Nonnull dictionary) {
            afterRead = true;
            [self displayConfigRegisters:dictionary];
        } onFailure:^(AuthStatus status) {
            [self throwAuthController: &status];
        }];
    }else if([[NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
        [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    }
}

- (void) displayConfigRegisters: (NSDictionary *) dictionary{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self->_configRegisters = dictionary;
        [_configurationRegistersTableView reloadData];
        self->_configurationRegistersTableView.hidden = false;
        self->_scanView.hidden = true;
        }];
    
    [self updateParameters: dictionary];
}

-(void) throwAuthController: (AuthStatus *) authStatus{
    NSString * storyboardName = TXT_SB_MAIN;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    AuthViewController * vc = [storyboard instantiateViewControllerWithIdentifier:TXT_AUTH_ID];
    [vc setAuthStatus:authStatus];
    [self presentViewController:vc animated:YES completion:nil];
}

-(bool) checkInputs{
    if (![FD_OFFStr  isEqual: @"00"] && ![FD_OFFStr  isEqual: @"01"] && ![FD_OFFStr  isEqual: @"10"] && ![FD_OFFStr  isEqual: @"11"])
        return false;
    if (![FD_ONStr  isEqual: @"00"] && ![FD_ONStr  isEqual: @"01"] && ![FD_ONStr  isEqual: @"10"] && ![FD_ONStr  isEqual: @"11"])
        return false;
    return true;
}

- (void)showAlertMessage{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert" message:MSG_TAG_WRONGINPUT_PARAMS preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)SetUIViews {
    _configurationRegistersTableView.dataSource = self;
    _configurationRegistersTableView.delegate = self;
    _configurationRegistersTableView.allowsSelection = YES;
    
    _expandedHeights = [[NSArray alloc] initWithObjects:
        [NSNumber numberWithFloat:110.0f],
        [NSNumber numberWithFloat:110.0f],
        [NSNumber numberWithFloat:120.0f],
        [NSNumber numberWithFloat:130.0f],
        [NSNumber numberWithFloat:220.0f],
        [NSNumber numberWithFloat:300.0f],
    nil];
    
    _collapsedStatus = [[NSMutableArray alloc] initWithObjects:
        [NSNumber numberWithBool:YES],
        [NSNumber numberWithBool:YES],
        [NSNumber numberWithBool:YES],
        [NSNumber numberWithBool:YES],
        [NSNumber numberWithBool:YES],
        [NSNumber numberWithBool:YES],
    nil];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    _scanView.hidden = false;
    _configurationRegistersTableView.hidden = true;
    
    _scanView.layer.cornerRadius        = 12;
    _scanView.layer.borderWidth         = 1.5;
    _scanView.layer.borderColor         = [UIColor blackColor].CGColor;
    _scanView.layer.masksToBounds       = true;
    
}

@end
