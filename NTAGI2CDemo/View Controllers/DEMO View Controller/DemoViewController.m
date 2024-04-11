//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController ()
@end

@implementation DemoViewController 

bool temperature_is_checked = false;
bool lcd_is_checked         = false;
bool ndeflcd_is_checked     = false;
bool switch_status          = false;

NSString * switch_str       = @"ntagblue";
NSString * str_celsius      = @"";
NSString * str_farenheit    = @"";
NSString * str_voltage      = @"";

signed button_status;

NSString * temp_cel;
NSString * temp_far;
NSString * volt_str;

NSMutableArray *dataToProcess64;
NSTimer * timer;

/*----------------------------------*/
/*           Main Method            */
/*----------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    // Setup NFC Listener
    //[self setUpNfcButtonListener];
  
}

- (void)initUI {
    [self setUpOrangeButton];
    [self setUpBlueButton];
    [self setUpGreenButton];
    [self setUpBoardConfigContainer];
    [self setUpBoardStatusContainer];
    [self setUpDropDownMenuContainer];
    [self setUpCheckBoxes];
    [self setUpSwitchListener];
    [self setUpDropDownButtonListener];
    [self setAutoHideDropDownMenuListener];
    [self setUpFeedbackButton];
    [self setupLockIcon];
}

- (void) setupLockIcon{
    UITapGestureRecognizer *lockIconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lockIconClick)];
    
    lockIconTap.numberOfTapsRequired = 1;
    [_lockIcon setUserInteractionEnabled:YES];
    [_lockIcon addGestureRecognizer:lockIconTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(yourNotificationHandler:)
    name:@"AUTH VC DISMISS" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeImage:) name:@"ImageChangeNotification" object:nil];
}

- (void) lockIconClick{
    AuthStatus authStatus;
    if(_lockIcon.image == [UIImage imageNamed:@"lock.png"])
        authStatus = PROTECTED_RW_SRAM;
    else
        authStatus = UNPROTECTED;
    [self throwAuthController: authStatus];
}

/*
- (void) setUpNfcButtonListener{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nfcTapListener)];
    singleTap.numberOfTapsRequired = 1;
    [_NFC_BUTTON setUserInteractionEnabled:YES];
    [_NFC_BUTTON addGestureRecognizer:singleTap];
}
 */

- (void)ModifyBoardStatusUI:(bool)status {
    if(status){
        self-> _TransferText.text = TXT_TRANS_DEV_TAG;
    }else{
        self-> _TransferText.text = TXT_TRANS_TAG_DEV;
    }
    
    NSString * str_display_celsius =  [NSString stringWithFormat:@"%s%@%@", "Temperature: ", str_celsius, @"ºC /"];
    NSString * str_display_farenheit =  [NSString stringWithFormat:@"%@%@", str_farenheit, @"ºF"];
    
    self-> _TemperatureText.text = [NSString stringWithFormat:@"%@%@", str_display_celsius, str_display_farenheit];
    self-> _VoltageText.text =  [NSString stringWithFormat:@"%@%@%@", @"Energy Harvesting Voltage: ", str_voltage, @"V"];
}

