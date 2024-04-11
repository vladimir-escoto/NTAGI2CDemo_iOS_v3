//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassthroughTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *passthroughCheckbox;
@property (weak, nonatomic) IBOutlet UIImageView *i2cLockedCheckbox;
@property (weak, nonatomic) IBOutlet UIImageView *rfLockedCheckbox;
@property (weak, nonatomic) IBOutlet UIImageView *sramI2cReadyCheckbox;
@property (weak, nonatomic) IBOutlet UIImageView *sramRfReadyCheckbox;
@property (weak, nonatomic) IBOutlet UIImageView *rfToI2cCheckbox;

@end
