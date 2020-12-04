#include "GRDModulesListController.h"
#include "Localize.h"

@implementation GRDModulesListController

- (NSArray *)specifiers {
	if (!_specifiers) {
        _specifiers = [NSMutableArray new];
        
        // Get module identifiers in order
        NSArray *moduleConfiguration = [[CCSModuleSettingsProvider sharedProvider] orderedFixedModuleIdentifiers] ? [[[CCSModuleSettingsProvider sharedProvider] orderedFixedModuleIdentifiers] arrayByAddingObjectsFromArray:[[CCSModuleSettingsProvider sharedProvider] orderedUserEnabledModuleIdentifiers]] : [[CCSModuleSettingsProvider sharedProvider] orderedUserEnabledModuleIdentifiers];
        
        // Get the module repository
        // Gives us useful info about modules
        CCSModuleRepository *moduleRepo = [CCSModuleRepository repositoryWithDefaults];
        // Go through all modules in Control Center
        for (NSString *moduleIdentifier in moduleConfiguration) {
            // Get the bundle for module
            NSBundle *moduleBundle = [NSBundle bundleWithURL:[[moduleRepo moduleMetadataForModuleIdentifier:moduleIdentifier] moduleBundleURL]];
            // For some reason ReplayKitModule(Screen Recording) is improperly named
            BOOL screenrecord = [[moduleBundle infoDictionary][@"CFBundleDisplayName"] isEqualToString:@"CFBundleDisplayName"];
            // Create specifier for module and get localized name
            PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:([moduleBundle infoDictionary][@"CFBundleDisplayName"] && !screenrecord) ? [moduleBundle infoDictionary][@"CFBundleDisplayName"] : localize([moduleBundle infoDictionary][@"CFBundleName"])
                target:self
                set:@selector(setPreferenceValue:specifier:)
                get:@selector(readPreferenceValue:)
                detail:nil
                cell:PSSwitchCell
                edit:nil];
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

@end