//
//  PSSFaviconFetcher.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-13.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSSPasswordBaseObject;

@interface PSSFaviconFetcher : NSObject

-(void)backgroundFetchFaviconForBasePassword:(PSSPasswordBaseObject*)basePassword;

@end
