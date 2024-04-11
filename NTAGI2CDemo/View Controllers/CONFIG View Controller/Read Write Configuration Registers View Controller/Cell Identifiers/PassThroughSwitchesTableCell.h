//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PassThroughSwitchesTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *directionSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *writeFromRfSegmentedControl;
- (IBAction)directionChanged:(id)sender;
- (IBAction)writeFromRFChanged:(id)sender;

@end

NS_ASSUME_NONNULL_END
