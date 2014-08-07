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

@interface TSKMenuScene()

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
        
        [self addChild:play];
        
        
        highScore = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
        highScore.text = [NSString stringWithFormat:@"High Score %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"bestScore"]];
        highScore.name = @"High Score";
        highScore.fontSize = self.frame.size.width * 0.0260;
        highScore.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame)-self.frame.size.width * 0.1302);
        [highScore setFontColor:[SKColor blackColor]];
        
        [self addChild:highScore];
    
        [highScore setHidden:YES];
        
        
        name = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
        name.text = @"Funny Bounce";
        name.name = @"Nome";
        name.fontSize = self.frame.size.width * 0.0781;
        name.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame)+self.frame.size.width * 0.2604);
        [self addChild:name];
        
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

@end