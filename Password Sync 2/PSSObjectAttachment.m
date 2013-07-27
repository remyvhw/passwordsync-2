//
//  PSSObjectAttachment.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSObjectAttachment.h"
#import "PSSBaseObjectVersion.h"
#import "PSSObjectDecorativeImage.h"
#import "PSSEncryptor.h"
#import "PSSAppDelegate.h"

@implementation PSSObjectAttachment

@dynamic binaryContent;
@dynamic name;
@dynamic encryptedObjectVersions;
@dynamic thumbnail;
@dynamic timestamp;
@dynamic fileExtension;

@synthesize decryptedBinaryContent = _decryptedBinaryContent;



-(void)setDecryptedBinaryContent:(NSData *)decryptedBinaryContent{
    _decryptedBinaryContent = decryptedBinaryContent;
    
    self.binaryContent = [PSSEncryptor encryptData:decryptedBinaryContent];
}


-(NSData*)decryptedBinaryContent{
    if (_decryptedBinaryContent) {
        return _decryptedBinaryContent;
    }
    
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.isUnlocked) {
        return nil;
    }
    
    
    NSData * decryptedData = [PSSEncryptor decryptData:self.binaryContent];
    _decryptedBinaryContent = decryptedData;
    
    return _decryptedBinaryContent;
    
}





@end
