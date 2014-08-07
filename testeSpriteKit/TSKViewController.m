//
//  TSKViewController.m
//  testeSpriteKit
//
//  Created by João Pedro Cappelletto D'Agnoluzzo on 3/17/14.
//  Copyright (c) 2014 João Pedro Cappelletto D'Agnoluzzo. All rights reserved.
//

#import "TSKViewController.h"
#import "TSKMenuScene.h"


@interface TSKViewController()

@property (nonatomic) BOOL gameCenterEnabled;
@property (nonatomic, strong) NSString *leaderboardIdentifier;
@property NSMutableDictionary *achievementsDescDictionary;

@end

@implementation TSKViewController



-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self authenticateLocalPlayer];
    [self addScoreAndAchievementsObserversForNotifications];
}

- (void)viewWillLayoutSubviews
{
    
    [super viewWillLayoutSubviews];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //iPaskView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    //skView.showsPhysics = YES;
    
    // Create and configure the scene.
    
    
    
    SKScene *scene = [TSKMenuScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    if ( !skView.scene ) { // <------- !!
        
        // Present the scene.
        [skView presentScene:scene];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(presentMenu)
                                                     name:@"gotoMenu"
                                                   object:nil];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)presentMenu{
    
    
    SKView *skView = (SKView *)self.view;
    
    SKScene *menuScene = [TSKMenuScene sceneWithSize:skView.bounds.size];
    menuScene.scaleMode = SKSceneScaleModeAspectFill;
    
    [skView presentScene:menuScene];
    
}

-(void)gameKit{
    NSLog(@"Funcionou!");
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


-(void)addScoreAndAchievementsObserversForNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportScore) name:@"reportScore" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstTimePlayed) name:@"firstTimePlaying" object:nil];

}



#pragma mark - gamekit

-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                    
                    if([GKLocalPlayer localPlayer].isAuthenticated){
                        [self retrieveAchievmentMetadata];         //Here is the new code
                    }
                }];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}

-(void)reportScore{
    if(self.gameCenterEnabled){
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
        score.value = [[NSUserDefaults standardUserDefaults]integerForKey:@"bestScore"];
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}


-(void)firstTimePlayed{
    
    if(self.gameCenterEnabled){
        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:@"firstTimePlaying"];
        
        [achievement setPercentComplete:100.0];
        
        [achievement setShowsCompletionBanner:YES];
        
        NSLog(@"FirstTime!");
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
            if(error != nil){
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
        
        //[self showLeaderboard:self.leaderboardIdentifier];
        
        
    }
}

- (void) retrieveAchievmentMetadata
{
    self.achievementsDescDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:
     ^(NSArray *descriptions, NSError *error) {
         if (error != nil) {
             NSLog(@"Error %@", error);
             
         } else {
             if (descriptions != nil){
                 for (GKAchievementDescription* a in descriptions) {
                     [self.achievementsDescDictionary setObject: a forKey: a.identifier];
                     [a loadImageWithCompletionHandler:^(UIImage *image, NSError *error) {
                         if (error != nil) {
                             NSLog(@"Não carreguei a imagem!");
                         }
                         NSLog(@"%f",image.size.height);
                     }];
                     
                 }
             }
         }
     }];
    
}

- (void) showLeaderboard: (NSString*) leaderboardID
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
        [self presentViewController: gameCenterController animated: YES completion:nil];
    }
}

#pragma mark - GKGameCenterControllerDelegate method implementation

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
