//
//  PSSExtentedNoteViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSDocumentBaseObject.h"

@interface PSSExtentedNoteViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) PSSDocumentBaseObject* detailItem;

@end
