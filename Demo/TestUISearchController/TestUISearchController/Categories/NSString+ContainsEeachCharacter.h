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

/** 
  * whether each character in `string` is contained.
  * 是否`string`里面的每个字符都有出现(被包含)
  */
- (BOOL)containsEachCharacter:(NSString *)string;
- (BOOL)containsEachCharacter:(NSString *)string options:(NSStringCompareOptions)options;
- (BOOL)containsEachCharacter:(NSString *)string options:(NSStringCompareOptions)options withStringContainsOptions:(StringContains)containsOptions;
/**
 * return an array which each element is a `NSValue` of type `NSRange`(self's range of each character in `string`).
 * 返回一个数组，每个数组元素是一个`NSRange`类型的`NSValue`(`string`里每个字符出现在被判断字符串(self)中的位置)
 */
- (NSArray<NSValue *> *)rangeArrayOfEachCharacter:(NSString *)string;
- (NSArray<NSValue *> *)rangeArrayOfEachCharacter:(NSString *)string options:(NSStringCompareOptions)options;

@end
