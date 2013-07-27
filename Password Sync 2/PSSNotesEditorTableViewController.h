//
//  PSSNotesEditorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericEditorTableViewController.h"
#import "PSSNoteBaseObject.h"
#import "MAImagePickerController.h"

@interface PSSNotesEditorTableViewController : PSSGenericEditorTableViewController <MAImagePickerControllerDelegate>

@property (strong, nonatomic) PSSNoteBaseObject * baseObject;

@end
