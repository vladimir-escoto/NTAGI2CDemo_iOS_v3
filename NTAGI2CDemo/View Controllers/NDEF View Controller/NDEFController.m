//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "NDEFController.h"

@interface NDEFController ()
@end

@implementation NDEFController

typedef enum : NSUInteger {
    LINE_POSITION_TOP,
    LINE_POSITION_BOTTOM
} LINE_POSITION;

AuthStatus currentRecordSelected;
bool isCheckBoxSelected;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeViews];
}

- (IBAction)scanButtonTap:(id)sender {
    
    if( self.writeNDEFView.hidden == false && ![self isWrittingAvailable])
        return;
    
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
        
        if (_readNDEFView.hidden == false){
            
            [[NDEFOperationController sharedInstance] readNDEFMessage:^(Message *message) {
                
                // Display message performance
                [self showPerformanceWithMessage:message];
                
            } onFailure:^(AuthStatus status) {
                // Authentication required. Throw Authentication ViewController
                [self throwAuthController: status];
            }];
        } else if (_writeNDEFView.hidden == false) {
            [self writeNDEF];
        }
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 1){
        NSLog(@"Not connected!!!");
    }
}

- (IBAction)writeDefaultNDEFButtonClick:(UIButton *)sender {
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
        [[NDEFOperationController sharedInstance] writeDefaultNDEF:^(float timeInterval, int bytesLen) {
            
            [self showPerformanceWithValues:timeInterval bytesLen:bytesLen];
            
        } onFailure:^(AuthStatus status) {
            [self throwAuthController: status];
        }];
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 1){
        NSLog(@"Not connected!!!");
    }
}

- (IBAction)lockIconTap:(id)sender {
    AuthStatus authStatus;
    if(_lockIcon.image == [UIImage imageNamed:@"lock.png"])
        authStatus = PROTECTED_RW_SRAM;
    else
        authStatus = UNPROTECTED;
    [self throwAuthController: authStatus];
}

// Takes the NDEF message read, checks each record and its type and displays it on the screen
-(void) showPerformanceWithMessage: (Message *) message{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSString * text = @"";
        NSString * msfType = @"";
        
        // Iterate through records received on NDEF Message and print the message depending on the type of NDEF Message
        for (int i = 0; i < message.records.count; i++){
            RecordType recordType = [[message getRecord:i] getRecordType];
            
            if(recordType == SP_RECORD){
                SmartPosterRecord * record = [message getRecord:i];
                text = [text stringByAppendingFormat: @"%@", [NSString stringWithFormat:@"#%d SmartPosterRecord:\n", i+1]];
                text = [text stringByAppendingFormat: @"%@\n", [NSString stringWithFormat:@"#%d.1 TextRecord:\n%@", i+1,[record getTitle]]];
                text = [text stringByAppendingFormat: @"%@", [NSString stringWithFormat:@"#%d.2 UriRecord:\nwww.%@\n\n", i+1,[record getUri]]];
                msfType = @"NDEF Msg Type: SmartPosterRecord";
            }
            else if(recordType == TEXT_RECORD){
                TextRecord * record = [message getRecord:i];
                text = [text stringByAppendingFormat: @"%@", [NSString stringWithFormat:@"#%d TextRecord:\n%@\n\n", i+1,[record getText]]];
                msfType = @"NDEF Msg Type: TextRecord";
            }
            else if(recordType == URI_RECORD){
                UriRecord * record = [message getRecord:i];
                text = [text stringByAppendingFormat: @"%@", [NSString stringWithFormat:@"#%d UriRecord:\n%@\n\n", i+1, [record getUri]]];
                msfType = @"NDEF Msg Type: UriRecord";
            }
            else if(recordType == MIME_RECORD){
                MIMERecord * record = [message getRecord:i];
                text = [text stringByAppendingFormat: @"%@", [NSString stringWithFormat:@"#%d MimeRecord:\n%@\n\n", i+1, [record getType]]];
            }
            else if(recordType == BT_RECORD){
                text = [text stringByAppendingFormat: @"%@", [NSString stringWithFormat:@"#%d HandoverSelectRecord\n\n", i+1]];
                msfType = @"NDEF Msg Type: HandoverSelectRecord";
            }
            else if(recordType == EXTERNAL_RECORD){
                ExternalRecord * record = [message getRecord:i];
                if ([[record getType]  isEqual: @"android.com:pkg"])
                    text = [text stringByAppendingFormat: @"%@", [NSString stringWithFormat:@"#%d AndriodApplicationRecord:\n%@\n\n", i+1, [record getPayload]]];
                else
                    text = [text stringByAppendingFormat: @"%@", [NSString stringWithFormat:@"#%d ExternalRecord:\n%@\n\n", i+1, [record getPayload]]];
            }
            else if(recordType == UNKNOWN_RECORD){
                text = [text stringByAppendingFormat: @"%@", [NSString stringWithFormat:@"#%d UnknownRecord\n\n", i+1]];
            }
        }
        
        if(self->_readNDEFView.hidden == false){
            self.NDEFMessageTextView.text = text;
            self.NDEFMessageTextView.textColor = UIColor.blackColor;
            self->_readViewMsgTypeLabel.text = msfType;
        }
        
        NSTimeInterval time_interval = [message getTimeInterval];
        int len = [message getLen];
        float speed = len / (time_interval / 1000);
        
        self.TextField_Layer2.text = [NSString stringWithFormat:@"Speed(%d Byte / %.0f ms): %.0f Bytes/s", len, time_interval, speed];
        self.TextField_Layer2.textColor = UIColor.blackColor;
    }];
}

