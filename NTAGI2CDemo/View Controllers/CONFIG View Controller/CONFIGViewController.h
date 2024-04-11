//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthViewController.h"

#define URLEMail @"mailto:mobileapp.support@nxp.com"

@interface CONFIGViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView             *ConfigLayer_View;
@property (weak, nonatomic) IBOutlet UIImageView        *lockIcon;
@property (weak, nonatomic) IBOutlet UIView             *DropDownMenu_View;
@property (weak, nonatomic) IBOutlet UIImageView        *DropDownIcon;
@property (strong, nonatomic) IBOutlet UIView           *MainDemoView;
@property (weak, nonatomic) IBOutlet UIButton           *FeedBackEmailButton;

- (IBAction)lockIconClick:(id)sender;

@end
