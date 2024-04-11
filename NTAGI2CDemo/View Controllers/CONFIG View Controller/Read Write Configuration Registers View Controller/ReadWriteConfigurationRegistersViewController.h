//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReadWriteConfigurationRegistersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *configurationRegistersTableView;
@property (strong, nonatomic) NSArray *expandedHeights;
@property (strong, nonatomic) NSMutableArray *collapsedStatus;
@property (weak, nonatomic) IBOutlet UIImageView *scanButton;
@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (strong, nonatomic) NSDictionary *configRegisters;
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionPT;

#define CHIP_INFO_CELLID @"generalChipInfoTableCell"
#define FIELD_DETECTION_MENU_CELLID @"fieldDetectionMenuTableCell"
#define PASSTHROUGH_SWITCHES_CELLID @"passThroughSwitchesTableCell"
#define SRAM_MEMORY_CELLID @"sramMemoryTextTableCell"
#define I2C_SETTINGS_TEXT_CELLID @"i2cSettingsTextTableCell"
#define ACCESS_CONFIGURATION_CELLID @"accessConfigurationTableCell"

- (IBAction)writeFromRFChanged:(id)sender;
- (IBAction)directionPTChanged:(id)sender;
- (IBAction)i2cClockStretchChanged:(id)sender;
- (IBAction)i2cRSTSOnStartChanged:(id)sender;
- (IBAction)NFCprotChanged:(id)sender;
- (IBAction)NFCDISSec1Changed:(id)sender;
- (IBAction)k2ProtChanged:(id)sender;
- (IBAction)SRAMProtChanged:(id)sender;

- (IBAction)scanButtonClick:(id)sender;
@end

NS_ASSUME_NONNULL_END
