//
//  RVshaDigester.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-30.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVshaDigester : NSObject

-(NSData*)sha512DataDigestWithString:(NSString*)source;
/// @description Will digest a string to a NSData.
-(NSString*)base64EncodedSha512DigestWithString:(NSString*)source;
/// @description Will digest a string to a base64 representation, returned as an NSString.

@end
