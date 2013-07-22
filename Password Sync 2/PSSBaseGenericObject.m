//
//  PSSBaseGenericObject.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSBaseGenericObject.h"
#import "PSSBaseGenericObject.h"
#import "PSSBaseObjectVersion.h"
#import "PSSObjectCategory.h"
#import "PSSObjectDecorativeImage.h"
#import "PSSObjectTag.h"


@implementation PSSBaseGenericObject
@synthesize decorativeImageForDevice = _decorativeImageForDevice;

@dynamic created;
@dynamic displayName;
@dynamic category;
@dynamic children;
@dynamic decorativeImages;
@dynamic parent;
@dynamic tags;
@dynamic versions;


-(NSString*)viewportIdentifierForCurrentDevice{
    
    CGRect mainScreenRect = [[UIScreen mainScreen] bounds];
    // We'll just create a string of format @"320x568"
    NSString *identifyerString = [NSString stringWithFormat:@"%gx%g", mainScreenRect.size.width, mainScreenRect.size.height];
    return identifyerString;
}


-(PSSObjectDecorativeImage*)decorativeImageObjectForDevice{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PSSObjectDecorativeImage"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(encryptedObject == %@) AND (viewportIdentifier == %@)", self, [self viewportIdentifierForCurrentDevice]];

    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError * error;
    NSArray * results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error || [results count] == 0) {
        return nil;
    }
    
    PSSObjectDecorativeImage * decorativeImageObject = [results objectAtIndex:0];
    return decorativeImageObject;
}

-(UIImage*)decorativeImageForDevice{
    
    if (_decorativeImageForDevice) {
        return _decorativeImageForDevice;
    }
    
    PSSObjectDecorativeImage * decorativeImageObject = [self decorativeImageObjectForDevice];
    
    
    UIImage * decorativeImage = [UIImage imageWithData:decorativeImageObject.data];
    _decorativeImageForDevice = decorativeImage;
    
    return decorativeImage;
}

-(void)setDecorativeImageForDevice:(UIImage *)decorativeImageForDevice{
    
    // Will set a decorative image for the current device height and width (ex: iPhone 4 or iPhone 5 form factor). We don't really care about the screen scale: since these images will be heavily blurred and just showned in the background of views, we'll just scale up or down our images in a UIImageView.
    
    // First, delete any other previous images for the same device
    PSSObjectDecorativeImage *newManagedObject;
    if (self.decorativeImageForDevice) {
        newManagedObject = [self decorativeImageObjectForDevice];
    } else {
        newManagedObject = (PSSObjectDecorativeImage*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSObjectDecorativeImage" inManagedObjectContext:self.managedObjectContext];
    }
    
    
    
    newManagedObject.timestamp = [NSDate date];
    newManagedObject.viewportIdentifier = [self viewportIdentifierForCurrentDevice];
    newManagedObject.encryptedObject = self;
    newManagedObject.data = UIImagePNGRepresentation(decorativeImageForDevice);
    
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
}


@end
