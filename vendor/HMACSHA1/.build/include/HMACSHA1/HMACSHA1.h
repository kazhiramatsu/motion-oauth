//
//  HMACSHA1.h
//  HMACSHA1
//
//  Created by Kazutake Hiramatsu on 12/09/10.
//  Copyright (c) 2012年 Kazutake Hiramatsu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMACSHA1 : NSObject

+ (NSData *)digest:(NSString *)key message:(NSString *)message;
    
@end
