//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEBUG_MODE true
#define TBD        FALSE

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]


@interface AppDelegate : UIResponder <UIApplicationDelegate>{}

@property (strong, nonatomic) UIWindow *window;

- (void) showDebugLogs:(NSString*) text;
    
@end

