//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} forState:UIControlStateNormal];
    [NSThread sleepForTimeInterval:2.0];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

/*----------------------------------*/
/*           Debug Logs             */
/*----------------------------------*/
- (void) showDebugLogs:(NSString*) text {
    if(DEBUG_MODE){
        NSLog(@"%@", text);
    }
}

@end
