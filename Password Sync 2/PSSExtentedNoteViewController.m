//
//  PSSExtentedNoteViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSExtentedNoteViewController.h"
#import "PSSDocumentVersion.h"

@interface PSSExtentedNoteViewController ()

@end

@implementation PSSExtentedNoteViewController

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
    self.title = NSLocalizedString(@"Note", nil);
    
    
    self.textView.text = [(PSSDocumentVersion*)self.detailItem.currentHardLinkedVersion decryptedNoteTextContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
