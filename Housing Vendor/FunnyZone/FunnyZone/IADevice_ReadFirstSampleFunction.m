//
//  IADevice_ReadFirstSampleFunction.m
//  FunnyZone
//
//  Created by Cheng Ming on 2011/8/3.
//  Copyright 2011年 PEGATRON. All rights reserved.
//

/*
 2011.08.03 write by Ming
 For the Class,IADevice_ReadFirstSampleFunction is the sample code for you to study "How to add a new script's function in FunnyZone"
 that's mean if we see the function format as -(NSNumber*) FunctionName:(NSDictionary*)dicContents ReturnValue:(NSString**)strReturnValue
 we will know that it is "script's function"..
 */

#import "IADevice_ReadFirstSampleFunction.h"


@implementation TestProgress (IADevice_ReadFirstSampleFunction)

/*
 Step1: need to remark the function's Descripton and Param, as detial as you can
 */

// Descripton: MyFirstFunction is the sample function for to know how to add a new and right function for funnyzone
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 

/*
 Step2: the function's format shoule follow as below
 a> Function return should be (NSNumber*)
 b> Function should have two Params, one is dicContents (NSDictionary*), another is strReturnValue (NSString**)
 the dicContents is your necessary input parameters, such as TimeOut....
 the strReturnValue is the value you want to show in the UI's tableview's value. 
 */
-(NSNumber*)My_FIRST_FUNCTION:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    
/*
 Step3: please add a lot of ATSDebug();
 it will be helpful for you to debug your function/overlay...
 */
    ATSDebug(@"Use ATSDebug to log more detial information in your Function");
    ATSDebug(@"MyFirstFunction's input patameter in Dictionary is %@",dicContents);
        
/*
 Step4:Write your Algorithm
 please follow Coding Style 3.0
 */
    
    ATSDebug(@"Start My Algorithm from MyFirstFunction");
    
    
/*
Step5: Save the result for strReturnValue and m_szLastValue
the strReturnValue is the value you want to show in the UI's tableview's value.
the m_szLastValue is the value you want to use in next function. 
 */
    [strReturnValue setString:[NSString stringWithFormat:@"%s","PaSs"]];
    ATSDebug(@"strReturnValue = %@",strReturnValue);
    //[m_szLastValue setString:strReturnValue ];
/*
 Step6:  At your station , you may need to save one value at the first testItem for the third testItem to use.
 you can save the value to m_dicMemoryValues([m_dicMemoryValues setObject:@"Pass" forKey:kYouDefineTheKey];) at the first item,
 then get it from m_dicMemoryValues([m_dicMemoryValues valueForKey:kYouDefineTheKey];) at the third item
 */ 
#define kOtherDefineTheKey @"other defined"//you should define it in "IADevice_Define.h",here is just an example
#define kYouDefineTheKey @"you defined"//you should define it in "IADevice_Define.h",here is just an example
    //you can get value from dictionary(m_dicMemoryValues) whose key has been defined by other people
    [m_dicMemoryValues valueForKey:kOtherDefineTheKey];
    //if you want to set a new value in dictionary(m_dicMemoryValues) ,you must define a macro(such as :kYouDefineTheKey) first
    [m_dicMemoryValues setObject:@"Pass" forKey:kYouDefineTheKey];
    
    
/*
Step7: return format should be [NSNumber numberWithBool:YES]; or [NSNumber numberWithBool:NO];
*/
    return [NSNumber numberWithBool:YES];	
    
}

@end
