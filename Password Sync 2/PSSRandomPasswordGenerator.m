//
//  PSSRandomPasswordGenerator.m
//  Password Sync
//
//  Created by Remy on 11-05-28.
//  Copyright 2011 Pumax. All rights reserved.
//

#import "PSSRandomPasswordGenerator.h"
#define ALPHA_LC        @"aeiouyaeiouyabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
#define ALPHA_UC        [ALPHA_LC uppercaseString]
#define NUMBERS         @"01234567890123456789"
#define PUNCTUATION     @"_,!@#$%.&*+=?/:;"

@interface PSSRandomPasswordGenerator ()

@property (strong, nonatomic) NSArray * dictionaryOfWords;

@end

@implementation PSSRandomPasswordGenerator


-(NSString * )generateShortLetterNumberAndSpecialCharRandomPassword{
    
    NSString *selectedSet = [NSString stringWithFormat:@"%@%@%@%@", ALPHA_LC, ALPHA_UC, NUMBERS, PUNCTUATION]; // We build a long string of possible characters
    
    NSString *result = @""; // Initialize the results string  
    NSRange range; 
    range.length = 1;
    
    int targetLength = 12;
    
    int randomizer = arc4random() % 5; // We randomize if we use random() or arc4random(), just for fun
    
    int i;  
    for (i = 0; i < targetLength; i++)  
    {  
        if (randomizer <3 ) {
            range.location = arc4random() % [selectedSet length];
        } else {
            range.location = random() % [selectedSet length];
        }
        result = [result stringByAppendingString:[selectedSet substringWithRange:range]];  
    }  
    
    return result;
}

-(NSString * )generateShortLetterNumberCharRandomPassword{
    
    NSString *selectedSet = [NSString stringWithFormat:@"%@%@%@", ALPHA_LC, ALPHA_UC, NUMBERS]; // We build a long string of possible characters
    
    NSString *result = @""; // Initialize the results string  
    NSRange range; 
    range.length = 1;
    
    int targetLength = 14;
    
    int randomizer = arc4random() % 5; // We randomize if we use random() or arc4random(), just for fun
    
    int i;  
    for (i = 0; i < targetLength; i++)  
    {  
        if (randomizer <3 ) {
            range.location = arc4random() % [selectedSet length];
        } else {
            range.location = random() % [selectedSet length];
        }
        result = [result stringByAppendingString:[selectedSet substringWithRange:range]];  
    }  
    
    return result;
}

-(NSString*)generateComplexPasswordUsingPunctuation:(BOOL)usePunctuation{
    
    NSArray *wordsArray;
    if (self.dictionaryOfWords) {
        wordsArray = self.dictionaryOfWords;
    } else {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"15Dict_en" ofType:@"plist"];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        
        NSArray * cumulatedWordsArray = [dict objectForKey:@"Root"];
        
        
        self.dictionaryOfWords = [[NSArray alloc]initWithArray:(NSArray *)cumulatedWordsArray];
        wordsArray = self.dictionaryOfWords;
    }
    
    
    
    NSMutableString * newPassword = [[NSMutableString alloc] init];
    
    
    int i=0;
    int numberOfGeneratedWords;
    if (usePunctuation) {
        numberOfGeneratedWords = 4;
    } else {
        numberOfGeneratedWords = 2;
    }
    
    
    while (i<numberOfGeneratedWords) {
        
        NSUInteger randomIndex = arc4random() % [wordsArray count];
        
        NSString * randomString;
        if (usePunctuation) {
            randomString = [wordsArray objectAtIndex:randomIndex];
        } else {
            // When user does not use punctuation, we capitalize first letters
            NSString * randomUncapitalizedString = [wordsArray objectAtIndex:randomIndex];
            
            if (i==0) {
                // One time out of 5, the first word is not capitalized, to remind us of Apple coding style and add a bit of fun entropy
                
                NSUInteger randomCapitalizeFirstLetterOrNot = arc4random() % 5;
                if (randomCapitalizeFirstLetterOrNot == 2) {
                    randomString = randomUncapitalizedString;
                } else {
                    randomString = [randomUncapitalizedString capitalizedString];
                }
                
            } else {
                randomString = [randomUncapitalizedString capitalizedString];
            }
            
        }
        
        
        
        
        
        if (i==(numberOfGeneratedWords-1) && !usePunctuation) {
            // One time every 10 passwords, the last word is replaced by a random 4 digits number if the user settings permit it
            
            NSUInteger lastDigitsRandomSwitch = arc4random() % 10;
            
            if (lastDigitsRandomSwitch == 5) {
                NSUInteger lastDigitsRandomNumber = arc4random() % 9999;
                
                [newPassword appendString:[NSString stringWithFormat:@"%lu", (unsigned long)lastDigitsRandomNumber]];
                
            } else {
                [newPassword appendString:randomString];
            }
            
        } else {
            [newPassword appendString:randomString];
        }
        
        
        
        
        
        if (i!=(numberOfGeneratedWords-1) && usePunctuation) {
            // One out of 50 times, we'll add a comma or other character.  The rest of the time,
            // we simply insert a space.
            
            NSUInteger trailingDotRandomNumber = arc4random() % 50;
            
            if (trailingDotRandomNumber == 20 || trailingDotRandomNumber == 22) {
                [newPassword appendString:@", "];
            } else if (trailingDotRandomNumber == 23){
                [newPassword appendString:@": "];
            } else {
                // Normal case scenario, we just add a space
                [newPassword appendString:@" "];
            }
            
            
            
        } else if (usePunctuation) {
            // One out of 25 times, we'll add a trailing dot, exclamation point or question mark
            
            NSUInteger trailingDotRandomNumber = arc4random() % 25;
            
            if (trailingDotRandomNumber == 20) {
                [newPassword appendString:@"."];
            } else if (trailingDotRandomNumber == 21){
                [newPassword appendString:@"!"];
            } else if (trailingDotRandomNumber == 22){
                [newPassword appendString:@"?"];
            }
            
        }
        
        i++;
    }
    
    // We append 4 digits at the end of a non punctuated password
    if (!usePunctuation) {
        NSUInteger lastDigitsRandomNumber = arc4random() % 9999;
        [newPassword appendString:[NSString stringWithFormat:@"%lu", (unsigned long)lastDigitsRandomNumber]];
        
    }
    
    return newPassword;
}


-(NSString*)generateRandomPassword{
    return [self generateShortLetterNumberCharRandomPassword];
}

@end
