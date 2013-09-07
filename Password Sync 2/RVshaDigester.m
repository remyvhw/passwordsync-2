//
//  RVshaDigester.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-30.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "RVshaDigester.h"
#import <CommonCrypto/CommonDigest.h>
#import "Base64.h"

@implementation RVshaDigester

-(NSData*)sha512DataDigestWithString:(NSString*)source{
    const char *s = [source cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA512_DIGEST_LENGTH] = {0};
    
    CC_SHA512(keyData.bytes, keyData.length, digest);
    
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];

    return out;
}

-(NSString*)base64EncodedSha512DigestWithString:(NSString *)source{
    
    NSData * sha512data = [self sha512DataDigestWithString:source];
    
    // Use the Base64 NSData category to encode the content in Bas64
    return [sha512data base64EncodedString];
    
    
}


@end
