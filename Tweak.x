#import "Tweak.h"

NSDictionary *prefs;
BOOL enabled;
BOOL airplane;
BOOL cellular;
BOOL wifi;
BOOL bluetooth;
BOOL airdrop;
BOOL hotspot;

static BOOL boolPref(NSDictionary *prefs, NSString *key) {
	return [prefs objectForKey:key] ? [[prefs objectForKey:key] boolValue] : YES;
}

static void loadPrefs() {
	enabled = boolPref(prefs, @"enabled");
	airplane = boolPref(prefs, @"airplane");
	cellular = boolPref(prefs, @"cellular");
	wifi = boolPref(prefs, @"wifi"),
	bluetooth = boolPref(prefs, @"wifi");
	airdrop = boolPref(prefs, @"airdrop");
	hotspot = boolPref(prefs, @"hotspot");
}

// Modules like the Connectivity Module
%hook CCUIRoundButton

- (BOOL)isEnabled {
	// Create locked bool
	// 0 and 1 are both unlocked states
	BOOL locked = [[%c(SBLockStateAggregator) sharedInstance] lockState] != 0 && [[%c(SBLockStateAggregator) sharedInstance] lockState] != 1;
	if (locked && enabled) {
		if ([[self.superview _viewDelegate] isKindOfClass:objc_getClass("CCUIConnectivityAirplaneViewController")] && !airplane) {
			return false;
		} else if ([[self.superview _viewDelegate] isKindOfClass:objc_getClass("CCUIConnectivityCellularDataViewController")] && !cellular) {
			return false;
		} else if ([[self.superview _viewDelegate] isKindOfClass:objc_getClass("CCUIConnectivityWifiViewController")] && !wifi) {
			return false;
		} else if ([[self.superview _viewDelegate] isKindOfClass:objc_getClass("CCUIConnectivityBluetoothViewController")] && !bluetooth) {
			return false;
		} else if ([[self.superview _viewDelegate] isKindOfClass:objc_getClass("CCUIConnectivityAirDropViewController")] && !airdrop) {
			return false;
		} else if ([[self.superview _viewDelegate] isKindOfClass:objc_getClass("CCUIConnectivityHotspotViewController")] && !hotspot) {
			return false;
		}
	}
	return %orig;
}

%end

// Normal modules
%hook CCUIToggleViewController

- (void)viewWillAppear:(BOOL)appear {
	%orig(appear);

	//NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.bid3v.groundedprefs.plist"];
	BOOL locked = [[%c(SBLockStateAggregator) sharedInstance] lockState] != 0 && [[%c(SBLockStateAggregator) sharedInstance] lockState] != 1;

	if (locked && enabled && !boolPref(prefs, self.module.contentModuleContext.moduleIdentifier)) {
		[self.buttonView setEnabled:false];
		[self.buttonView setAlpha:0.5]; // Make disabled modules look disabled
	} else {
		[self.buttonView setEnabled:true];
		[self.buttonView setAlpha:1.0];
	}
}

%end

// Modules like the Screen Mirroring module
%hook CCUIMenuModuleViewController

- (void)viewWillAppear:(BOOL)appear {
	%orig(appear);

	//NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.bid3v.groundedprefs.plist"];
	BOOL locked = [[%c(SBLockStateAggregator) sharedInstance] lockState] != 0 && [[%c(SBLockStateAggregator) sharedInstance] lockState] != 1;

	if (locked && enabled && !boolPref(prefs, self.contentModuleContext.moduleIdentifier)) {
		[self.buttonView setEnabled:false];
		[self.buttonView setAlpha:0.5];
	} else {
		[self.buttonView setEnabled:true];
		[self.buttonView setAlpha:1.0];
	}
}

%end

// Slider Modules (Brightness & Volume)
%hook CCUIContinuousSliderView

- (BOOL)isEnabled {
	BOOL locked = [[%c(SBLockStateAggregator) sharedInstance] lockState] != 0 && [[%c(SBLockStateAggregator) sharedInstance] lockState] != 1;
	if (locked && enabled) {
		if (!boolPref(prefs, @"com.apple.control-center.DisplayModule") && [[self.allTargets allObjects][0] isKindOfClass:NSClassFromString(@"CCUIDisplayModuleViewController")]) {
			return false;
		} else if (!boolPref(prefs, @"com.apple.mediaremote.controlcenter.audio") && [[self.allTargets allObjects][0] isKindOfClass:NSClassFromString(@"MediaControlsVolumeViewController")]) {
			return false;
		}
	}

	return %orig;
}

%end

%ctor {
	prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.bid3v.groundedprefs.plist"];
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.bid3v.groundedprefs.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
