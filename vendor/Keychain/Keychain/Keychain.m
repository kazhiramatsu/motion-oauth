//
//  Keychain.m
//  Keychain
//
//  Created by Kazutake Hiramatsu on 12/09/07.
//  Copyright (c) 2012年 Kazutake Hiramatsu. All rights reserved.
//

#import "Keychain.h"
#import <Security/Security.h>

@implementation HKKeychain

- (id)initWithConsumerKey:(NSString *)consumerKey
{
  if (self = [super init]) {
    self.consumerKey = consumerKey;
  }
  return self; 
}


- (void)removeOAuthTokenFromKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnAttributes,
                                          nil];
    
    // If there's a token stored for this user, delete it
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    SecItemDelete(query);
    CFRelease(query);
}

- (void)storeOAuthTokenInKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnAttributes,
                                          nil];
    
    CFTypeRef resData = NULL;
    
    // If there's a token stored for this user, delete it first
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    SecItemDelete(query);
    CFRelease(query);
    
    // Build the token dictionary
    NSMutableDictionary *tokenDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            self.token, @"oauth_token",
                                            self.tokenSecret, @"oauth_token_secret",
                                            self.screenName, @"screen_name",
                                            nil];
    
    // Add the token dictionary to the query
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:tokenDictionary]
                      forKey:(__bridge_transfer NSString *)kSecValueData];
    
    // Add the token data to the keychain
    // Even if we never use resData, replacing with NULL in the call throws EXC_BAD_ACCESS
    query = (__bridge_retained CFDictionaryRef) keychainQuery;
    SecItemAdd(query, (CFTypeRef *) &resData);
    CFRelease(query);
}

- (NSMutableDictionary *)retrieveOAuthTokenFromKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnData,
                                          kSecMatchLimitOne, kSecMatchLimit,
                                          nil];
    
    // Get the token data from the keychain
    CFTypeRef resData = NULL;
    
    // Get the token dictionary from the keychain
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    
    if (SecItemCopyMatching(query, (CFTypeRef *) &resData) == noErr)
    {
        NSData *resultData = (__bridge_transfer NSData *)resData;
        
        if (resultData)
        {
            NSMutableDictionary *tokenDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:resultData];
            
            if (tokenDictionary) {
                NSMutableDictionary *result
                    = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [tokenDictionary objectForKey:@"oauth_token"],
                       @"oauth_token",
                       [tokenDictionary objectForKey:@"oauth_token_secret"],
                       @"oauth_token_secret",
                       [tokenDictionary objectForKey:@"screen_name"],
                       @"screen_name",
                       nil];
                
                return result;
            }
        }
    }
    
    CFRelease(query);
    NSMutableDictionary *result
      = [NSMutableDictionary dictionaryWithObjectsAndKeys:
      nil,
      @"oauth_token",
      nil,
      @"oauth_token_secret",
      nil,
      @"screen_name",
      nil];

    return result;
}


@end