// Takes the NDEF message read, checks each record and its type and displays it on the screen
-(void) showPerformanceWithValues:  (float) timeInterval bytesLen: (int) bytesLen{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        float speed = bytesLen / (timeInterval / 1000);
        
        self.TextField_Layer2.text = [NSString stringWithFormat:@"Speed(%d Byte / %.0f ms): %.0f Bytes/s", bytesLen, timeInterval, speed];
        self.TextField_Layer2.textColor = UIColor.blackColor;
    }];
}

- (void) writeNDEF{
    
    NFCNDEFMessage * ndefMessage;
    
    if (currentRecordSelected == TEXT_RECORD){
        // Create NFCNDEFMessage object and call writeNDEF command
        NSString * text = [[NSString alloc] initWithString:_ndefMessageTextField.text];
        
        ndefMessage = [[Message alloc] createMessageWithTextRecord:text appendPackage: isCheckBoxSelected];
        
    } else if (currentRecordSelected == URI_RECORD){
        
        // Create NFCNDEFMessage object and call writeNDEF command
        NSString * uri = [[NSString alloc] initWithString:_uriRecordTextField.text];
        
        ndefMessage = [[Message alloc] createMessageWithUriRecord:uri appendPackage: isCheckBoxSelected];
        
    } else if (currentRecordSelected == BT_RECORD){
        
        // Create NFCNDEFMessage object and call writeNDEF command
        NSString * macAddress = [[NSString alloc] initWithString:_macAddressTextField.text];
        NSString * deviceName = [[NSString alloc] initWithString:_deviceNameTextField.text];
        NSString * deviceClass = [[NSString alloc] initWithString:_deviceClassTextField.text];
        
        ndefMessage = [[Message alloc] createMessageWithBTRecord:macAddress deviceName:deviceName deviceClass:deviceClass appendPackage: isCheckBoxSelected];
        
    } else if (currentRecordSelected == SP_RECORD){
        
        // Create NFCNDEFMessage object and call writeNDEF command
        NSString * title = [[NSString alloc] initWithString:_spRecordTitleTextField.text];
        NSString * uri = [[NSString alloc] initWithString:_spRecordLinkTextField.text];
        
        ndefMessage = [[Message alloc] createMessageWithSPRecord:title uri:uri  appendPackage: isCheckBoxSelected];
    }
    
    [[NDEFOperationController sharedInstance] writeNDEF:ndefMessage onSuccess:^(Message * _Nonnull message) {
        
        // Display message performance
        [self showPerformanceWithMessage:message];
        
    } onFailure:^(AuthStatus status) {
        // Authentication required. Throw Authentication ViewController
        [self throwAuthController: status];
    }];
}

