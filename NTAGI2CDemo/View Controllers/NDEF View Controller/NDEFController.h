//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NTAG_I2C_LIB.h"
#import "NDEFOperationController.h"
#import "UriRecord.h"
#import "TextRecord.h"
#import "SmartPosterRecord.h"
#import "BTRecord.h"
#import "MIMERecord.h"
#import "ExternalRecord.h"
#import "AuthViewController.h"

@interface NDEFController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *NDEFView_Layer1;
@property (weak, nonatomic) IBOutlet UIView *NDEFView_Layer2;
@property (weak, nonatomic) IBOutlet UIButton *ReadNDEFButton;
@property (weak, nonatomic) IBOutlet UIButton *WriteNDEFButton;
@property (weak, nonatomic) IBOutlet UIButton *writeDefaultNDEFButton;
@property (weak, nonatomic) IBOutlet UITextField *TextField_Layer1;
@property (weak, nonatomic) IBOutlet UITextField *TextField_Layer2;
@property (weak, nonatomic) IBOutlet UILabel *performanceLabel;
@property (weak, nonatomic) IBOutlet UITextView *NDEFMessageTextView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *readNDEFView;
@property (weak, nonatomic) IBOutlet UIView *writeNDEFView;
@property (weak, nonatomic) IBOutlet UIView *textRecordCheckbox;
@property (weak, nonatomic) IBOutlet UIView *uriRecordCheckbox;
@property (weak, nonatomic) IBOutlet UIView *btRecordCheckbox;
@property (weak, nonatomic) IBOutlet UIView *spRecordCheckbox;
@property (weak, nonatomic) IBOutlet UIView *writeNDEFtextFieldsView;
@property (weak, nonatomic) IBOutlet UIView *writeNDEFRecordOptionsBar;
@property (weak, nonatomic) IBOutlet UIImageView *textrecordCheckBoxImage;
@property (weak, nonatomic) IBOutlet UIImageView *uriRecordCheckboxImage;
@property (weak, nonatomic) IBOutlet UIImageView *btRecordCheckboxImage;
@property (weak, nonatomic) IBOutlet UIImageView *spRecordCheckboxImage;

@property (weak, nonatomic) IBOutlet UITextField *ndefMessageTextField;

@property (weak, nonatomic) IBOutlet UITextField *uriRecordTextField;

@property (weak, nonatomic) IBOutlet UIView *macAddressView;
@property (weak, nonatomic) IBOutlet UITextField *macAddressTextField;
@property (weak, nonatomic) IBOutlet UIView *deviceNameView;
@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextField;
@property (weak, nonatomic) IBOutlet UIView *deviceClassView;
@property (weak, nonatomic) IBOutlet UITextField *deviceClassTextField;

@property (weak, nonatomic) IBOutlet UIView *spRecordTitleView;
@property (weak, nonatomic) IBOutlet UITextField *spRecordTitleTextField;
@property (weak, nonatomic) IBOutlet UIView *spRecordLinkView;
@property (weak, nonatomic) IBOutlet UITextField        *spRecordLinkTextField;
@property (weak, nonatomic) IBOutlet UIImageView        *lockIcon;
@property (weak, nonatomic) IBOutlet UIButton           *iARChechboxButton;
@property (weak, nonatomic) IBOutlet UILabel            *readViewMsgTypeLabel;
@property (weak, nonatomic) IBOutlet UIView             *DropDownMenu_View;
@property (weak, nonatomic) IBOutlet UIImageView        *DropDownIcon;
@property (weak, nonatomic) IBOutlet UIButton           *FeedBackEmailButton;

- (IBAction)scanButtonTap:(id)sender;
- (IBAction)readNDEFButtonClick:(UIButton *)sender;
- (IBAction)writeNDEFButtonClick:(UIButton *)sender;
- (IBAction)lockIconTap:(id)sender;
- (IBAction)writeDefaultNDEFButtonClick:(UIButton *)sender;
- (IBAction)iARCheckboxButtonClick:(UIButton *)sender;

@end
