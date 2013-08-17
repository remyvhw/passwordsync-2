//
//  PSSTagsSelectorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-16.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSBaseGenericObject.h"

@protocol PSSTagsSelectorDelegate;


@interface PSSTagsSelectorTableViewController : UITableViewController<NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    
    NSString        *savedSearchTerm_;
    NSInteger       savedScopeButtonIndex_;
    BOOL            searchWasActive_;
    BOOL            userDrivenDataModelChange;
}

@property (nonatomic, strong) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@property (nonatomic) BOOL editionMode;

@property (nonatomic, strong) PSSBaseGenericObject *detailItem;

@property (nonatomic, strong) NSMutableSet * selectionSet;

@property (weak, nonatomic) id<PSSTagsSelectorDelegate> tagsSelectorDelegate;

@end

@protocol PSSTagsSelectorDelegate <NSObject>

-(void)tagsSelector:(PSSTagsSelectorTableViewController*)tagsSelector didFinishWithSelection:(NSSet*)selectionSet;

@end