-(bool) isWrittingAvailable{
    if (currentRecordSelected == TEXT_RECORD){
        if([self isTextRecordWriteable])
            return YES;
        else{
            [self showAlertMessage];
            return NO;
        }
        
    } else if (currentRecordSelected == URI_RECORD){
        if([self isUriRecordWriteable])
            return YES;
        else{
            [self showAlertMessage];
            return NO;
        }
        
    } else if (currentRecordSelected == BT_RECORD){
        if([self isBTRecordWriteable])
            return YES;
        else{
            [self showAlertMessage];
            return NO;
        }
        
    } else if (currentRecordSelected == SP_RECORD){
        if([self isSPRecordWriteable])
            return YES;
        else{
            [self showAlertMessage];
            return NO;
        }
    }
    return false;
}

- (Boolean) isTextRecordWriteable{
    if([_ndefMessageTextField.text  isEqual: @""])
        return NO;
    
    return YES;
}

- (Boolean) isUriRecordWriteable{
    if([_uriRecordTextField.text  isEqual: @""])
        return NO;
    
    if(![_uriRecordTextField.text containsString:@"http://www."])
        return NO;
    
    NSString * uri = [[NSString alloc] initWithString:_uriRecordTextField.text];
    NSData * minLenData = [NtagUtils dataFromHexString: @"http://www."];
    NSData * actualData = [NtagUtils dataFromHexString: uri];
    if(actualData.length < minLenData.length)
        return NO;
    
    return YES;
}

- (Boolean) isBTRecordWriteable{
    if([_macAddressTextField.text  isEqual: @""])
        return NO;
    
    if([_deviceNameTextField.text  isEqual: @""])
        return NO;
    
    if([_deviceClassTextField.text  isEqual: @""])
        return NO;
    
    NSString * macAddress = [[NSString alloc] initWithString:_macAddressTextField.text];
    NSString * deviceName = [[NSString alloc] initWithString:_deviceNameTextField.text];
    NSString * deviceClass = [[NSString alloc] initWithString:_deviceClassTextField.text];
    
    NSData * macAddressData = [NtagUtils dataFromHexString: macAddress];
    NSData * deviceNameData = [NtagUtils dataFromHexString: deviceName];
    NSData * deviceClassData = [NtagUtils dataFromHexString: deviceClass];
    
    // Check correct lengths
    if(macAddressData.length != 6 || deviceNameData.length == 0 || deviceClassData.length != 3)
        return NO;
    
    return YES;
}

- (Boolean) isSPRecordWriteable{
    if([_spRecordTitleTextField.text  isEqual: @""])
        return NO;
    
    if([_spRecordLinkTextField.text  isEqual: @""])
        return NO;
    
    if(![_spRecordLinkTextField.text containsString:@"http://www."])
        return NO;
    
    return YES;
}



/*---------------------- UI METHODS -----------------------*/


