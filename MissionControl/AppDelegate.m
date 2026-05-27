#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Clear cached HTTP data (including HSTS) that may block HTTP connections
    NSSet *dataTypes = [NSSet setWithArray:@[
        WKWebsiteDataTypeDiskCache,
        WKWebsiteDataTypeMemoryCache,
    ]];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:dataTypes modifiedSince:dateFrom completionHandler:^{
        // Cleared
    }];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[ViewController alloc] init];
    self.window.backgroundColor = [UIColor colorWithRed:0.059f green:0.09f blue:0.165f alpha:1.0f];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
