//
//  TSKMenuScene.m
//  testeSpriteKit
//
//  Created by João Pedro Cappelletto D'Agnoluzzo on 7/14/14.
//  Copyright (c) 2014 João Pedro Cappelletto D'Agnoluzzo. All rights reserved.
//

#import "TSKMenuScene.h"
#import "TSKMyScene.h"
#import "TSKViewController.h"

static const uint32_t WORLD = 0x1 << 0;
static const uint32_t GROUND = 0x1 << 1;
static const uint32_t SHAPE = 0x1 << 2;
static const uint32_t PADDLE = 0x1 << 3;

static NSString* shapeCategoryName = @"shape";
static NSString* paddleCategoryName = @"paddle";

@interface TSKMenuScene()

@property NSMutableArray *balls;
@property int lastShape;

@end


@implementation TSKMenuScene{
    
    SKLabelNode *play, *highScore, *name;
    
}

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:1-0.15 green:1-0.15 blue:1-0.3 alpha:1.0];
        
        play = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
        play.text = @"Play";
        play.name = @"Play";
        play.fontSize = self.frame.size.width * 0.0520;
        play.position = CGPointMake(CGRectGetMidX(self.frame),
                                               CGRectGetMidY(self.frame));
        [play setFontColor:[SKColor blackColor]];
        play.zPosition = 2;
        
        [self addChild:play];
        
        
        highScore = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
        highScore.text = [NSString stringWithFormat:@"High Score %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"bestScore"]];
        highScore.name = @"High Score";
        highScore.fontSize = self.frame.size.width * 0.0260;
        highScore.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame)-self.frame.size.width * 0.1302);
        [highScore setFontColor:[SKColor blackColor]];
        highScore.zPosition = 2;
        
        [self addChild:highScore];
    
        [highScore setHidden:YES];
        
        
        name = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
        name.text = @"Funny Bounce";
        name.name = @"Nome";
        name.fontSize = self.frame.size.width * 0.0781;
        name.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame)+self.frame.size.width * 0.2604);
        name.zPosition = 2;
        
        [self addChild:name];
        
        
        SKAction *wait = [SKAction waitForDuration:4];
        SKAction *action = [SKAction performSelector:@selector(addShapes) onTarget:self];
        SKAction *sequence = [SKAction sequence:@[wait, action]];
        SKAction *repeat = [SKAction repeatAction:sequence count:6];
        [self runAction:repeat completion:^{
            SKAction *wait4reanimate = [SKAction waitForDuration:3];
            SKAction *resetPosition = [SKAction performSelector:@selector(resetPositions) onTarget:self];
            SKAction *animateAgain = [SKAction sequence:@[wait4reanimate, resetPosition]];
            SKAction *repeat4ever = [SKAction repeatActionForever:animateAgain];
            
            [self runAction:repeat4ever];
        }];
        
        
        self.physicsWorld.contactDelegate = self;
        
        self.physicsBody.categoryBitMask = WORLD;
        //NSLog(@"%u", self.physicsBody.categoryBitMask);
        
        self.physicsBody.collisionBitMask = SHAPE | GROUND;
        self.physicsBody.contactTestBitMask = SHAPE;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        self.balls = [[NSMutableArray alloc] init];
        self.lastShape = 0;
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches) {
        SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];
        if ( [node.name isEqual: @"Play"]){
            SKScene * scene = [TSKMyScene sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            [self.view presentScene:scene];
        }
        
        else{
            [self showHideScore];
        }
        
    }
}

-(void)showHideScore{
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5];
    
    
    if(highScore.isHidden){
        [highScore setHidden:!highScore.isHidden];
        [highScore runAction:fadeIn];
    }
    else
        [highScore runAction:fadeOut completion:^{
            [highScore setHidden:!highScore.isHidden];
        }];
}

-(void)resetPositions{
    if(self.lastShape<5){
        [[self.balls objectAtIndex:self.lastShape] setPosition:CGPointMake((self.frame.size.width * 0.1302 + arc4random() % (int)(self.frame.size.width * 0.9114 - self.frame.size.width * 0.1302 + 1)), self.frame.size.width * 1.1718)];
        self.lastShape++;
    }else{
        self.lastShape=0;
    }
}

-(void)addShapes{
    
    SKShapeNode *shape = [[SKShapeNode alloc] init];
    
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGPathAddArc(myPath, NULL, 0, 0, self.frame.size.width * 0.0390, 0, M_PI*2, YES);
    
    shape.path = myPath;
    
    //Random Color
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    shape.fillColor = [SKColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    shape.position = CGPointMake((self.frame.size.width * 0.1302 + arc4random() % (int)(self.frame.size.width * 0.9114 - self.frame.size.width * 0.1302 + 1)), self.frame.size.width * 1.1718);
    
    shape.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.frame.size.width * 0.0390];
    
    shape.physicsBody.dynamic = YES;
    
    shape.name = shapeCategoryName;
    shape.strokeColor = [SKColor blackColor];
    
    shape.physicsBody.categoryBitMask = SHAPE;
    shape.physicsBody.collisionBitMask = SHAPE| PADDLE | GROUND;
    shape.physicsBody.contactTestBitMask = SHAPE | GROUND | PADDLE ;
    
    shape.physicsBody.restitution = 1.00001; //bouncing
    shape.physicsBody.linearDamping = 0; //reduces linear velocity
    shape.physicsBody.velocity = CGVectorMake(0, -10);
    
    [self addChild:shape];
    [self.balls addObject:shape];
}


@end