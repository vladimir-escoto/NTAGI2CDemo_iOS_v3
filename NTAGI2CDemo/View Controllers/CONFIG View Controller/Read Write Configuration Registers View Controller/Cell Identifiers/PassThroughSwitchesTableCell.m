//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "PassThroughSwitchesTableCell.h"

@implementation PassThroughSwitchesTableCell

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

- (IBAction)directionChanged:(id)sender {
    if(_directionSegmentedControl.selectedSegmentIndex == 0)
        _writeFromRfSegmentedControl.selectedSegmentIndex = 0;
    else
        _writeFromRfSegmentedControl.selectedSegmentIndex = 1;
}

- (IBAction)writeFromRFChanged:(id)sender {
    if(_writeFromRfSegmentedControl.selectedSegmentIndex == 0)
        _directionSegmentedControl.selectedSegmentIndex = 0;
    else
        _directionSegmentedControl.selectedSegmentIndex = 1;
}
@end
