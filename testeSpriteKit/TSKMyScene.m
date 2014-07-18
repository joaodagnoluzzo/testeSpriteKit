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

#pragma mark - implementation

@implementation TSKMyScene {

    SKLabelNode *waitingForTouch, *gameOverLabel, *playAgainLabel, *highScoreLabel, *scoreLabel, *play_pause, *goBackToMenu;
    
    SKSpriteNode *pausePlaceholder;
    
    int time;
    
}

#pragma mark - init

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
        waitingForTouch.text = @"Tap when Ready!";
        waitingForTouch.fontSize = 30;
        waitingForTouch.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame)-200);
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

#pragma mark - play again

-(void)playAgain{
  
   // [self removeAllActions];
    [self removeAllChildren];
   
    [self setWorldPhysics];
    
    self.userPoints = 0;
    self.qtdShapes = 0;
    
    self.gameStarted = NO;
    self.isPaused = NO;
    [play_pause setHidden:NO];
    
    [playAgainLabel removeFromParent];
    [gameOverLabel removeFromParent];
    [scoreLabel removeFromParent];
    [highScoreLabel removeFromParent];
    
    [self addEnvironment];
}


#pragma mark - add nodes

-(void)addEnvironment{
    /* Called when a touch begins */
    
    firstTouch = YES;
    
    self.paddleHeight = 20;
    self.paddleWidth = 180;
    self.userPoints = 0;
    
    
    self.points_hud = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.points_hud.text = [NSString stringWithFormat:@"Score: %li", (long)self.userPoints];
    self.points_hud.fontSize = 30;
    self.points_hud.position = CGPointMake(CGRectGetMidX(self.frame)-280, CGRectGetHeight(self.frame)-60);
    
    [self.points_hud setFontColor:[SKColor blackColor]];
    self.points_hud.zPosition = 2;
    
    [self addChild:self.points_hud];
    
    self.balls_number = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.balls_number.text = [NSString stringWithFormat:@"Number of balls: %li", (long)self.qtdShapes];
    self.balls_number.fontSize = 30;
    self.balls_number.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame)*1/3 -50);
    [self.balls_number setFontColor:[SKColor blackColor]];
    self.balls_number.zPosition = 0;
    
    [self addChild:self.balls_number];
    
    
    [self addGround];
    
    [self addPaddle];
    
    [self addSecondaryPaddle];
    
    
    play_pause = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    play_pause.name = @"Play_Pause";
    play_pause.text = @"Pause";
    play_pause.fontColor = [SKColor blackColor];
    play_pause.fontSize = 30.0f;
    play_pause.zPosition = 3;
    play_pause.position = CGPointMake(CGRectGetWidth(self.frame)-60, CGRectGetHeight(self.frame)-60);
    
    [self addChild:play_pause];
    
    pausePlaceholder = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:CGSizeMake(120, 120)];
    pausePlaceholder.name = @"Play_Pause";
    pausePlaceholder.zPosition = 2;
    
    [play_pause addChild:pausePlaceholder];
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
    
    SKAction *wait = [SKAction waitForDuration:4];
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
    
    shape.physicsBody.restitution = 1.00001; //bouncing
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

