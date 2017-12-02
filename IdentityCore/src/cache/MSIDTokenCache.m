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

#import "MSIDTokenCache.h"
#import "MSIDToken.h"
#import "MSIDTokenCacheKey.h"
#import "MSIDTokenCacheDataSource.h"

@implementation MSIDTokenCache
{
    id<MSIDTokenCacheDataSource> _dataSource;
}

- (id)initWithDataSource:(id<MSIDTokenCacheDataSource>)dataSource
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    _dataSource = dataSource;
    return self;
}

- (id<MSIDTokenCacheDataSource>)dataSource
{
    return _dataSource;
}


- (BOOL)saveMsalAT:(MSIDToken *)token
            forKey:(MSIDTokenCacheKey *)key
             error:(NSError **)error
{
    return NO;
}

- (BOOL)saveAdalToken:(MSIDToken *)token
               forKey:(MSIDTokenCacheKey *)key
                error:(NSError **)error
{
    return NO;
}

- (MSIDToken *)getAdalAT:(NSString *)userId
                resource:(NSString *)resource
                clientId:(NSString *)clientId
                   error:(NSError **)error
{
    return nil;
}

- (MSIDToken *)getMsalAT:(NSString *)userId
                  scopes:(NSSet<NSString *> *)scopes
                clientId:(NSString *)clientId
                   error:(NSError **)error
{
    return nil;
}

- (MSIDToken *)getFRT:(NSString *)userId
             familyId:(NSString *)familyId
                error:(NSError **)error
{
    return nil;
}

- (MSIDToken *)getAdfsUserToken:(NSString *)resource
                       clientId:(NSString *)clientId
                          error:(NSError **)error
{
    return nil;
}

- (NSArray<MSIDToken *> *)getRTs:(NSString *)clientId
                          error:(NSError **)error
{
    return nil;
}

@end
