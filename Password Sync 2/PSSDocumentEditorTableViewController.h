//
//  PSSNotesEditorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericEditorTableViewController.h"
#import "PSSDocumentBaseObject.h"
#import "MAImagePickerController.h"

@interface PSSDocumentEditorTableViewController : PSSGenericEditorTableViewController <MAImagePickerControllerDelegate>

@property (strong, nonatomic) PSSDocumentBaseObject * baseObject;

-(id)initWithDocumentURL:(NSURL*)documentURL;

@end
