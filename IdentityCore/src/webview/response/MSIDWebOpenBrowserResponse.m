//------------------------------------------------------------------------------
//
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
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------
#import "MSIDWebOpenBrowserResponse.h"
#import "MSIDWebResponseOperationFactory.h"
#import "MSIDWebOpenBrowserResponseOperation.h"
#import "MSIDWebResponseOperationConstants.h"
#import "MSIDWebOpenBrowserAdditionalParameters.h"
#import "NSDictionary+MSIDQueryItems.h"

@implementation MSIDWebOpenBrowserResponse

+ (void)load
{
    [MSIDWebResponseOperationFactory registerOperationClass:MSIDWebOpenBrowserResponseOperation.class forResponseClass:self];
}

- (instancetype)initWithURL:(NSURL *)url
                    context:(id<MSIDRequestContext>)context
                      error:(NSError **)error
{
    NSString *scheme = url.scheme;
    
    if (!([scheme isEqualToString:@"browser"]))
    {
        if (error)
        {
            *error = MSIDCreateError(MSIDOAuthErrorDomain,
                                     MSIDErrorServerInvalidResponse,
                                     @"Browser response should have browser:// as a scheme",
                                     nil, nil, nil, context.correlationId, nil, NO);
        }
        return nil;
    }
    
    self = [super initWithURL:url context:context error:error];
    if (self)
    {
        _browserURL = [self addAdditionalQueryParameters:[url.absoluteString stringByReplacingOccurrencesOfString:@"browser://"
                                                                                                       withString:@"https://"]];
    }
    
    return self;
}

+ (NSString *)operation
{
    return MSID_OPEN_BROSWER_OPERATION;
}

- (NSURL *)addAdditionalQueryParameters:(NSString *)url
{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url];
    MSIDWebOpenBrowserAdditionalParameters *additionalParameters = [MSIDWebOpenBrowserAdditionalParameters sharedInstance];

    if ([additionalParameters.queryParameters count] > 0)
    {
	    NSMutableArray *queryItems = [[urlComponents queryItems] mutableCopy];
        [queryItems addObjectsFromArray:[additionalParameters.queryParameters msidQueryItems]];
        urlComponents.queryItems = queryItems;
    }

    return [urlComponents URL];
}

@end
