//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "CONFIGViewController.h"
#import "AppDelegate.h"
@interface CONFIGViewController ()
@end

@implementation CONFIGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeViews];
}

- (void)SetNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yourNotificationHandler:) name:TXT_AUTH_DISMISS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeImage:)             name:TXT_IMG_CHANGE_NOTIFY object:nil];
}

- (void)CustomizeViews {
    [self SetConfigLayerView];
    [self SetNotifications];
    [self setUpDropDownMenuContainer];
    [self setUpDropDownButtonListener];
    [self setAutoHideDropDownMenuListener];
    [self setUpFeedbackButton];
}

- (void)SetConfigLayerView {
    _ConfigLayer_View.layer.cornerRadius       = 12;
    _ConfigLayer_View.layer.borderWidth        = 2;
    _ConfigLayer_View.layer.borderColor        = [UIColor blackColor].CGColor;
    _ConfigLayer_View.layer.masksToBounds      = true;
}

- (IBAction)lockIconClick:(id)sender {
    AuthStatus authStatus;
    if(_lockIcon.image == [UIImage imageNamed:IMG_SRC_LOCK])
        authStatus = PROTECTED_RW_SRAM;
    else
        authStatus = UNPROTECTED;
    [self throwAuthController: authStatus];
}

-(void) throwAuthController: (AuthStatus *) authStatus{
    NSString * storyboardName = TXT_SB_MAIN;
    UIStoryboard *storyboard  = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    AuthViewController * vc   = [storyboard instantiateViewControllerWithIdentifier:TXT_AUTH_ID];
    [vc setAuthStatus:authStatus];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)yourNotificationHandler:(NSNotification *)notice{
    NSString *str = [notice object];
    if ([str  isEqual: MSG_TAG_PROTECTED]){
        _lockIcon.image = [UIImage imageNamed:IMG_SRC_LOCK];
    }
    else if ([str  isEqual: MSG_TAG_UNPROTECTED]){
        _lockIcon.image = [UIImage imageNamed:IMG_SRC_OPEN];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TXT_IMG_CHANGE_NOTIFY object:str];
}

-(void)changeImage:(NSNotification *)notice{
    NSString *str = [notice object];
    if ([str  isEqual: MSG_TAG_PROTECTED]){
        _lockIcon.image = [UIImage imageNamed:IMG_SRC_LOCK];
    }
    else if ([str  isEqual: MSG_TAG_UNPROTECTED]){
        _lockIcon.image = [UIImage imageNamed:IMG_SRC_OPEN];
    }
}

- (void) setUpDropDownMenuContainer {
    _DropDownMenu_View.layer.cornerRadius  = 1;
    _DropDownMenu_View.layer.borderWidth   = 1;
    _DropDownMenu_View.layer.borderColor   = [UIColor blueColor].CGColor;
    _DropDownMenu_View.layer.masksToBounds = NO;
    _DropDownMenu_View.layer.shadowOffset  = CGSizeMake(3, 3);
    _DropDownMenu_View.layer.shadowRadius  = 1;
    _DropDownMenu_View.layer.shadowOpacity = 0.35;
}

- (void) setUpDropDownButtonListener{
    UITapGestureRecognizer *singleTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DropDownTapDetected)];
    singleTap.numberOfTapsRequired      = 1;
    
    [_DropDownIcon setUserInteractionEnabled:YES];
    [_DropDownIcon addGestureRecognizer:singleTap];
}

- (void)DoDropdownUIAnim {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionReveal;
    animation.duration = 0.15;
    [_DropDownMenu_View.layer addAnimation:animation forKey:nil];
}

- (void) DropDownTapDetected{
    bool ishidden = _DropDownMenu_View.hidden;
    if(ishidden == NO){
        [self DoDropdownUIAnim];
        _DropDownMenu_View.hidden = YES;
    }else{
        [self DoDropdownUIAnim];
        _DropDownMenu_View.hidden = NO;
    }
}

-(void)HideWhenTappedAnywhere{
    [self DoDropdownUIAnim];
    _DropDownMenu_View.hidden = YES;
}

- (void) setAutoHideDropDownMenuListener {
    UITapGestureRecognizer *singleTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideWhenTappedAnywhere)];
    singleTap.numberOfTapsRequired      = 1;
    
    [_MainDemoView setUserInteractionEnabled:YES];
    [_MainDemoView addGestureRecognizer:singleTap];
}

- (void) setUpFeedbackButton{
    [_FeedBackEmailButton addTarget:self action:@selector(callAlert)forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FeedbackEmail)];
    singleTap.numberOfTapsRequired = 1;
    [_FeedBackEmailButton setUserInteractionEnabled:YES];
    [_FeedBackEmailButton addGestureRecognizer:singleTap];
}

- (void) FeedbackEmail{
    NSString * url     = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString * title   = TXT_TITLE_FEEDBACK;
    NSString * content = @"iOS Version: ";
    
    content = [NSString stringWithFormat: @"%@%@\n", content, [[UIDevice currentDevice] systemVersion]];
    content = [NSString stringWithFormat: @"%@Model: %@\n", content, [[UIDevice currentDevice] model]];
    content = [NSString stringWithFormat: @"%@Name: %@\n", content, [[UIDevice currentDevice] systemName]];
    content = [NSString stringWithFormat: @"%@Brand: %@\n", content, @"Apple"];
    content = [NSString stringWithFormat: @"%@App Version: %@\n", content, APP_VERSION];
    url = [NSString stringWithFormat: @"%@?subject=%@&body=%@", url, title, content];
    
    NSURL *url2 = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [[UIApplication sharedApplication]  openURL:url2 options:@{} completionHandler:^(BOOL success) {}];
}

@end
