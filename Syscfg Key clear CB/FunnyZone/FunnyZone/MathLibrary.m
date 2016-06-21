//
//  MathLibrary.m
//  FunnyZone
//
//  Created by Lorky on 3/30/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//



#import "MathLibrary.h"



@implementation MathLibrary

+ (NSDictionary *)LeastSquareBestFit:(NSArray *)XValues
							  YValue:(NSArray *)YValues;
{
	NSDictionary	*dict;
	if ([XValues count] != [YValues count])
	{
		dict	= [NSDictionary dictionaryWithObjectsAndKeys:
				   @"1",	@"slope",
				   @"0",	@"intercept",nil];
		NSRunAlertPanel(@"错误(LeastSquareBestFit Error)",
						[NSString stringWithFormat:
						 @"XValues have [%d],but YValues have [%d]",
						 [XValues count],[YValues count]],
						@"确认(OK)", nil, nil);
	}
	else
	{
		double	fSumX = 0.0, fSumY = 0.0, fSumXY = 0.0, fSumX2 = 0.0, fMeanX = 0.0,
		fMeanY = 0.0, slope = 0.0, intercept = 0.0, ssy = 0.0, ssr = 0.0,R2 = 0.0;
		for (int i = 0; i<[XValues count]; i++)
		{
			fSumX	+= [[XValues objectAtIndex:i] floatValue];
			fSumY	+= [[YValues objectAtIndex:i] floatValue];
			fSumXY	+= [[XValues objectAtIndex:i] floatValue] * [[YValues objectAtIndex:i] floatValue];
			fSumX2	+= [[XValues objectAtIndex:i] floatValue] * [[XValues objectAtIndex:i] floatValue];
		}
		fMeanX	= fSumX / [XValues count];
		fMeanY	= fSumY / [YValues count];
		slope	= ([XValues count] * fSumXY - fSumX * fSumY)/([XValues count] * fSumX2 - fSumX * fSumX);//斜率k，最小二乘法公式
		intercept	= fMeanY - (slope * fMeanX);//求b
		for (int i = 0; i<[XValues count]; i++)
		{
			ssy	+= ([[YValues objectAtIndex:i] floatValue] - fMeanY) * ([[YValues objectAtIndex:i] floatValue] - fMeanY);//方差
			ssr	+= ([[YValues objectAtIndex:i] floatValue] - slope * [[XValues objectAtIndex:i] floatValue]) * ([[YValues objectAtIndex:i] floatValue] - slope * [[XValues objectAtIndex:i] floatValue]);//吗用？
		}
		R2		= 1 - (ssr / ssy);
		dict	= [NSDictionary dictionaryWithObjectsAndKeys:
				   [NSNumber numberWithDouble: slope],		@"slope",
				   [NSNumber numberWithDouble: intercept],	@"intercept",
				   [NSNumber numberWithDouble: ssy],		@"ssy",
				   [NSNumber numberWithDouble: ssr],		@"ssr",
				   [NSNumber numberWithDouble: R2],			@"R2",nil];
	}
	return dict;
}

-(void)CompleteExpression:(NSMutableArray *)mutableArray
{
    int	iElement	= 0;
	for(NSObject *objElement in mutableArray)
	{
		if((([objElement isEqualTo:@"+"])
			||([objElement isEqualTo:@"-"]))
		   &&((0==iElement)
			  ||([[mutableArray objectAtIndex:iElement-1] isEqualTo:@"("])))
		{
			[mutableArray insertObject:[NSNumber numberWithDouble:0]
							   atIndex:iElement];
            [self CompleteExpression:mutableArray];
            break;
		}
		iElement++;
	}
}

