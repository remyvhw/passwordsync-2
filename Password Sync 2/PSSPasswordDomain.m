//
//  PSSPasswordDomain.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-13.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordDomain.h"
#import "PSSPasswordBaseObject.h"


@implementation PSSPasswordDomain

@dynamic hostname;
@dynamic timestamp;
@dynamic original_url;
@dynamic passwords;

-(NSString*)cleanUpHostname:(NSString *)dirtyHost{
    // We don't want user to use artibrary URLs as hosts so we can regroup them easily.
    // We'll only keep the host name of a domain name. For example, @"http://example.com/private/index.php?page=login&language=en" will become @"example.com". We'll store the long original url in the original_url variable.
    
    NSURL * urlFromDirtyHost = [NSURL URLWithString:dirtyHost];
    
    NSString * completeHost = [urlFromDirtyHost host];
    
    // We'll remove any www. if any from the host
    NSString * cleanedupHost = [completeHost stringByReplacingOccurrencesOfString:@"www." withString:@""];
    
    return cleanedupHost;
}

@end
