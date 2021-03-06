//
//  PSSNotesDetailCollectionViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailCollectionViewController.h"
@import QuickLook;

@class PSSDocumentBaseObject;
@interface PSSNotesDetailCollectionViewController : PSSGenericDetailCollectionViewController <QLPreviewControllerDataSource>

@property (nonatomic, strong) PSSDocumentBaseObject * detailItem;

@end
