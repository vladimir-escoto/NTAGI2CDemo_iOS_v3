//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "AboutMenuController.h"
#import "AppDelegate.h"
#import "AuthViewController.h"

@interface AboutMenuController ()
@end

@implementation AboutMenuController

NSString * dataToPrint;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeViews];
    [self setUpNfcButtonListener];
}

- (void) setUpNfcButtonListener{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nfcTapListener)];
    singleTap.numberOfTapsRequired = 1;
    [_NFC_Button setUserInteractionEnabled:YES];
    [_NFC_Button addGestureRecognizer:singleTap];
}

-(void) nfcTapListener{
    
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
           [self AboutProcessDemo];
       }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 4){
           NSLog(@"Not connected!!!");
       }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 1){
           NSLog(@"Not connected!!!");
       }
}

- (void)UpdateUI_ProcessDone {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self->_Top_Box.hidden       = false;
        self->_Top_Box_Text.hidden  = false;
        self->_Top_Box_Text.text    = dataToPrint;
        
        self->_IMG_DEVICE.hidden    = true;
        self->_TEXT1.hidden         = true;
        self->_TEXT2_VERSION.hidden = true;
        self->_TEXT3_DATE.hidden    = true;
        self->_NFC_TEXT.hidden      = true;
        self->_NFC_Button.hidden    = true;
    }];
}

-(void)AboutProcessDemo {

    dataToPrint = @"";
    
    [[AboutUseCase sharedInstance] SetBoardVersion:^(NSData *aData, int type, NSString *str) {
    
        if(type == 0){
            dataToPrint = [NSString stringWithFormat: @"%@%@\n", dataToPrint, str];
        }else if(type == 1){
            dataToPrint = [NSString stringWithFormat: @"%@%@\n", dataToPrint, str];
            
            dataToPrint = [NSString stringWithFormat: @"%@App Version: %@\n", dataToPrint, APP_VERSION];
        }
    
        [self UpdateUI_ProcessDone];
        
        } onFailure:^(AuthStatus status) {
            [self throwAuthController: &status];
        }];
   
}

- (void)CustomizeViews {
    _AboutViewController.layer.cornerRadius       = 12;
    _AboutViewController.layer.borderWidth        = 1.5;
    _AboutViewController.layer.borderColor        = [UIColor blackColor].CGColor;
    _AboutViewController.layer.masksToBounds      = true;
}

- (IBAction)Close_Window:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


-(void) throwAuthController: (AuthStatus *) authStatus{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    AuthViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"AUTH_ID"];
    [vc setAuthStatus:authStatus];
    [self presentViewController:vc animated:YES completion:nil];
}



@end
