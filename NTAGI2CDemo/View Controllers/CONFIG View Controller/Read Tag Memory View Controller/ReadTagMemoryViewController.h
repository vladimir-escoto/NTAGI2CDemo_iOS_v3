//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReadTagMemoryViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *scanPicture;
@property (weak, nonatomic) IBOutlet UIView *scanButtonView;
@property (weak, nonatomic) IBOutlet UIView *globalView;
@property (weak, nonatomic) IBOutlet UIView *performanceView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITextView *readMessageTextView;
@property (weak, nonatomic) IBOutlet UITextView *performanceTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *scanButton;

- (IBAction)cancelButtonClick:(id)sender;
- (IBAction)scanButtonClick:(id)sender;


@end

NS_ASSUME_NONNULL_END
