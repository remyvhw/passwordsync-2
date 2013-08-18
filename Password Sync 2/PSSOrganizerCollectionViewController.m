//
//  PSSOrganizerCollectionViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-17.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSOrganizerCollectionViewController.h"
#import "PSSUnlockPromptViewController.h"
#import "PSSTagsAndDirectoriesTableViewController.h"

@interface PSSOrganizerCollectionViewController ()

@property (nonatomic) BOOL passcodeUnlockedForSettingsSegue;

@end

@implementation PSSOrganizerCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UINavigationController * masterNavController = [self.splitViewController.viewControllers firstObject];
        PSSTagsAndDirectoriesTableViewController * mainViewController = (PSSTagsAndDirectoriesTableViewController*)[masterNavController.viewControllers firstObject];
        
        
        if ([mainViewController respondsToSelector:@selector(deselectAllRowsAnimated:)]) {
            [mainViewController deselectAllRowsAnimated:YES];
        }
        
    }
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"presentSettingsPopoverSegue"]) {
        
        if (self.passcodeUnlockedForSettingsSegue) {
            return YES;
        } else {
            
            UIStoryboard * unlockStoryboard = [UIStoryboard storyboardWithName:@"UnlockPrompt" bundle:[NSBundle mainBundle]];
            PSSUnlockPromptViewController * unlockController = (PSSUnlockPromptViewController*)[unlockStoryboard instantiateInitialViewController];
            
            [self.navigationController presentViewController:[unlockController promptForPasscodeBlockingView:NO completion:^{
                
                double delayInSeconds = 0.1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    self.passcodeUnlockedForSettingsSegue = YES;
                    [self performSegueWithIdentifier:@"presentSettingsPopoverSegue" sender:self.navigationItem.rightBarButtonItem];
                });
                
                
                
            } cancelation:^{
                
            }] animated:YES completion:^{
                
            }];
            return NO;
        }
        
    }
    
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    if ([[segue identifier] isEqualToString:@"presentSettingsPopoverSegue"]) {
        self.passcodeUnlockedForSettingsSegue = NO;
    }
    
}



@end
