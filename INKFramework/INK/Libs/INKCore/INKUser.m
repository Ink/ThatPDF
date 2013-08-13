//
//  INKUser.m
//  InkCore
//
//  Created by Jonathan Uy on 6/4/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "INKUser.h"

@implementation INKUser

@synthesize InkId, email, apps;


+ (id)user
{
    NSString *testuser = @"InkTestUser";
    return testuser;
}
+ (id)user:(NSString *)email
{
    NSString *testuser = @"InkTestUser";
    return testuser;
}
+ (id)user:(NSString *)email apps:(NSArray *)apps
{
    NSString *testuser = @"InkTestUser";
    return testuser;
}
+ (id)fetch:(NSString *)id
{
    NSString *testuser = @"InkTestUser";
    return testuser;
}
+ (id)current
{
    NSString *testuser = @"InkTestUser";
    return testuser;
}

@end
