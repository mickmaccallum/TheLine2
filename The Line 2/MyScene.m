#import "MyScene.h"
#import "GameOver.h"
#import "DSMultilineLabelNode.h"

static CGSize tileSize = {46.0, 80.0};

@interface MyScene () < SKPhysicsContactDelegate >

@property (strong, nonatomic) SKSpriteNode *lastSpawnedSafeMode;
@property (strong, nonatomic) SKSpriteNode *touchPad;
@property (strong, nonatomic) SKShapeNode *circle;
@property (nonatomic, assign) CGFloat SpawnY;
@property (nonatomic, assign) BOOL isGameRunning;
@property (nonatomic, assign) BOOL isGameOver;

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, strong) SKSpriteNode *topBar;
@property (nonatomic, strong) DSMultilineLabelNode *tutLabel;

@end

@implementation MyScene

-(instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    
    if (self) {
        [self setSpawnY:0.0];
        [self setIsGameRunning:NO];
        [self setIsGameOver:NO];

        [self setBackgroundColor:[self mainColor]];
        [self.physicsWorld setGravity:CGVectorMake(0.0, 0.0)];
        [self.physicsWorld setContactDelegate:self];
        
        [self setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:size
                                                             center:CGPointMake(size.width / 2.0, size.height / 2.0)]];
        
        [self.physicsBody setCategoryBitMask:1];
        [self.physicsBody setCollisionBitMask:0];
        [self.physicsBody setContactTestBitMask:~(1 | 16)];
        
        [self generateInitial];

        SKColor *color = [SKColor colorWithRed:76.0 / 255.0
                                         green:217.0 / 255.0
                                          blue:100.0 / 255.0
                                         alpha:1.0];


        self.touchPad = [[SKSpriteNode alloc] initWithColor:color
                                                       size:CGSizeMake(size.width, 120.0)];
        [self.touchPad setPosition:CGPointMake(size.width / 2.0, 110.0)];
        [self.touchPad setZPosition:700.0];


        DSMultilineLabelNode *tutLabel = [[DSMultilineLabelNode alloc] initWithFontNamed:@"ComicNeue-Regular"];
        [tutLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [tutLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [tutLabel setFontColor:[self tileColor]];
        [tutLabel setFontSize:20.0];
        [tutLabel setText:@"<<  Pan here to move the dot  >>\n\n Don't lift your finger!"];


        [self.touchPad addChild:tutLabel];
        [self setTutLabel:tutLabel];

        [self addChild:self.touchPad];



        self.circle = [[SKShapeNode alloc] init];
        
        UIBezierPath *bezier = [UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width / 2.0, 220.0) radius:8.0
                                                          startAngle:0.0
                                                            endAngle:2.0 * M_PI
                                                           clockwise:YES];
        
        [self.circle setPath:bezier.CGPath];
        [self.circle setFillColor:[SKColor blueColor]];
        [self.circle setStrokeColor:[SKColor blueColor]];
        [self.circle setPosition:CGPointMake(0.0, 0.0)];
        [self.circle setZPosition:1000.0];

        SKPhysicsBody *circlePhysics = [SKPhysicsBody bodyWithPolygonFromPath:bezier.CGPath];

        [circlePhysics setCategoryBitMask:16];
        [circlePhysics setCollisionBitMask:0];
        [circlePhysics setContactTestBitMask:2];
        [circlePhysics setDynamic:NO];
        [circlePhysics setUsesPreciseCollisionDetection:YES];

        [self.circle setPhysicsBody:circlePhysics];

        [self addChild:self.circle];

        SKSpriteNode *backgroundNode = [[SKSpriteNode alloc] initWithColor:[self mainColor]
                                                                      size:size];
        [backgroundNode setZPosition:1];
        [backgroundNode setAnchorPoint:CGPointZero];
        [backgroundNode setPosition:CGPointZero];
        [backgroundNode setName:@"backgroundNode"];

        [self addChild:backgroundNode];


        SKSpriteNode *topBar = [[SKSpriteNode alloc] initWithColor:[self grey]
                                                              size:CGSizeMake(size.width, 50.0)];
        [topBar setZPosition:15000];
        [topBar setAlpha:0.0];
        [topBar setPosition:CGPointMake(size.width / 2.0, size.height - 25.0)];

        SKLabelNode *scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"ComicNeue-Regular"];
        [scoreLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [scoreLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [scoreLabel setName:@"scoreLabel"];
        [scoreLabel setText:@"Score: 0"];
        [scoreLabel setFontColor:[SKColor whiteColor]];
        [scoreLabel setFontSize:24.0];
        [scoreLabel setPosition:CGPointMake(0.0, 0.0)];
        [topBar addChild:scoreLabel];

        [self setScoreLabel:scoreLabel];


        [self addChild:topBar];
        [self setTopBar:topBar];
    }

    return self;
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

- (SKColor *)grey
{
    static SKColor *color = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [SKColor colorWithRed:168.0 / 255.0
                                green:168.0 / 255.0
                                 blue:168.0 / 255.0
                                alpha:0.9];
    });

    return color;
}

