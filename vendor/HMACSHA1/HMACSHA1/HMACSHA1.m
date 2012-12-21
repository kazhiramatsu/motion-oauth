//
//  HMACSHA1.m
//  HMACSHA1
//
//  Created by Kazutake Hiramatsu on 12/09/10.
//  Copyright (c) 2012年 Kazutake Hiramatsu. All rights reserved.
//

#import "HMACSHA1.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation HMACSHA1


+ (NSData *)digest:(NSString *)key message:(NSString *)message {

    const char *ckey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cdata = [message cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char macOut[CC_SHA1_DIGEST_LENGTH];
    
	  CCHmacContext ctx;
    CCHmacInit(&ctx, kCCHmacAlgSHA1, ckey, strlen(ckey));
	  CCHmacUpdate(&ctx, cdata, strlen(cdata));
	  CCHmacFinal(&ctx, macOut);
	  NSData *digestData = [NSData dataWithBytes:macOut length:CC_SHA1_DIGEST_LENGTH];
    return digestData;
 
}

@end
