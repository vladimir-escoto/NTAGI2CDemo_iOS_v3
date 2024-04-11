//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResetViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *scanButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *performanceView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *globalView;
@property (weak, nonatomic) IBOutlet UITextView *performanceTextView;

- (IBAction)scanButtonClick:(id)sender;
- (IBAction)cancelButtonClick:(id)sender;

@end

NS_ASSUME_NONNULL_END
