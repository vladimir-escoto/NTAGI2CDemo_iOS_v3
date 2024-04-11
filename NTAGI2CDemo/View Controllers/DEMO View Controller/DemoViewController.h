//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreNFC/CoreNFC.h>
#import "AppDelegate.h"
#import "NTAG_I2C_LIB.h"
#import "DemoUseCase.h"
#import "AuthViewController.h"

@interface DemoViewController : UIViewController

// CheckBox Listener
- (IBAction)CheckBoxClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView        *Switch;
@property (strong, nonatomic) IBOutlet UIView           *MainDemoView;

// UI BUTTONS
@property (weak, nonatomic) IBOutlet UIButton           *Orange_Button;
@property (weak, nonatomic) IBOutlet UIButton           *Blue_Button;
@property (weak, nonatomic) IBOutlet UIButton           *Green_Button;

@property (weak, nonatomic) IBOutlet UIButton           *NavigationButtonLeftDEMO;

//UI VIEWS
@property (weak, nonatomic) IBOutlet UIView             *BoardConfig_View;
@property (weak, nonatomic) IBOutlet UIView             *BoardStatus_View;
@property (weak, nonatomic) IBOutlet UIView             *DropDownMenu_View;

//UI BUTTONS
@property (weak, nonatomic) IBOutlet UIButton           *TemperatureSensor_CheckBox;
@property (weak, nonatomic) IBOutlet UIButton           *LCD_CheckBox;
@property (weak, nonatomic) IBOutlet UIButton           *NDEFLCD_CheckBox;
@property (weak, nonatomic) IBOutlet UIButton           *FeedBackEmailButton;
@property (weak, nonatomic) IBOutlet UIImageView        *lockIcon;

//UI IMAGE VIEWS
@property (weak, nonatomic) IBOutlet UIImageView        *NTAGLogo_ImageView;
@property (weak, nonatomic) IBOutlet UIImageView        *NXPLogo_ImageView;
@property (weak, nonatomic) IBOutlet UIImageView        *DropDownIcon;

//UI LABELS
@property (weak, nonatomic) IBOutlet UILabel            *NDEFLCD_TextView;
@property (weak, nonatomic) IBOutlet UILabel            *TapToSwitch_TextView;

//UI LAYOUT CONSTAINTS
@property (weak, nonatomic) IBOutlet UIImageView        *NFC_BUTTON;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BoardViewHeight;


@property (weak, nonatomic) IBOutlet UILabel            *TransferText;
@property (weak, nonatomic) IBOutlet UILabel            *TemperatureText;
@property (weak, nonatomic) IBOutlet UILabel            *VoltageText;


@end

