//
//  PSSBaseObjectVersion.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSBaseObjectVersion.h"
#import "PSSBaseGenericObject.h"
#import "PSSObjectAttachment.h"
#import "PSSEncryptor.h"
#import "PSSAppDelegate.h"


@implementation PSSBaseObjectVersion

@dynamic additionalJSONfields;
@dynamic timestamp;
@dynamic attachments;
@dynamic encryptedObject;


-(NSString*)decryptDataToUTF8String:(NSData*)encryptedString{
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isUnlocked) {
        return @"••••••••••";
    }
    
    NSData * decryptedData = [PSSEncryptor decryptData:encryptedString];
    if (!decryptedData || ![decryptedData bytes]) {
        return @"";
    }
    
    return [NSString stringWithCString:[decryptedData bytes] encoding:NSUTF8StringEncoding];
}

-(NSData*)encryptedDataFromUTF8String:(NSString*)string{
    
    return [PSSEncryptor encryptData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}


@end
