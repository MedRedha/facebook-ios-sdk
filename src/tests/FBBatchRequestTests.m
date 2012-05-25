/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FBBatchRequestTests.h"
#import "FBTestSession.h"
#import "FBRequestConnection.h"
#import "FBRequest.h"
#import "FBTestBlocker.h"

#if defined(FBIOSSDK_SKIP_BATCH_REQUEST_TESTS)

#pragma message ("warning: Skipping FBCommonRequestTests")

#else

@implementation FBBatchRequestTests

- (void)testBatchingTwoSearches 
{
    FBTestSession *session = [self createAndLoginTestUserWithPermissions:nil];

    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(38.889468, -77.03524);
    FBRequest *request1 = [FBRequest requestForPlacesSearchAtCoordinate:coordinate 
                                                         radiusInMeters:100 
                                                           resultsLimit:100 
                                                             searchText:@"Lincoln Memorial" 
                                                                session:session];
    FBRequest *request2 = [FBRequest requestForPlacesSearchAtCoordinate:coordinate 
                                                         radiusInMeters:100 
                                                           resultsLimit:100 
                                                             searchText:@"Washington Monument" 
                                                                session:session];

    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    __block FBTestBlocker *blocker = [[FBTestBlocker alloc] init];

    [connection addRequest:request1 
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             STAssertTrue(!error, @"!error");
             STAssertNotNil(result, @"nil result");
    }];
    [connection addRequest:request2
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             STAssertTrue(!error, @"!error");
             STAssertNotNil(result, @"nil result");

             [blocker signal];
    }];
         
    [connection start];
    [blocker wait];
    
    [connection release];
    [blocker release];
}

@end

#endif
