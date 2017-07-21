//
//  NSString+ContainsEeachCharacter.h
//  eForp
//
//  Created by GJS on 2017/7/20.
//
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, StringContains) {           //二进制值    十进制
    StringContainsNormal                      = 0,         //0000 0000  0
    StringContainsLiteralRepeatSensitive      = 1 << 0,    //0000 0001  1
    StringContainsOrderSensitive              = 1 << 1     //0000 0010  2
};

@interface NSString (ContainsEeachCharacter)

- (BOOL)containsEachCharacter:(NSString *)string;
- (NSArray *)rangeArrayOfEachCharacter:(NSString *)string options:(NSStringCompareOptions)options;
- (NSArray *)rangeArrayOfEachCharacter:(NSString *)string;

@end
