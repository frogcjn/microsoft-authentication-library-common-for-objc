// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <XCTest/XCTest.h>
#import "MSIDKeychainTokenCache.h"
#import "MSIDKeychainUtil.h"
#import "MSIDToken.h"
#import "MSIDTokenCacheKey.h"
#import "MSIDKeyedArchiverSerializer.h"
#import "MSIDKeychainTokenCache+MSIDTestsUtil.h"

@interface MSIDKeychainTokenCacheIntegrationTests : XCTestCase

@end

@implementation MSIDKeychainTokenCacheIntegrationTests

- (void)setUp
{
    [super setUp];
    
    [MSIDKeychainTokenCache reset];
    
    MSIDKeychainTokenCache.defaultKeychainGroup = @"com.microsoft.adalcache";
}

- (void)tearDown
{
    [super tearDown];
    
    [MSIDKeychainTokenCache reset];
}

- (void)test_whenSetDefaultKeychainGroup_shouldReturnProperGroup
{
    MSIDKeychainTokenCache.defaultKeychainGroup = @"my.group";
    
    XCTAssertEqualObjects(MSIDKeychainTokenCache.defaultKeychainGroup, @"my.group");
}

#pragma mark - MSIDTokenCacheDataSource

- (void)test_whenSetItemWithValidParameters_shouldReturnTrue
{    
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    MSIDToken *token = [MSIDToken new];
    [token setValue:@"some token" forKey:@"token"];
    MSIDTokenCacheKey *key = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"test_service"];
    MSIDKeyedArchiverSerializer *keyedArchiverSerializer = [MSIDKeyedArchiverSerializer new];
    
    BOOL result = [keychainTokenCache setItem:token key:key serializer:keyedArchiverSerializer context:nil error:nil];
    
    XCTAssertTrue(result);
}

- (void)test_whenSetItem_shouldGetSameItem
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    MSIDToken *token = [MSIDToken new];
    [token setValue:@"some token" forKey:@"token"];
    MSIDTokenCacheKey *key = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"test_service"];
    MSIDKeyedArchiverSerializer *keyedArchiverSerializer = [MSIDKeyedArchiverSerializer new];
    
    [keychainTokenCache setItem:token key:key serializer:keyedArchiverSerializer context:nil error:nil];
    MSIDToken *token2 = [keychainTokenCache itemWithKey:key serializer:keyedArchiverSerializer context:nil error:nil];
    
    XCTAssertEqualObjects(token, token2);
}

- (void)testSetItem_whenKeysAccountIsNil_shouldReturnFalseAndError
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    MSIDToken *token = [MSIDToken new];
    MSIDTokenCacheKey *key = [[MSIDTokenCacheKey alloc] initWithAccount:nil service:@"test_service"];
    MSIDKeyedArchiverSerializer *keyedArchiverSerializer = [MSIDKeyedArchiverSerializer new];
    NSError *error;
    
    BOOL result = [keychainTokenCache setItem:token key:key serializer:keyedArchiverSerializer context:nil error:&error];
    
    XCTAssertFalse(result);
    XCTAssertNotNil(error);
}

- (void)testSetItem_whenKeysServiceIsNil_shouldReturnFalseAndError
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    MSIDToken *token = [MSIDToken new];
    MSIDTokenCacheKey *key = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:nil];
    MSIDKeyedArchiverSerializer *keyedArchiverSerializer = [MSIDKeyedArchiverSerializer new];
    NSError *error;
    
    BOOL result = [keychainTokenCache setItem:token key:key serializer:keyedArchiverSerializer context:nil error:&error];
    
    XCTAssertFalse(result);
    XCTAssertNotNil(error);
}

