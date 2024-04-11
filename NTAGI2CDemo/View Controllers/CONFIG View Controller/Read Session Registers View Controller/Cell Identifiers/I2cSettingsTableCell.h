//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface I2cSettingsTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *wdLsValue;
@property (weak, nonatomic) IBOutlet UILabel *wdMsValue;
@property (weak, nonatomic) IBOutlet UIImageView *i2cClockStretchValue;

@end
