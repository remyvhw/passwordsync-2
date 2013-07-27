//
//  PSSGenericEditorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSObjectEditorProtocol.h"

@interface PSSGenericEditorTableViewController : UITableViewController

@property (strong, nonatomic) id baseObject;
@property (weak, nonatomic) id<PSSObjectEditorProtocol> editorDelegate;

-(void)cancelAction:(id)sender;
-(void)saveAction:(id)sender;

@end
