#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray *running = [NSRunningApplication runningApplicationsWithBundleIdentifier:
            [[NSBundle mainBundle] bundleIdentifier]];
        if (running.count > 1) {
            [[NSDistributedNotificationCenter defaultCenter]
                postNotificationName:@"com.airpods-fixer.showIcon"
                object:nil];
            return 0;
        }
    }
    return NSApplicationMain(argc, argv);
}