- (void) setButtonStatus: (NSData *) buttonStatus {
   int pressed = 0;
    
    char * bytes = [buttonStatus bytes];
    char buttonStatusByte = bytes[0];

   
   if ((buttonStatusByte & 0x01) == 0x01) {
      pressed = pressed + 1;
   }
   
   if ((buttonStatusByte & 0x02) == 0x02) {
     pressed = pressed + 2;
   }

   if ((buttonStatusByte & 0x04) == 0x04) {
      pressed = pressed + 4;
   }
   
   switch (pressed) {
   case 0 :
      [self->_NXPLogo_ImageView setImage:[UIImage imageNamed:IMG_SRC_NO_PRESSED]];
      break;
   case 1 :
      [self->_NXPLogo_ImageView setImage:[UIImage imageNamed:IMG_SRC_LEFT_PRESSED]];
      break;
   case 2 :
      [self->_NXPLogo_ImageView setImage:[UIImage imageNamed:IMG_SRC_MID_PRESSED]];
      break;
   case 3 :
      [self->_NXPLogo_ImageView setImage:[UIImage imageNamed:IMG_SRC_LEFT_MID_PRESSED]];
      break;
   case 4 :
      [self->_NXPLogo_ImageView setImage:[UIImage imageNamed:IMG_SRC_RIGHT_PRESSED]];
      break;
   case 5 :
      [self->_NXPLogo_ImageView setImage:[UIImage imageNamed:IMG_SRC_RIGHT_LEFT_PRESSED]];
      break;
   case 6 :
      [self->_NXPLogo_ImageView setImage:[UIImage imageNamed:IMG_SRC_MID_RIGHT_PRESSED]];
      break;
   case 7 :
      [self->_NXPLogo_ImageView setImage:[UIImage imageNamed:IMG_SRC_ALL_PRESSED]];
      break;
   default:
      [self->_NXPLogo_ImageView setImage:[UIImage imageNamed:IMG_SRC_NO_PRESSED]];
      break;
   }
}

-(void)nfcTapListener{
     NSLog(@"NFC Tapped!");
    
     NSString * startAddress_fr = @"0xF0";
     NSString * endAddress_fr   = @"0xFF";
    
     int sramsize = 64;

     dataToProcess64 = [NSMutableArray new];

     for (int i = 0; i < sramsize; i++){
         [dataToProcess64 addObject:[NSNumber numberWithUnsignedInt:0]];
     }
     
     if (temperature_is_checked){
         unsigned temp_status = 0;
         NSScanner * scanner_temp = [NSScanner scannerWithString:@"0x45"];
         [scanner_temp scanHexInt:&temp_status];
         dataToProcess64 [55] = [NSNumber numberWithUnsignedInt:temp_status];
     }
    
     if (lcd_is_checked){
         unsigned lcd_status = 0;
         NSScanner * scanner_led = [NSScanner scannerWithString:@"0x45"];
         [scanner_led scanHexInt:&lcd_status];
         dataToProcess64 [54] = [NSNumber numberWithUnsignedInt:lcd_status];
     }
    
     if (ndeflcd_is_checked){
         unsigned ndef_status = 0;
         NSScanner * scanner_ndef = [NSScanner scannerWithString:@"0x45"];
         [scanner_ndef scanHexInt:&ndef_status];
         dataToProcess64 [53] = [NSNumber numberWithUnsignedInt:ndef_status];
     }
    
    if ([switch_str isEqualToString:@"ntagorange"]){
        unsigned led0     = 0;
        unsigned led1     = 0;
        NSScanner * scanner_led = [NSScanner scannerWithString:@"0x4C"];
        [scanner_led scanHexInt:&led0];
        scanner_led = [NSScanner scannerWithString:@"0x31"];
        [scanner_led scanHexInt:&led1];
        dataToProcess64 [60] = [NSNumber numberWithUnsignedInt:led0];
        dataToProcess64 [61] = [NSNumber numberWithUnsignedInt:led1];
        
    }else if ([switch_str isEqualToString:@"ntagblue"]){
        unsigned led0     = 0;
        unsigned led1     = 0;
        NSScanner * scanner_led = [NSScanner scannerWithString:@"0x4C"];
        [scanner_led scanHexInt:&led0];
        scanner_led = [NSScanner scannerWithString:@"0x32"];
        [scanner_led scanHexInt:&led1];
        dataToProcess64 [60] = [NSNumber numberWithUnsignedInt:led0];
        dataToProcess64 [61] = [NSNumber numberWithUnsignedInt:led1];
        
    }else if ([switch_str isEqualToString:@"ntaggreen"]){
        unsigned led0     = 0;
        unsigned led1     = 0;
        NSScanner * scanner_led = [NSScanner scannerWithString:@"0x4C"];
        [scanner_led scanHexInt:&led0];
        scanner_led = [NSScanner scannerWithString:@"0x33"];
        [scanner_led scanHexInt:&led1];
        dataToProcess64 [60] = [NSNumber numberWithUnsignedInt:led0];
        dataToProcess64 [61] = [NSNumber numberWithUnsignedInt:led1];
    }
    
    if (switch_status){
        unsigned led0     = 0;
        unsigned led1     = 0;
        NSScanner * scanner_led = [NSScanner scannerWithString:@"0x4C"];
        [scanner_led scanHexInt:&led0];
        scanner_led = [NSScanner scannerWithString:@"0x30"];
        [scanner_led scanHexInt:&led1];
        dataToProcess64 [60] = [NSNumber numberWithUnsignedInt:led0];
        dataToProcess64 [61] = [NSNumber numberWithUnsignedInt:led1];
    }
    
    [[ NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {
        NSLog(@"Connection done");
    } onFailure:^(NSError *error) {
        NSLog(@"Failure at init Session");
    }];
    
    NSLog(@"Waiting for connection...");
    
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent() + 5;
    CFAbsoluteTime after = CFAbsoluteTimeGetCurrent();
    
    while ([[ NTAG_I2C_LIB sharedInstance] isConnect] == 0){
        
        if(before == after){
            break;
        }
        after = CFAbsoluteTimeGetCurrent();
        
    }
    
    if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 3){
        NSLog(@"Connected!!!");
        [[DemoUseCase sharedInstance] LEDDemo:temperature_is_checked isLCDEnabled:lcd_is_checked isScrollEnabled:ndeflcd_is_checked LedStr: switch_str onSuccess:^(NSString *str1, NSString *str2, NSString *str3, NSData *buttonStatus) {
            [self showData:str1 temp:str2 voltage:str3 buttonStatus:
             buttonStatus];
        } onFailure:^(AuthStatus status) {
            // Authentication required. Throw Authentication ViewController
            [self throwAuthController: status];
        }];
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 1){
        NSLog(@"Not connected!!!");
    }
}