- (void)CustomizeViews {
    
    
    _NDEFView_Layer1.layer.cornerRadius       = 12;
    _NDEFView_Layer1.layer.borderWidth        = 2;
    _NDEFView_Layer1.layer.borderColor        = [UIColor blackColor].CGColor;
    _NDEFView_Layer1.layer.masksToBounds      = true;
    
    _NDEFView_Layer2.layer.cornerRadius       = 12;
    _NDEFView_Layer2.layer.borderWidth        = 2;
    _NDEFView_Layer2.layer.borderColor        = [UIColor blackColor].CGColor;
    _NDEFView_Layer2.layer.masksToBounds      = true;
    
    _ReadNDEFButton.layer.cornerRadius        = 4;
    _ReadNDEFButton.layer.borderWidth         = 1;
    _ReadNDEFButton.layer.borderColor         = [UIColor blackColor].CGColor;
    _ReadNDEFButton.layer.masksToBounds       = true;
    
    _WriteNDEFButton.layer.cornerRadius       = 4;
    _WriteNDEFButton.layer.borderWidth        = 1;
    _WriteNDEFButton.layer.borderColor        = [UIColor blackColor].CGColor;
    _WriteNDEFButton.layer.masksToBounds      = true;
    
    _writeDefaultNDEFButton.layer.cornerRadius        = 4;
    _writeDefaultNDEFButton.layer.borderWidth         = 1;
    _writeDefaultNDEFButton.layer.borderColor         = [UIColor blackColor].CGColor;
    _writeDefaultNDEFButton.layer.masksToBounds       = true;
    
    _NDEFMessageTextView.layer.masksToBounds     = YES;
    _NDEFMessageTextView.layer.borderColor       = [[UIColor orangeColor]CGColor];
    _NDEFMessageTextView.layer.borderWidth       = 2.0f;
    
    _TextField_Layer2.layer.masksToBounds     = YES;
    _TextField_Layer2.layer.borderColor       = [[UIColor orangeColor]CGColor];
    _TextField_Layer2.layer.borderWidth       = 2.0f;
    
    _writeNDEFtextFieldsView.layer.masksToBounds     = YES;
    _writeNDEFtextFieldsView.layer.borderColor       = [[UIColor orangeColor]CGColor];
    _writeNDEFtextFieldsView.layer.borderWidth       = 2.0f;
    
    CAGradientLayer * gradient                = [CAGradientLayer layer];
    
    gradient.frame                            = _ReadNDEFButton.bounds;
    gradient.colors                           = @[(id)UIColorFromRGB(0x7BB1D9).CGColor, (id) UIColorFromRGB(0x2f6699).CGColor];
    [_ReadNDEFButton.layer insertSublayer:gradient atIndex:0];
    
    CAGradientLayer * gradient2                = [CAGradientLayer layer];
    gradient2.frame                            = _writeDefaultNDEFButton.bounds;
    gradient2.colors                           = @[(id)UIColorFromRGB(0x7BB1D9).CGColor, (id) UIColorFromRGB(0x2f6699).CGColor];
    [_writeDefaultNDEFButton.layer insertSublayer:gradient2 atIndex:0];
    
    _ndefMessageTextField.backgroundColor = [self colorWithHexString:@"EBEBEB" alpha:0];
    _ndefMessageTextField.textColor = UIColor.blackColor;
    _ndefMessageTextField.userInteractionEnabled = true;
    [self addLine:_ndefMessageTextField atPosition:LINE_POSITION_BOTTOM withColor:[UIColor darkGrayColor] lineWitdh:0.5];
    
    _macAddressTextField.backgroundColor = [self colorWithHexString:@"EBEBEB" alpha:0];
    _macAddressTextField.textColor = UIColor.blackColor;
    _macAddressTextField.userInteractionEnabled = true;
    [self addLine:_macAddressTextField atPosition:LINE_POSITION_BOTTOM withColor:[UIColor darkGrayColor] lineWitdh:0.5];
    
    _ndefMessageTextField.backgroundColor = [self colorWithHexString:@"EBEBEB" alpha:0];
    _ndefMessageTextField.textColor = UIColor.blackColor;
    _ndefMessageTextField.userInteractionEnabled = true;
    [self addLine:_ndefMessageTextField atPosition:LINE_POSITION_BOTTOM withColor:[UIColor darkGrayColor] lineWitdh:0.5];
    
    _uriRecordTextField.backgroundColor = [self colorWithHexString:@"EBEBEB" alpha:0];
    _uriRecordTextField.textColor = UIColor.blackColor;
    _uriRecordTextField.userInteractionEnabled = true;
    [self addLine:_uriRecordTextField atPosition:LINE_POSITION_BOTTOM withColor:[UIColor darkGrayColor] lineWitdh:0.5];
    
    _macAddressTextField.backgroundColor = [self colorWithHexString:@"EBEBEB" alpha:0];
    _macAddressTextField.textColor = UIColor.blackColor;
    _macAddressTextField.userInteractionEnabled = true;
    [self addLine:_macAddressTextField atPosition:LINE_POSITION_BOTTOM withColor:[UIColor darkGrayColor] lineWitdh:0.5];
    
    _deviceNameTextField.backgroundColor = [self colorWithHexString:@"EBEBEB" alpha:0];
    _deviceNameTextField.textColor = UIColor.blackColor;
    _deviceNameTextField.userInteractionEnabled = true;
    [self addLine:_deviceNameTextField atPosition:LINE_POSITION_BOTTOM withColor:[UIColor darkGrayColor] lineWitdh:0.5];
    
    _deviceClassTextField.backgroundColor = [self colorWithHexString:@"EBEBEB" alpha:0];
    _deviceClassTextField.textColor = UIColor.blackColor;
    _deviceClassTextField.userInteractionEnabled = true;
    [self addLine:_deviceClassTextField atPosition:LINE_POSITION_BOTTOM withColor:[UIColor darkGrayColor] lineWitdh:0.5];
    
    _spRecordTitleTextField.backgroundColor = [self colorWithHexString:@"EBEBEB" alpha:0];
    _spRecordTitleTextField.textColor = UIColor.blackColor;
    _spRecordTitleTextField.userInteractionEnabled = true;
    [self addLine:_spRecordTitleTextField atPosition:LINE_POSITION_BOTTOM withColor:[UIColor darkGrayColor] lineWitdh:0.5];
    
    _spRecordLinkTextField.backgroundColor = [self colorWithHexString:@"EBEBEB" alpha:0];
    _spRecordLinkTextField.textColor = UIColor.blackColor;
    _spRecordLinkTextField.userInteractionEnabled = true;
    [self addLine:_spRecordLinkTextField atPosition:LINE_POSITION_BOTTOM withColor:[UIColor darkGrayColor] lineWitdh:0.5];
    
    [self setUpDropDownMenuContainer];
    [self setUpDropDownButtonListener];
    [self setUpFeedbackButton];
    
    _ndefMessageTextField.hidden = false;
    _uriRecordTextField.hidden = true;
    _macAddressView.hidden = true;
    _deviceNameView.hidden = true;
    _deviceClassView.hidden = true;
    _spRecordTitleView.hidden = true;
    _spRecordLinkView.hidden = true;
    
    _readNDEFView.hidden = false;
    _writeNDEFView.hidden = true;
    currentRecordSelected = TEXT_RECORD;
    
    [self setAutoHideDropDownMenuListener];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yourNotificationHandler:)
                                                 name:@"AUTH VC DISMISS" object:nil];
    
    isCheckBoxSelected = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeImage:) name:@"ImageChangeNotification" object:nil];
}

