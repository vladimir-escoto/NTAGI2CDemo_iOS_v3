//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralChipInfoTableCell.h"
#import "NtagConfigurationTableCell.h"
#import "FieldDetectionTableCell.h"
#import "PassthroughTableCell.h"
#import "SramMemorySettingsTableCell.h"
#import "I2cSettingsTableCell.h"
#import "readSessionRegistersOperationsController.h"
#import "AuthViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReadSessionRegistersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *sessionRegistersTableView;
@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (weak, nonatomic) IBOutlet UIImageView *scanButton;

@property (strong, nonatomic) NSDictionary *sessionRegistersRead;
@property (strong, nonatomic) NSArray *expandedHeights;
@property (strong, nonatomic) NSMutableArray *collapsedStatus;

#define CHIP_INFO_CELLID @"generalChipInfoTableCell"
#define NTAG_CONFIG_CELLID @"ntagConfigurationTableCell"
#define FIELD_DETECT_CELLID @"fieldDetectionTableCell"
#define PASSTHROUGH_CELLID @"passthroughTableCell"
#define SRAM_MEM_CELLID @"sramMemorySettingsTableCell"
#define I2C_SETTINGS_CELLID @"i2cSettingsTableCell"

- (IBAction)scanButtonClick:(id)sender;

@end

NS_ASSUME_NONNULL_END
