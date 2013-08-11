//
//  PSSVersionFlowPasswordCollectionViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSVersionFlowPasswordCollectionViewController.h"
#import "PSSPasswordVersion.h"
#import "PSSAppDelegate.h"

@interface PSSVersionFlowPasswordCollectionViewController ()

@end

@implementation PSSVersionFlowPasswordCollectionViewController


-(void)restoreVersionForCell:(PSSVersionGenericCollectionViewCell *)cell{

    NSInteger indexOfCell = [self.collectionView indexPathForCell:cell].row;

    PSSPasswordVersion * versionToRestore = [self.orderedVersions objectAtIndex:indexOfCell];
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    PSSPasswordVersion *newManagedObject = (PSSPasswordVersion*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSPasswordVersion" inManagedObjectContext:context];
        
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    
    newManagedObject.displayName = versionToRestore.displayName;
    newManagedObject.encryptedObject = versionToRestore.encryptedObject;
    newManagedObject.username = versionToRestore.username;
    newManagedObject.password = versionToRestore.password;
    newManagedObject.notes = versionToRestore.notes;
    newManagedObject.attachments = versionToRestore.attachments;
    newManagedObject.additionalJSONfields = versionToRestore.additionalJSONfields;
    
    self.detailItem.displayName = newManagedObject.displayName;
    self.detailItem.currentHardLinkedVersion = newManagedObject;
    
    [newManagedObject.managedObjectContext save:NULL];
    
    // Perform animation on cell
    
    [UIView animateWithDuration:0.2 animations:^{
        cell.transform = CGAffineTransformScale(cell.transform, 3., 3.);
        
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}


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
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PSSVersionPasswordCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"passwordVersionCell"];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource



-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PSSVersionGenericCollectionViewCell * cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"passwordVersionCell" forIndexPath:indexPath];
    
    PSSPasswordVersion * passwordVersion = [self.orderedVersions objectAtIndex:indexPath.row];
    
    cell.dateLabel.text = [self.dateFormatter stringFromDate:passwordVersion.timestamp];
    
    cell.titleLabel.text = passwordVersion.displayName;
    
    [cell.infoButton addTarget:self action:@selector(showBacksideViewByPressingButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * usernameCell = (UILabel*)[cell viewWithTag:5];
    UILabel * passwordCell = (UILabel*)[cell viewWithTag:7];
    UILabel * notesCell = (UILabel*)[cell viewWithTag:9];
    
    usernameCell.textColor = [UIColor lightGrayColor];
    passwordCell.textColor = [UIColor lightGrayColor];
    notesCell.textColor = [UIColor lightGrayColor];
    
    usernameCell.text = NSLocalizedString(@"Decrypting...", nil);
    passwordCell.text = NSLocalizedString(@"Decrypting...", nil);
    notesCell.text = NSLocalizedString(@"Decrypting...", nil);
    
    dispatch_async(self.backgroundQueue, ^(void) {
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            NSString * decryptedUsername = [passwordVersion decryptedUsername];
            NSString * decryptedPassword = [passwordVersion decryptedPassword];
            NSString * decryptedNotes = [passwordVersion decryptedNotes];
            
            [UIView animateWithDuration:0.1 animations:^{
                
                usernameCell.alpha = 0;
                passwordCell.alpha = 0;
                notesCell.alpha = 0;
                
            } completion:^(BOOL finished) {
                usernameCell.textColor = [UIColor blackColor];
                passwordCell.textColor = [UIColor blackColor];
                
                usernameCell.text = decryptedUsername;
                passwordCell.text = decryptedPassword;
                
                if (decryptedNotes && ![decryptedNotes isEqualToString:@""]) {
                    notesCell.textColor = [UIColor blackColor];
                    notesCell.text = decryptedNotes;
                } else {
                    notesCell.textColor = [UIColor lightGrayColor];
                    notesCell.text = NSLocalizedString(@"No Notes", nil);
                }
                
                [UIView animateWithDuration:0.1 animations:^{
                    
                    usernameCell.alpha = 1;
                    passwordCell.alpha = 1;
                    notesCell.alpha = 1;
                    
                }];
                
            }];
            
            
        });
        
    });
    
    
    if (passwordVersion == [self.orderedVersions lastObject]) {
        cell.currentVersion = YES;
    } else {
        cell.currentVersion = NO;
    }
    
    
    
    return cell;
}


@end
