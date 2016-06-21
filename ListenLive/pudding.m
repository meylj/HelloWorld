//
//  pudding.m
//  ListenLive
//
//  Created by raniys on 3/31/15.
//  Copyright (c) 2015 raniys. All rights reserved.
//

#import "pudding.h"


@implementation pudding

-(NSDictionary *)loadDataFromJsonFile:(NSString *)path
{
    NSString        *strJsonData    = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSData          *dtJsonData     = [strJsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary    *dicJsonData    = [NSJSONSerialization JSONObjectWithData:dtJsonData options:NSJSONReadingMutableLeaves error:nil];
    
    //get command and result
    return [NSDictionary dictionaryWithDictionary:[dicJsonData objectForKey:@"ghinfo"]];
}

@end


