//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashUseCase.h"

@interface FlashMenuController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *FlashLayer1_View;

@property (weak, nonatomic) IBOutlet UIButton *select_appl_flash1;
@property (weak, nonatomic) IBOutlet UIButton *select_storage_flash1;
@property (weak, nonatomic) IBOutlet UIView *Background_Black;
@property (weak, nonatomic) IBOutlet UIView *Select_App_Flash_Box;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