-(void)HideWhenTappedAnywhere{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionReveal;
    animation.duration = 0.15;
    [_DropDownMenu_View.layer addAnimation:animation forKey:nil];
    _DropDownMenu_View.hidden = YES;
}

/*----------------------------------*/
/*      Custom Button Profiles      */
/*----------------------------------*/
- (void) setUpOrangeButton {
    _Orange_Button.layer.cornerRadius     = 4;
    _Orange_Button.layer.borderWidth      = 1;
    _Orange_Button.layer.borderColor      = [UIColor blackColor].CGColor;
    _Orange_Button.layer.masksToBounds    = true;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = _Orange_Button.bounds;
    gradient.colors = @[(id)UIColorFromRGB(0xf9b500).CGColor, (id) UIColorFromRGB(0x992f2f).CGColor];
    
    [_Orange_Button.layer insertSublayer:gradient atIndex:0];
    
}

- (void) setUpBlueButton {
    _Blue_Button.layer.cornerRadius       = 4;
    _Blue_Button.layer.borderWidth        = 1;
    _Blue_Button.layer.borderColor        = [UIColor blackColor].CGColor;
    _Blue_Button.layer.masksToBounds      = true;
    
    switch_str = @"L2";
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = _Blue_Button.bounds;
    gradient.colors = @[(id)UIColorFromRGB(0x7BB1D9).CGColor, (id) UIColorFromRGB(0x2f6699).CGColor];
    
    [_Blue_Button.layer insertSublayer:gradient atIndex:0];
    
}

- (void) setUpGreenButton {
    _Green_Button.layer.cornerRadius      = 4;
    _Green_Button.layer.borderWidth       = 1;
    _Green_Button.layer.borderColor       = [UIColor blackColor].CGColor;
    _Green_Button.layer.masksToBounds     = true;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame                        = _Green_Button.bounds;
    gradient.colors                       = @[(id)UIColorFromRGB(0xC9D200).CGColor, (id) UIColorFromRGB(0x53933f).CGColor];
    
    [_Green_Button.layer insertSublayer:gradient atIndex:0];
}