- (void)testSetItem_whenItemAlreadyExistInKeychain_shouldUpdateIt
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    MSIDToken *token = [MSIDToken new];
    [token setValue:@"some token" forKey:@"token"];
    MSIDToken *token2 = [MSIDToken new];
    [token2 setValue:@"some token2" forKey:@"token"];
    MSIDTokenCacheKey *key = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"test_service"];
    MSIDKeyedArchiverSerializer *keyedArchiverSerializer = [MSIDKeyedArchiverSerializer new];
    
    [keychainTokenCache setItem:token key:key serializer:keyedArchiverSerializer context:nil error:nil];
    [keychainTokenCache setItem:token2 key:key serializer:keyedArchiverSerializer context:nil error:nil];
    MSIDToken *tokenResult = [keychainTokenCache itemWithKey:key serializer:keyedArchiverSerializer context:nil error:nil];
    
    XCTAssertEqualObjects(tokenResult, token2);
}

- (void)testItemsWithyKey_whenKeyIsQuery_shouldReturnProperItems
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    MSIDKeyedArchiverSerializer *keyedArchiverSerializer = [MSIDKeyedArchiverSerializer new];
    // Item 1.
    MSIDToken *token1 = [MSIDToken new];
    MSIDTokenCacheKey *key1 = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"item1"];
    [keychainTokenCache setItem:token1 key:key1 serializer:keyedArchiverSerializer context:nil error:nil];
    // Item 2.
    MSIDToken *token2 = [MSIDToken new];
    MSIDTokenCacheKey *key2 = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"item2"];
    [keychainTokenCache setItem:token2 key:key2 serializer:keyedArchiverSerializer context:nil error:nil];
    // Item 3.
    MSIDToken *token3 = [MSIDToken new];
    MSIDTokenCacheKey *key3 = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account2" service:@"item3"];
    [keychainTokenCache setItem:token3 key:key3 serializer:keyedArchiverSerializer context:nil error:nil];
    MSIDTokenCacheKey *queryKey = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:nil];
    NSError *error;
    
    NSArray<MSIDToken *> *items = [keychainTokenCache itemsWithKey:queryKey serializer:keyedArchiverSerializer context:nil error:&error];
    
    XCTAssertEqual(items.count, 2);
    
    XCTAssertTrue([items containsObject:token1]);
    XCTAssertTrue([items containsObject:token2]);
    XCTAssertNil(error);
}

- (void)testRemoveItemWithKey_whenKeyIsValid_shouldRemoveItem
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    MSIDToken *token = [MSIDToken new];
    [token setValue:@"some token" forKey:@"token"];
    MSIDTokenCacheKey *key = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"test_service"];
    MSIDKeyedArchiverSerializer *keyedArchiverSerializer = [MSIDKeyedArchiverSerializer new];
    [keychainTokenCache setItem:token key:key serializer:keyedArchiverSerializer context:nil error:nil];
    NSError *error;
    
    [keychainTokenCache removeItemsWithKey:key context:nil error:&error];
    
    NSArray<MSIDToken *> *items = [keychainTokenCache itemsWithKey:[MSIDTokenCacheKey new] serializer:keyedArchiverSerializer context:nil error:nil];
    XCTAssertEqual(items.count, 0);
    XCTAssertNil(error);
}

- (void)testRemoveItemWithKey_whenKeyIsNil_shouldRemoveAllItems
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    MSIDKeyedArchiverSerializer *keyedArchiverSerializer = [MSIDKeyedArchiverSerializer new];
    // Item 1.
    MSIDToken *token1 = [MSIDToken new];
    MSIDTokenCacheKey *key1 = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"item1"];
    [keychainTokenCache setItem:token1 key:key1 serializer:keyedArchiverSerializer context:nil error:nil];
    // Item 2.
    MSIDToken *token2 = [MSIDToken new];
    MSIDTokenCacheKey *key2 = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"item2"];
    [keychainTokenCache setItem:token2 key:key2 serializer:keyedArchiverSerializer context:nil error:nil];
    // Item 3.
    MSIDToken *token3 = [MSIDToken new];
    MSIDTokenCacheKey *key3 = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account2" service:@"item3"];
    [keychainTokenCache setItem:token3 key:key3 serializer:keyedArchiverSerializer context:nil error:nil];
    NSError *error;
    
    BOOL result = [keychainTokenCache removeItemsWithKey:nil context:nil error:&error];
    NSArray<MSIDToken *> *items = [keychainTokenCache itemsWithKey:nil serializer:keyedArchiverSerializer context:nil error:nil];
    
    XCTAssertTrue(result);
    XCTAssertEqual(items.count, 0);
    XCTAssertNil(error);
}

