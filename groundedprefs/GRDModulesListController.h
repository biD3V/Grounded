#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSSwitchTableCell.h>

@interface GRDModulesListController : PSListController

@end

@interface CCSModuleSettingsProvider : NSObject

@property (nonatomic,copy,readonly) NSArray *orderedFixedModuleIdentifiers; 
@property (nonatomic,copy,readonly) NSArray *orderedUserEnabledModuleIdentifiers; 
@property (nonatomic,copy,readonly) NSArray *userDisabledModuleIdentifiers;

+ (id)sharedProvider;

@end

@interface CCSModuleMetadata : NSObject

@property (nonatomic,copy,readonly) NSURL *moduleBundleURL;

@end

@interface CCSModuleRepository : NSObject {
    NSDictionary* _allModuleMetadataByIdentifier;
}

+ (CCSModuleRepository *)repositoryWithDefaults;
- (CCSModuleMetadata *)moduleMetadataForModuleIdentifier:(NSString *)identifier;

@end