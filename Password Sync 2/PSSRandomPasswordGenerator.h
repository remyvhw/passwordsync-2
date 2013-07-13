//
//  PSSRandomPasswordGenerator.h
//  Password Sync
//
//  Created by Remy on 11-05-28.
//  Copyright 2011 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSSRandomPasswordGenerator : NSObject {
    
}

-(NSString*)generateShortLetterNumberAndSpecialCharRandomPassword;
-(NSString*)generateShortLetterNumberCharRandomPassword;
-(NSString*)generateComplexPasswordUsingPunctuation:(BOOL)usePunctuation;
-(NSString*)generateRandomPassword;

@end
