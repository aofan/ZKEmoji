//
//  JRJEmojiHandler.m
//  JRJEmojiHandler
//
//  Created by lizhikai on 16/7/15.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "JRJEmojiHandler.h"
#import "JRJEmojiSet.h"

static NSString *const REGEX_EMOJI_WEB = @"&#x(\\w+)?;";
@implementation JRJEmojiHandler

#pragma mark - 表情转16进制编码
+(NSString *)convertEmojiStrToHexStr:(NSString *)emojiStr{
    
    __block NSString *tempS = [emojiStr copy];
    NSSet *emojiSet = [JRJEmojiSet sharedEmoji];
    NSRange strR = NSMakeRange(0, [emojiStr length]);
    
    [emojiStr enumerateSubstringsInRange:strR options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        
        
        NSString *str = [emojiStr substringWithRange:substringRange];
        // 两个字节拼成一个字符
        if (substringRange.length ==2 ) {
            
            int code = [self toCodePoint:str];
            tempS =[self  replacingString:tempS rstr:str emojiSet:emojiSet code:code];
            
        }else{
            int code = [str characterAtIndex:0];
            tempS = [self  replacingString:tempS rstr:str emojiSet:emojiSet code:code];
        }
    }];
    return tempS;
}

#pragma mark - 把16进制的数值加上标示传给后台
+(NSString *) replacingString : (NSString *) tempS rstr : (NSString *) str emojiSet : (NSSet *) emojiSet code : (int) code {
    
    __block NSString *temp = tempS;
    
    [emojiSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        unsigned long codeS = strtoul([obj UTF8String],0,0);
        if (code == codeS) {
            NSString *objC = [[obj substringFromIndex:2] copy];
            
            temp = [tempS stringByReplacingOccurrencesOfString:str withString:[NSString stringWithFormat:@"&#x%@;", objC]];
            *stop = YES;
        }
    }];
    return temp;
}


#pragma mark - 16进制编码转表情
+(NSString *) convertHexStrToEmojiStr:(NSString *)hexStr{
    hexStr = [self replaceHexStrToEmojiStr:hexStr];
    return hexStr;
}


#pragma mark - 获取码点对应的字符
+(NSString *)codePointToChar:(int)codePoint{
    
    if (codePoint < 0x10000) {
        return [NSString stringWithFormat:@"%C",(unichar)codePoint];
    }
    
    int cpPrime = codePoint - 0x10000;
    int high = 0xD800 | ((cpPrime >> 10) & 0x3FF);
    int low = 0xDC00 | (cpPrime & 0x3FF);
    
    NSString *str2 =  [NSString stringWithFormat:@"%C%C",(unichar)high, (unichar)low];
    return str2;
}

#pragma mark - 获取码点
+(int)toCodePoint:(NSString *)str{
    
    unichar c = [str characterAtIndex:0];
    unichar c1 = [str characterAtIndex:1];
    
    if (c > 0xD800 && c < 0xDBFF  && c1 > 0xDC00 && c1 < 0xDFFF) {
        int h = (c & 0x3FF) << 10;
        int l = c1 & 0x3FF;
        return (h | l) + 0x10000;
    }else{
        return c;
    }
    
}

#pragma mark - 把表达式转换成对应的表情
+(NSString*)replaceHexStrToEmojiStr:(NSString*)str{
    
    NSString *tempString = [str copy];
    
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_EMOJI_WEB
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:tempString options:0 range:NSMakeRange(0, [tempString length])];
    
    for (NSTextCheckingResult *result in arrayOfAllMatches) {
        NSString *tempS = [str substringWithRange:result.range];
        tempS = [tempS substringWithRange:NSMakeRange(3, tempS.length - 1 - 3)];
        tempS = [NSString stringWithFormat:@"0x%@",tempS];
        unsigned long codeS = strtoul([tempS UTF8String],0,0);
        tempS = [self codePointToChar:(int)codeS];
        
        tempString = [tempString stringByReplacingOccurrencesOfString:[str substringWithRange:result.range] withString:tempS];
    }
    return tempString;
}

@end
