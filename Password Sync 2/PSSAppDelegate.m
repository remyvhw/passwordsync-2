//
//  PSSAppDelegate.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSAppDelegate.h"
#import "MKiCloudSync.h"
#import "PSSPasswordListViewController.h"
#import "PDKeychainBindings.h"
#import "PSSUnlockPromptViewController.h"
#import "TSMessage.h"
#import "PSSLocationBaseObject.h"
#import "PSSPasswordBaseObject.h"
#import "PSSDocumentBaseObject.h"
#import "PSSCreditCardBaseObject.h"

#import "PSSLocationDetailViewController.h"
#import "PSSLocationsSplitViewDetailViewController.h"
#import "PSSPasswordSplitViewDetailViewController.h"
#import "PSSPasswordDetailViewController.h"
#import "PSSPasswordSyncOneDataImporter.h"
#import "PSSDocumentsSplitViewDetailViewController.h"
#import "PSSDocumentDetailCollectionViewController.h"

#import "TestFlight.h"

@interface PSSAppDelegate ()

@property (strong, nonatomic) PSSLocationBaseObject *awaitingBaseObject;

@end

@implementation PSSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

-(void)openBaseObjectDetailView:(PSSBaseGenericObject*)baseObject{
    
    if ([baseObject isKindOfClass:[PSSLocationBaseObject class]]) {
        [self openLocationDetailView:(PSSLocationBaseObject*)baseObject];
    } else if ([baseObject isKindOfClass:[PSSPasswordBaseObject class]]){
        [self openPasswordDetailView:(PSSPasswordBaseObject*)baseObject];
    } else if ([baseObject isKindOfClass:[PSSDocumentBaseObject class]]){
        [self openDocumentDetailView:(PSSDocumentBaseObject*)baseObject];
    }
    
    
}

- (NSManagedObject *)objectWithURI:(NSURL *)uri
{
    NSManagedObjectID *objectID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
    
    if (!objectID)
    {
        return nil;
    }
    
    NSManagedObject *objectForID = [self.managedObjectContext objectWithID:objectID];
    if (![objectForID isFault])
    {
        return objectForID;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[objectID entity]];
    

    NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression: [NSExpression expressionForEvaluatedObject] rightExpression: [NSExpression expressionForConstantValue:objectForID] modifier:NSDirectPredicateModifier type:NSEqualToPredicateOperatorType options:0];
    [request setPredicate:predicate];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ([results count] > 0 )
    {
        return [results objectAtIndex:0];
    }
    
    return nil;
}

-(void)openDocumentDetailView:(PSSDocumentBaseObject*)documentObject {
    
    UITabBarController * tabBarController = (UITabBarController*)self.window.rootViewController;
    
    // Documents are at index 0
    [tabBarController setSelectedIndex:3];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        UISplitViewController * splitViewForLocations = (UISplitViewController*)tabBarController.selectedViewController;
        
        PSSDocumentsSplitViewDetailViewController * navController = [splitViewForLocations.viewControllers lastObject];
        [navController presentViewControllerForDocumentEntity:documentObject];
        
    } else {
        UINavigationController * navController = (UINavigationController*)tabBarController.selectedViewController;
        
        PSSDocumentDetailCollectionViewController * detailViewController = (PSSDocumentDetailCollectionViewController*)[navController.storyboard instantiateViewControllerWithIdentifier:@"PSSDocumentDetailCollectionViewController"];
        detailViewController.detailItem = documentObject;
        
        [navController pushViewController:detailViewController animated:YES];
        
    }
    
}

