//
//  PSSGenericEditorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSObjectEditorProtocol.h"
#import "PSSTagsSelectorTableViewController.h"

@interface PSSGenericEditorTableViewController : UITableViewController <PSSTagsSelectorDelegate>

@property (strong, nonatomic) id baseObject;
@property (weak, nonatomic) id<PSSObjectEditorProtocol> editorDelegate;
@property (strong, nonatomic) UITableViewCell * tagsTableViewCell;
@property (strong, nonatomic) NSSet * itemTags;



-(void)cancelAction:(id)sender;
-(void)saveAction:(id)sender;

-(void)presentTagSelectorViewController;

@end
