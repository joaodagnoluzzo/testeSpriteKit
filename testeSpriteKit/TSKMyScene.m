//
//  TSKMyScene.m
//  testeSpriteKit
//
//  Created by João Pedro Cappelletto D'Agnoluzzo on 3/17/14.
//  Copyright (c) 2014 João Pedro Cappelletto D'Agnoluzzo. All rights reserved.
//

#import "TSKMyScene.h"


static const uint32_t WORLD = 0x1 << 0;
static const uint32_t SHAPE = 0x1 << 1;
static const uint32_t PADDLE = 0x1 << 2;


static NSString* shapeCategoryName = @"shape";
static NSString* paddleCategoryName = @"paddle";


@interface TSKMyScene()

@property (nonatomic) BOOL isFingerOnPaddle;
@property NSInteger paddleHeight, paddleWidth, qtdShapes, userPoints;
@property SKLabelNode *points_hud, *balls_number;
@end


@implementation TSKMyScene {
    
    
    SKLabelNode *waitingForTouch;
}


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        firstTouch = NO;
        
        //self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.backgroundColor = [SKColor colorWithRed:1-0.15 green:1-0.15 blue:1-0.3 alpha:1.0];
        
        
        self.physicsWorld.contactDelegate = self;
        
        self.physicsBody.categoryBitMask = WORLD;
        //NSLog(@"%u", self.physicsBody.categoryBitMask);
        
        self.physicsBody.collisionBitMask = SHAPE | WORLD;
        self.physicsBody.contactTestBitMask = SHAPE;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        self.physicsBody.friction = 0.0f;
        // 4
        self.physicsBody.restitution = 1.0f;
        // 5
        self.physicsBody.linearDamping = 0.0f;
        // 6
        self.physicsBody.allowsRotation = NO;
        
        
        waitingForTouch = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
        waitingForTouch.text = @"Tap to START!";
        waitingForTouch.fontSize = 30;
        waitingForTouch.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        [waitingForTouch setFontColor:[SKColor blackColor]];
        
        
        SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5f];
        SKAction *fadeIn = [SKAction fadeInWithDuration:0.5f];
        SKAction *actionSequence = [SKAction sequence:@[fadeOut, fadeIn]];
        SKAction *repeat = [SKAction repeatActionForever:actionSequence];
        
        [waitingForTouch runAction:repeat];
        
        [self addChild:waitingForTouch];
        

    
    }
    return self;
}


-(void)addEnvironment{
    /* Called when a touch begins */
    
    firstTouch = YES;
    
    self.paddleHeight = 20;
    self.paddleWidth = 180;
    self.userPoints = 0;
    
    
    self.points_hud = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.points_hud.text = [NSString stringWithFormat:@"Score: %i", self.userPoints];
    self.points_hud.fontSize = 30;
    self.points_hud.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame)*1/3 -10);
    [self.points_hud setFontColor:[SKColor blackColor]];
    
    [self addChild:self.points_hud];
    
    self.balls_number = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.balls_number.text = [NSString stringWithFormat:@"Number of balls: %i", self.qtdShapes];
    self.balls_number.fontSize = 30;
    self.balls_number.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame)*1/3 -50);
    [self.balls_number setFontColor:[SKColor blackColor]];
    
    [self addChild:self.balls_number];
    
    [self addPaddle];
    
    
}

-(void)addPaddle{
    SKShapeNode *paddle = [[SKShapeNode alloc] init];
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGPathAddRect(myPath, NULL, CGRectMake(-(self.paddleWidth/2), -(self.paddleHeight/2), self.paddleWidth, self.paddleHeight));
    
    paddle.path = myPath;
    paddle.fillColor = [SKColor redColor];
    
    paddle.name = paddleCategoryName;
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.paddleWidth, self.paddleHeight)];
    
    paddle.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/5);
    
    paddle.physicsBody.dynamic = NO;
    
    paddle.physicsBody.categoryBitMask = PADDLE;
    paddle.physicsBody.collisionBitMask = PADDLE | WORLD;
    paddle.physicsBody.contactTestBitMask = PADDLE;
    
    
    [self addChild:paddle];
    
    SKAction *wait = [SKAction waitForDuration:2];
    SKAction *action = [SKAction performSelector:@selector(addShapes) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[wait, action]];
    SKAction *repeat = [SKAction repeatActionForever:sequence];
    [self runAction:repeat];
}


