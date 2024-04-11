//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "DebugMenuController.h"
#import "AppDelegate.h"

@interface DebugMenuController ()
@end

@implementation DebugMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeViews];
}

- (void)CustomizeViews {
    _DebugMenuView.layer.cornerRadius       = 12;
    _DebugMenuView.layer.borderWidth        = 2;
    _DebugMenuView.layer.borderColor        = [UIColor blackColor].CGColor;
    _DebugMenuView.layer.masksToBounds      = true;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


@end
