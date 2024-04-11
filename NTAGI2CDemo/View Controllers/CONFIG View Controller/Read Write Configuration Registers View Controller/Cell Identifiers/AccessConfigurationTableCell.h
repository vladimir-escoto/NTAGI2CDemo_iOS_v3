//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccessConfigurationTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *auth0TextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *nfcProtSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *authLimTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *nfcDisSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *twoKSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sramProtSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *i2cProtTextField;

@end

NS_ASSUME_NONNULL_END
