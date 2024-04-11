//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "ReadSessionRegistersViewController.h"


@interface ReadSessionRegistersViewController ()
@end

@implementation ReadSessionRegistersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SetUIView];
}

- (IBAction)scanButtonClick:(id)sender {
    [[NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    NSLog(@"Waiting for connection...");
    while ([[NTAG_I2C_LIB sharedInstance] isConnect] == 0){}

    if([[NTAG_I2C_LIB sharedInstance]isConnect] == 3){
       NSLog(@"Connected!!!");
       [[readSessionRegistersOperationsController sharedInstance] readSessionRegisters:^(NSDictionary * _Nonnull dictionary) {
           [self displaySessionRegisters:dictionary];
       } onFailure:^(AuthStatus status) {
           [self throwAuthController: &status];
       }];
    }else if([[NTAG_I2C_LIB sharedInstance]isConnect] == 4){
       NSLog(@"Not connected!!!");
       [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    }
}

- (IBAction)onCancelButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
        GeneralChipInfoTableCell *generalChipInfoTableCell = [self.sessionRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
     
        if (generalChipInfoTableCell == nil) {
            generalChipInfoTableCell = [[GeneralChipInfoTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            generalChipInfoTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        generalChipInfoTableCell.icProductValueLabel.text = [_sessionRegistersRead objectForKey:@"IC Product"];
        generalChipInfoTableCell.userMemoryValueLabel.text = [_sessionRegistersRead objectForKey:@"User Memory"];
        return generalChipInfoTableCell;
        
    }else if (indexPath.row == 1) {
        
        cellIdentifier = NTAG_CONFIG_CELLID;
        NtagConfigurationTableCell *ntagConfigurationTableCell = [self.sessionRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
       
        if (ntagConfigurationTableCell == nil){
            ntagConfigurationTableCell = [[NtagConfigurationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            ntagConfigurationTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if([[_sessionRegistersRead objectForKey:@"RST on Start"] isEqualToString:@"true"]) {
            ntagConfigurationTableCell.checkBoxImageView.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            ntagConfigurationTableCell.checkBoxImageView.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        return ntagConfigurationTableCell;
        
    }else if (indexPath.row == 2) {
        
        cellIdentifier = FIELD_DETECT_CELLID;
        FieldDetectionTableCell *fieldDetectionTableCell = [self.sessionRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (fieldDetectionTableCell == nil) {
            fieldDetectionTableCell = [[FieldDetectionTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            fieldDetectionTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        fieldDetectionTableCell.fdOffValueLabel.text = [_sessionRegistersRead objectForKey:@"FD_OFF"];
        fieldDetectionTableCell.fdOnValueLabel.text = [_sessionRegistersRead objectForKey:@"FD_ON"];
        fieldDetectionTableCell.lastBlockValueLabel.text = [_sessionRegistersRead objectForKey:@"Last NDEF Block"];
        
        if([[_sessionRegistersRead objectForKey:@"NDEF Data Read"] isEqualToString:@"true"]) {
            fieldDetectionTableCell.dataReadCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            fieldDetectionTableCell.dataReadCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        if([[_sessionRegistersRead objectForKey:@"RF Field present"] isEqualToString:@"true"]) {
            fieldDetectionTableCell.rfFieldCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            fieldDetectionTableCell.rfFieldCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        return fieldDetectionTableCell;
        
    }else if (indexPath.row == 3) {
        
        cellIdentifier = PASSTHROUGH_CELLID;
        PassthroughTableCell *passthroughTableCell = [self.sessionRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
      
        if (passthroughTableCell == nil) {
            passthroughTableCell = [[PassthroughTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            passthroughTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if([[_sessionRegistersRead objectForKey:@"PT"] isEqualToString:@"true"]) {
            passthroughTableCell.passthroughCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            passthroughTableCell.passthroughCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        if([[_sessionRegistersRead objectForKey:@"I2Locked"] isEqualToString:@"true"]) {
            passthroughTableCell.i2cLockedCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            passthroughTableCell.i2cLockedCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        if([[_sessionRegistersRead objectForKey:@"RFLocked"] isEqualToString:@"true"]) {
            passthroughTableCell.rfLockedCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            passthroughTableCell.rfLockedCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        if([[_sessionRegistersRead objectForKey:@"SRAMI2CReady"] isEqualToString:@"true"]) {
            passthroughTableCell.sramI2cReadyCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            passthroughTableCell.sramI2cReadyCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        if([[_sessionRegistersRead objectForKey:@"SRAMRFReady"] isEqualToString:@"true"]) {
            passthroughTableCell.sramRfReadyCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            passthroughTableCell.sramRfReadyCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        if([[_sessionRegistersRead objectForKey:@"RFTOI2C"] isEqualToString:@"true"]) {
            passthroughTableCell.rfToI2cCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            passthroughTableCell.rfToI2cCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        return passthroughTableCell;
        
    }else if (indexPath.row == 4) {
        
        cellIdentifier = SRAM_MEM_CELLID;
        SramMemorySettingsTableCell *sramMemorySettingsTableCell = [self.sessionRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (sramMemorySettingsTableCell == nil) {
            sramMemorySettingsTableCell = [[SramMemorySettingsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            sramMemorySettingsTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        sramMemorySettingsTableCell.sramMirrorBlockLabel.text = [_sessionRegistersRead objectForKey:@"SRAMMirrorBlock"];
        if([[_sessionRegistersRead objectForKey:@"SRAMMirror"] isEqualToString:@"true"]) {
            sramMemorySettingsTableCell.sramMirrorCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            sramMemorySettingsTableCell.sramMirrorCheckbox.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        return sramMemorySettingsTableCell;
    }else if (indexPath.row == 5) {
        
        cellIdentifier = I2C_SETTINGS_CELLID;
        I2cSettingsTableCell *i2cSettingsTableCell = [self.sessionRegistersTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (i2cSettingsTableCell == nil) {
            i2cSettingsTableCell = [[I2cSettingsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            i2cSettingsTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        i2cSettingsTableCell.wdLsValue.text = [_sessionRegistersRead objectForKey:@"WD_LS"];
        i2cSettingsTableCell.wdMsValue.text = [_sessionRegistersRead objectForKey:@"WD_MS"];
        
        if([[_sessionRegistersRead objectForKey:@"I2CClock"] isEqualToString:@"true"]) {
            i2cSettingsTableCell.i2cClockStretchValue.image = [UIImage imageNamed:IMG_CHECKBOX_ON];
        }else{
            i2cSettingsTableCell.i2cClockStretchValue.image = [UIImage imageNamed:IMG_CHECKBOX_OFF];
        }
        
        return i2cSettingsTableCell;
        
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (IBAction)onGeneralChipInfoTitleClick:(id)sender {
    NSLog(@"Click on General Chip Info");
    _collapsedStatus[0] = ([_collapsedStatus[0] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_sessionRegistersTableView reloadData];
}

- (IBAction)onNtagConfigurationTitleClick:(id)sender {
    NSLog(@"Click on Ntag Configuration");
    _collapsedStatus[1] = ([_collapsedStatus[1] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_sessionRegistersTableView reloadData];
}

- (IBAction)onFieldDetectionTitleClick:(id)sender {
    NSLog(@"Click on Field Detection");
    _collapsedStatus[2] = ([_collapsedStatus[2] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_sessionRegistersTableView reloadData];
}

- (IBAction)onPassthroughTitleClick:(id)sender {
    NSLog(@"Click on Passthrough");
    _collapsedStatus[3] = ([_collapsedStatus[3] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_sessionRegistersTableView reloadData];
}

- (IBAction)onSramMemorySettingsTitleClick:(id)sender {
    NSLog(@"Click on Memory settings");
    _collapsedStatus[4] = ([_collapsedStatus[4] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_sessionRegistersTableView reloadData];
}

- (IBAction)onI2cSettingsTitleClick:(id)sender {
    NSLog(@"Click on I2C settings");
    _collapsedStatus[5] = ([_collapsedStatus[5] boolValue]) ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [_sessionRegistersTableView reloadData];
}

- (void) displaySessionRegisters: (NSDictionary *) dictionary{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _sessionRegistersRead = dictionary;
        _sessionRegistersTableView.hidden = NO;
        _scanView.hidden = YES;
    }];
}

-(void) throwAuthController: (AuthStatus *) authStatus{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    AuthViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"AUTH_ID"];
    [vc setAuthStatus:authStatus];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)SetUIView {
    _sessionRegistersTableView.delegate = self;
    _sessionRegistersTableView.dataSource = self;
    _sessionRegistersTableView.allowsSelection = NO;
    _sessionRegistersTableView.hidden = YES;
    
    _expandedHeights = [[NSArray alloc] initWithObjects:
    [NSNumber numberWithFloat:110.0f],
    [NSNumber numberWithFloat:75.0f],
    [NSNumber numberWithFloat:220.0f],
    [NSNumber numberWithFloat:270.0f],
    [NSNumber numberWithFloat:110.0f],
    [NSNumber numberWithFloat:150.0f],
    nil];
    
    _collapsedStatus = [[NSMutableArray alloc] initWithObjects:
    [NSNumber numberWithBool:YES],
    [NSNumber numberWithBool:YES],
    [NSNumber numberWithBool:YES],
    [NSNumber numberWithBool:YES],
    [NSNumber numberWithBool:YES],
    [NSNumber numberWithBool:YES],
    nil];
    
    _scanView.layer.cornerRadius        = 12;
    _scanView.layer.borderWidth         = 1.5;
    _scanView.layer.borderColor         = [UIColor blackColor].CGColor;
    _scanView.layer.masksToBounds       = true;
}


@end
