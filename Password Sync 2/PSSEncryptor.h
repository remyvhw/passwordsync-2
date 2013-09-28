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

/*! Will reencrypt provided data with provided hashed password. Can be useful for changing master password.
 * \param originalData Data currently encrypted with master password in keychain.
 * \param newPassword A hashed password that will be used to encrypt the provided password.
 * \returns Data encrypted with the provided password.
 */
+(NSData*)reencryptData:(NSData*)originalData withPassword:(NSString*)newPassword;


@end
