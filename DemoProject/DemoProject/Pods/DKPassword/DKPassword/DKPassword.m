//
//  DKPassword.m
//  DKPassword
//
//  Created by Dmitry Kurilo on 1/19/14.
//  Copyright (c) 2014 Kurilo Dmitry. All rights reserved.
//

#import "DKPassword.h"

@implementation DKPassword

-(int)countLetterCharset:(NSCharacterSet*)set {
    int count = 0;
    for (int i = 0; i < [_pass length]; i++) {
        if ([set characterIsMember:[_pass characterAtIndex:i]]) {
            count++;
        }
    }
    return count;
}

-(int)symbolsCount {
    return [self countLetterCharset:[NSCharacterSet characterSetWithCharactersInString:@")!@#$%^&*()"]];
}

-(int)numbersCount {
    return [self countLetterCharset:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
}

-(int)uppercaseCount {
    return [self countLetterCharset:[NSCharacterSet uppercaseLetterCharacterSet]];
}

-(int)lowcaseCount {
    return [self countLetterCharset:[NSCharacterSet lowercaseLetterCharacterSet]];
}

-(int)lettersCount {
    return [self countLetterCharset:[NSCharacterSet letterCharacterSet]];
}

-(BOOL)numbersOnly {
    return [self numbersCount] == _pass.length;
}

-(BOOL)lettersOnly {
    return [self lettersCount] == _pass.length;
}


#pragma mark deductions

-(unsigned long)lettersOnlyScore {
    return [self lettersOnly] ? [self lettersCount] : 0;
}

-(unsigned long)numbersOnlyScore {
    return [self numbersOnly] ? [self numbersCount] : 0;
}

#pragma mark additions

-(unsigned long)numberOfCharactersScore {
    return _pass.length*4;
}

-(unsigned long)lowercaseLetterScore {
    return ([self uppercaseCount] > 0 && [self lowcaseCount]) > 0 ? (_pass.length-[self lowcaseCount])*2 : 0 ;
}

-(unsigned long)uppercaseLetterScore {
    return ([self uppercaseCount] > 0 && [self lowcaseCount]) > 0 ? (_pass.length-[self uppercaseCount])*2 : 0;
}

-(unsigned long)numbersScore {
    return [self numbersOnly] ? 0 : [self numbersCount]*4;
}

-(unsigned long)symbolsScore {
    return [self symbolsCount]*6;
}

#pragma mark counting

-(int)additions {
    int count = 0;
    count += [self numberOfCharactersScore] + [self uppercaseLetterScore] + [self lowercaseLetterScore] + [self numbersScore];
    return count;
}

-(int)deductions {
    int count = 0;
    count += [self numbersOnlyScore] + [self lettersOnlyScore];
    return count;
}

-(int)mark {
    int mark = [self additions]-[self deductions];
    return mark > 100 ? 100 : mark;
}

#pragma mark public

+(int)passwordStrength:(NSString*)password {
    DKPassword *i = [DKPassword new];
    i.pass = password;
    return [i mark];
}

@end
