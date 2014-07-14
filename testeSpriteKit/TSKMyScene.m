//
//  TSKMyScene.m
//  testeSpriteKit
//
//  Created by João Pedro Cappelletto D'Agnoluzzo on 3/17/14.
//  Copyright (c) 2014 João Pedro Cappelletto D'Agnoluzzo. All rights reserved.
//

#import "TSKMyScene.h"


static const uint32_t WORLD = 0x1 << 0;
static const uint32_t GROUND = 0x1 << 1;
static const uint32_t SHAPE = 0x1 << 2;
static const uint32_t PADDLE = 0x1 << 3;
static const uint32_t PLACEHOLDER = 0x1 << 4;

static NSString* shapeCategoryName = @"shape";
static NSString* paddleCategoryName = @"paddle";


@interface TSKMyScene()

@property (nonatomic) BOOL isFingerOnPaddle;
@property (nonatomic) BOOL isFinderOnSecondaryPaddle;
@property (nonatomic) BOOL gameStarted, isPaused;
@property NSInteger paddleHeight, paddleWidth, qtdShapes, userPoints;
@property SKLabelNode *points_hud, *balls_number;
@property SKShapeNode *mainPaddle, *secondaryPaddle;
@property SKSpriteNode *mainPlaceholder, *secondaryPlaceholder, *backNode;

@end


@implementation TSKMyScene {
    
    
    SKLabelNode *waitingForTouch, *gameOverLabel, *playAgainLabel, *highScoreLabel, *scoreLabel;
}


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        firstTouch = NO;
        self.gameStarted = NO;
        self.isPaused = NO;
        //self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.backgroundColor = [SKColor colorWithRed:1-0.15 green:1-0.15 blue:1-0.3 alpha:1.0];
        
        
        [self setWorldPhysics];
        
        
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

-(void)setWorldPhysics{
    self.physicsWorld.contactDelegate = self;
    
    self.physicsBody.categoryBitMask = WORLD;
    //NSLog(@"%u", self.physicsBody.categoryBitMask);
    
    self.physicsBody.collisionBitMask = SHAPE | GROUND;
    self.physicsBody.contactTestBitMask = SHAPE;
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    self.physicsBody.friction = 0.0f;
    // 4
    self.physicsBody.restitution = 1.0f;
    // 5
    self.physicsBody.linearDamping = 0.0f;
    // 6
    self.physicsBody.allowsRotation = NO;
    
    self.physicsWorld.gravity = CGVectorMake(0, -10);
}

-(void)playAgain{
  
   // [self removeAllActions];
    [self removeAllChildren];
   
    [self setWorldPhysics];
    
    self.userPoints = 0;
    self.qtdShapes = 0;
    
    self.gameStarted = NO;
    self.isPaused = NO;
    
    [playAgainLabel removeFromParent];
    [gameOverLabel removeFromParent];
    [scoreLabel removeFromParent];
    [highScoreLabel removeFromParent];
    
    [self addEnvironment];
}

-(void)addEnvironment{
    /* Called when a touch begins */
    
    firstTouch = YES;
    
    self.paddleHeight = 20;
    self.paddleWidth = 180;
    self.userPoints = 0;
    
    
    self.points_hud = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.points_hud.text = [NSString stringWithFormat:@"Score: %li", (long)self.userPoints];
    self.points_hud.fontSize = 30;
    self.points_hud.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame)*1/3 -10);
    [self.points_hud setFontColor:[SKColor blackColor]];
    
    [self addChild:self.points_hud];
    
    self.balls_number = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.balls_number.text = [NSString stringWithFormat:@"Number of balls: %li", (long)self.qtdShapes];
    self.balls_number.fontSize = 30;
    self.balls_number.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame)*1/3 -50);
    [self.balls_number setFontColor:[SKColor blackColor]];
    
    [self addChild:self.balls_number];
    
    
    [self addGround];
    
    [self addPaddle];
    
    [self addSecondaryPaddle];
}

