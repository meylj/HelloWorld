//
//  MathLibrary.h
//  FunnyZone
//
//  Created by Lorky on 3/30/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//


// ************************************************************************************** //
//	Description : This file was used to record some math functions, It can be used in each
//				project. This file won't modify if you don't have one new function that offen
//				use.
// ************************************************************************************** //
@interface MathLibrary : NSObject 

// Added by Lorky 2011-01-12
//
// Description	:
//
//		Least Square Best Fit.
//
// Parameter:
//
//		XValues		-->		NSArray	:	X values in coordinate
//		YValues		-->		NSArray	:	Y values in coordinate
//
// Return value	:	
//
//		A dictionary that include slope, intercept, ssy, ssr, R2, you can query it with following example.
//
//	Example		:	
//		NSDictionary *dictExample = [MathFunction LeastSquareBestFit:XValues YValue:YValues];
//		float fSlopeExam = [[dictExample objectValueForKey:@"slope"] floatValue];
// 
+(NSDictionary *)LeastSquareBestFit:(NSArray *)XValues
							 YValue:(NSArray *)YValues;


// Calculater
// Relate:
//		-(NSNumber*)DoCalculate:(NSObject*)szOperator
//						Number1:(NSNumber*)num1
//						Number2:(NSNumber*)num2
-(BOOL)Calculater:(NSString**)szExpression;
// Do calculate
-(BOOL)DoCalculate:(NSObject*)objOperator 
		   Number1:(NSNumber**)num1 
		   Number2:(NSNumber*)num2;

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
-(int)GetComplementOfInt:(int)iPrimary
			   BitNumber:(int)iBitNum;

// torres 2011.11.30
// Calculate the average,make sure the object in array could be transform to a double value,the bool parameter control the ABS value
-(double)GetAverageWithArray:(NSArray *)aryValue
					 NeedABS:(BOOL)bABS;

// torres 2011.11.30
// Bring a up order to the array,the object in array must be NSNumber type,return the seriation array.
-(NSArray *)BringOrderToArray:(NSArray *)aryUndisposed;

@end




