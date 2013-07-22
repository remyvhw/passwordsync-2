//
//  PSSEncryptor.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSSEncryptor : NSObject

+(NSData*)decryptData:(NSData*)encryptedData;
+(NSData*)encryptData:(NSData*)dataToEncrypt;

+(NSData*)encryptString:(NSString*)stringToEncrypt;
+(NSString*)decryptString:(NSData*)encryptedData;


@end