-(void)openPasswordDetailView:(PSSPasswordBaseObject*)passwordObject {
    
    UITabBarController * tabBarController = (UITabBarController*)self.window.rootViewController;
    
    // Passwords are at index 0
    [tabBarController setSelectedIndex:0];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        UISplitViewController * splitViewForLocations = (UISplitViewController*)tabBarController.selectedViewController;
        
        PSSPasswordSplitViewDetailViewController * navController = [splitViewForLocations.viewControllers lastObject];
        [navController presentViewControllerForPasswordEntity:passwordObject];
        
    } else {
        UINavigationController * navController = (UINavigationController*)tabBarController.selectedViewController;
        
        PSSPasswordDetailViewController * detailViewController = (PSSPasswordDetailViewController*)[navController.storyboard instantiateViewControllerWithIdentifier:@"PSSPasswordDetailViewController"];
        detailViewController.detailItem = passwordObject;
        
        [navController pushViewController:detailViewController animated:YES];
        
    }
    
}


-(void)openLocationDetailView:(PSSLocationBaseObject*)locationObject {
    
    UITabBarController * tabBarController = (UITabBarController*)self.window.rootViewController;
    
    // Location is at index 2
    [tabBarController setSelectedIndex:2];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        UISplitViewController * splitViewForLocations = (UISplitViewController*)tabBarController.selectedViewController;
        
        PSSLocationsSplitViewDetailViewController * navController = [splitViewForLocations.viewControllers lastObject];
        [navController presentViewControllerForLocationEntity:locationObject];
        
    } else {
        

        UINavigationController * navController = (UINavigationController*)tabBarController.selectedViewController;
        
        PSSLocationDetailViewController * detailViewController = (PSSLocationDetailViewController*)[navController.storyboard instantiateViewControllerWithIdentifier:@"locationDetailViewController"];
        detailViewController.detailItem = locationObject;
        
        
        [navController pushViewController:detailViewController animated:NO];

    }
    
}

-(PSSLocationBaseObject *)findLocationObjectForRegion:(CLRegion*)region{
    
    
    NSString * regionIdentifier = region.identifier;
    NSURL * regionObjectURI = [NSURL URLWithString:regionIdentifier];
    
    
    PSSLocationBaseObject * locationObject = (PSSLocationBaseObject*)[self objectWithURI:regionObjectURI];
    return locationObject;
}

-(void)presentLocalNotificationForLocation:(PSSLocationBaseObject*)locationObject{
    
    NSString * identifierString = [[[locationObject objectID] URIRepresentation] absoluteString];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.fireDate = [NSDate date];
    localNotification.repeatInterval = 0;
    localNotification.alertBody = [NSString stringWithFormat:@"%@ %@", locationObject.displayName, NSLocalizedString(@"is nearby.", nil)];
    localNotification.userInfo = @{@"locationObjectIDURI" : identifierString};
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

-(void)presentActiveNotificationForLocation:(PSSLocationBaseObject*)locationObject{
    
    NSString * locationMessage = [NSString stringWithFormat:@"%@ %@", locationObject.displayName, NSLocalizedString(@"is nearby.", nil)];
    
    [TSMessage showNotificationInViewController:self.window.rootViewController withTitle:NSLocalizedString(@"Location Alert", nil) withMessage:locationMessage withType:TSMessageNotificationTypeMessage withDuration:TSMessageNotificationDurationEndless withCallback:NULL withButtonTitle:NSLocalizedString(@"Open", nil) withButtonCallback:^{
        [self openLocationDetailView:locationObject];
    } atPosition:TSMessageNotificationPositionBottom canBeDismisedByUser:YES];
    
    self.awaitingBaseObject = nil;
}


-(void)presentUnlockPromptAnimated:(BOOL)animated{
    
    
    // Make sure we're not in a modal view.
    if (self.window.rootViewController.isViewLoaded && self.window.rootViewController.view.window) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"UnlockPrompt" bundle:nil];
        PSSUnlockPromptViewController *promptController = [sb instantiateInitialViewController];
        
        
        [self.window.rootViewController presentViewController:[promptController promptForPasscodeBlockingView:YES completion:^{
            [self setIsUnlocked:YES];
            
            if (self.awaitingBaseObject) {
                [self presentActiveNotificationForLocation:self.awaitingBaseObject];
            }
            
            
        } cancelation:nil] animated:animated completion:^{
            
        }];

    }
    
    
    
    
    
    
}

