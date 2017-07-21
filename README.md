# NSString-ContainsEeachCharacter



## Install

Copy the files in `Categories` :

[NSString+ContainsEeachCharacter.h](https://github.com/ksti/NSString-ContainsEeachCharacter/blob/master/Categories/NSString%2BContainsEeachCharacter.h)

[NSString+ContainsEeachCharacter.m](https://github.com/ksti/NSString-ContainsEeachCharacter/blob/master/Categories/NSString%2BContainsEeachCharacter.m)



## Usage

\/** 

  * whether each character in `string` is contained.

  * 是否`string`里面的每个字符都有出现(被包含)

  */

\- (BOOL)containsEachCharacter:(NSString *)string;

\- (BOOL)containsEachCharacter:(NSString *)string options:(NSStringCompareOptions)options;

\- (BOOL)containsEachCharacter:(NSString *)string options:(NSStringCompareOptions)options withStringContainsOptions:(StringContains)containsOptions;

/**

 * return an array which each element is a `NSValue` of type `NSRange`(self's range of each character in `string`).

 * 返回一个数组，每个数组元素是一个`NSRange`类型的`NSValue`(`string`里每个字符出现在被判断字符串(self)中的位置)

 */

\- (NSArray<NSValue *> *)rangeArrayOfEachCharacter:(NSString *)string;

\- (NSArray<NSValue *> *)rangeArrayOfEachCharacter:(NSString *)string options:(NSStringCompareOptions)options;

## Demo

[See the demo](https://github.com/ksti/NSString-ContainsEeachCharacter/tree/master/Demo/TestUISearchController)



## License

MIT

