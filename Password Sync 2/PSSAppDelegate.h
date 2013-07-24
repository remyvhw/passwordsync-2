//
//  PSSAppDelegate.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface PSSAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) CLLocationManager * locationManager;

@property BOOL isUnlocked;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(void)presentUnlockPromptAnimated:(BOOL)animated;

@end
