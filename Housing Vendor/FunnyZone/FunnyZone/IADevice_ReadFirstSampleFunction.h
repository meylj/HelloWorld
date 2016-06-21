//
//  IADevice_ReadFirstSampleFunction.h
//  FunnyZone
//
//  Created by Cheng Ming on 2011/8/3.
//  Copyright 2011年 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestProgress.h"

/*
 2011.08.03 write by Ming
 For the Class,IADevice_ReadFirstSampleFunction is the sample code for you to study "How to add a new script's function in FunnyZone"
*/


@interface TestProgress (IADevice_ReadFirstSampleFunction)

// Descripton: MyFirstFunction is the sample function for to know how to add a new and right function for funnyzone
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)My_FIRST_FUNCTION:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;

@end
