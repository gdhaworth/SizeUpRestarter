//
//  SURAppDelegate.m
//  SizeUpRestarter
//
//  Created by Graham Haworth on 9/5/13.
//  Copyright (c) 2013 Graham Haworth. All rights reserved.
//

#import "SURAppDelegate.h"


@interface SURAppDelegate () {
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
}
@end


@implementation SURAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	statusItem.menu = statusMenu;
	statusItem.title = @"SUR";
	statusItem.highlightMode = YES;
	
	CGDisplayRegisterReconfigurationCallback(SURDisplayReconfigurationCallback, NULL);
}

static BOOL scheduled = NO;

void SURDisplayReconfigurationCallback(CGDirectDisplayID display, CGDisplayChangeSummaryFlags flags, void *userInfo) {
//	NSMutableDictionary *flagsDict = [NSMutableDictionary dictionary];
//	CGDisplayChangeSummaryFlags flag;
//#define FLAG(KEY) \
//		flag = flags & KEY; \
//		if(flag) \
//			[flagsDict setObject:[NSNumber numberWithInt:flag] forKey:[NSString stringWithCString: #KEY encoding:NSASCIIStringEncoding]];
//	
//	FLAG(kCGDisplayBeginConfigurationFlag)
//	FLAG(kCGDisplayMovedFlag)
//	FLAG(kCGDisplaySetMainFlag)
//	FLAG(kCGDisplaySetModeFlag)
//	FLAG(kCGDisplayAddFlag)
//	FLAG(kCGDisplayRemoveFlag)
//	FLAG(kCGDisplayEnabledFlag)
//	FLAG(kCGDisplayDisabledFlag)
//	FLAG(kCGDisplayMirrorFlag)
//	FLAG(kCGDisplayUnMirrorFlag)
//	FLAG(kCGDisplayDesktopShapeChangedFlag)
//#undef FLAG
//	NSLog(@"display changed: %d  flags: %@", display, flagsDict);
	
	if(!scheduled && (flags & kCGDisplayDesktopShapeChangedFlag)) {
		[[NSApp delegate] performSelector:@selector(restartSizeUp) withObject:nil afterDelay:3.0];
		scheduled = YES;
	}
}

#define kSizeUpBundleID @"com.irradiatedsoftware.SizeUp"

- (void) restartSizeUp {
	for(NSRunningApplication *app in [NSRunningApplication runningApplicationsWithBundleIdentifier:kSizeUpBundleID]) {
		NSLog(@"killing sizeup: %@", app);
		BOOL terminated = [app terminate];
		if(!terminated) {
			NSLog(@"failed to terminate %@", app);
			return;
		}
	}
	
	NSLog(@"launching sizeup");
	[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:kSizeUpBundleID
														 options:NSWorkspaceLaunchDefault
								  additionalEventParamDescriptor:[NSAppleEventDescriptor nullDescriptor]
												launchIdentifier:NULL];
	
	scheduled = NO;
}

@end