- (IBAction)iARCheckboxButtonClick:(UIButton *)sender {
    if (isCheckBoxSelected){
        isCheckBoxSelected = false;
        [_iARChechboxButton setImage: [UIImage imageNamed:@"checkbox_off.png"] forState:UIControlStateNormal];    } else {
            isCheckBoxSelected = true;
            [_iARChechboxButton setImage: [UIImage imageNamed:@"checkbox_on.png"] forState:UIControlStateNormal];
        }
}

- (IBAction)readNDEFButtonClick:(UIButton *)sender {
    
    if(_readNDEFView.hidden == true){
        
        CAGradientLayer * gradient                = [CAGradientLayer layer];
        gradient.frame                            = _ReadNDEFButton.bounds;
        gradient.colors                           = @[(id)UIColorFromRGB(0x7BB1D9).CGColor, (id) UIColorFromRGB(0x2f6699).CGColor];
        [_ReadNDEFButton.layer insertSublayer:gradient atIndex:0];
        _ReadNDEFButton.backgroundColor = [self colorWithHexString:@"0096FF" alpha:0];
        
        [_WriteNDEFButton.layer.sublayers[0] removeFromSuperlayer ];
        _WriteNDEFButton.backgroundColor = UIColor.blackColor;
        
        _readNDEFView.hidden = false;
        _writeNDEFView.hidden = true;
        
        _TextField_Layer2.text = @"";
        _performanceLabel.text = @"Read performance";
        
    }
}

