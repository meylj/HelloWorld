//
//  IADevice_Battery.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.
//

#import "IADevice_Battery.h"


@implementation TestProgress (IADevice_Battery)

/*  
 2012-04-17 Add remark by Stephen
 Function:       Calculate the product of two value.
 Description:    Calculate the product of two value, for example : result(power) = valueone(current)*valuetwo(voltage)/1000.
 Para:           (NSDictionary*)dicPara --> A dictionary to save the two value with key in script, format:"Key -> one,two"
                 (NSMutableString*)szReturnValue --> Value returned from the last function, here we set the power value, show on UI and save in csv.
 Return:         If the key or the value with the key is nil return NO, else return YES.
 */
-(NSNumber *)CALCULATE_POEWR:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString*)szReturnValue
{
    //Basic judge
    if (![dicPara isKindOfClass:[NSDictionary class]]
        || ![dicPara valueForKey:kFZ_Script_MemoryKey]
        || ![szReturnValue isKindOfClass:[NSString class]]) 
    {
        return [NSNumber numberWithBool:NO];
    }
    
    //do minus arithmetic with two values
    NSArray *aryKeyNames = [[dicPara valueForKey:kFZ_Script_MemoryKey] componentsSeparatedByString:kFunnyZoneComma];
    NSString *szValueOne,*szValueTwo; //modified by desikan 2012.5.2 for current when Volt is NA but current is not NA, pow should be NA, and return NO.
    if([aryKeyNames count]!=2)
    {
        return [NSNumber numberWithBool:NO];
    }
    else
    {
        szValueOne = [m_dicMemoryValues valueForKey:[aryKeyNames objectAtIndex:0]];
        szValueTwo = [m_dicMemoryValues valueForKey:[aryKeyNames objectAtIndex:1]];
    }
    if (szValueOne== NULL || szValueTwo==NULL || [szValueOne isEqualTo:@"NA"] || [szValueTwo isEqualTo:@"NA"])
    {
        ATSDebug(@"No decimal data with keys[%@]",aryKeyNames);
        // set a monstrosity
        ATSDebug(@"-99999issue");
        [szReturnValue setString:kFZ_99999_Value_Issue];
        return [NSNumber numberWithBool:NO];
    }
    
    //calculate power
    double fValueOne,fValueTwo,fResult;
    fValueOne = [szValueOne doubleValue];
    fValueTwo = [szValueTwo doubleValue];
    fResult = (fValueOne*fValueTwo)/1000;
    [szReturnValue setString:[NSString stringWithFormat:@"%.4f", fResult]];
    
    return [NSNumber numberWithBool:YES];
}

/*  
 2012-04-17 Add remark by Stephen
 Function:       Get the sleep current from unit.
 Description:    To deal with the return value from unit after sending some one command, catch the sleep current value and save it.
                 The format may like this: SleepDLOG3, xxx mA
                 SleepDLOG2, xxx mA
                 SleepDLOG1, xxx mA
 Para:           (NSDictionary*)dicPara --> Save the key in script, here we do not use.
                 (NSMutableString*)szReturnValue --> Value returned from the last function, contains the unit's return value, show on UI and save in csv.
 Return:         If the return value format from unit is error return NO, else return YES.
 */
-(NSNumber *)GET_SLEEP_DATA:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString*)szReturnValue
{
	NSArray *arrData = [szReturnValue componentsSeparatedByString:@" mA"];
	int i;
    NSString *strStart = @"";
	NSRange rangeStart;
	if ([arrData count] >= 3) 
	{
		for(i = 0; i < 3; i++)
		{
			rangeStart = [[arrData objectAtIndex:i] rangeOfString:@", "];
			
			if ((NSNotFound != rangeStart.location) && (rangeStart.length > 0) && ((rangeStart.location +rangeStart.length) <= [[arrData objectAtIndex:i]length])) 
			{
				strStart =[[arrData objectAtIndex:i] substringFromIndex:rangeStart.location+rangeStart.length];
			}
            else
            {
                strStart = kFZ_99999_Value_Issue;
                ATSDebug(@"-99999issue");
                ATSDebug(@"Do not Find Sleep data,%@",[arrData objectAtIndex:i]);
            }
			
			[m_dicMemoryValues setValue:strStart forKey:[NSString stringWithFormat:@"SleepDLOG%d",3-i]];
		}
        return [NSNumber numberWithBool:YES];
	}
	else
	{
		[szReturnValue setString:[NSString stringWithFormat:@"Don't get Sleep data"]];
        return [NSNumber numberWithBool:NO];
	}
}

@end
