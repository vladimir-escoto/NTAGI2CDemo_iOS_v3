//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FieldDetectionMenuTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *FD_OFFTextField;
@property (weak, nonatomic) IBOutlet UITextField *FD_ONTextField;

@property (weak, nonatomic) IBOutlet UILabel *FD_OFFLabel;
@property (weak, nonatomic) IBOutlet UILabel *FD_ONLabel;
@end

NS_ASSUME_NONNULL_END