- (IBAction)writeNDEFButtonClick:(UIButton *)sender {
    if(_writeNDEFView.hidden == true){
        
        CAGradientLayer * gradient                = [CAGradientLayer layer];
        gradient.frame                            = _ReadNDEFButton.bounds;
        gradient.colors                           = @[(id)UIColorFromRGB(0x7BB1D9).CGColor, (id) UIColorFromRGB(0x2f6699).CGColor];
        [_WriteNDEFButton.layer insertSublayer:gradient atIndex:0];
        _WriteNDEFButton.backgroundColor = [self colorWithHexString:@"0096FF" alpha:0];
        
        [_ReadNDEFButton.layer.sublayers[0] removeFromSuperlayer ];
        _ReadNDEFButton.backgroundColor = UIColor.blackColor;
        
        _readNDEFView.hidden = true;
        _writeNDEFView.hidden = false;
        
        _TextField_Layer2.text = @"";
        _performanceLabel.text = @"Write performance";
    }
}
-(void)yourNotificationHandler:(NSNotification *)notice{
    NSString *str = [notice object];
    if ([str  isEqual: @"PROTECTED"]){
        _lockIcon.image = [UIImage imageNamed:@"lock.png"];
    }
    else if ([str  isEqual: @"UNPROTECTED"])
        _lockIcon.image = [UIImage imageNamed:@"open.png"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageChangeNotification" object:str];
}

-(void)changeImage:(NSNotification *)notice{
    NSString *str = [notice object];
    if ([str  isEqual: @"PROTECTED"]){
        self.lockIcon.image = [UIImage imageNamed:@"lock.png"];
    }
    else if ([str  isEqual: @"UNPROTECTED"])
        self.lockIcon.image = [UIImage imageNamed:@"open.png"];
}

- (void) addLine:(UIView *)view atPosition:(LINE_POSITION)position withColor:(UIColor *)color lineWitdh:(CGFloat)width {
    // Add line
    UIView *lineView = [[UIView alloc] init];
    [lineView setBackgroundColor:color];
    [lineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:lineView];
    
    NSDictionary *metrics = @{@"width" : [NSNumber numberWithFloat:width]};
    NSDictionary *views = @{@"lineView" : lineView};
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lineView]|" options: 0 metrics:metrics views:views]];
    
    switch (position) {
        case LINE_POSITION_TOP:
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lineView(width)]" options: 0 metrics:metrics views:views]];
            break;
            
        case LINE_POSITION_BOTTOM:
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lineView(width)]|" options: 0 metrics:metrics views:views]];
            break;
        default: break;
    }
}

- (UIColor *)colorWithHexString:(NSString *)str_HEX  alpha:(CGFloat)alpha_range{
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf([str_HEX UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha_range];
}

- (void)setAutoHideDropDownMenuListener {
    // set listener for clicking anywhere in the screen
    UITapGestureRecognizer *singleTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideWhenTappedAnywhere)];
    singleTap.numberOfTapsRequired = 1;
    [self.mainView setUserInteractionEnabled:YES];
    [self.mainView addGestureRecognizer:singleTap];
    
    // set listener for selecting Text Record option
    UITapGestureRecognizer *textRecordOptionTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textRecordOptionTap)];
    singleTap.numberOfTapsRequired = 1;
    [self.textRecordCheckbox setUserInteractionEnabled:YES];
    [self.textRecordCheckbox addGestureRecognizer:textRecordOptionTap];
    
    // set listener for selecting URI Record option
    UITapGestureRecognizer *uriRecordOptionTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uriRecordOptionTap)];
    singleTap.numberOfTapsRequired = 1;
    [self.uriRecordCheckbox setUserInteractionEnabled:YES];
    [self.uriRecordCheckbox addGestureRecognizer:uriRecordOptionTap];
    
    // set listener for selecting BT Record option
    UITapGestureRecognizer *btRecordOptionTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btRecordOptionTap)];
    singleTap.numberOfTapsRequired = 1;
    [self.btRecordCheckbox setUserInteractionEnabled:YES];
    [self.btRecordCheckbox addGestureRecognizer:btRecordOptionTap];
    
    // set listener for selecting SP Record option
    UITapGestureRecognizer *spRecordOptionTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spRecordOptionTap)];
    singleTap.numberOfTapsRequired = 1;
    [self.spRecordCheckbox setUserInteractionEnabled:YES];
    [self.spRecordCheckbox addGestureRecognizer:spRecordOptionTap];
    
    
    UITapGestureRecognizer *dropdowntap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideWhenTappedAnywhere)];
    dropdowntap.numberOfTapsRequired      = 1;
    
    [_mainView setUserInteractionEnabled:YES];
    [_mainView addGestureRecognizer:dropdowntap];
}

