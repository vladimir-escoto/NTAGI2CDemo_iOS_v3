//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface I2cSettingsTextTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *wdLsTimerTextField;
@property (weak, nonatomic) IBOutlet UITextField *wdMsTimerTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *i2cClockStretchSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *i2cRstSegmentedControl;


@end

NS_ASSUME_NONNULL_END
