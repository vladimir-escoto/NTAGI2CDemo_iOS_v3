//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "SPEEDViewController.h"
#import "AuthViewController.h"

@interface SPEEDViewController ()
@end

@implementation SPEEDViewController

bool isSRAM = false;
NSString * authStatus = @"UNPROTECTED";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeViews];
}

- (IBAction)Start_Button_Listener:(id)sender {
    
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
        if(isSRAM){
            [[SpeedUseCase sharedInstance] SRAMDemo:_blockmulti.text onSuccess:^(NSString *str) {
                [self showPerformance:str];
            } onFailure:^(AuthStatus status) {
                // Authentication required. Throw Authentication ViewController
                [self throwAuthController: status];
            }];
        } else {
            [[SpeedUseCase sharedInstance] EEPROMDemo:_blockmulti.text onSuccess:^(NSString *str) {
                [self showPerformance:str];
            } onFailure:^(AuthStatus status) {
                // Authentication required. Throw Authentication ViewController
                [self throwAuthController: status];
            }];
        }
        
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 1){
        NSLog(@"Not connected!!!");
    }
}

/*---------------------- UI METHODS -----------------------*/

- (IBAction)SRAM_LISTENER:(id)sender {
    _blockmulti.text = @"10";
    _blockmulti_str.text = @"x 64 Bytes";
    
    isSRAM = true;
}

- (IBAction)EEPROM_LISTENER:(id)sender {
    _blockmulti.text = @"640";
    _blockmulti_str.text = @"+ 12 (overhead) Bytes";
    
    isSRAM = false;
}

- (void)CustomizeViews {
    _SpeedLayer1_View.layer.cornerRadius       = 12;
    _SpeedLayer1_View.layer.borderWidth        = 2;
    _SpeedLayer1_View.layer.borderColor        = [UIColor blackColor].CGColor;
    _SpeedLayer1_View.layer.masksToBounds      = true;
    
    _SpeedLayer2_View.layer.cornerRadius       = 12;
    _SpeedLayer2_View.layer.borderWidth        = 2;
    _SpeedLayer2_View.layer.borderColor        = [UIColor blackColor].CGColor;
    _SpeedLayer2_View.layer.masksToBounds      = true;
    
    _StartLayer1_Button.layer.cornerRadius        = 4;
    _StartLayer1_Button.layer.borderWidth         = 1;
    _StartLayer1_Button.layer.borderColor         = [UIColor blackColor].CGColor;
    _StartLayer1_Button.layer.masksToBounds       = true;
    
    CAGradientLayer * gradient                = [CAGradientLayer layer];
    
    gradient.frame                            = _StartLayer1_Button.bounds;
    gradient.colors                           = @[(id)UIColorFromRGB(0x7BB1D9).CGColor, (id) UIColorFromRGB(0x2f6699).CGColor];
    
    [_StartLayer1_Button.layer insertSublayer:gradient atIndex:0];
    
    _performance_text.layer.masksToBounds     = YES;
    _performance_text.layer.borderColor       = [[UIColor orangeColor]CGColor];
    _performance_text.layer.borderWidth       = 2.0f;
    
    
    _blockmulti.text = @"10";
    _blockmulti_str.text = @"x 64 Bytes";
    
    isSRAM = true;
    
    [self setAutoHideDropDownMenuListener];
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(yourNotificationHandler:)
    name:@"AUTH VC DISMISS" object:nil];
    
    [self setUpDropDownMenuContainer];
    [self setUpDropDownButtonListener];
    [self setUpFeedbackButton];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeImage:)
                                                 name:@"ImageChangeNotification"
                                               object:authStatus];
}


// Shows the messages coming from the callbacks in EEPROMDemo and SRAMDemo and print it in the performance text view
- (void) showPerformance: (NSString *) text {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        self->_performance_text.text = text;
        
    }];
}

-(void) throwAuthController: (AuthStatus *) authStatus{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    AuthViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"AUTH_ID"];
    [vc setAuthStatus:authStatus];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)lockIconClick:(id)sender{
    AuthStatus authStatus;
    if(_lockIcon.image == [UIImage imageNamed:@"lock.png"])
        authStatus = PROTECTED_RW_SRAM;
    else
        authStatus = UNPROTECTED;
    [self throwAuthController: authStatus];
}

-(void)yourNotificationHandler:(NSNotification *)notice{
    NSString *str = [notice object];
    if ([str  isEqual: @"PROTECTED"]){
        _lockIcon.image = [UIImage imageNamed:@"lock.png"];
    }
    else if ([str  isEqual: @"UNPROTECTED"])
        _lockIcon.image = [UIImage imageNamed:@"open.png"];
    

    authStatus = str;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageChangeNotification" object:authStatus];
}

-(void)changeImage:(NSNotification *)notice{
     NSString *str = [notice object];
       if ([str  isEqual: @"PROTECTED"]){
           _lockIcon.image = [UIImage imageNamed:@"lock.png"];
       }
       else if ([str  isEqual: @"UNPROTECTED"])
           _lockIcon.image = [UIImage imageNamed:@"open.png"];
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

- (void) setAutoHideDropDownMenuListener {
    UITapGestureRecognizer *singleTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideWhenTappedAnywhere)];
    singleTap.numberOfTapsRequired      = 1;
    
    [_mainView setUserInteractionEnabled:YES];
    [_mainView addGestureRecognizer:singleTap];
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
