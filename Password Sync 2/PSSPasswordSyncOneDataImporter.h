//
//  PSSPasswordSyncOneDataImporter.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-20.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSSPasswordSyncOneDataImporter : NSObject

-(void)beginImportProcedure:(id)sender;
-(BOOL)handleImportURL:(NSURL*)importUrl;

@end
