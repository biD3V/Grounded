#import "Localize.h"

NSString *localize(NSString *key) {
    NSBundle *GroundedPrefsBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/GroundedPrefs.bundle"];

	if ([key isEqualToString:@"MediaControlsAudioModule"]) key = @"AudioModule"; //Fix Volume name on 13 and above
	
	NSString* localizedString = [GroundedPrefsBundle localizedStringForKey:key value:@"" table:nil];

	if ([localizedString isEqualToString:@""])
	{
		return english(key);
	}

	return localizedString;
}

NSString *english(NSString *key) {
    NSBundle *GroundedPrefsBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/GroundedPrefs.bundle"];

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