- (void) setUpSwitchListener {
    _TapToSwitch_TextView.text          = @"Tap to switch off";
    
    [_NTAGLogo_ImageView setImage:[UIImage imageNamed:@"ntagblue"]];
    
    UITapGestureRecognizer *singleTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SwitchTapDetected)];
    singleTap.numberOfTapsRequired      = 1;
    
    [_Switch setUserInteractionEnabled:YES];
    [_Switch addGestureRecognizer:singleTap];
}

- (void) setUpDropDownButtonListener{
    UITapGestureRecognizer *singleTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DropDownTapDetected)];
    singleTap.numberOfTapsRequired      = 1;
    
    [_DropDownIcon setUserInteractionEnabled:YES];
    [_DropDownIcon addGestureRecognizer:singleTap];
    
}

- (void) DropDownTapDetected{
    
    bool ishidden =_DropDownMenu_View.hidden;
    
    if(ishidden == NO){
        NSLog(@"HIDDEN!!!!");
        
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionReveal;
        animation.duration = 0.15;
        [_DropDownMenu_View.layer addAnimation:animation forKey:nil];
        _DropDownMenu_View.hidden = YES;
        
        
    }else{
        NSLog(@"NOT HIDDEN!!!!");
        
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionReveal;
        animation.duration = 0.15;
        [_DropDownMenu_View.layer addAnimation:animation forKey:nil];
        _DropDownMenu_View.hidden = NO;
    }
}

- (void) setAutoHideDropDownMenuListener {
    UITapGestureRecognizer *singleTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideWhenTappedAnywhere)];
    singleTap.numberOfTapsRequired      = 1;
    
    [_MainDemoView setUserInteractionEnabled:YES];
    [_MainDemoView addGestureRecognizer:singleTap];
}

- (void) SwitchTapDetected{
    if(switch_status){
        _TapToSwitch_TextView.text = @"Tap to switch off";
        [( AppDelegate* )[UIApplication sharedApplication].delegate showDebugLogs: @"Switch Status: On"];
        [_NTAGLogo_ImageView setImage:[UIImage imageNamed:switch_str]];
    }else{
        _TapToSwitch_TextView.text = @"Tap to switch on";
        [( AppDelegate* )[UIApplication sharedApplication].delegate showDebugLogs: @"Switch Status: Off"];
        [_NTAGLogo_ImageView setImage:[UIImage imageNamed:@"ntaggrey"]];
    }
    switch_status = !switch_status;
}

/*----------------------------------*/
/*      Custom Board Config UI      */
/*----------------------------------*/
- (void) setUpBoardConfigContainer {
    _BoardConfig_View.layer.cornerRadius  = 12;
    _BoardConfig_View.layer.borderWidth   = 2;
    _BoardConfig_View.layer.borderColor   = [UIColor blackColor].CGColor;
    _BoardConfig_View.layer.masksToBounds = true;
}

/*----------------------------------*/
/*      Custom Board Status UI      */
/*----------------------------------*/
- (void) setUpBoardStatusContainer {
    _BoardStatus_View.layer.cornerRadius  = 12;
    _BoardStatus_View.layer.borderWidth   = 2;
    _BoardStatus_View.layer.borderColor   = [UIColor blackColor].CGColor;
    _BoardStatus_View.layer.masksToBounds = true;
}

/*----------------------------------*/
/*    Custom Drop Down Menu UI      */
/*----------------------------------*/
- (void) setUpDropDownMenuContainer {
    _DropDownMenu_View.layer.cornerRadius  = 1;
    _DropDownMenu_View.layer.borderWidth   = 1;
    _DropDownMenu_View.layer.borderColor   = [UIColor blueColor].CGColor;
    _DropDownMenu_View.layer.masksToBounds = NO;
    _DropDownMenu_View.layer.shadowOffset = CGSizeMake(3, 3);
    _DropDownMenu_View.layer.shadowRadius = 1;
    _DropDownMenu_View.layer.shadowOpacity = 0.35;
    
    
}

