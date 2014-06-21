#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@class ADBannerView;

@interface ViewController : UIViewController

@property (nonatomic, assign) BOOL isAdBannerCurrentlyVisible;
@property (weak, nonatomic) IBOutlet ADBannerView *adBanner;
@property (weak, nonatomic) IBOutlet UIView *underAd;

@end