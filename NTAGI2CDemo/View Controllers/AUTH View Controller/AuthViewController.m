//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "AuthViewController.h"
@interface AuthViewController ()
@end

@implementation AuthViewController

AuthStatus status;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self customizeViews];
}

-(AuthStatus) getAuthStatus{
    return self.currentStatus;
}

-(void) setAuthStatus: (AuthStatus *) authStatus{
    self.currentStatus = authStatus;
}

- (IBAction)cancelButtonClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (AuthStatus)DoAuthStatusProcessing {
    return [[AuthOperationController alloc] pwdAuth:PWD_SUN authStatus:[self getAuthStatus] onSuccess:^(NSString * _Nonnull protectionStatus) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:3.5f];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AUTH VC DISMISS" object:protectionStatus];
        }];
    } onFailure:^{}];
}

- (IBAction)authButtonSUNClick:(UIButton *)sender {
    [[NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    NSLog(@"Waiting for connection...");
    while ([[NTAG_I2C_LIB sharedInstance] isConnect] == 0){}
    if([[NTAG_I2C_LIB sharedInstance]isConnect] == 3){
        NSLog(@"Connected!!!");
        status = [self DoAuthStatusProcessing];
    }else if([[NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
        [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    }
}

- (IBAction)authButtonSTARClick:(UIButton *)sender {
    [[NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    NSLog(@"Waiting for connection...");
    while ([[NTAG_I2C_LIB sharedInstance] isConnect] == 0){}
    if([[NTAG_I2C_LIB sharedInstance]isConnect] == 3){
    NSLog(@"Connected!!!");
    status = [[AuthOperationController alloc] pwdAuth:PWD_STAR authStatus:[self getAuthStatus] onSuccess:^(NSString * _Nonnull protectionStatus) {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [NSThread sleepForTimeInterval:3.5f];
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AUTH VC DISMISS" object:protectionStatus];
    }];

    } onFailure:^{}];

    }else if([[NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
        [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    }
}

- (IBAction)authButtonMOONClick:(UIButton *)sender {
    [[NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    while ([[NTAG_I2C_LIB sharedInstance] isConnect] == 0){
        NSLog(@"Waiting for connection...");
    }
    
    if([[NTAG_I2C_LIB sharedInstance]isConnect] == 3){
        NSLog(@"Connected!!!");
        
        status = [[AuthOperationController alloc] pwdAuth:PWD_MOON authStatus:[self getAuthStatus] onSuccess:^(NSString * _Nonnull protectionStatus) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [NSThread sleepForTimeInterval:3.5f];

                [self dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"AUTH VC DISMISS"
                 object:protectionStatus];
            }];
        } onFailure:^{
            
        }];
        
    }else if([[NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
        [[NTAG_I2C_LIB sharedInstance] close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    }
}

- (void) customizeViews{
    self.mainView.layer.cornerRadius       = 12;
    self.mainView.layer.borderWidth        = 1.5;
    self.mainView.layer.borderColor        = [UIColor blackColor].CGColor;
    self.mainView.layer.masksToBounds      = true;
    
    if ([self getAuthStatus] == UNPROTECTED)
        _currentAuthStatusLabel.text = MSG_TAG_UNPROTECTED;
    else
        _currentAuthStatusLabel.text = MSG_TAG_PROTECTED;
}

@end
