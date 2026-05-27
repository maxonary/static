#import "AppDelegate.h"
#import <CoreAudio/CoreAudio.h>
#import <ServiceManagement/ServiceManagement.h>


@interface AppDelegate ( )
{
    BOOL paused;
    NSMenu* menu;
    NSStatusItem* statusItem;
    AudioDeviceID forcedInputID;
    NSUserDefaults* defaults;
    NSMutableDictionary* itemsToIDS;
    NSMenuItem *startupItem;
}

@property (weak) IBOutlet NSWindow *window;

@end


@implementation AppDelegate


OSStatus callbackFunction(  AudioObjectID inObjectID,
                            UInt32 inNumberAddresses,
                            const AudioObjectPropertyAddress inAddresses[],
                            void *inClientData)
{

    printf( "default input device changed" );
    // check default input
    [ ( (__bridge  AppDelegate* ) inClientData ) listDevices ];

    return 0;
}


- ( void ) applicationDidFinishLaunching : ( NSNotification* ) aNotification
{

    defaults = [ NSUserDefaults standardUserDefaults ];
    
    itemsToIDS = [ NSMutableDictionary dictionary ];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger readenId = [prefs integerForKey: @"Device"];
    
    if (readenId == 0) {
        readenId = UINT32_MAX;
        [prefs setInteger:readenId forKey: @"Device"];
    }
    
    forcedInputID = (UInt32)readenId; // Explicit cast to UInt32
    
    NSLog(@"Loaded device from UserDefaults: %d", forcedInputID);

    // Menu bar icon: studio-microphone SF Symbol (matches the 🎙️ app icon),
    // rendered as a template image so it tints in light and dark menu bars.
    // A color emoji can't be a template image, so the menu bar uses the
    // closest monochrome symbol instead.
    NSImage* image = [ NSImage imageWithSystemSymbolName : @"mic.fill"
                                accessibilityDescription : @"Static" ];
    [ image setTemplate : YES ];

    statusItem = [ [ NSStatusBar systemStatusBar ] statusItemWithLength : NSVariableStatusItemLength ];
    statusItem.button.toolTip = @"Static — locks your microphone input"; // NEW: Use button.toolTip
    statusItem.button.image = image; // NEW: Use button.image

    // Restore status icon visibility
    BOOL shouldHideIcon = [defaults boolForKey:@"StatusIconHidden"];
    [statusItem setVisible:!shouldHideIcon];

    // Listen for show-icon requests from second-launch instances
    [[NSDistributedNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(showStatusIcon:)
        name:@"com.maxonary.static.showIcon"
        object:nil];

    // add listener for detecting when input device is changed

    AudioObjectPropertyAddress inputDeviceAddress = {
        kAudioHardwarePropertyDefaultInputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };

    AudioObjectAddPropertyListener(
        kAudioObjectSystemObject,
        &inputDeviceAddress,
        &callbackFunction,
        (__bridge  void* ) self );

   AudioObjectPropertyAddress runLoopAddress = {
        kAudioHardwarePropertyRunLoop,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };

    CFRunLoopRef runLoop = NULL;
    
    UInt32 size = sizeof(CFRunLoopRef);
    
    AudioObjectSetPropertyData(
        kAudioObjectSystemObject,
        &runLoopAddress,
        0,
        NULL,
        size,
        &runLoop);
    
    [[NSDistributedNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(showStatusIcon:)
        name:@"com.maxonary.static.showIcon"
        object:nil];

     [ self listDevices ];
    
}


- ( void ) deviceSelected : ( NSMenuItem* ) item
{

    NSNumber* number = itemsToIDS[ item.title ];
    
    if ( number != nil )
    {
    
        AudioDeviceID newId = [ number unsignedIntValue ];
        
        NSLog( @"switching to new device : %u" , newId );
        
        forcedInputID = newId;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:newId forKey: @"Device"];
        NSLog(@"Saved device from UserDefaults: %d", forcedInputID);

        // NEW: Use AudioObjectSetPropertyData instead of AudioHardwareSetProperty
        AudioObjectPropertyAddress defaultInputAddress = {
            kAudioHardwarePropertyDefaultInputDevice,
            kAudioObjectPropertyScopeGlobal,
            kAudioObjectPropertyElementMain
        };
        
        UInt32 dataSize = sizeof(UInt32);
        AudioObjectSetPropertyData(
            kAudioObjectSystemObject,
            &defaultInputAddress,
            0,
            NULL,
            dataSize,
            &forcedInputID
        );
        
        // show forcing

        [ menu
            insertItemWithTitle : @"locking..."
            action : NULL
            keyEquivalent : @""
            atIndex : 2 ];

    }
    
}


- ( void ) listDevices
{

    NSDictionary *bundleInfo = [ [ NSBundle mainBundle] infoDictionary];
    NSString *versionString = [ NSString stringWithFormat : @"Version %@ (build %@)",
                               bundleInfo[ @"CFBundleShortVersionString" ],
                               bundleInfo[ @"CFBundleVersion"] ];

    menu = [ [ NSMenu alloc ] init ];
    menu.delegate = self;
    [ menu addItemWithTitle : versionString action : nil keyEquivalent : @"" ];
    [ menu addItem : [ NSMenuItem separatorItem ] ]; // A thin grey line
    
    NSMenuItem* item =  [ menu
            addItemWithTitle : NSLocalizedString(@"Pause", @"Pause")
            action : @selector(manualPause:)
            keyEquivalent : @"" ];

    if ( paused ) [ item setState : NSControlStateValueOn ];

    [ menu addItem : [ NSMenuItem separatorItem ] ]; // A thin grey line
    [ menu addItemWithTitle : @"Locked microphone:" action : nil keyEquivalent : @"" ];
    
    UInt32 propertySize;
    
    AudioDeviceID dev_array[64];
    int numberOfDevices = 0;
    char deviceName[256];
    
    // NEW: Get the size of the array of audio devices using AudioObjectGetPropertyDataSize
    AudioObjectPropertyAddress devicesAddressSize = {
        kAudioHardwarePropertyDevices,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };
    AudioObjectGetPropertyDataSize(
        kAudioObjectSystemObject,
        &devicesAddressSize,
        0,
        NULL,
        &propertySize
    );
    
    // NEW: Get the array of audio devices using AudioObjectGetPropertyData
    AudioObjectPropertyAddress devicesAddressData = {
        kAudioHardwarePropertyDevices,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };
    AudioObjectGetPropertyData(
        kAudioObjectSystemObject,
        &devicesAddressData,
        0,
        NULL,
        &propertySize,
        dev_array
    );
    
    numberOfDevices = ( propertySize / sizeof( AudioDeviceID ) );
    
    NSLog( @"devices found : %i" , numberOfDevices );
    
    if ( forcedInputID < UINT32_MAX )
    {
    
        char found = 0;

        for( int index = 0 ;
                 index < numberOfDevices ;
                 index++ )
        {
        
            if ( dev_array[ index] == forcedInputID ) found = 1;
        
        }
        
        if ( found == 0 )
        {
            NSLog( @"force input not found in device list" );
            forcedInputID = UINT32_MAX;
        }
        else NSLog( @"force input found in device list" );
        
    }


    for( int index = 0 ;
             index < numberOfDevices ;
             index++ )
    {
    
        AudioDeviceID oneDeviceID = dev_array[ index ];

        propertySize = 256;
        
        // NEW: Use AudioObjectGetPropertyDataSize instead of AudioDeviceGetPropertyInfo
        AudioObjectPropertyAddress streamsAddress = {
            kAudioDevicePropertyStreams,
            kAudioObjectPropertyScopeInput,
            kAudioObjectPropertyElementMain
        };
        AudioObjectGetPropertyDataSize(
            oneDeviceID,
            &streamsAddress,
            0,
            NULL,
            &propertySize
        );

        // if there are any input streams, then it is an input

        if ( propertySize > 0 )
        {
        
            // get name

            propertySize = 256;
            
            // NEW: Use AudioObjectGetPropertyData instead of AudioDeviceGetProperty
            AudioObjectPropertyAddress nameAddress = {
                kAudioDevicePropertyDeviceName,
                kAudioObjectPropertyScopeGlobal,
                kAudioObjectPropertyElementMain
            };
            AudioObjectGetPropertyData(
                oneDeviceID,
                &nameAddress,
                0,
                NULL,
                &propertySize,
                deviceName
            );

            NSLog( @"found input device : %s  %u\n" , deviceName , (unsigned int)oneDeviceID );
            
            NSString* nameStr = [ NSString stringWithUTF8String : deviceName ];

            // Determine built-in by transport type instead of localized name
            UInt32 transportType = 0;
            UInt32 transportSize = sizeof(transportType);
            AudioObjectPropertyAddress transportAddress = {
                kAudioDevicePropertyTransportType,
                kAudioObjectPropertyScopeGlobal,
                kAudioObjectPropertyElementMain
            };
            if (AudioObjectGetPropertyData(oneDeviceID,
                                           &transportAddress,
                                           0,
                                           NULL,
                                           &transportSize,
                                           &transportType) == noErr) {
                if (transportType == kAudioDeviceTransportTypeBuiltIn && forcedInputID == UINT32_MAX) {
                    // if there is no forced device yet, select built-in by default
                    NSLog(@"setting forced device (built-in by transport): %s  %u\n", deviceName, (unsigned int)oneDeviceID);
                    forcedInputID = oneDeviceID;
                }
            }

            NSMenuItem* item = [ menu
                addItemWithTitle : [ NSString stringWithUTF8String : deviceName ]
                action : @selector(deviceSelected:)
                keyEquivalent : @"" ];
            
            if ( oneDeviceID == forcedInputID )
            {
                [ item setState : NSControlStateValueOn ];
                NSLog( @"setting device selected : %s  %u\n" , deviceName , (unsigned int)oneDeviceID );
            }
            
            itemsToIDS[ nameStr ] = [ NSNumber numberWithUnsignedInt : oneDeviceID];

        }

        [ statusItem setMenu : menu ];

    }

    // get current input device
    
    AudioDeviceID deviceID = kAudioDeviceUnknown;

    // get the default output device
    // if it is not the built in, change
    
    // NEW: Use AudioObjectGetPropertyData instead of AudioHardwareGetProperty
    AudioObjectPropertyAddress defaultInputAddress = {
        kAudioHardwarePropertyDefaultInputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };
    
    UInt32 dataSize = sizeof(deviceID);
    AudioObjectGetPropertyData(
        kAudioObjectSystemObject,
        &defaultInputAddress,
        0,
        NULL,
        &dataSize,
        &deviceID
    );

    NSLog(@"default input device is %u", deviceID);

    if ( !paused && forcedInputID != UINT32_MAX && deviceID != forcedInputID )
    {

        NSLog( @"forcing input device for default : %u" , forcedInputID );

        UInt32 propertySize = sizeof(UInt32);
        AudioObjectSetPropertyData(
            kAudioObjectSystemObject,
            &defaultInputAddress,
            0,
            NULL,
            propertySize,
            &forcedInputID
        );
        
        // show forcing

        [ menu
            insertItemWithTitle : @"locking..."
            action : NULL
            keyEquivalent : @""
            atIndex : 2 ];

    }
    
    [ menu addItem : [ NSMenuItem separatorItem ] ]; // A thin grey line

    startupItem = [ menu
        addItemWithTitle : @"Open at login"
        action : @selector(toggleStartupItem)
        keyEquivalent : @"" ];
    
    [ menu addItem : [ NSMenuItem separatorItem ] ]; // A thin grey line

    [ menu addItem : [ NSMenuItem separatorItem ] ]; // A thin grey line

    [ menu addItemWithTitle : @"Check for updates"
           action : @selector(update)
           keyEquivalent : @"" ];
    
    [ menu addItemWithTitle : @"Hide"
           action : @selector(hide)
           keyEquivalent : @"" ];
    
    [ menu addItemWithTitle : @"Quit"
           action : @selector(terminate)
           keyEquivalent : @"" ];

}

- ( void ) manualPause : ( NSMenuItem* ) item
{
    paused = !paused;
    [ self listDevices ];
}

- ( void ) terminate
{
    [ NSApp terminate : nil ];
}

- ( void ) update
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://github.com/maxonary/Static/releases"]];
}

- ( void ) hide
{
    [statusItem setVisible:false];
    [defaults setBool:YES forKey:@"StatusIconHidden"];
}

- (void)toggleStartupItem
{
    SMAppService *loginItemService = [SMAppService mainAppService];
    if (loginItemService.status == SMAppServiceStatusEnabled) {
        NSError *error = nil;
        if (![loginItemService unregisterAndReturnError:&error]) {
            NSLog(@"Failed to unregister login item: %@", error);
        }
    } else {
        NSError *error = nil;
        if (![loginItemService registerAndReturnError:&error]) {
            NSLog(@"Failed to register login item: %@", error);
        }
    }
    [self updateStartupItemState];
}

- (void)updateStartupItemState
{
    SMAppService *loginItemService = [SMAppService mainAppService];
    [startupItem setState: (loginItemService.status == SMAppServiceStatusEnabled) ? NSControlStateValueOn : NSControlStateValueOff];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self updateStartupItemState];
}

- (void)showStatusIcon:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->statusItem setVisible:YES];
        [self->defaults setBool:NO forKey:@"StatusIconHidden"];
    });
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [statusItem setVisible:YES];
    [defaults setBool:NO forKey:@"StatusIconHidden"];
    return YES;
}

@end