-(void)textRecordOptionTap{
    _textrecordCheckBoxImage.image = [UIImage imageNamed:@"fullCheckbox.png"];
    _uriRecordCheckboxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    _btRecordCheckboxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    _spRecordCheckboxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    
    _ndefMessageTextField.hidden = false;
    _uriRecordTextField.hidden = true;
    _macAddressView.hidden = true;
    _deviceNameView.hidden = true;
    _deviceClassView.hidden = true;
    _spRecordTitleView.hidden = true;
    _spRecordLinkView.hidden = true;
    
    currentRecordSelected = TEXT_RECORD;
}

-(void)uriRecordOptionTap{
    _textrecordCheckBoxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    _uriRecordCheckboxImage.image = [UIImage imageNamed:@"fullCheckbox.png"];
    _btRecordCheckboxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    _spRecordCheckboxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    
    _ndefMessageTextField.hidden = true;
    _uriRecordTextField.hidden = false;
    _macAddressView.hidden = true;
    _deviceNameView.hidden = true;
    _deviceClassView.hidden = true;
    _spRecordTitleView.hidden = true;
    _spRecordLinkView.hidden = true;
    
    currentRecordSelected = URI_RECORD;
}
-(void)btRecordOptionTap{
    _textrecordCheckBoxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    _uriRecordCheckboxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    _btRecordCheckboxImage.image = [UIImage imageNamed:@"fullCheckbox.png"];
    _spRecordCheckboxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    
    _ndefMessageTextField.hidden = true;
    _uriRecordTextField.hidden = true;
    _macAddressView.hidden = false;
    _deviceNameView.hidden = false;
    _deviceClassView.hidden = false;
    _spRecordTitleView.hidden = true;
    _spRecordLinkView.hidden = true;
    
    currentRecordSelected = BT_RECORD;
}
-(void)spRecordOptionTap{
    _textrecordCheckBoxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    _uriRecordCheckboxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    _btRecordCheckboxImage.image = [UIImage imageNamed:@"emptyCheckbox.png"];
    _spRecordCheckboxImage.image = [UIImage imageNamed:@"fullCheckbox.png"];
    
    _ndefMessageTextField.hidden = true;
    _uriRecordTextField.hidden = true;
    _macAddressView.hidden = true;
    _deviceNameView.hidden = true;
    _deviceClassView.hidden = true;
    _spRecordTitleView.hidden = false;
    _spRecordLinkView.hidden = false;
    
    currentRecordSelected = SP_RECORD;
}

- (void)showAlertMessage{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                   message:@"Wrong input parameters!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) throwAuthController: (AuthStatus *) authStatus{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    AuthViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"AUTH_ID"];
    [vc setAuthStatus:authStatus];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) setUpDropDownMenuContainer {
    _DropDownMenu_View.layer.cornerRadius  = 1;
    _DropDownMenu_View.layer.borderWidth   = 1;
    _DropDownMenu_View.layer.borderColor   = [UIColor blueColor].CGColor;
    _DropDownMenu_View.layer.masksToBounds = NO;
    _DropDownMenu_View.layer.shadowOffset = CGSizeMake(3, 3);
    _DropDownMenu_View.layer.shadowRadius = 1;
    _DropDownMenu_View.layer.shadowOpacity = 0.35;
    
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

-(void)HideWhenTappedAnywhere{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionReveal;
    animation.duration = 0.15;
    [_DropDownMenu_View.layer addAnimation:animation forKey:nil];
    _DropDownMenu_View.hidden = YES;
    
    [self.view endEditing:true];
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
    
    
    [[UIApplication sharedApplication]  openURL:url2 options:@{} completionHandler:^(BOOL success) {
        
    }];
    
}

@end
