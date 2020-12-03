#include "GRDModulesListController.h"

// Taken from CCSupport https://github.com/opa334/CCSupport/blob/939095586188a17c53ee74cad812979e3f3e1037/Tweak.xm#L12-L44
NSDictionary* englishLocalizations;
//Get localized string for given key
NSString *localize(NSString *key) {
    NSBundle *GroundedPrefsBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/GroundedPrefs.bundle"];

	if ([key isEqualToString:@"MediaControlsAudioModule"]) key = @"AudioModule"; //Fix Volume name on 13 and above
	
	NSString* localizedString = [GroundedPrefsBundle localizedStringForKey:key value:@"" table:nil];

	if ([localizedString isEqualToString:@""])
	{
		if (!englishLocalizations) englishLocalizations = [NSDictionary dictionaryWithContentsOfFile:[GroundedPrefsBundle pathForResource:@"Localizable" ofType:@"strings" inDirectory:@"en.lproj"]];

		//If no localization was found, fallback to english
		NSString* engString = [englishLocalizations objectForKey:key];

		if(engString) {
			return engString;
		} else {
			//If an english localization was not found, just return the key itself
			return key;
		}
	}

	return localizedString;
}

@implementation GRDModulesListController

- (NSArray *)specifiers {
	if (!_specifiers) {
        _specifiers = [NSMutableArray new];
        NSString *defaultPath = @"/var/mobile/Library/ControlCenter/ModuleConfiguration.plist";
        NSString *ccSupportPath = @"/var/mobile/Library/ControlCenter/ModuleConfiguration_CCSupport.plist";
        //NSBundle *GroundedPrefsBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/GroundedPrefs.bundle"];
        NSDictionary *moduleConfiguration;
        if ([[NSFileManager defaultManager] fileExistsAtPath:ccSupportPath]) {
            moduleConfiguration = [NSDictionary dictionaryWithContentsOfFile:ccSupportPath];
        } else {
            moduleConfiguration = [NSDictionary dictionaryWithContentsOfFile:defaultPath];
        }
        NSMutableArray <NSBundle *>*bundles = [NSMutableArray new];
        [bundles addObjectsFromArray:[self CCBundles]];
        //freopen([@"/var/mobile/Documents/Bundles.txt" cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
        for (NSString *moduleIdentifier in moduleConfiguration[@"module-identifiers"]) {
            NSBundle *moduleBundle = [NSBundle new];
            for (NSBundle *bundle in bundles) {
                if ([[bundle bundleIdentifier] isEqualToString:moduleIdentifier]) {
                    // [specifier setProperty:[bundle infoDictionary][@"CFBundleDisplayName"] ?: moduleIdentifier forKey:@"name"];
                    //[bundles removeObject:bundle];
                    moduleBundle = bundle;
                }
            }
            //NSLog(@"GRD moduleBundle: %@", [moduleBundle infoDictionary][@"CFBundleName"]);
            BOOL screenrecord = [[moduleBundle infoDictionary][@"CFBundleDisplayName"] isEqualToString:@"CFBundleDisplayName"]; // For some reason ReplayKitModule(Screen Recording is improperly named)
            PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:([moduleBundle infoDictionary][@"CFBundleDisplayName"] && !screenrecord) ? [moduleBundle infoDictionary][@"CFBundleDisplayName"] : localize([moduleBundle infoDictionary][@"CFBundleName"])
                target:self
                set:@selector(setPreferenceValue:specifier:)
                get:@selector(readPreferenceValue:)
                detail:nil
                cell:PSSwitchCell
                edit:nil];
            //[specifier removePropertyForKey:@"cell"];
            //[specifier setProperty:@"GRDSwitchTableCell" forKey:@"cellClass"];
            // [specifier setProperty:@YES forKey:@"hasIcon"];
            // [specifier setProperty:[GroundedPrefsBundle pathForResource:moduleIdentifier ofType:@"png"] forKey:@"icon"];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:moduleIdentifier forKey:@"key"];
            [specifier setProperty:@YES forKey:@"default"];
            [specifier setProperty:@"com.bid3v.groundedprefs" forKey:@"defaults"];
            [specifier setProperty:@"com.bid3v.groundedprefs.changed" forKey:@"PostNotification"];
            [_specifiers addObject:specifier];
        }
		//_specifiers = [self loadSpecifiersFromPlistName:@"Modules" target:self];
	}

	return _specifiers;
}

// - (void)viewWillAppear:(BOOL)appear {
//     [super viewWillAppear:appear];

//     [self CCBundles];
// }

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (NSArray <NSBundle *>*)CCBundles {
    NSArray *bundleDirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/System/Library/ControlCenter/Bundles" error:nil];
    NSMutableArray *bundleArray = [NSMutableArray new];
    
    for (NSString *bundlePath in bundleDirs) {
        NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"/System/Library/ControlCenter/Bundles/%@", bundlePath]];
        [bundleArray addObject:bundle];
        // NSLog(@"GRD Bundle: %@, %@", [bundle bundleIdentifier], bundle);
    }
    
    return bundleArray;
}

@end