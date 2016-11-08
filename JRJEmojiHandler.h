//
//  JRJEmojiHandler.h
//  JRJEmojiHandler
//
//  Created by lizhikai on 16/7/15.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRJEmojiHandler : NSObject

/**
 *  把含有表情的字符串 表情转成16进制编码
 *
 *  @param emojiStr 表情字符串 ： 😄
 *
 *  @return 16进制编码  ： &#x1F5E3;
 */
+(NSString *) convertEmojiStrToHexStr : (NSString *) emojiStr;


/**
 *  把16进制编码转成表情
 *
 *  @param hexStr 16进制编码  ： &#x1F5E3;
 *
 *  @return 表情字符串 ： 😄
 */
+(NSString *) convertHexStrToEmojiStr : (NSString *) hexStr;

@end
