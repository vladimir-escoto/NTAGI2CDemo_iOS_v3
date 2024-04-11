//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreNFC/CoreNFC.h>
#import "AppDelegate.h"
#import "NTAG_I2C_LIB.h"
#import "AboutUseCase.h"
@interface AboutMenuController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *AboutViewController;

@property (weak, nonatomic) IBOutlet UIButton *Top_Box;
@property (weak, nonatomic) IBOutlet UITextView *Top_Box_Text;

@property (weak, nonatomic) IBOutlet UIImageView *IMG_DEVICE;
@property (weak, nonatomic) IBOutlet UILabel *TEXT1;
@property (weak, nonatomic) IBOutlet UILabel *TEXT2_VERSION;
@property (weak, nonatomic) IBOutlet UILabel *TEXT3_DATE;
@property (weak, nonatomic) IBOutlet UILabel *NFC_TEXT;
@property (weak, nonatomic) IBOutlet UIImageView *NFC_Button;
@end
