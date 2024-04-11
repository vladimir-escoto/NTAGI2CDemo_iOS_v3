//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreNFC/CoreNFC.h>
#import "AppDelegate.h"

#import "NTAG_I2C_LIB.h"
#import "SpeedUseCase.h"
@interface SPEEDViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *SpeedLayer1_View;
@property (weak, nonatomic) IBOutlet UIButton *StartLayer1_Button;
@property (weak, nonatomic) IBOutlet UIView *SpeedLayer2_View;
@property (weak, nonatomic) IBOutlet UITextField *SpeedPerformanceText;
@property (weak, nonatomic) IBOutlet UILabel *rf_textcallback;
@property (weak, nonatomic) IBOutlet UITextView *SpeedResultText;
@property (weak, nonatomic) IBOutlet UITextField *blockmulti;
@property (weak, nonatomic) IBOutlet UILabel *blockmulti_str;
@property (weak, nonatomic) IBOutlet UITextView *performance_text;
@property (weak, nonatomic) IBOutlet UIImageView *lockIcon;
@property (weak, nonatomic) NSString * writeString;
@property (weak, nonatomic) NSString * readString;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView             *DropDownMenu_View;
@property (weak, nonatomic) IBOutlet UIImageView        *DropDownIcon;
@property (weak, nonatomic) IBOutlet UIButton           *FeedBackEmailButton;

- (IBAction)lockIconClick:(id)sender;

@end