// Calculater
// Relate:
//		-(BOOL)DoCalculate:(NSObject*)objOperator
//						Number1:(NSNumber**)num1
//						Number2:(NSNumber*)num2
-(BOOL)Calculater:(NSString**)szExpression
{	
	// Format expression
	*szExpression	= [NSString stringWithFormat:@"(%@)",*szExpression];
	NSMutableArray	*arrayFormatExpression	= [[[NSMutableArray alloc] init] autorelease];
	// Seperate each digit
	for(int i=0;i<[*szExpression length];i++)
	{
		NSString	*szDigit	= [[*szExpression substringFromIndex:i] substringToIndex:1];
		char		cDigit		= [szDigit characterAtIndex:0];
		if(('0'<=cDigit)
		   &&(cDigit<='9'))
			[arrayFormatExpression addObject:[NSNumber numberWithDouble:[szDigit doubleValue]]];
		else
			[arrayFormatExpression addObject:szDigit];
	}
	// Combine numbers
	int	iCombineNumber;
CombineNumbers:iCombineNumber = 0;
	for(NSObject *objElement in arrayFormatExpression)
	{
		if(([objElement isKindOfClass:[NSNumber class]])
		   &&(iCombineNumber < [arrayFormatExpression count])
		   &&(([[arrayFormatExpression objectAtIndex:iCombineNumber+1] isKindOfClass:[NSNumber class]])
			  ||([[arrayFormatExpression objectAtIndex:iCombineNumber+1] isEqualTo:@"."])))
		{
			NSString	*szNumber	= [NSString stringWithString:[objElement description]];
			int			iEnd		= iCombineNumber;
			for(int j=iCombineNumber+1;j<[arrayFormatExpression count];j++)
			{
				if(([[arrayFormatExpression objectAtIndex:j] isKindOfClass:[NSNumber class]])
				   ||([[arrayFormatExpression objectAtIndex:j] isEqualTo:@"."]))
					szNumber	= [NSString stringWithFormat:@"%@%@",
								   szNumber,[[arrayFormatExpression objectAtIndex:j] description]];
				else
					break;
				iEnd	= j;
			}
			for(int j=iCombineNumber;j<=iEnd;j++)
				[arrayFormatExpression removeObjectAtIndex:iCombineNumber];
			[arrayFormatExpression insertObject:[NSNumber numberWithDouble:[szNumber doubleValue]]
										atIndex:iCombineNumber];
			goto CombineNumbers;
		}
		iCombineNumber++;
	}
	// Lowercase
	for(int i=0;i<[arrayFormatExpression count];i++)
	{
		if([[arrayFormatExpression objectAtIndex:i] isKindOfClass:[NSString class]])
		{
			[arrayFormatExpression insertObject:[[arrayFormatExpression objectAtIndex:i] lowercaseString] 
										atIndex:i];
			[arrayFormatExpression removeObjectAtIndex:i+1];
		}
	}
	// Combine operators
	for(int i=0;i<[arrayFormatExpression count];i++)
	{
		if(([[arrayFormatExpression objectAtIndex:i] isKindOfClass:[NSString class]])
		   &&(1 == [[arrayFormatExpression objectAtIndex:i] length])
		   &&('a' <= [[arrayFormatExpression objectAtIndex:i] characterAtIndex:0])
		   &&([[arrayFormatExpression objectAtIndex:i] characterAtIndex:0] <= 'z'))
		{
			NSString	*szOperator = [arrayFormatExpression objectAtIndex:i];
			int			iEnd		= i;
			for(int j=i+1;j<[arrayFormatExpression count];j++)
			{
				if(([[arrayFormatExpression objectAtIndex:j] isKindOfClass:[NSString class]])
				   &&(1 == [[arrayFormatExpression objectAtIndex:j] length])
				   &&('a' <= [[arrayFormatExpression objectAtIndex:j] characterAtIndex:0])
				   &&([[arrayFormatExpression objectAtIndex:j] characterAtIndex:0] <= 'z'))
				{
					szOperator	= [NSString stringWithFormat:@"%@%@",
								   szOperator,[arrayFormatExpression objectAtIndex:j]];
					iEnd		= j;
				}
				else
					break;
			}
			for(int j=i;j<=iEnd;j++)
				[arrayFormatExpression removeObjectAtIndex:i];
			[arrayFormatExpression insertObject:szOperator atIndex:i];
		}
	}
	
	// Complete expression
    [self CompleteExpression:arrayFormatExpression];
	
	// Create RPN
	NSArray	*arrayHighPriority		= [NSArray arrayWithObjects:@"%",@"^",@"!",
									   @"sin",@"cos",@"tan",@"cot",@"sec",@"csc",
									   @"ln",@"log",@"abs",nil];
	NSArray	*arrayMidPriority		= [NSArray arrayWithObjects:@"*",@"/",nil];
	NSArray	*arrayLowPriority		= [NSArray arrayWithObjects:@"+",@"-",nil];
	NSMutableArray	*arrayRPN		= [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray	*arrayTempRPN	= [[[NSMutableArray alloc] init] autorelease];
	for(NSObject *objElement in arrayFormatExpression)
	{
		// Numbers
		if(([objElement isKindOfClass:[NSNumber class]])
		   ||([objElement isEqualTo:@"("]))
			[arrayTempRPN addObject:objElement];
		// High priority operators
		else if([arrayHighPriority containsObject:objElement])
		{
			while((![[arrayTempRPN lastObject] isEqualTo:@"("])
				  &&(![arrayMidPriority containsObject:[arrayTempRPN lastObject]])
				  &&(![arrayLowPriority containsObject:[arrayTempRPN lastObject]]))
			{
				[arrayRPN addObject:[arrayTempRPN lastObject]];
				[arrayTempRPN removeLastObject];
			}
			[arrayTempRPN addObject:objElement];
		}
		// Mid priority operators
		else if([arrayMidPriority containsObject:objElement])
		{
			while((![[arrayTempRPN lastObject] isEqualTo:@"("])
				  &&(![arrayLowPriority containsObject:[arrayTempRPN lastObject]]))
			{
				[arrayRPN addObject:[arrayTempRPN lastObject]];
				[arrayTempRPN removeLastObject];
			}
			[arrayTempRPN addObject:objElement];
		}
		// Low priority operators
		else if([arrayLowPriority containsObject:objElement])
		{
			while(![[arrayTempRPN lastObject] isEqualTo:@"("])
			{
				[arrayRPN addObject:[arrayTempRPN lastObject]];
				[arrayTempRPN removeLastObject];
			}
			[arrayTempRPN addObject:objElement];
		}
		// Most priority
		else if([objElement isEqualTo:@")"])
		{
			while(![[arrayTempRPN lastObject] isEqualTo:@"("])
			{
				[arrayRPN addObject:[arrayTempRPN lastObject]];
				[arrayTempRPN removeLastObject];
			}
			[arrayTempRPN removeLastObject];
		}
	}
	
	// Pup and calculate each operator
	NSArray	*arrayBineryOperators	= [NSArray arrayWithObjects:@"+",@"-",@"*",@"/",
									   @"%",@"^",
									   @"log",nil];
	NSArray	*arrayUnaryOperators	= [NSArray arrayWithObjects:@"!",
									   @"sin",@"cos",@"tan",@"cot",@"sec",@"csc",
									   @"ln",@"abs",nil];
	NSMutableArray	*arrayResult	= [[[NSMutableArray alloc] init] autorelease];
	for(NSObject *objElement in arrayRPN)
	{
		if([objElement isKindOfClass:[NSNumber class]])
			[arrayResult addObject:objElement];
		else if([arrayUnaryOperators containsObject:objElement])
		{
			if(1 > [arrayResult count])
				return NO;
			NSNumber	*num1	= [arrayResult lastObject];
			[arrayResult removeLastObject];
			if(![self DoCalculate:objElement 
						  Number1:&num1 
						  Number2:nil])
				return NO;
			[arrayResult addObject:num1];
		}
		else if([arrayBineryOperators containsObject:objElement])
		{
			if(2 > [arrayResult count])
				return NO;
			NSNumber	*num2	= [arrayResult lastObject];
			[arrayResult removeLastObject];
			NSNumber	*num1	= [arrayResult lastObject];
			[arrayResult removeLastObject];
			if(![self DoCalculate:objElement 
						  Number1:&num1 
						  Number2:num2])
				return NO;
			[arrayResult addObject:num1];
		}
	}
	
	// Judge result
	if(1 != [arrayResult count])
		return NO;
	
	// Store result and repoint
	*szExpression	= [[arrayResult lastObject] description];
	return YES;
}
// Do calculate
-(BOOL)DoCalculate:(NSObject*)objOperator
		   Number1:(NSNumber**)num1
		   Number2:(NSNumber*)num2
{
	// Valid operators list
	NSArray	*arrayValidOperators	= [NSArray arrayWithObjects:@"+",@"-",@"*",@"/",
									   @"%",@"^",@"!",
									   @"sin",@"cos",@"tan",@"cot",@"sec",@"csc",
									   @"ln",@"log",@"abs",nil];
	if(![arrayValidOperators containsObject:objOperator])
		return NO;
	
	// Get numbers
	double	d1		= [*num1 doubleValue];
	double	d2		= [num2 doubleValue];
	double	dResult	= 0;
	
	// Calculate
	if([objOperator isEqualTo:@"+"])
		dResult	= d1 + d2;
	else if([objOperator isEqualTo:@"-"])
		dResult	= d1 - d2;
	else if([objOperator isEqualTo:@"*"])
		dResult = d1 * d2;
	else if([objOperator isEqualTo:@"/"])
	{
		if(0 == d2)
			return NO;
		dResult = d1 / d2;
	}
	else if([objOperator isEqualTo:@"%"])
	{
		if(0 == d2)
			return NO;
		dResult = fmod(d1,d2);
	}
	else if([objOperator isEqualTo:@"^"])
		dResult = pow(d1,d2);
    //阶乘
	else if([objOperator isEqualTo:@"!"])
	{
		dResult = 1;
		for(int i=1;i<=d1;i++)
			dResult = dResult * i;
	}
	else if([objOperator isEqualTo:@"sin"])
		dResult	= sin(d1);
	else if([objOperator isEqualTo:@"cos"])
		dResult = cos(d1);
	else if([objOperator isEqualTo:@"tan"])
		dResult = tan(d1);
	else if([objOperator isEqualTo:@"cot"])
		dResult = 1/(tan(d1));
	else if([objOperator isEqualTo:@"sec"])
		dResult = 1/(cos(d1));
	else if([objOperator isEqualTo:@"csc"])
		dResult = 1/(sin(d1));
    //
	else if([objOperator isEqualTo:@"ln"])
		dResult = log(d1);
	else if([objOperator isEqualTo:@"log"])
		dResult = log(d2)/log(d1);
    else if([objOperator isEqualTo:@"abs"])
        dResult = fabs(d1);
	
	*num1	= [NSNumber numberWithDouble:dResult];
	return YES;
}

// torres 2011.11.30
// Calculater the complement of int value
// Parameter:
//
//      iPrimary    -->     int : the primary int
//      iBitNum     -->     int : bit of the primary
//                                8 or 16
//
// Return value:
//
//      int --> the complement of the primary
- (int)GetComplementOfInt:(int)iPrimary
				BitNumber:(int)iBitNum
{
   	if (8 == iBitNum)
		return ((iPrimary & 0x80) ? -((iPrimary ^ 0xff) + 1) : iPrimary);
    else if (16 == iBitNum) 
		return ((iPrimary & 0x8000) ? -((iPrimary ^ 0xffff) + 1) : iPrimary);
    else
		return 0;
}

// torres 2011.11.30
// Calculate the average,make sure the object in array could be transform to a double value,the bool parameter control the ABS value
- (double)GetAverageWithArray:(NSArray *)aryValue
					  NeedABS:(BOOL)bABS
{
    if (nil == aryValue || 0 == [aryValue count])
        return [@"NA" doubleValue];
    double	sum	= 0.0;
    for(id obj in aryValue)
    {
        double	result;
        if ([obj isKindOfClass:[NSString class]]) 
        {
            NSScanner	*scanner	= [NSScanner scannerWithString:obj];
            if(![scanner scanDouble:&result] || ![scanner isAtEnd])
                return [@"NA" doubleValue];
            if (bABS)
                sum	+= fabs(result);
            else
                sum += result;
        } 
        else if ([obj isKindOfClass:[NSNumber class]])
        {
            if (bABS)
                sum += fabs([obj doubleValue]);
            else
                sum += [obj doubleValue];
        }
        else
            return [@"NA" doubleValue];
    }
    return sum / [aryValue count];
}

// torres 2011.11.30
// Bring a up order to the array,the object in array must be NSNumber type,return the seriation array.
- (NSArray *)BringOrderToArray:(NSArray *)aryUndisposed
{
    for (id obj in aryUndisposed)
        if (![obj isKindOfClass:[NSNumber class]])
            return nil;
    return [aryUndisposed sortedArrayUsingSelector:@selector(compare:)];
}

@end




