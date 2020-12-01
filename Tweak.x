@interface CCUIRoundButton : UIControl
@end

@interface SBLockStateAggregator : NSObject {
	NSInteger _lockState;
}
+(id)sharedInstance;
-(NSInteger)lockState;
@end

@interface UIView (Grounded)

@property (assign,setter=_setViewDelegate:,getter=_viewDelegate,nonatomic) UIViewController * viewDelegate;

@end

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
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.bid3v.groundedprefs.plist"];

	enabled = boolPref(prefs, @"enabled");
	airplane = boolPref(prefs, @"airplane");
	cellular = boolPref(prefs, @"cellular");
	wifi = boolPref(prefs, @"wifi"),
	bluetooth = boolPref(prefs, @"wifi");
	airdrop = boolPref(prefs, @"airdrop");
	hotspot = boolPref(prefs, @"hotspot");
}

%hook CCUIRoundButton

- (BOOL)isEnabled {
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

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.bid3v.groundedprefs.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