- (void)generateInitial
{
    [self createRowWithTileWidth:7 atContactPoint:self.size.width / 2.0];
    [self createRowWithTileWidth:5 atContactPoint:self.size.width / 2.0];
    [self createRowWithTileWidth:3 atContactPoint:self.size.width / 2.0];
    [self createRowWithTileWidth:1 atContactPoint:self.size.width / 2.0];
    [self createRowWithTileWidth:1 atContactPoint:self.size.width / 2.0];

}

- (void)createRowWithTileWidth:(CGFloat)width atContactPoint:(CGFloat)contactPosition
{
    NSLog(@"%@",NSStringFromCGSize(tileSize));
    CGFloat x = ((7.0 - width) / 2.0) * tileSize.width;
    NSLog(@"%f",x);



    SKSpriteNode *safeZone = [[SKSpriteNode alloc] initWithColor:[self tileColor]
                                                            size:CGSizeMake(width * tileSize.width, tileSize.height * 2.0)];
    [safeZone setAnchorPoint:CGPointMake(0.0, 0.0)];
    [safeZone setName:@"safe"];
    [safeZone setPosition:CGPointMake(x, self.SpawnY)];
    [safeZone setZPosition:10.0];


    SKPhysicsBody *leftBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero
                                                           toPoint:CGPointMake(0.0, safeZone.size.height)];

    SKPhysicsBody *rightBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(safeZone.size.width, 0.0)
                                                            toPoint:CGPointMake(safeZone.size.width, safeZone.size.height)];
    NSArray *bodies = nil;

    if (safeZone.size.width > tileSize.width) {

        SKPhysicsBody *leftCap = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0.0, safeZone.size.height)
                                                              toPoint:CGPointMake(tileSize.width, safeZone.size.height)];

        SKPhysicsBody *rightCap = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(safeZone.size.width, safeZone.size.height)
                                                               toPoint:CGPointMake(safeZone.size.width - tileSize.width, safeZone.size.height)];
        bodies = @[leftBody,rightBody,leftCap,rightCap];
    }else{
        bodies = @[leftBody,rightBody];
    }

    SKPhysicsBody *physicsBody = [SKPhysicsBody bodyWithBodies:bodies];

    [physicsBody setCategoryBitMask:2];
    [physicsBody setCollisionBitMask:0];
    [physicsBody setContactTestBitMask:16];
    [physicsBody setLinearDamping:0.0];
    [physicsBody setMass:1.0];
    [physicsBody setFriction:0.0];
    [physicsBody setRestitution:0.0];
    [physicsBody setAllowsRotation:NO];

    [safeZone setPhysicsBody:physicsBody];

    [self addChild:safeZone];

    self.SpawnY += tileSize.height * 2.0;

    [self setLastSpawnedSafeMode:safeZone];
}