/*----------------------------------*/
/*         Custom Checkboxes        */
/*----------------------------------*/
- (void) setUpCheckBoxes {
    [_TemperatureSensor_CheckBox setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
    [_LCD_CheckBox               setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
    [_NDEFLCD_CheckBox           setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
    
    temperature_is_checked                = NO;
    lcd_is_checked                        = NO;
    ndeflcd_is_checked                    = NO;
    
    [self NDEFLCD_SetStatus:FALSE];
}

- (void) NDEFLCD_SetStatus:(BOOL)status{
    if(status){
        _BoardViewHeight.constant         = 265;
    }else{
        [_NDEFLCD_CheckBox setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
        ndeflcd_is_checked                = NO;
        _BoardViewHeight.constant         = 240;
    }
    _NDEFLCD_TextView.hidden              = !status;
    _NDEFLCD_CheckBox.hidden              = !status;
}

/*----------------------------------*/
/*       Checkboxes Listener        */
/*----------------------------------*/
- (IBAction) CheckBoxClick:(UIButton*)sender {
    [( AppDelegate* )[UIApplication sharedApplication].delegate showDebugLogs: [NSString stringWithFormat:@" CheckBox clicked Tag: %lid", (long)sender.tag]];
    
    if(switch_status){
        return;
    }
    
    if (sender.tag == 1){
        [self ProcessCheckBoxTemperature];
        
    }else  if (sender.tag == 2){
        [self ProcessCheckBoxLCD];
        
    }else  if (sender.tag == 3){
        [self ProcessCheckBoxNDEFLCD];
        
    }else  if (sender.tag == 4){
        // Orange button click
        switch_str = @"L1";
        [_NTAGLogo_ImageView setImage:[UIImage imageNamed:@"ntagorange"]];
        [self nfcTapListener];
        
    }else  if (sender.tag == 5){
        // Blue button click
        switch_str = @"L2";
        [_NTAGLogo_ImageView setImage:[UIImage imageNamed:@"ntagblue"]];
        [self nfcTapListener];
        
    }else  if (sender.tag == 6){
        // Green button click
        switch_str = @"L3";
        [_NTAGLogo_ImageView setImage:[UIImage imageNamed:@"ntaggreen"]];
        [self nfcTapListener];
    }
    
}

/*----------------------------------*/
/*       Checkboxes Process         */
/*----------------------------------*/
- (void) ProcessCheckBoxTemperature {
    if(!temperature_is_checked){
        [_TemperatureSensor_CheckBox setImage:[UIImage imageNamed:@"checkbox_on"] forState:UIControlStateNormal];
        temperature_is_checked    = YES;
        [( AppDelegate* )[UIApplication sharedApplication].delegate showDebugLogs: @"Temperature CheckBox: Enabled"];
    }
    else if(temperature_is_checked){
        [_TemperatureSensor_CheckBox setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
        temperature_is_checked    = NO;
        [( AppDelegate* )[UIApplication sharedApplication].delegate showDebugLogs: @"Temperature CheckBox: Disabled"];
    }
}

- (void) ProcessCheckBoxLCD {
    if(!lcd_is_checked){
        [_LCD_CheckBox setImage:[UIImage imageNamed:@"checkbox_on"] forState:UIControlStateNormal];
        lcd_is_checked            = YES;
        [self NDEFLCD_SetStatus:TRUE];
        [( AppDelegate* )[UIApplication sharedApplication].delegate showDebugLogs: @"LCD CheckBox: Enabled"];
    }
    else if(lcd_is_checked){
        [_LCD_CheckBox setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
        lcd_is_checked            = NO;
        [self NDEFLCD_SetStatus:FALSE];
        [( AppDelegate* )[UIApplication sharedApplication].delegate showDebugLogs: @"LCD CheckBox: Disabled"];
    }
}

- (void) ProcessCheckBoxNDEFLCD {
    if(!ndeflcd_is_checked){
        [_NDEFLCD_CheckBox setImage:[UIImage imageNamed:@"checkbox_on"] forState:UIControlStateNormal];
        ndeflcd_is_checked        = YES;
        [( AppDelegate* )[UIApplication sharedApplication].delegate showDebugLogs: @"NDEF LCD CheckBox: Enabled"];
    }
    else if(ndeflcd_is_checked){
        [_NDEFLCD_CheckBox setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
        ndeflcd_is_checked        = NO;
        [( AppDelegate* )[UIApplication sharedApplication].delegate showDebugLogs: @"NDEF LCD CheckBox: Disabled"];
    }
}

- (void) setUpFeedbackButton{
    [_FeedBackEmailButton addTarget:self action:@selector(callAlert)forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FeedbackEmail)];
    
    singleTap.numberOfTapsRequired = 1;
    [_FeedBackEmailButton setUserInteractionEnabled:YES];
    [_FeedBackEmailButton addGestureRecognizer:singleTap];
    
}

- (void) FeedbackEmail{
    NSLog(@"single Tap on imageview");
    
    #define URLEMail @"mailto:mobileapp.support@nxp.com"

    NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString * title = @"NTAG I2C Demo Feedback";
    NSString * content = @"iOS Version: ";
    
    content = [NSString stringWithFormat: @"%@%@\n", content, [[UIDevice currentDevice] systemVersion]];
    content = [NSString stringWithFormat: @"%@Model: %@\n", content, [[UIDevice currentDevice] model]];
    content = [NSString stringWithFormat: @"%@Name: %@\n", content, [[UIDevice currentDevice] systemName]];
    content = [NSString stringWithFormat: @"%@Brand: %@\n", content, @"Apple"];
    //  content = [NSString stringWithFormat: @"%@Description: %@\n", content, [[UIDevice currentDevice] description]];
    content = [NSString stringWithFormat: @"%@App Version: %@\n", content, APP_VERSION];
    
    url = [NSString stringWithFormat: @"%@?subject=%@&body=%@", url, title, content];
    
    NSURL *url2 = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [[UIApplication sharedApplication]  openURL:url2 options:@{} completionHandler:^(BOOL success) {}];
}

- (void) showData: (NSString *) transferDir temp: (NSString *) temp voltage: (NSString *) voltage buttonStatus: (NSData *) buttonStatus{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
        if (transferDir != nil)
            self->_TransferText.text = transferDir;
        if (temp != nil)
            self->_TemperatureText.text = temp;
        if(voltage != nil)
            self->_VoltageText.text = voltage;
        if (buttonStatus != nil)
            [self setButtonStatus:buttonStatus];
    }];
}

-(void) throwAuthController: (AuthStatus *) authStatus{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    AuthViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"AUTH_ID"];
    [vc setAuthStatus:authStatus];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)yourNotificationHandler:(NSNotification *)notice{
    NSString *str = [notice object];
    if ([str  isEqual: @"PROTECTED"]){
        _lockIcon.image = [UIImage imageNamed:IMG_SRC_LOCK];
    }
    else if ([str  isEqual: @"UNPROTECTED"])
        _lockIcon.image = [UIImage imageNamed:IMG_SRC_OPEN];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageChangeNotification" object:str];
}

-(void)changeImage:(NSNotification *)notice{
     NSString *str = [notice object];
       if ([str  isEqual: @"PROTECTED"]){
           self.lockIcon.image = [UIImage imageNamed:IMG_SRC_LOCK];
       }
       else if ([str  isEqual: @"UNPROTECTED"])
           self.lockIcon.image = [UIImage imageNamed:IMG_SRC_OPEN];
}

@end
