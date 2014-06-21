//
//  GameOver.m
//  The Line 2
//
//  Created by Michael MacCallum on 6/2/14.
//  Copyright (c) 2014 MacCDevTeam LLC. All rights reserved.
//

#import "GameOver.h"
#import "MyScene.h"
#import "Appirater.h"
#import "DSMultilineLabelNode.h"

@import GameKit;

@interface GameOver () < GKGameCenterControllerDelegate >

@end

@implementation GameOver

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];

    if (self) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [self setScore:[defaults integerForKey:@"lastScore"]];

        [self setBackgroundColor:[self mainColor]];

        SKLabelNode *gameOver = [[SKLabelNode alloc] initWithFontNamed:@"ComicNeue-Regular"];
        [gameOver setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [gameOver setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [gameOver setText:@"Game Over!"];
        [gameOver setFontColor:[self tileColor]];
        [gameOver setFontSize:54.0];
        [gameOver setPosition:CGPointMake(size.width / 2.0, size.height - 50.0)];
        [self addChild:gameOver];


        NSArray *names = @[@"Play Again",@"Leaderboard",@"Share"];

        for (int i = 0; i < 3 ; i ++) {
            SKSpriteNode *backdrop = [[SKSpriteNode alloc] initWithColor:[self tileColor] size:CGSizeMake(size.width, 54.0)];

            [backdrop setPosition:CGPointMake(size.width / 2.0, 102 + 54 * i + i * 15)];
            [backdrop setName:names[i]];
            [backdrop setAlpha:i == 2];

            SKLabelNode *label = [[SKLabelNode alloc] initWithFontNamed:@"ComicNeue-Regular"];
            [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
            [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
            [label setText:names[i]];
            [label setFontColor:[self mainColor]];
            [label setFontSize:40.0];


            [backdrop addChild:label];

            [self addChild:backdrop];
        }

        SKSpriteNode *backdrop = [[SKSpriteNode alloc] initWithColor:[self tileColor] size:CGSizeZero];

        if ([[UIScreen mainScreen] bounds].size.height == 568.0) {
            [backdrop setSize:CGSizeMake(size.width, 160.0)];
            [backdrop setPosition:CGPointMake(size.width / 2.0, size.height - 185.0)];
        }else{
            [backdrop setSize:CGSizeMake(size.width, 100.0)];
            [backdrop setPosition:CGPointMake(size.width / 2.0, size.height - 145.0)];
        }

        DSMultilineLabelNode *label = [[DSMultilineLabelNode alloc] initWithFontNamed:@"ComicNeue-Regular"];
        [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [label setText:[NSString stringWithFormat:@"Last Score: %li\n Best Score: %li",(long)[defaults integerForKey:@"lastScore"],(long)[defaults integerForKey:@"highScore"]]];
        [label setFontColor:[self mainColor]];
        [label setFontSize:34.0];
        [backdrop addChild:label];

        [self addChild:backdrop];

        if ([defaults integerForKey:@"lastScore"] > [defaults integerForKey:@"highScore"]) {
            [defaults setInteger:[defaults integerForKey:@"lastScore"] forKey:@"highScore"];
        }

        [defaults synchronize];
    }

    return self;
}

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];

    [Appirater userDidSignificantEvent:YES];
    [self attemptGameCenterScoreReporting];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (SKNode *node in self.children) {
            if (node.alpha == 0.0) {
                [node runAction:[SKAction fadeAlphaTo:1.0 duration:0.45]];
            }
        }
    });
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    CGPoint location = [[touches anyObject] locationInNode:self];

    NSArray *nodes = [self nodesAtPoint:location];

    for (SKNode *node in nodes) {
        if ([node isMemberOfClass:[SKSpriteNode class]] && node.name) {


            if ([node.name isEqualToString:@"Play Again"]) {
                MyScene *scene = [[MyScene alloc] initWithSize:self.size];
                [scene setScaleMode:self.scaleMode];

                [self.view presentScene:scene
                             transition:[SKTransition revealWithDirection:SKTransitionDirectionUp
                                                                 duration:0.35]];
            }else if ([node.name isEqualToString:@"Share"]) {
                UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:@"I just scored %li in The Line 2! Check it out! https://itunes.apple.com/app/the-line-2/id884935957",(long)self.score]] applicationActivities:nil];
                [self.view.window.rootViewController presentViewController:controller animated:YES completion:nil];
            }else if ([node.name isEqualToString:@"Leaderboard"]) {
                GKGameCenterViewController *controller = [[GKGameCenterViewController alloc] init];
                [controller setViewState:GKGameCenterViewControllerStateLeaderboards];
                [controller setGameCenterDelegate:self];

                [self.view.window.rootViewController presentViewController:controller animated:YES completion:^{
                    [self setPaused:YES];
                }];

            }

            [self runAction:[SKAction playSoundFileNamed:@"tap.m4a" waitForCompletion:NO]];
        }
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:^{
        [self setPaused:NO];
    }];
}

- (void)attemptGameCenterScoreReporting
{
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];

    if (player.isAuthenticated) {
        [self submitScore];
    }else{
        [player setAuthenticateHandler:^(UIViewController *viewController, NSError *error) {
            if (!error) {
                [self submitScore];
            }
        }];
    }
}

- (void)submitScore
{
    GKScore *submissionScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"scoreLeaderboard"];
    [submissionScore setValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"]];

    [GKScore reportScores:@[submissionScore] withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error submitting score to Game Center");
        }else{
            NSLog(@"Submited Score: %lld",submissionScore.value);
        }
    }];
}

- (SKColor *)tileColor
{
    static SKColor *color = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [SKColor colorWithRed:253.0 / 255.0
                                green:234.0 / 255.0
                                 blue:175.0 / 255.0
                                alpha:1.0];
    });

    return color;
}

- (SKColor *)mainColor
{
    static SKColor *color = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [SKColor colorWithRed:255.0 / 255.0
                                green:29.0 / 255.0
                                 blue:67.0 / 255.0
                                alpha:1.0];
    });

    return color;
}

@end