- (void)addSet
{
    SKSpriteNode *lastSpawnedNode = self.lastSpawnedSafeMode;

    BOOL isLastOnLeft = lastSpawnedNode.frame.origin.x < self.size.width / 2.0;

    CGPoint pointAbove = CGPointMake(lastSpawnedNode.frame.origin.x, lastSpawnedNode.frame.origin.y + lastSpawnedNode.frame.size.height - 5);

    SKSpriteNode *safeZone = [[SKSpriteNode alloc] initWithColor:[self tileColor]
                                                            size:CGSizeZero];
    [safeZone setAnchorPoint:CGPointMake(0.0, 0.0)];
    [safeZone setName:@"safe"];
    [safeZone setZPosition:10.0];

    if (isLastOnLeft) {
        [safeZone setSize:CGSizeMake(((arc4random_uniform(ceil(self.size.width - tileSize.width - lastSpawnedNode.frame.origin.x) / tileSize.width)) + 2.0) * tileSize.width, tileSize.height)];
        [safeZone setPosition:pointAbove];
    }else{
        [safeZone setSize:CGSizeMake((arc4random_uniform(floor((lastSpawnedNode.frame.origin.x - tileSize.width) / tileSize.width)) + 2.0) * tileSize.width, tileSize.height)];
        [safeZone setPosition:CGPointMake(pointAbove.x + tileSize.width - safeZone.size.width, pointAbove.y)];
    }


    CGPoint bottomFromPoint = CGPointZero;
    CGPoint bottomToPoint = CGPointMake(safeZone.size.width, 0.0);

    CGPoint topFromPoint = CGPointMake(0.0, safeZone.size.height);
    CGPoint topToPoint = CGPointMake(safeZone.size.width, safeZone.size.height);

    if (isLastOnLeft) {
        topToPoint = CGPointMake(safeZone.size.width - tileSize.width, safeZone.size.height);
        bottomFromPoint = CGPointMake(lastSpawnedNode.frame.size.width, 0.0);
    }else{
        bottomToPoint = CGPointMake(safeZone.size.width - tileSize.width, 0.0);
        topFromPoint = CGPointMake(tileSize.width, safeZone.size.height);
    }


    SKPhysicsBody *topBody = [SKPhysicsBody bodyWithEdgeFromPoint:topFromPoint
                                                          toPoint:topToPoint];

    SKPhysicsBody *bottomBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomFromPoint
                                                             toPoint:bottomToPoint];

    SKPhysicsBody *leftWall = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero
                                                           toPoint:CGPointMake(0.0, safeZone.size.height)];

    SKPhysicsBody *rightWall = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(safeZone.size.width, 0.0)
                                                            toPoint:CGPointMake(safeZone.size.width, safeZone.size.height)];

    SKPhysicsBody *physicsBody = [SKPhysicsBody bodyWithBodies:@[topBody,bottomBody,leftWall,rightWall]];

    [physicsBody setCategoryBitMask:2];
    [physicsBody setCollisionBitMask:0];
    [physicsBody setContactTestBitMask:16];
    [physicsBody setLinearDamping:0.0];
    [physicsBody setMass:1.0];
    [physicsBody setFriction:0.0];
    [physicsBody setRestitution:0.0];
    [physicsBody setAllowsRotation:NO];

    [safeZone setPhysicsBody:physicsBody];

    [self addChild:safeZone];

    SKSpriteNode *upwardNode = [[SKSpriteNode alloc] initWithColor:[self tileColor]
                                                              size:CGSizeMake(tileSize.width, (arc4random_uniform(4) + 1) * tileSize.height)];
    [upwardNode setAnchorPoint:CGPointMake(0.0, 0.0)];
    [upwardNode setName:@"safe"];
    [upwardNode setZPosition:10.0];

    if (isLastOnLeft) {
        [upwardNode setPosition:CGPointMake(safeZone.frame.origin.x + safeZone.frame.size.width - tileSize.width, safeZone.frame.origin.y + safeZone.frame.size.height)];
    }else{
        [upwardNode setPosition:CGPointMake(safeZone.frame.origin.x, safeZone.frame.origin.y + safeZone.frame.size.height)];
    }


    SKPhysicsBody *leftBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero
                                                           toPoint:CGPointMake(0.0, upwardNode.size.height)];

    SKPhysicsBody *rightBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(upwardNode.size.width, 0.0)
                                                            toPoint:CGPointMake(upwardNode.size.width, upwardNode.size.height)];

    SKPhysicsBody *upwardBody = [SKPhysicsBody bodyWithBodies:@[leftBody,rightBody]];

    [upwardBody setCategoryBitMask:2];
    [upwardBody setCollisionBitMask:0];
    [upwardBody setContactTestBitMask:16];
    [upwardBody setLinearDamping:0.0];
    [upwardBody setMass:1.0];
    [upwardBody setFriction:0.0];
    [upwardBody setRestitution:0.0];
    [upwardBody setAllowsRotation:NO];

    [upwardNode setPhysicsBody:upwardBody];

    [self addChild:upwardNode];

    [self setLastSpawnedSafeMode:upwardNode];

    if (self.isGameRunning) {
        [safeZone.physicsBody setVelocity:CGVectorMake(0.0, -150.0)];
        [upwardNode.physicsBody setVelocity:CGVectorMake(0.0, -150.0)];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.node == self || contact.bodyB.node == self) {

        MyScene *scene = nil;
        SKSpriteNode *safeZone = nil;

        if (contact.bodyA.node == self) {
            scene = (MyScene *)contact.bodyA.node;

            if ([contact.bodyB.node.name isEqualToString:@"safe"]) {
                safeZone = (SKSpriteNode *)contact.bodyB.node;
            }
        }

        if (contact.bodyB.node == self) {
            scene = (MyScene *)contact.bodyB.node;

            if ([contact.bodyA.node.name isEqualToString:@"safe"]) {
                safeZone = (SKSpriteNode *)contact.bodyA.node;
            }
        }

        if (scene && safeZone) {
            [self addSet];
        }
    }

}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.node == self || contact.bodyB.node == self) {

        MyScene *scene = nil;
        SKSpriteNode *safeZone = nil;

        if (contact.bodyA.node == self) {
            scene = (MyScene *)contact.bodyA.node;

            if ([contact.bodyB.node.name isEqualToString:@"safe"]) {
                safeZone = (SKSpriteNode *)contact.bodyB.node;
            }
        }

        if (contact.bodyB.node == self) {
            scene = (MyScene *)contact.bodyB.node;

            if ([contact.bodyA.node.name isEqualToString:@"safe"]) {
                safeZone = (SKSpriteNode *)contact.bodyA.node;
            }
        }

        if (scene && safeZone) {
            [safeZone runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0],[SKAction removeFromParent]]]];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    CGPoint location = [[touches anyObject] locationInNode:self];

    if (!self.isGameOver) {

        if (CGRectContainsPoint(self.touchPad.frame, location) && !self.paused) {
            [self.circle setPosition:CGPointMake(location.x - self.size.width / 2.0, self.circle.position.y)];

            BOOL hasGoodTile = NO;
            for (SKNode *node in [self nodesAtPoint:self.circle.position]) {
                if ([node.name isEqualToString:@"safe"]) {
                    hasGoodTile = YES;
                    break;
                }
            }
            if (!hasGoodTile) {
                [self lose];
                return;
            }

            if (!self.isGameRunning) {
                [self enumerateChildNodesWithName:@"safe" usingBlock:^(SKNode *node, BOOL *stop) {
                    [node.physicsBody setVelocity:CGVectorMake(0.0, -150.0)];
                }];

                [self setIsGameRunning:YES];
                [self.topBar runAction:[SKAction fadeAlphaTo:1.0 duration:0.25]];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.tutLabel runAction:[SKAction fadeOutWithDuration:0.4]];
                });

                SKAction *block = [SKAction runBlock:^{
                    [self increment];
                } queue:dispatch_get_main_queue()];

                [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1],block]]] withKey:@"loop"];
            }
        }else{

        }
    }else{

    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];

    [self enumerateChildNodesWithName:@"safe" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node hasActions]) {
            [node removeAllActions];
        }
    }];

    [self lose];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];

    [self enumerateChildNodesWithName:@"safe" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node hasActions]) {
            [node removeAllActions];
        }
    }];

    [self lose];
}

