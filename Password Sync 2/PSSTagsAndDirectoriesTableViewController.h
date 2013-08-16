//
//  PSSTagsAndDirectoriesTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSTagsAndDirectoriesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    
    NSString        *savedSearchTerm_;
    NSInteger       savedScopeButtonIndex_;
    BOOL            searchWasActive_;
    BOOL            userDrivenDataModelChange;
}

@property (nonatomic, strong) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;


@end
