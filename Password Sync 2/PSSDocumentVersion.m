//
//  PSSNoteVersion.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSDocumentVersion.h"


@implementation PSSDocumentVersion

@dynamic noteTextContent;
@dynamic displayName;
@synthesize decryptedNoteTextContent = _decryptedNoteTextContent;

-(NSString*)decryptedNoteTextContent{
    
    if (_decryptedNoteTextContent) {
        return _decryptedNoteTextContent;
    }
    
    NSString * decryptedNoteTextContent = [self decryptDataToUTF8String:self.noteTextContent];
    
    _decryptedNoteTextContent = decryptedNoteTextContent;
    return _decryptedNoteTextContent;
}

-(void)setDecryptedNoteTextContent:(NSString *)decryptedNoteTextContent{
    _decryptedNoteTextContent = decryptedNoteTextContent;
    self.noteTextContent = [self encryptedDataFromUTF8String:decryptedNoteTextContent];
}

-(void)reencryptAllContainedObjectsWithPasswordHash:(NSString *)newPasswordHash{
    [super reencryptAllContainedObjectsWithPasswordHash:newPasswordHash];
    
    self.noteTextContent = [self reencryptData:self.noteTextContent withPassword:newPasswordHash];
    
}

@end