- (void)testSaveWipeInfo_shouldReturnTrueAndNilError
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    NSError *error;
    
    BOOL result = [keychainTokenCache saveWipeInfoWithContext:nil error:&error];
    
    XCTAssertTrue(result);
    XCTAssertNil(error);
}

- (void)test_whenSaveWipeInfo_shouldReturnSameWipeInfoOnGet
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    NSDictionary *expectedWipeInfo = @{@"key2": @"value2"};
    NSError *error;
    
    [keychainTokenCache saveWipeInfo:expectedWipeInfo context:nil error:nil];
    NSDictionary *resultWipeInfo = [keychainTokenCache wipeInfo:nil error:&error];
    
    XCTAssertEqualObjects(resultWipeInfo, expectedWipeInfo);
    XCTAssertNil(error);
}

- (void)testItemsWithKey_whenFindsTombstoneItems_shouldSkipThem
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    MSIDKeyedArchiverSerializer *keyedArchiverSerializer = [MSIDKeyedArchiverSerializer new];
    // Item 1.
    MSIDToken *token1 = [MSIDToken new];
    [token1 setValue:@"<tombstone>" forKey:@"token"];
    [token1 setValue:[[NSNumber alloc] initWithInt:MSIDTokenTypeRefreshToken] forKey:@"tokenType"];
    MSIDTokenCacheKey *key1 = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"item1"];
    [keychainTokenCache setItem:token1 key:key1 serializer:keyedArchiverSerializer context:nil error:nil];
    // Item 2.
    MSIDToken *token2 = [MSIDToken new];
    MSIDTokenCacheKey *key2 = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"item2"];
    [keychainTokenCache setItem:token2 key:key2 serializer:keyedArchiverSerializer context:nil error:nil];
    // Item 3.
    MSIDToken *token3 = [MSIDToken new];
    MSIDTokenCacheKey *key3 = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"item3"];
    [keychainTokenCache setItem:token3 key:key3 serializer:keyedArchiverSerializer context:nil error:nil];
    NSError *error;
    
    NSArray<MSIDToken *> *items = [keychainTokenCache itemsWithKey:nil serializer:keyedArchiverSerializer context:nil error:nil];
    
    XCTAssertEqual(items.count, 2);
    XCTAssertNil(error);
}

- (void)testItemsWithKey_whenFindsTombstoneItems_shouldDeleteThemFromKeychain
{
    MSIDKeychainTokenCache *keychainTokenCache = [MSIDKeychainTokenCache new];
    MSIDKeyedArchiverSerializer *keyedArchiverSerializer = [MSIDKeyedArchiverSerializer new];
    MSIDToken *token1 = [MSIDToken new];
    [token1 setValue:@"<tombstone>" forKey:@"token"];
    [token1 setValue:[[NSNumber alloc] initWithInt:MSIDTokenTypeRefreshToken] forKey:@"tokenType"];
    MSIDTokenCacheKey *key1 = [[MSIDTokenCacheKey alloc] initWithAccount:@"test_account" service:@"item1"];
    [keychainTokenCache setItem:token1 key:key1 serializer:keyedArchiverSerializer context:nil error:nil];
    
    [keychainTokenCache itemsWithKey:nil serializer:keyedArchiverSerializer context:nil error:nil];
    
    NSMutableDictionary *query = [@{(id)kSecClass : (id)kSecClassGenericPassword} mutableCopy];
    [query setObject:@YES forKey:(id)kSecReturnData];
    [query setObject:@YES forKey:(id)kSecReturnAttributes];
    [query setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit];
    [query setObject:@"item1" forKey:(id)kSecAttrService];
    [query setObject:@"test_account" forKey:(id)kSecAttrAccount];
    CFTypeRef cfItems = nil;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, &cfItems);

    XCTAssertEqual(status, errSecItemNotFound);
}

@end
