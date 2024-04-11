//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FieldDetectionTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fdOffValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *fdOnValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastBlockValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dataReadCheckbox;
@property (weak, nonatomic) IBOutlet UIImageView *rfFieldCheckbox;

@end