-(void)addPaddle{
    SKShapeNode *paddle = [[SKShapeNode alloc] init];
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGPathAddRect(myPath, NULL, CGRectMake(-(self.paddleWidth/2), -(self.paddleHeight/2), self.paddleWidth, self.paddleHeight));
    
    paddle.path = myPath;
    paddle.fillColor = [SKColor redColor];
    
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.paddleWidth, self.paddleHeight)];
    
    paddle.position = CGPointMake(self.frame.size.width/2 + self.paddleWidth, self.frame.size.height/5);
    
    paddle.physicsBody.dynamic = NO;
    
    paddle.physicsBody.categoryBitMask = PADDLE;
    paddle.physicsBody.collisionBitMask = PADDLE | WORLD;
    paddle.physicsBody.contactTestBitMask = PADDLE;
    
    paddle.name = @"mainPaddle";
    
    [self addChild:paddle];
    
    SKSpriteNode *placeholder = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:CGSizeMake(self.paddleWidth, self.paddleWidth)];
    
    placeholder.name = @"mainPlaceholder";
    
    placeholder.anchorPoint = CGPointMake(0.5, 0.5);
    
    placeholder.physicsBody.categoryBitMask = PLACEHOLDER;
    
    [paddle addChild:placeholder];
    
    self.mainPaddle = paddle;
    self.mainPlaceholder = placeholder;
    
    SKAction *wait = [SKAction waitForDuration:2];
    SKAction *action = [SKAction performSelector:@selector(addShapes) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[wait, action]];
    SKAction *repeat = [SKAction repeatActionForever:sequence];
    [self runAction:repeat];
    
    
}

-(void)addSecondaryPaddle{
    SKShapeNode *paddle = [[SKShapeNode alloc] init];
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGPathAddRect(myPath, NULL, CGRectMake(-(self.paddleWidth/2), -(self.paddleHeight/2), self.paddleWidth, self.paddleHeight));
    
    paddle.path = myPath;
    paddle.fillColor = [SKColor redColor];
    
    paddle.name = paddleCategoryName;
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.paddleWidth, self.paddleHeight)];
    
    paddle.position = CGPointMake(self.frame.size.width/4, self.frame.size.height/5);
    
    paddle.physicsBody.dynamic = NO;
    
    paddle.physicsBody.categoryBitMask = PADDLE;
    paddle.physicsBody.collisionBitMask = PADDLE | WORLD;
    paddle.physicsBody.contactTestBitMask = PADDLE;
    
    paddle.name = @"secondaryMainPaddle";
    
    
    [self addChild:paddle];
    
    
    SKSpriteNode *placeholder = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:CGSizeMake(self.paddleWidth, self.paddleWidth)];
    
    placeholder.name = @"secondaryPlaceholder";
    
    placeholder.anchorPoint = CGPointMake(0.5, 0.5);
    
    placeholder.physicsBody.categoryBitMask = PLACEHOLDER;
    
    [paddle addChild:placeholder];
    
    self.secondaryPaddle = paddle;
    self.secondaryPlaceholder = placeholder;
    
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
    shape.physicsBody.collisionBitMask = SHAPE| PADDLE | GROUND;
    shape.physicsBody.contactTestBitMask = SHAPE | GROUND | PADDLE ;
    
    shape.physicsBody.restitution = 1; //bouncing
    shape.physicsBody.linearDamping = 0; //reduces linear velocity
    shape.physicsBody.velocity = CGVectorMake(0, -10);
    
    [self addChild:shape];
    self.qtdShapes += 1;
    self.gameStarted = YES;
    //self.physicsWorld.gravity = CGVectorMake(0,-20);

}


