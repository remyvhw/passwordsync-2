//
//  PSSAppDelegate.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import iAd;

@class PSSBaseGenericObject;
@interface PSSAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) CLLocationManager * locationManager;

@property BOOL isUnlocked;

@property (nonatomic) BOOL shouldPresentAds;
@property (nonatomic) BOOL shouldAllowUnlimitedFeatures;
/**
 * Should user be able to use a New button or Import new data into the app.
 */
@property (nonatomic, readonly) BOOL shouldAllowNewData;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(void)presentUnlockPromptAnimated:(BOOL)animated;

-(void)openBaseObjectDetailView:(PSSBaseGenericObject*)baseObject;
-(BOOL)handleFileURL:(NSURL*)url;

-(void)triggerInterstitialAd;
- (void)prepareInterstitialAd;

@end
