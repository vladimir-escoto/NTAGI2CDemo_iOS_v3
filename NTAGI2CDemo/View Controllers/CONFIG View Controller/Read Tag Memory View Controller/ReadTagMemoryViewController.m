//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "ReadTagMemoryViewController.h"
#import "NTAG_I2C_LIB.h"
#import "readTagMemoryOperationController.h"
#import "AuthViewController.h"

@interface ReadTagMemoryViewController ()

@end

@implementation ReadTagMemoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self customizeView];
}

- (IBAction)cancelButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)scanButtonClick:(id)sender {
    [[NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    NSLog(@"Waiting for connection...");
    while ([[NTAG_I2C_LIB sharedInstance] isConnect] == 0){}
    if([[NTAG_I2C_LIB sharedInstance]isConnect] == 3){
        NSLog(@"Connected!!!");

        [[readTagMemoryOperationController sharedInstance] readTagMemory:^(float timeInterval, int bytesLen, NSString * _Nonnull dataStr) {
            [self showPerformance:timeInterval bytesLen:bytesLen dataStr:dataStr];
        } onFailure:^(AuthStatus status) {
            // Authentication required. Throw Authentication ViewController
            [self throwAuthController: status];
        }];
    }else if([[NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
        [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    }
}

- (void)customizeView {

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
    
    _topView.layer.cornerRadius        = 12;
    _topView.layer.borderWidth         = 1.5;
    _topView.layer.borderColor         = [UIColor blackColor].CGColor;
    _topView.layer.masksToBounds       = true;
    _topView.hidden = true;
}


- (void)showPerformance: (float) timeInterval bytesLen: (int) len dataStr: (NSString *) dataStr{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        float speed = len/(timeInterval/1000);
        self.performanceTextView.text = [NSString stringWithFormat:@"NTAG Memory Read\nSpeed(%d Byte / %.0f ms): %.0f Bytes/s", len, timeInterval, speed];
        
        self.performanceView.hidden = false;
        self.topView.hidden = false;
        
        self->_globalView.layer.cornerRadius        = 0;
        self->_globalView.layer.borderWidth         = 0;
        self->_globalView.layer.borderColor         = [UIColor whiteColor].CGColor;
        self->_globalView.layer.masksToBounds       = false;
        
        self.readMessageTextView.text = dataStr;
        
    }];
}

-(void) throwAuthController: (AuthStatus *) authStatus{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    AuthViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"AUTH_ID"];
    [vc setAuthStatus:authStatus];
    [self presentViewController:vc animated:YES completion:nil];
}



@end
