//
//  PSSNotesDetailCollectionViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailCollectionViewController.h"

@class PSSNoteBaseObject;
@interface PSSNotesDetailCollectionViewController : PSSGenericDetailCollectionViewController

@property (nonatomic, strong) PSSNoteBaseObject * detailItem;

@end
