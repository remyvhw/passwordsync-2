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



@implementation PSSBaseObjectVersion

@dynamic additionalJSONfields;
@dynamic timestamp;
@dynamic attachments;
@dynamic encryptedObject;


-(NSString*)decryptDataToUTF8String:(NSData*)encryptedString{
    return [NSString stringWithCString:[[PSSEncryptor decryptData:encryptedString] bytes] encoding:NSUTF8StringEncoding];
}



@end
