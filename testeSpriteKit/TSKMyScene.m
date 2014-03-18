//
//  TSKMyScene.m
//  testeSpriteKit
//
//  Created by João Pedro Cappelletto D'Agnoluzzo on 3/17/14.
//  Copyright (c) 2014 João Pedro Cappelletto D'Agnoluzzo. All rights reserved.
//

#import "TSKMyScene.h"


static const uint32_t SHAPE = 0x1 << 1;
static const uint32_t WORLD = 0x1 << 0;

@implementation TSKMyScene {

    
    SKLabelNode *waitingForTouch;
}


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        firstTouch = NO;
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.physicsWorld.contactDelegate = self;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = WORLD | SHAPE;
        self.physicsBody.collisionBitMask = WORLD | SHAPE;
        
        
        
        
        waitingForTouch = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
        waitingForTouch.text = @"Click to add shapes!";
        waitingForTouch.fontSize = 30;
        waitingForTouch.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5f];
        SKAction *fadeIn = [SKAction fadeInWithDuration:0.5f];
        SKAction *actionSequence = [SKAction sequence:@[fadeOut, fadeIn]];
        SKAction *repeat = [SKAction repeatActionForever:actionSequence];
        
        [waitingForTouch runAction:repeat];
        
        [self addChild:waitingForTouch];
        

    
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    firstTouch = YES;
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
       
        SKShapeNode *shape = [[SKShapeNode alloc] init];
        
        CGMutablePathRef myPath = CGPathCreateMutable();
        CGPathAddArc(myPath, NULL, 0, 0, 30, 0, M_PI*2, YES);
        
        shape.path = myPath;
        
        shape.position = location;
        
        //Random Color
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        shape.fillColor = [SKColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        
        shape.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:30];
        
        
        
        shape.physicsBody.dynamic = YES;
        
        shape.physicsBody.categoryBitMask = SHAPE;
        shape.physicsBody.collisionBitMask = SHAPE | WORLD;
        shape.physicsBody.contactTestBitMask = SHAPE | WORLD;
        //shape.physicsBody.velocity = CGVectorMake(0.0, 1000.0);
        
        shape.physicsBody.restitution = 1; //bouncing
        shape.physicsBody.linearDamping = 0; //reduces linear velocity
        shape.physicsBody.restitution = 1;
        
        [self addChild:shape];
        
        
        
        
        //Label
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = @"Shape adicionado!";
        label.fontSize = 30;
        label.position = CGPointMake(CGRectGetMidX(self.frame), 50);
       
        SKAction *actionForLabel = [SKAction fadeOutWithDuration:1.0f];
        SKAction *remove = [SKAction removeFromParent];
        
        [label runAction:[SKAction sequence:@[actionForLabel, remove]]];
        
        [self addChild:label];
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    NSLog(@"contact!");
    
    
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if(firstTouch){
        [waitingForTouch removeFromParent];
    }
}


@end
