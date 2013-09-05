//
//  PSSTwoStepCodeViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-09-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSBaseGenericObject.h"
#import "PSSTwoStepEditorTableViewController.h"

@interface PSSTwoStepCodeViewController : UIViewController <PSSTwoStepEditorProtocol>

@property (nonatomic, retain) PSSBaseGenericObject * detailItem;

@end
