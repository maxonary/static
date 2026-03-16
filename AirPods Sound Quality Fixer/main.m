#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    // If the app is already running, tell it to show its menu bar icon and exit.
    // This is needed because LSUIElement apps have no Dock icon, so
    // applicationShouldHandleReopen: is unreliable for restoring the icon.
    @autoreleasepool {
        NSArray *running = [NSRunningApplication runningApplicationsWithBundleIdentifier:
            [[NSBundle mainBundle] bundleIdentifier]];
        if (running.count > 1) {
            [[NSDistributedNotificationCenter defaultCenter]
                postNotificationName:@"com.airpods-fixer.showIcon"
                object:nil
                userInfo:nil
                deliverImmediately:YES];
            return 0;
        }
    }
    return NSApplicationMain(argc, argv);
}
