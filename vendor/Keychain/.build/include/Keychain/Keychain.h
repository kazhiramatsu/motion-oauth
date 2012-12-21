//
//  Keychain.h
//  Keychain
//
//  Created by Kazutake Hiramatsu on 12/09/07.
//  Copyright (c) 2012年 Kazutake Hiramatsu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKKeychain : NSObject

@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *tokenSecret;
@property (nonatomic, copy) NSString *screenName;

- (id)initWithConsumerKey:(NSString *)consumerKey;
- (void)removeOAuthTokenFromKeychain;
- (void)storeOAuthTokenInKeychain;
- (NSMutableDictionary *)retrieveOAuthTokenFromKeychain;

@end