-(void)addShapes{
    
    SKShapeNode *shape = [[SKShapeNode alloc] init];
    
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGPathAddArc(myPath, NULL, 0, 0, 30, 0, M_PI*2, YES);
    
    shape.path = myPath;
    
    //Random Color
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    shape.fillColor = [SKColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    shape.position = CGPointMake((100 + arc4random() % (700 - 100 + 1)), 900);
    
    shape.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:30];
    
    shape.physicsBody.dynamic = YES;
    
    shape.name = shapeCategoryName;
    shape.strokeColor = [SKColor blackColor];
    
    shape.physicsBody.categoryBitMask = SHAPE;
    shape.physicsBody.collisionBitMask = SHAPE| PADDLE | WORLD;
    shape.physicsBody.contactTestBitMask = SHAPE | PADDLE | WORLD;
    
    shape.physicsBody.restitution = 1; //bouncing
    shape.physicsBody.linearDamping = 0; //reduces linear velocity
    shape.physicsBody.restitution = 1;
    
    [self addChild:shape];
    self.qtdShapes += 1;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(firstTouch == NO){
        [self addEnvironment];
    }
    else{
    
    /* Called when a touch begins */
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:touchLocation];
    if (body && [body.node.name isEqualToString: paddleCategoryName]) {
        NSLog(@"Began touch on paddle");
        self.isFingerOnPaddle = YES;
    }
    }

//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//       
//        SKShapeNode *shape = [[SKShapeNode alloc] init];
//        
//        CGMutablePathRef myPath = CGPathCreateMutable();
//        CGPathAddArc(myPath, NULL, 0, 0, 30, 0, M_PI*2, YES);
//        
//        shape.path = myPath;
//        
//        shape.position = location;
//        
//        //Random Color
//        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
//        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
//        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
//        shape.fillColor = [SKColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
//        
//        
//        shape.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:30];
//        
//        shape.physicsBody.dynamic = YES;
//        
//        shape.physicsBody.categoryBitMask = SHAPE;
//        shape.physicsBody.collisionBitMask = SHAPE | WORLD;
//        shape.physicsBody.contactTestBitMask = SHAPE | WORLD;
//        //shape.physicsBody.velocity = CGVectorMake(0.0, 1000.0);
//        
//        shape.physicsBody.restitution = 1; //bouncing
//        shape.physicsBody.linearDamping = 0; //reduces linear velocity
//        shape.physicsBody.restitution = 1;
//        
//        [self addChild:shape];
//        
//        
//        
//        
//        //Label
//        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//        label.text = @"Shape adicionado!";
//        label.fontSize = 30;
//        label.position = CGPointMake(CGRectGetMidX(self.frame), 50);
//       
//        SKAction *actionForLabel = [SKAction fadeOutWithDuration:1.0f];
//        SKAction *remove = [SKAction removeFromParent];
//        
//        [label runAction:[SKAction sequence:@[actionForLabel, remove]]];
//        
//        [self addChild:label];
//    }
    
}


-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    // 1 Check whether user tapped paddle
    if (self.isFingerOnPaddle) {
        // 2 Get touch location
        UITouch* touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        // 3 Get node for paddle
        SKShapeNode* paddle = (SKShapeNode*)[self childNodeWithName: paddleCategoryName];
        // 4 Calculate new position along x for paddle
        int paddleX = paddle.position.x + (touchLocation.x - previousLocation.x);
        int paddleY = paddle.position.y + (touchLocation.y - previousLocation.y);

        // 6 Update position of paddle
        paddle.position = CGPointMake(paddleX, paddleY);
    }
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    self.isFingerOnPaddle = NO;
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    
    if(contact.bodyA.categoryBitMask != contact.bodyB.contactTestBitMask){
        
        SKPhysicsBody* firstBody;
        SKPhysicsBody* secondBody;
        
        if (contact.bodyA.categoryBitMask == SHAPE) {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        } else {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        if(secondBody.categoryBitMask > firstBody.categoryBitMask && secondBody.categoryBitMask != PADDLE){
            
//            NSLog(@"WORLD> %u %u",secondBody.categoryBitMask,WORLD);
//            NSLog(@"SHAPE> %u %u",firstBody.categoryBitMask,SHAPE);
            
            firstBody.node.physicsBody.affectedByGravity = NO;
            firstBody.node.physicsBody.velocity = CGVectorMake(0, 0);
            SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5f];
            SKAction *remove = [SKAction removeFromParent];
            SKAction *block = [SKAction runBlock:^{
                self.qtdShapes-= 1;
            }];
            [firstBody.node runAction:[SKAction sequence:@[fadeOut,block,remove]]];
            
            NSLog(@"removed!");
        }
        
        else if(secondBody.categoryBitMask == PADDLE){
            self.userPoints += 1;
        }
        
    }
    
}

-(void)didEndContact:(SKPhysicsContact *)contact{
    
    
    NSLog(@"contact!");
    
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if(firstTouch){
        [waitingForTouch removeFromParent];
    }
    self.points_hud.text = [NSString stringWithFormat:@"Score: %i", self.userPoints];
    self.balls_number.text = [NSString stringWithFormat:@"Number of balls: %i", self.qtdShapes];
}


@end
