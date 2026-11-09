#import "AppDelegate.h"
#import <CoreAudio/CoreAudio.h>

@interface AppDelegate (Testing)
- (void)listDevices;
@end
extern OSStatus callbackFunction(AudioObjectID, UInt32, const AudioObjectPropertyAddress[], void *);

@interface CallbackProbe : AppDelegate
@property NSInteger refreshCount;
@end
@implementation CallbackProbe
- (void)listDevices {
    NSCAssert([NSThread isMainThread], @"Callback touched UI off-main");
    self.refreshCount++;
}
@end

int main(void) {
    @autoreleasepool {
        [NSApplication sharedApplication];
        CallbackProbe *probe = [CallbackProbe new];
        callbackFunction(0, 0, NULL, (__bridge void *)probe);
        NSCAssert(probe.refreshCount == 0, @"Callback re-entered menu construction synchronously");
        dispatch_apply(100, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^(size_t index) {
            callbackFunction(0, 0, NULL, (__bridge void *)probe);
        });
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:5];
        while (probe.refreshCount < 101 && deadline.timeIntervalSinceNow > 0) {
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        }
        NSCAssert(probe.refreshCount == 101, @"Lost audio callbacks");

        AppDelegate *delegate = [AppDelegate new];
        // Inspect real menus without changing the user's microphone or preferences.
        [delegate setValue:@YES forKey:@"paused"];
        [delegate setValue:@(UINT32_MAX) forKey:@"forcedInputID"];
        [delegate setValue:[NSMutableDictionary dictionary] forKey:@"itemsToIDS"];
        for (int i = 0; i < 25; i++) {
            [delegate listDevices];
            NSMenu *menu = [delegate valueForKey:@"menu"];
            for (NSString *title in @[@"Pause", @"Locked microphone:", @"Mute microphone", @"Open at login", @"Check for updates", @"Hide", @"Quit"]) {
                NSUInteger count = 0;
                for (NSMenuItem *item in menu.itemArray) {
                    if ([item.title isEqualToString:title]) count++;
                }
                NSCAssert(count == 1, @"Duplicate/missing menu item: %@", title);
            }
            NSUInteger volumeCount = 0;
            for (NSMenuItem *item in menu.itemArray) {
                if ([item.title hasPrefix:@"Input volume:"]) volumeCount++;
            }
            NSCAssert(volumeCount == 1, @"Duplicate/missing volume controls");
        }
        NSLog(@"PASS: 101 serialized callbacks and 25 complete menus");
    }
    return 0;
}
