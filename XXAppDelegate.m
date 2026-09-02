#import "XXAppDelegate.h"
#import "XXRootViewController.h"
#import "HTTPServer.h"

@implementation XXAppDelegate {
    HTTPServer *_server;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [[NSFileManager defaultManager] createDirectoryAtPath:docsPath
          withIntermediateDirectories:YES attributes:nil error:nil];

    // Create default index.html if none exists
    NSString *indexPath = [docsPath stringByAppendingPathComponent:@"index.html"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:indexPath]) {
        NSString *defaultPage = @"<!DOCTYPE html>\n"
            @"<html>\n<head><meta charset='utf-8'>\n"
            @"<meta name='viewport' content='width=device-width, initial-scale=1'>\n"
            @"<title>Carbonara WebServer</title>\n"
            @"<style>\n"
            @"body { font-family: -apple-system; padding: 20px; background: #1a1a2e; color: #eee; }\n"
            @"h1 { color: #00d4ff; }\n"
            @"p { color: #aaa; }\n"
            @"</style></head>\n"
            @"<body>\n"
            @"<h1>Carbonara WebServer</h1>\n"
            @"<p>Place your HTML, CSS, and JS files in the Documents folder.</n"
            @"Access via iTunes/Finder -> File Sharing.</p>\n"
            @"<p>Server is running on port 8080.</p>\n"
            @"</body></html>\n";
        [defaultPage writeToFile:indexPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }

    _server = [[HTTPServer alloc] initWithPort:8080 documentRoot:docsPath];
    BOOL started = [_server start];

    XXRootViewController *vc = [[XXRootViewController alloc] initWithServerStarted:started port:8080];
    _window.rootViewController = vc;
    [_window makeKeyAndVisible];

    return YES;
}

@end
