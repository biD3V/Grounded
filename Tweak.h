@interface CCUIRoundButton : UIControl
@end

@interface CCUIButtonModuleView : UIControl
@end

@interface CCUIButtonModuleViewController : UIViewController

@property (nonatomic,readonly) CCUIButtonModuleView *buttonView;

@end

@interface CCUIContentModuleContext : NSObject

@property (nonatomic,copy,readonly) NSString *moduleIdentifier;

@end

@interface CCUIToggleModule : NSObject

@property (nonatomic,retain) CCUIContentModuleContext *contentModuleContext;

@end

@interface CCUIToggleViewController : CCUIButtonModuleViewController

@property (assign,nonatomic) CCUIToggleModule *module;

@end

@interface CCUIMenuModuleViewController : CCUIButtonModuleViewController

@property (nonatomic,retain) CCUIContentModuleContext *contentModuleContext;

@end

@interface CCUIBaseSliderView : UIControl
@end

@interface CCUIContinuousSliderView : CCUIBaseSliderView
@end

@interface CCUIDisplayModuleViewController : UIViewController

@property (nonatomic,retain) CCUIContinuousSliderView *sliderView;

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