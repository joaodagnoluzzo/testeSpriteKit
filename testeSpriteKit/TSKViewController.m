//
//  TSKViewController.m
//  testeSpriteKit
//
//  Created by João Pedro Cappelletto D'Agnoluzzo on 3/17/14.
//  Copyright (c) 2014 João Pedro Cappelletto D'Agnoluzzo. All rights reserved.
//

#import "TSKViewController.h"
#import "TSKMenuScene.h"

@implementation TSKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    //skView.showsPhysics = YES;
    
    // Create and configure the scene.
    SKScene * scene = [TSKMenuScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    
    if ( !skView.scene ) { // <------- !!
        
        SKScene *menuScene = [TSKMenuScene sceneWithSize:skView.bounds.size];
        menuScene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(presentMenu)
                                                     name:@"gotoMenu"
                                                   object:nil];
    }
    
}



-(void)presentMenu{
    
    
    SKView *skView = (SKView *)self.view;
    
    SKScene *menuScene = [TSKMenuScene sceneWithSize:skView.bounds.size];
    menuScene.scaleMode = SKSceneScaleModeAspectFill;
    
    [skView presentScene:menuScene];
    
}



- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
