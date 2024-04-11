//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTAG_I2C_LIB.h"
#import "AuthOperationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AuthViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView          *mainView;
@property (weak, nonatomic) IBOutlet UIButton        *authButtonSUN;
@property (weak, nonatomic) IBOutlet UIButton        *authButtonSTAR;
@property (weak, nonatomic) IBOutlet UIButton        *authButtonMOON;
@property (weak, nonatomic) IBOutlet UILabel         *currentAuthStatusLabel;
@property (weak, nonatomic) IBOutlet UITextView      *warningTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *CancelButton;

@property (assign) AuthStatus *currentStatus;

- (AuthStatus) getAuthStatus;

- (void) setAuthStatus: (AuthStatus *)       authStatus;
- (IBAction)cancelButtonClick:(UIBarButtonItem *)sender;
- (IBAction)authButtonSUNClick:(UIButton *)      sender;
- (IBAction)authButtonSTARClick:(UIButton *)     sender;
- (IBAction)authButtonMOONClick:(UIButton *)     sender;

@end

NS_ASSUME_NONNULL_END
