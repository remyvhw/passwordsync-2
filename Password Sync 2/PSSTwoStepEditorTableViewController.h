//
//  PSSTwoStepEditorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-09-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSBarcodeScannerViewController.h"

@protocol PSSTwoStepEditorProtocol;

@interface PSSTwoStepEditorTableViewController : UITableViewController <PSSBarcodeScannerDelegate>

@property (nonatomic, strong) NSString * username;
@property (nonatomic, weak) id<PSSTwoStepEditorProtocol> editorDelegate;

@end

@protocol PSSTwoStepEditorProtocol <NSObject>

-(void)twoStepEditor:(PSSTwoStepEditorTableViewController*)editor finishedWithValues:(NSDictionary*)values;

@end