- (void)increment
{
    self.score ++ ;
}

- (void)setScore:(NSInteger)score
{
    _score = score;

    [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %li",(long)score]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];

    if (!self.isGameOver) {
        CGPoint location = [[touches anyObject] locationInNode:self];

        if (self.isGameRunning) {
            if (CGRectContainsPoint(self.touchPad.frame, location) && !self.paused) {
                [self.circle setPosition:CGPointMake(location.x - self.size.width / 2.0, self.circle.position.y)];
            }
        }
    }
}

- (void)update:(CFTimeInterval)currentTime
{
    [super update:currentTime];

    if (self.isGameRunning) {
        NSInteger count = [self.circle.physicsBody allContactedBodies].count;

        if (count) {
            [self lose];

            return;
        }
    }
}

- (void)lose
{
    if (self.isGameRunning) {
        [self setIsGameRunning:NO];
        [self setIsGameOver:YES];

        [self removeActionForKey:@"loop"];

        if (self.hasActions) {
            [self removeAllActions];
        }
        [self runAction:[SKAction playSoundFileNamed:@"lose.m4a" waitForCompletion:NO]];

        [self enumerateChildNodesWithName:@"safe" usingBlock:^(SKNode *node, BOOL *stop) {
            [node.physicsBody setVelocity:CGVectorMake(0.0, 0.0)];
        }];

        SKAction *colorize = [SKAction colorizeWithColor:[SKColor yellowColor] colorBlendFactor:1.0 duration:0.25];
        [[self childNodeWithName:@"backgroundNode"] runAction:[SKAction sequence:@[colorize, colorize.reversedAction]]];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [defaults setInteger:self.score forKey:@"lastScore"];
        [defaults synchronize];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            GameOver *scene = [[GameOver alloc] initWithSize:self.size];
            [scene setScaleMode:self.scaleMode];

            [self.view presentScene:scene
                         transition:[SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.35]];
        });
    }
}

@end