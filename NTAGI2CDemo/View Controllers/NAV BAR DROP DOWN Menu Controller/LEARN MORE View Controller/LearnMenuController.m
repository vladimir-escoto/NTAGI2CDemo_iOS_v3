//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "LearnMenuController.h"
#import "AppDelegate.h"

@interface LearnMenuController ()
@end

@implementation LearnMenuController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeViews];
    
    [self SetUiButtonListeners];
}

- (void)CustomizeViews {
    _LearnMenuView.layer.cornerRadius       = 12;
    _LearnMenuView.layer.borderWidth        = 1.5;
    _LearnMenuView.layer.borderColor        = [UIColor blackColor].CGColor;
    _LearnMenuView.layer.masksToBounds      = true;
}

- (void) SetUiButtonListeners{

    UITapGestureRecognizer *web_link_webpage_tap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(web_link_webpage_tap_logic)];
    web_link_webpage_tap.numberOfTapsRequired      = 1;
    [_web_link_webpage setUserInteractionEnabled:YES];
    [_web_link_webpage addGestureRecognizer:web_link_webpage_tap];
    
    UITapGestureRecognizer *web_link_datasheet_tap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(web_link_datasheet_tap_logic)];
    web_link_datasheet_tap.numberOfTapsRequired      = 1;
    [_web_link_datasheet setUserInteractionEnabled:YES];
    [_web_link_datasheet addGestureRecognizer:web_link_datasheet_tap];
     
    UITapGestureRecognizer *web_link_usermanual_tap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(web_link_usermanual_tap_logic)];
    web_link_usermanual_tap.numberOfTapsRequired      = 1;
    [_web_link_usermanual setUserInteractionEnabled:YES];
    [_web_link_usermanual addGestureRecognizer:web_link_usermanual_tap];
      
    UITapGestureRecognizer *web_link_design_tap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(web_link_designfiles_tap_logic)];
    web_link_design_tap.numberOfTapsRequired      = 1;
    [_web_link_design setUserInteractionEnabled:YES];
    [_web_link_design addGestureRecognizer:web_link_design_tap];
       
    UITapGestureRecognizer *web_link_src_tap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(web_link_src_tap_logic)];
    web_link_src_tap.numberOfTapsRequired      = 1;
    [_web_link_usercode setUserInteractionEnabled:YES];
    [_web_link_usercode addGestureRecognizer:web_link_src_tap];
}

- (void) web_link_webpage_tap_logic {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_WEB_LINK_WEBPAGE] options:@{} completionHandler:nil];
}

- (void) web_link_datasheet_tap_logic {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_WEB_LINK_DATASHEET] options:@{} completionHandler:nil];
}

- (void) web_link_usermanual_tap_logic {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_WEB_LINK_USERMANUAL] options:@{} completionHandler:nil];
}

- (void) web_link_designfiles_tap_logic {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_WEB_LINK_DESIGNFILES] options:@{} completionHandler:nil];
}

- (void) web_link_src_tap_logic {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_WEB_LINK_SRC] options:@{} completionHandler:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}



- (IBAction)Close_View:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
