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

@synthesize decryptedAdditionalJSONfields = _decryptedAdditionalJSONfields;

@dynamic additionalJSONfields;
@dynamic timestamp;
@dynamic attachments;
@dynamic encryptedObject;
@dynamic currentOwningBaseObject;


-(NSString*)decryptDataToUTF8String:(NSData*)encryptedString{
    if (!APP_DELEGATE.isUnlocked) {
        return NSLocalizedString(@"Locked", nil);
    }
    
    NSData * decryptedData = [PSSEncryptor decryptData:encryptedString];
    if (!decryptedData) {
        return @"";
    }
    
    NSString * decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}

-(NSData*)encryptedDataFromUTF8String:(NSString*)string{
    
    return [PSSEncryptor encryptString:string];
}


-(NSData*)reencryptData:(NSData *)data withPassword:(NSString *)password{
    
    return [PSSEncryptor reencryptData:data withPassword:password];
}


-(NSData*)decryptedAdditionalJSONfields{
    if (_decryptedAdditionalJSONfields) {
        return _decryptedAdditionalJSONfields;
    }
    
    if (!self.additionalJSONfields) {
        return nil;
    }
    
    
    NSData * decryptedData = [PSSEncryptor decryptData:self.additionalJSONfields];
    
    _decryptedAdditionalJSONfields = decryptedData;
    
    return _decryptedAdditionalJSONfields;
}

-(void)setDecryptedAdditionalJSONfields:(NSData *)decryptedAdditionalJSONfields{
    _decryptedAdditionalJSONfields = decryptedAdditionalJSONfields;
    
    self.additionalJSONfields = [PSSEncryptor encryptData:decryptedAdditionalJSONfields];
}


-(void)reencryptAllContainedObjectsWithPasswordHash:(NSString *)newPasswordHash{
    
    self.additionalJSONfields = [self reencryptData:self.additionalJSONfields withPassword:newPasswordHash];
    
    // Will be subclassed
}

@end
