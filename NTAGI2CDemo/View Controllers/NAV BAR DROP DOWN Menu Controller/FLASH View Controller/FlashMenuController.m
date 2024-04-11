//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "FlashMenuController.h"
#import "AppDelegate.h"

@interface FlashMenuController ()
@end

@implementation FlashMenuController
NSArray *directoryList;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeViews];
    
    [self SetUIActionListener];
    
    directoryList = [[NSArray alloc] init];
}

- (void) SetUIActionListener{
    
      UITapGestureRecognizer *TapToBackground   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HidePopups)];
    
      TapToBackground.numberOfTapsRequired      = 1;
      
      [_Background_Black setUserInteractionEnabled:YES];
      [_Background_Black addGestureRecognizer:TapToBackground];
      [_Select_App_Flash_Box setHidden:true];
      [_table setDelegate:self];
      [_table setDataSource:self];
    
      _table.layer.borderWidth = 2.0;
}

-(void) HidePopups{
    [_Background_Black     setHidden:true];
    [_Select_App_Flash_Box setHidden:true];
    [_table     setHidden:true];
     
}

- (void)CustomizeViews {
    _FlashLayer1_View.layer.cornerRadius       = 12;
    _FlashLayer1_View.layer.borderWidth        = 1.5;
    _FlashLayer1_View.layer.borderColor        = [UIColor blackColor].CGColor;
    _FlashLayer1_View.layer.masksToBounds      = true;

    _select_appl_flash1.layer.cornerRadius        = 4;
    _select_appl_flash1.layer.borderWidth         = 1;
    _select_appl_flash1.layer.borderColor         = [UIColor blackColor].CGColor;
    _select_appl_flash1.layer.masksToBounds       = true;
    
    _select_storage_flash1.layer.cornerRadius        = 4;
    _select_storage_flash1.layer.borderWidth         = 1;
    _select_storage_flash1.layer.borderColor         = [UIColor blackColor].CGColor;
    _select_storage_flash1.layer.masksToBounds       = true;
    
    CAGradientLayer * gradient_select_appl_flash1    = [CAGradientLayer layer];
    gradient_select_appl_flash1.frame                = _select_appl_flash1.bounds;
    gradient_select_appl_flash1.colors               = @[(id)UIColorFromRGB(0x7BB1D9).CGColor, (id) UIColorFromRGB(0x2f6699).CGColor];
    [_select_appl_flash1.layer insertSublayer:gradient_select_appl_flash1 atIndex:0];
    
    CAGradientLayer * gradient_select_storage_flash1 = [CAGradientLayer layer];
    CGRect cgrect= _select_appl_flash1.bounds;
    
    cgrect.size.width *= 2 ;
    
    gradient_select_storage_flash1.frame             =cgrect;
    gradient_select_storage_flash1.colors            = @[(id)UIColorFromRGB(0x7BB1D9).CGColor, (id) UIColorFromRGB(0x2f6699).CGColor];
    [_select_storage_flash1.layer insertSublayer:gradient_select_storage_flash1 atIndex:0];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
           [self showAlertMessage];
       });}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


- (IBAction)Close_Window:(id)sender {
      [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)Select_From_App_Action:(id)sender {
    
    [_Background_Black     setHidden:false];
    [_Select_App_Flash_Box setHidden:false];

}

- (IBAction)Select_From_Storage_Action:(id)sender {
    
    [_Background_Black     setHidden:false];
    
    [_table     setHidden:false];
    
    //get an instance of the File Manager
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //Get the docs directory
    NSString *documentsPath = [paths objectAtIndex:0];

    //we'll need NSURL for the File Manager
    NSURL *tempDirURL = [NSURL fileURLWithPath:documentsPath];

      //An array of NSURL object representing the path to the file
        //using the flag NSDirectoryEnumerationSkipsHiddenFiles to skip hidden files

    directoryList = [fileManager contentsOfDirectoryAtURL:tempDirURL
                          includingPropertiesForKeys:nil
                  options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    [_Select_App_Flash_Box setHidden:true];
    
    [_table reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
 
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
 
    NSURL *obj = [directoryList objectAtIndex:indexPath.row];
    cell.textLabel.text = [obj  lastPathComponent];   //file:///private/var/mobile/Containers/Data/Application/E085C508-CE3C-45F5-A914-14779B4D7CD8/Documents/
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return directoryList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Your Code here
    NSURL *obj = [directoryList objectAtIndex:indexPath.row];
    NSString * path = [obj path];

    [self ExecuteFlashFromFile:path];
    
    [_table     setHidden:false];
    [self HidePopups];
}


- (void)ExecuteFlashFromFile:(NSString *) path {

    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
    
    [[ NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {
        NSLog(@"Connection done");
    } onFailure:^(NSError *error) {
        NSLog(@"Failure at init Session");
    }];
    
    NSLog(@"Waiting for connection...");
    
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent() + 5;
    CFAbsoluteTime after = CFAbsoluteTimeGetCurrent();
    
    while ([[ NTAG_I2C_LIB sharedInstance] isConnect] == 0){
        
        if(before == after){
            break;
        }
        after = CFAbsoluteTimeGetCurrent();
    }
    
    if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 3){
        NSLog(@"Connected!!!");
        
        [[FlashUseCase sharedInstance] Flash:^(int step, NSString *dataStr) {
            
            // CASE 1: Update FLashDialogMax
            
            if(step == 1){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [[NTAG_I2C_LIB sharedInstance] setAlertMessage:dataStr];
                    
                }];
                
            }
            
            if(step == 2){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [[NTAG_I2C_LIB sharedInstance] setAlertMessage:dataStr];
                    
                }];
            }
            
            if (step == 3 ){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [[NTAG_I2C_LIB sharedInstance] closeWithCustomMessage:dataStr];
                    
                }];
                
            }
            
        } onFailure:^(NSString *status) {
            [[ NTAG_I2C_LIB sharedInstance] customErrorMessage:status];
        } bytesToFlash:fileData];
        
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 1){
        NSLog(@"Not connected!!!");
    }
}