-(void)addGround{
    
    SKShapeNode *ground = [[SKShapeNode alloc] init];
    NSInteger groundWidth = self.view.frame.size.width;
    NSInteger groundHeight = 25;
    
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGPathAddRect(myPath, NULL, CGRectMake(-(groundWidth/2), -(groundHeight/2), groundWidth, groundHeight));
    
    ground.position = CGPointMake((groundWidth/2), groundHeight/2);
    ground.path = myPath;
    
    ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: CGSizeMake(groundWidth, groundHeight)];
    
    ground.strokeColor = [UIColor clearColor];
    ground.fillColor = [UIColor clearColor];
    
    ground.physicsBody.categoryBitMask = GROUND;
    ground.physicsBody.collisionBitMask = SHAPE;
    ground.physicsBody.contactTestBitMask = SHAPE | GROUND;
    ground.physicsBody.dynamic = NO;
    
    NSLog(@"%ld %ld", (long)groundWidth, (long)groundHeight);
    
    [self addChild:ground];
    
    
    SKSpriteNode *groundTexture;
    SKTexture *texture1 = [SKTexture textureWithImageNamed:@"spikes.png"];
    groundTexture = [SKSpriteNode spriteNodeWithTexture:texture1];
    groundTexture.position = CGPointMake(ground.position.x - groundWidth/2, ground.position.y);
    groundTexture.size = CGSizeMake(groundWidth, 50);
    
    [ground addChild:groundTexture];
    
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    if(self.isPaused)
//        return;
//    
    if(firstTouch == NO){
        [self addEnvironment];
    }
    else{
    
    /* Called when a touch begins */
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
        SKNode *aux = [self nodeAtPoint:touchLocation];
//    SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:touchLocation];
//        NSLog(@">> %@",body.node.name);
        
        if (aux) {
            if([aux.name isEqualToString:@"mainPaddle"] || [aux.name isEqualToString:@"mainPlaceholder"]){
                //            NSLog(@"Began touch on main paddle");
                self.isFingerOnPaddle = YES;
            }else if([aux.name isEqualToString:@"secondaryPaddle"] || [aux.name isEqualToString:@"secondaryPlaceholder"]){
                //            NSLog(@"Began touch on secondary paddle");
                self.isFinderOnSecondaryPaddle = YES;
            }else if([aux.name isEqualToString:@"Play Again"]){
                NSLog(@"Do the Play Again action..");
                [self playAgain];
            }
            //    NSLog(@"%hhd %hhd", self.isFingerOnPaddle, self.isFinderOnSecondaryPaddle);
        }
    }
}


-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:touches.allObjects];
    
    for(UITouch *touch in array){
        
        if(self.isFingerOnPaddle){
            //UITouch* touch = [touches anyObject];
            CGPoint touchLocation = [touch locationInNode:self];
            CGPoint previousLocation = [touch previousLocationInNode:self];
            // 3 Get node for paddle
            SKNode* aux = [self nodeAtPoint:touchLocation];
//            NSLog(@"%@", aux.name);
            if(aux && [aux.name isEqualToString:@"mainPlaceholder"]){
                SKShapeNode* paddle = (SKShapeNode*)self.mainPaddle;
                // 4 Calculate new position along x for paddle
                int paddleX = paddle.position.x + (touchLocation.x - previousLocation.x);
                int paddleY = paddle.position.y + (touchLocation.y - previousLocation.y);
                // 6 Update position of paddle
                paddle.position = CGPointMake(paddleX, paddleY);
            }
        }
        if(self.isFinderOnSecondaryPaddle){
            //UITouch* touch = [touches anyObject];
            CGPoint touchLocation = [touch locationInNode:self];
            CGPoint previousLocation = [touch previousLocationInNode:self];
            // 3 Get node for paddle
            SKNode* aux = [self nodeAtPoint:touchLocation];
//            NSLog(@"%@", aux.name);
            if(aux && [aux.name isEqualToString:@"secondaryPlaceholder"]){
                SKShapeNode* paddle = (SKShapeNode*)self.secondaryPaddle;
                // 4 Calculate new position along x for paddle
                int paddleX = paddle.position.x + (touchLocation.x - previousLocation.x);
                int paddleY = paddle.position.y + (touchLocation.y - previousLocation.y);
                // 6 Update position of paddle
                paddle.position = CGPointMake(paddleX, paddleY);
            }
        }
        
    }
    

}