#pragma mark - contact handlers

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
                NSLog(@"%f, %f",self.mainPlaceholder.size.height, self.mainPlaceholder.size.width);
                self.mainPlaceholder.size = CGSizeMake(220, 200);
                
                
            }else if([aux.name isEqualToString:@"secondaryPaddle"] || [aux.name isEqualToString:@"secondaryPlaceholder"]){
                //            NSLog(@"Began touch on secondary paddle");
                self.isFinderOnSecondaryPaddle = YES;
                NSLog(@"%f, %f",self.secondaryPlaceholder.size.height, self.secondaryPlaceholder.size.width);
                self.secondaryPlaceholder.size = CGSizeMake(220, 200);
                
                
            }else if([aux.name isEqualToString:@"Play Again"]){
                NSLog(@"Do the Play Again action..");
                [self playAgain];
            }if([aux.name isEqual:@"Back To Menu"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoMenu"
                                                                    object:nil
                                                                  userInfo:nil];
            }if([aux.name isEqual:@"Play_Pause"]){
                if(self.isPaused){
                    [self unPause];
                    [play_pause setText:@"Pause"];
                }else{
                    [self pause];
                    [play_pause setText:@"Play"];
                }
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
                // 5 verify if the position is allowed
                if(paddleX < self.view.frame.size.width/2 + 90){
                    paddleX = self.view.frame.size.width/2 + 90;
                }
                if(paddleY > self.view.frame.size.height/2 - 20){
                    paddleY = self.view.frame.size.height/2 - 20;
                }
                
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
                // 5 verify if the position is allowed
                if(paddleX > self.view.frame.size.width/2 - 90){
                    paddleX = self.view.frame.size.width/2 - 90;
                }
                if(paddleY > self.view.frame.size.height/2 - 20){
                    paddleY = self.view.frame.size.height/2 - 20;
                }
                // 6 Update position of paddle
                paddle.position = CGPointMake(paddleX, paddleY);
            }
        }
        
    }
    

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInNode:self];
    
    NSLog(@"ended");
    
    SKNode *node = [self nodeAtPoint:currentPosition];
    if([node.name isEqualToString:@"mainPaddle"] || [node.name isEqualToString:@"mainPlaceholder"]){
        self.isFingerOnPaddle = NO;
        self.mainPlaceholder.size = CGSizeMake(180, 180);
        NSLog(@"main");
        
    }else if([node.name isEqualToString:@"secondaryPaddle"] || [node.name isEqualToString:@"secondaryPlaceholder"]){
        self.isFinderOnSecondaryPaddle = NO;
        self.secondaryPlaceholder.size = CGSizeMake(180, 180);
        NSLog(@"secondary");
        
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
           // self.userPoints += 1;
            
            
            float randomNumber = ( arc4random() % 2) -0.5;
            NSLog(@"%f", randomNumber);
            [firstBody applyAngularImpulse: randomNumber];
        }
        else {
            NSLog(@"ELSE");
        }
        
    }
    
}


-(void)didEndContact:(SKPhysicsContact *)contact{
    //NSLog(@"contact!");
}


#pragma mark - game over


-(void)addGameOverBackScreen{
//    NSLog(@"ASDASD");

    if(!self.backNode){
        self.backNode = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
        self.backNode.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        self.backNode.zPosition = 1;
        self.backNode.alpha = 0.5;
    }
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
    [play_pause setHidden:YES];
    self.isPaused = YES;
}

#pragma mark - points increment

-(void)addPoints{
    self.userPoints = self.userPoints + (1 * self.qtdShapes);
}

#pragma mark - update

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if(firstTouch){
        [waitingForTouch removeFromParent];
    }
    
    
    if(self.gameStarted){
        if(self.qtdShapes <=0 && !self.isPaused){
            [self gameOver];
        }
        
        if(time>= 60){
            time = 0;
            [self addPoints];
        }else{
            time++;
        }
    }
    
    
    self.points_hud.text = [NSString stringWithFormat:@"Score: %li", (long)self.userPoints];
    self.balls_number.text = [NSString stringWithFormat:@"Number of balls: %li", (long)self.qtdShapes];
}



#pragma mark - pause

-(void)pause{
    
    [self.scene setPaused:YES];
    self.isPaused = YES;
    [play_pause setText:@"Continue"];
    [play_pause setFontColor:[SKColor whiteColor]];
    [self addGameOverBackScreen];
    
    
    goBackToMenu = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    goBackToMenu.name = @"Back To Menu";
    goBackToMenu.text = @"Back to Menu";
    goBackToMenu.fontSize = 30.0f;
    goBackToMenu.fontColor = [SKColor whiteColor];
    goBackToMenu.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    goBackToMenu.zPosition = 2;
    
    [self addChild:goBackToMenu];
    
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
    
    [goBackToMenu addChild:scoreLabel];
    [scoreLabel addChild:highScoreLabel];
    
    
    [self.balls_number setHidden:YES];
    [self.points_hud setHidden:YES];
}



-(void)unPause{
    
    [self.scene setPaused:NO];
    self.isPaused = NO;
    [play_pause setText:@"Pause"];
    [play_pause setFontColor:[SKColor blackColor]];
    [self.backNode removeFromParent];
    [goBackToMenu removeFromParent];
    
    [scoreLabel removeFromParent];
    [highScoreLabel removeFromParent];
    
    
    [self.balls_number setHidden:NO];
    [self.points_hud setHidden:NO];
    
}


@end
