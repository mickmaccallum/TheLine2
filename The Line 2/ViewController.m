#import "ViewController.h"
#import "MyScene.h"
@import iAd;

@interface ViewController () < ADBannerViewDelegate >

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    SKColor *color = [SKColor colorWithRed:76.0 / 255.0
                                     green:217.0 / 255.0
                                      blue:100.0 / 255.0
                                     alpha:1.0];
    [self.underAd setBackgroundColor:color];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    SKView *skView = (SKView *)self.view;

    if (!skView.scene) {

        SKScene *scene = [MyScene sceneWithSize:skView.bounds.size];

        [scene setScaleMode:SKSceneScaleModeAspectFill];
        
        [skView presentScene:scene];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    SKView *skView = (SKView *)self.view;

    if ([skView respondsToSelector:@selector(setPaused:)]) {
        [skView setPaused:NO];
    }
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    SKView *skView = (SKView *)self.view;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([skView respondsToSelector:@selector(setPaused:)]) {
            [skView setPaused:NO];
        }
    });
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self.adBanner.layer setZPosition:10000.0];
    [UIView animateWithDuration:0.15 animations:^{
        [self.adBanner setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self setIsAdBannerCurrentlyVisible:YES];
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView animateWithDuration:0.15 animations:^{
        [self.adBanner setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self setIsAdBannerCurrentlyVisible:NO];
    }];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner
               willLeaveApplication:(BOOL)willLeave
{
    SKView *skView = (SKView *)self.view;

    if ([skView respondsToSelector:@selector(setPaused:)]) {
        [skView setPaused:YES];
    }

    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end