-(void)checkForJailbreaks{
    
    
    NSURL* url = [NSURL URLWithString:@"cydia://package/com.example.package"];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        
        // iOS Device might be jailbroken. We'll alert the user (in english, we assume jailbreakers understand english and we won't pay to translate this).
        
        NSString * alertString = @"It appears your device is jailbroken. This is not the usual piracy yada yada: Password Sync relies on the OS' keychain to encrypt securely your data. YOUR DATA MIGHT NOT BE SAFE on a jailbroken device, as accessing the keychain through unofficial paths (and therefore retrieving the encryption key that locks the app's database) is possible.\nThe jailbreak should not prevent Password Sync to run normally. However, as a precaution, be extra-caraful about not losing your device and be extremely cautious about what third party non sandboxed software you install. Good luck!";
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Jailbreak Warning" message:alertString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    
    
}
-(void)instanciateLocationManager{
    CLLocationManager * locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager = locationManager;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{

    UIApplicationState state = [application applicationState];
    if (state != UIApplicationStateActive) {
        
        
        NSString * absoluteURI = [[notification userInfo] objectForKey:@"locationObjectIDURI"];
        NSURL * uriForID = [NSURL URLWithString:absoluteURI];
        NSManagedObject * locationObject = [self objectWithURI:uriForID];
        
        [self openLocationDetailView:(PSSLocationBaseObject*)locationObject];
        
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"1015eec8-43ae-46ec-9727-09a056b8ee95"];
    
    // Start iCloud synchronization of NSUserDefaults
    [MKiCloudSync start];
    
    
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // We received a location notification.
        NSString * absoluteURI = [[locationNotification userInfo] objectForKey:@"locationObjectIDURI"];
        NSURL * uriForID = [NSURL URLWithString:absoluteURI];
        NSManagedObject * locationObject = [self objectWithURI:uriForID];
        
        [self openLocationDetailView:(PSSLocationBaseObject*)locationObject];
        
    }
    
    ///////DEBUG 
    if (0) {
        
        PDKeychainBindings * keychainBindings = [PDKeychainBindings sharedKeychainBindings];
        [keychainBindings removeObjectForKey:PSSHashedMasterPasswordKeychainEntry];
        [keychainBindings removeObjectForKey:PSSHashedPasscodeCodeKeychainEntry];
        [keychainBindings removeObjectForKey:PSSDefinedPasscodeType];
        [keychainBindings removeObjectForKey:PSSlastLocalMasterPasswordChange];
        [keychainBindings removeObjectForKey:PSSFailedPasscodeAttempsCount];
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:PSSApplicationWasConfiguredOnAnotherDeviceDefaults];
        [userDefaults removeObjectForKey:PSSMasterPasswordHintTextString];
        [userDefaults removeObjectForKey:PSSMasterPasswordVerificationHash];
        [userDefaults removeObjectForKey:PSSUserAlreadyPrintedMasterPassword];
        [userDefaults removeObjectForKey:PSSlastGlobalMasterPasswordChange];
        

    }


    
    
    
    
    [self instanciateLocationManager];
    
    // Override point for customization after application launch.
    
    [self.window setTintColor:[UIColor colorWithRed:46./255.0 green:144./255.0 blue:90./255.0 alpha:1.0]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    UITabBarController * tabBarController = (UITabBarController *)self.window.rootViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UISplitViewController *splitViewController = (UISplitViewController *)[[tabBarController viewControllers] objectAtIndex:0];
        
        UINavigationController *navigationController = [splitViewController.viewControllers firstObject];
        
        PSSPasswordListViewController *controller = (PSSPasswordListViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
    } else {
        
        
        UINavigationController *navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:0];
        PSSPasswordListViewController *controller = (PSSPasswordListViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        
    }
    
    [self checkForJailbreaks];
    
    
    
    

    
    
    
    return YES;
}
							



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    self.isUnlocked = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:PSSGlobalLockNotification object:self];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Check for a master password on file
    
    /* Present next run loop. Prevents "unbalanced VC display" warnings. */
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        PDKeychainBindings * keychainBindings = [PDKeychainBindings sharedKeychainBindings];
        
        NSString * hashedMasterPassword = [keychainBindings stringForKey:PSSHashedMasterPasswordKeychainEntry];
        
        NSString * hashedPasscode = [keychainBindings stringForKey:PSSHashedPasscodeCodeKeychainEntry];
        
        
        if (!hashedMasterPassword || !hashedPasscode) {
            // Launch the welcome screen
            UIStoryboard * sb;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                sb = [UIStoryboard storyboardWithName:@"FirstLaunchStoryboard_iPad" bundle:[NSBundle mainBundle]];
            } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                sb = [UIStoryboard storyboardWithName:@"FirstLaunchStoryboard_iPhone" bundle:[NSBundle mainBundle]];
            }
            
            
            UINavigationController *vc = [sb instantiateInitialViewController];
            
            [self.window.rootViewController presentViewController:vc animated:YES completion:^{
                
            }];
            
            
            
        } else {
            
            
            NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
            
            if ([[standardUserDefaults objectForKey:PSSUserSettingsPromptForPasscodeAtEveryLaunch] boolValue]) {
                [self presentUnlockPromptAnimated:YES];
            }
            
            
            
            
        }
    });
    
    

    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    if ([[url scheme] isEqualToString:@"passsynctwojsonimport"] && [sourceApplication isEqualToString:@"com.pumaxprod.Password-Sync"]) {
        
        PSSPasswordSyncOneDataImporter * dataImporter = [[PSSPasswordSyncOneDataImporter alloc] init];
        
        return [dataImporter handleImportURL:url];
        
    }
    
    return NO;
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Password_Sync_2" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Password_Sync_2.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    //notification subscriptions, put these after you instantiate the instance of NSPersistentStoreCoordinator your app is going to use.
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
           selector:@selector(storesWillChange:)
               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
             object:_persistentStoreCoordinator];
    
    [defaultCenter addObserver:self
           selector:@selector(storesDidChange:)
               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
             object:_persistentStoreCoordinator];
    
    [defaultCenter addObserver:self
           selector:@selector(persistentStoreDidImportUbiquitiousContentChanges:)
               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object:_persistentStoreCoordinator];
    
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    PSSLocationBaseObject * locationObject = [self findLocationObjectForRegion:region];
    
    [self presentLocalNotificationForLocation:locationObject];
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        // We'll show an alert since the app is currently running
        
        [self presentActiveNotificationForLocation:locationObject];
        
    } else {
        
        // Send a local notification to the user
        [self presentLocalNotificationForLocation:locationObject];
        self.awaitingBaseObject = locationObject;
        
    }
    
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    self.awaitingBaseObject = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@", [error localizedDescription]);
}


#pragma mark - iCloud Support
/**
 Use these options in your call to -addPersistentStore:
 */
- (NSDictionary*) iCloudPersistentStoreOptions{
    NSDictionary *options = @{ NSPersistentStoreUbiquitousContentNameKey : @"com~pumaxprod~Password-Sync-2" };
    return options;
}

/**
 Subscribe to NSPersistentStoreDidImportUbiquitousContentChangesNotification
 */
- (void)persistentStoreDidImportUbiquitiousContentChanges:(NSNotification*)changeNotification{
    NSManagedObjectContext *moc = [self managedObjectContext];
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:changeNotification];
    }];
}

/**
 Subscribe to NSPersistentStoreCoordinatorStoresWillChangeNotification
 */
- (void)storesWillChange:(NSNotification *)n {
    NSManagedObjectContext *moc = [self managedObjectContext];
    [moc performBlockAndWait:^{
        NSError *error = nil;
        if ([moc hasChanges]) {
            [moc save:&error];
        }
        
        [moc reset];
    }];
    
    //reset user interface
}

/**
 Subscribe to NSPersistentStoreCoordinatorStoresDidChangeNotification
 */
- (void)storesDidChange:(NSNotification *)n {
    //refresh user interface
}





@end