//    for(UITouch *touch in array){
//    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", nil);
//    
//    dispatch_async(myQueue, ^{
//        
//        if(self.isFingerOnPaddle || self.isFinderOnSecondaryPaddle){
//            //            UITouch* touch = [touches anyObject];
//            CGPoint touchLocation = [touch locationInNode:self];
//            CGPoint previousLocation = [touch previousLocationInNode:self];
//            // 3 Get node for paddle
//            SKShapeNode* paddle = (SKShapeNode*)[self nodeAtPoint:touchLocation];
//            // 4 Calculate new position along x for paddle
//            int paddleX = paddle.position.x + (touchLocation.x - previousLocation.x);
//            int paddleY = paddle.position.y + (touchLocation.y - previousLocation.y);
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // 6 Update position of paddle
//            paddle.position = CGPointMake(paddleX, paddleY);
//        });
//        
//        }
//    });
//    }
//    

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInView:self.view];
    
    SKNode *node = [self nodeAtPoint:currentPosition];
    if([node.name isEqualToString:@"mainPaddle"] || [node.name isEqualToString:@"mainPlaceholder"]){
        self.isFingerOnPaddle = NO;
    }else if([node.name isEqualToString:@"secondaryPaddle"] || [node.name isEqualToString:@"secondaryPlaceholder"]){
        self.isFinderOnSecondaryPaddle = NO;
    }
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
        
        if(secondBody.categoryBitMask < firstBody.categoryBitMask && secondBody.categoryBitMask == GROUND){
            
//            NSLog(@"WORLD> %u %u",secondBody.categoryBitMask,WORLD);
//            NSLog(@"SHAPE> %u %u",firstBody.categoryBitMask,SHAPE);
            
            firstBody.node.physicsBody.affectedByGravity = NO;
            firstBody.node.physicsBody.velocity = CGVectorMake(0, 0);
            SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5f];
            SKAction *remove = [SKAction removeFromParent];
            SKAction *block = [SKAction runBlock:^{
                if(self.qtdShapes-1<0){
                    self.qtdShapes = 0;
                }
                else{
                    self.qtdShapes-= 1;
                }
            }];
            [firstBody.node runAction:[SKAction sequence:@[fadeOut,block,remove]]];
            
            NSLog(@"removed!");
        }
        
        else if(secondBody.categoryBitMask == PADDLE){
            self.userPoints += 1;
        }
        else {
            NSLog(@"ELSE");
        }
        
    }
    
}


-(void)didEndContact:(SKPhysicsContact *)contact{
    //NSLog(@"contact!");
}



-(void)addGameOverBackScreen{
    NSLog(@"ASDASD");
    self.backNode = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.backNode.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.backNode.zPosition = 1;
    self.backNode.alpha = 0.5;
    
    [self addChild:self.backNode];
}



-(void)gameOver{
    
    [self removeAllActions];
    
    gameOverLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    gameOverLabel.text = @"Game Over";
    gameOverLabel.fontSize = 50;
    gameOverLabel.zPosition = 2;
    gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame)/2 +500);
    [gameOverLabel setFontColor:[SKColor redColor]];
    
    
    playAgainLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    playAgainLabel.text = @"Play Again";
    playAgainLabel.name = playAgainLabel.text;
    playAgainLabel.fontSize = 30;
    playAgainLabel.zPosition = 2;
    playAgainLabel.position = CGPointMake(0, -100);
    
    scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)self.userPoints];
    scoreLabel.fontSize = 20;
    scoreLabel.zPosition = 2;
    scoreLabel.position = CGPointMake(0, -200);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger bestScore = [prefs integerForKey:@"bestScore"];
    if(bestScore<self.userPoints){
        bestScore = self.userPoints;
        [prefs setInteger:self.userPoints forKey:@"bestScore"];
    }
    
    highScoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    highScoreLabel.text =[NSString stringWithFormat:@"High Score: %li", (long)bestScore];
    highScoreLabel.fontSize = 20;
    highScoreLabel.zPosition = 2;
    highScoreLabel.position = CGPointMake(0, -50);
    
    
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5f];
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.5f];
    SKAction *actionSequence = [SKAction sequence:@[fadeOut, fadeIn]];
    SKAction *repeat = [SKAction repeatActionForever:actionSequence];
    
    
    [self addChild:gameOverLabel];
//    [gameOverLabel runAction: fadeIn];
    
    [gameOverLabel addChild: playAgainLabel];
    [playAgainLabel runAction:repeat];
    
    [gameOverLabel addChild:scoreLabel];
//    [scoreLabel runAction:fadeIn];
    
    [scoreLabel addChild:highScoreLabel];
//    [highScoreLabel runAction:fadeIn];
    
    [self addGameOverBackScreen];
    
    NSLog(@"GAME OVER!");
   // [self.view setPaused:YES];
     self.isPaused = YES;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if(firstTouch){
        [waitingForTouch removeFromParent];
    }
    
    if(self.gameStarted && self.qtdShapes <=0 && !self.isPaused){
        [self gameOver];
    }
    
    self.points_hud.text = [NSString stringWithFormat:@"Score: %li", (long)self.userPoints];
    self.balls_number.text = [NSString stringWithFormat:@"Number of balls: %li", (long)self.qtdShapes];
}


@end