- (void)ExecuteFlash {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *myFile = [mainBundle pathForResource: @"demo" ofType: @"bin"];
    
    NSLog(@"Main bundle path: %@", mainBundle);
    NSLog(@"myFile path: %@", myFile);
    
    NSURL *fileUrl = [NSURL fileURLWithPath:myFile];
    NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
    
    
    [[ NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {
        NSLog(@"Connection done");
    } onFailure:^(NSError *error) {
        NSLog(@"Failure at init Session");
    }];
    
    NSLog(@"Waiting for connection...");
    
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent() + 5;
    CFAbsoluteTime after = CFAbsoluteTimeGetCurrent();
    
    while ([[ NTAG_I2C_LIB sharedInstance] isConnect] == 0){
        
        if(before == after){
            break;
        }
        after = CFAbsoluteTimeGetCurrent();
    }
    
    if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 3){
        NSLog(@"Connected!!!");
        
        [[FlashUseCase sharedInstance] Flash:^(int step, NSString *dataStr) {
            
            // CASE 1: Update FLashDialogMax
            
            if(step == 1){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [[NTAG_I2C_LIB sharedInstance] setAlertMessage:dataStr];
                    
                }];
                
            }
            
            if(step == 2){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [[NTAG_I2C_LIB sharedInstance] setAlertMessage:dataStr];
                    
                }];
            }
            
            if (step == 3 ){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [[NTAG_I2C_LIB sharedInstance] closeWithCustomMessage:dataStr];
                    
                }];
                
            }
            
        } onFailure:^(NSString *status) {
            [[ NTAG_I2C_LIB sharedInstance] closeWithCustomMessage:status];
        } bytesToFlash:fileData];
        
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 4){
        NSLog(@"Not connected!!!");
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 1){
        NSLog(@"Not connected!!!");
    }
}

- (IBAction)Demo_App_Action:(id)sender {
    [self HidePopups];
    [self ExecuteFlash];
}

- (IBAction)Led_Blinker_Action:(id)sender {
    [self HidePopups];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *myFile = [mainBundle pathForResource: @"blink" ofType: @"bin"];

    NSLog(@"Main bundle path: %@", mainBundle);
    NSLog(@"myFile path: %@", myFile);

    NSURL *fileUrl = [NSURL fileURLWithPath:myFile];
    NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];

    [[ NTAG_I2C_LIB sharedInstance] initSession:^(NSData *aData) {
       NSLog(@"Connection done");
    } onFailure:^(NSError *error) {
       NSLog(@"Failure at init Session");
    }];

    NSLog(@"Waiting for connection...");

    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent() + 5;
    CFAbsoluteTime after = CFAbsoluteTimeGetCurrent();

    while ([[ NTAG_I2C_LIB sharedInstance] isConnect] == 0){
       
       if(before == after){
           break;
       }
       after = CFAbsoluteTimeGetCurrent();
    }

    if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 3){
       NSLog(@"Connected!!!");
       
       [[FlashUseCase sharedInstance] Flash:^(int step, NSString *dataStr) {
           
           // CASE 1: Update FLashDialogMax
           
           if(step == 1){
               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                   [[NTAG_I2C_LIB sharedInstance] setAlertMessage:dataStr];
               }];
           }
           
           if(step == 2){
               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                   [[NTAG_I2C_LIB sharedInstance] setAlertMessage:dataStr];
               }];
           }
           
           if (step == 3 ){
               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                   [[NTAG_I2C_LIB sharedInstance] closeWithCustomMessage:dataStr];
               }];
           }
           
       } onFailure:^(NSString *status) {
           [[ NTAG_I2C_LIB sharedInstance] closeWithCustomMessage:status];
       } bytesToFlash:fileData];
       
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 4){
       NSLog(@"Not connected!!!");
    }else if([[ NTAG_I2C_LIB sharedInstance]isConnect] == 1){
       NSLog(@"Not connected!!!");
    }
}

- (void)showAlertMessage{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"This functionality is only available in Debug Mode with Xcode" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

