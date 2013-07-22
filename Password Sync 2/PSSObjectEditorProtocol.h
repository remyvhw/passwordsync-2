//
//  PSSObjectEditorProtocol.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-22.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSSBaseGenericObject;
@protocol PSSObjectEditorProtocol <NSObject>

-(void)objectEditor:(id)editor finishedWithObject:(PSSBaseGenericObject*)genericObject;

@optional
-(void)objectEditor:(id)editor canceledOperationOnObject:(PSSBaseGenericObject*)genericObject;

@end
