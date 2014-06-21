@import GameKit;
#import "AppDelegate.h"
#import "Appirater.h"
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Appirater setAppId:@"884935957"];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:15];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setOpenInAppStore:YES];
    [Appirater setDebug:NO];

    [Appirater appLaunched:YES];

    [self authenticateLocalPlayer];

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];

    [self authenticateLocalPlayer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self authenticateLocalPlayer];
}

- (void)authenticateLocalPlayer
{
    [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewController, NSError *error) {

        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"scoreLeaderboard"];
        [score setValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"]];

        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            NSLog(@"Reporting Error: %@",error);
        }];

    }];
}
@end