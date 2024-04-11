//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "ResetViewController.h"
#import "NTAG_I2C_LIB.h"
#import "ResetOperationController.h"
#import "AuthViewController.h"

@interface ResetViewController ()

@end

@implementation ResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self CustomizeViews];
}

- (IBAction)scanButtonClick:(id)sender {
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
        [[ResetOperationController sharedInstance] resetTagMemory:^(float timeInterval, int bytesLen) {
            [self showPerformance:timeInterval bytesLen:bytesLen];
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

/*---------------------- UI METHODS -----------------------*/

- (void)CustomizeViews {
    
    _performanceView.layer.cornerRadius        = 12;
    _performanceView.layer.borderWidth         = 1.5;
    _performanceView.layer.borderColor         = [UIColor blackColor].CGColor;
    _performanceView.layer.masksToBounds       = true;
    _performanceView.hidden = true;
    
    _globalView.layer.cornerRadius        = 12;
    _globalView.layer.borderWidth         = 1.5;
    _globalView.layer.borderColor         = [UIColor blackColor].CGColor;
    _globalView.layer.masksToBounds       = true;
    
    _performanceTextView.layer.masksToBounds     = YES;
    _performanceTextView.layer.borderColor       = [[UIColor orangeColor]CGColor];
    _performanceTextView.layer.borderWidth       = 1.5f;
}

- (void)showPerformance: (float) timeInterval bytesLen: (int) len {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        float speed = len/(timeInterval/1000);
        self.performanceTextView.text = [NSString stringWithFormat:@"NTAG Memory Reset\nSpeed(%d Byte / %.0f ms): %.0f Bytes/s", len, timeInterval, speed];
        
        self->_performanceView.hidden = false;
        
        self->_globalView.layer.cornerRadius        = 00;
        self->_globalView.layer.borderWidth         = 0;
        self->_globalView.layer.borderColor         = [UIColor whiteColor].CGColor;
        self->_globalView.layer.masksToBounds       = false;
        
        self->_topView.layer.cornerRadius           = 12;
        self->_topView.layer.borderWidth            = 1.5;
        self->_topView.layer.borderColor            = [UIColor blackColor].CGColor;
        self->_topView.layer.masksToBounds          = true;
        
        self->_performanceView.hidden = false;
        
    }];
}

-(void) throwAuthController: (AuthStatus *) authStatus{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    AuthViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"AUTH_ID"];
    [vc setAuthStatus:authStatus];
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)cancelButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
