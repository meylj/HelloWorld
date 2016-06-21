#import <Cocoa/Cocoa.h>
#import "MemoryDraw.h"



/*!
 *	@author	Soshon Ran
 *	@since	2011-11-29
 *			Creation. 
 *	@since	2011-12-21	Izual Azurewrath
 *			Refactor. 
 */
@interface SingleView_Wifi : NSView 
{
@private
    NSPoint				pointStart;					//The coordinate orignial point
    CGFloat				heightOfCoordinate;			//The coordinate Ycoodheight
    CGFloat				widthOfCoordinate;			//The coordinate Xcoodheight
    CGFloat				xRate;						//The ratio between heightOfCoordinate \
														and the diatance from XEndvalue to XstartValue
    CGFloat				yRate;						//The ratio between widthOfCoordinate \
														and the diatance from YEndvalue to YstartValue
    NSMutableArray		*m_aryStoreInfo;			//store the all draw info.
    //public properity!
    NSMutableArray		*m_aryFreqForDraw;			//the array for Freq(PAT)
    NSMutableDictionary	*m_dictForDrawCoordinate;	//The dictionary for draw Coordinate,refernce to method DrawCoordinate:
    BOOL				m_bIsFirst;					//If the value is YES,will invoke method DrawCoordinate
    BOOL				m_bDrawChart;				//If the value is YES and call the method display,\
														then will invoke the method DrawThePICFromValueArray:
    BOOL				m_bDrawPhase;				//If the value is YES and call the method display,\
														then will invoke the method DrawThePICFromValueArray \
														the parameter is m_aryForPhase Otherwise m_aryForMagnitude:
    BOOL				m_bDrawSmitChart;			//If the value is YES and call the method display,\
														then will invoke the method DrawSmitChart:

    NSColor				*colorToDraw;				//path Color
    NSString			*m_strXCoordinateFormat;	//The Xcoordinate Comment
    NSString			*m_strYCoordinateFormat;	//The Ycoordinate Comment
    NSMutableArray		*m_aryForPhase;				//Store the Phase value
    NSMutableArray		*m_aryForMagnitude;			//Store the Magnitude value
    NSUInteger			m_uiCancel;
}



@property (retain, readwrite)	NSMutableArray		*m_aryFreqForDraw;
@property (retain, readwrite)	NSMutableDictionary	*m_dictForDrawCoordinate;
@property (retain, readwrite)	NSColor				*colorToDraw;
@property (readwrite)			BOOL				m_bDrawPhase;
@property (readwrite)			BOOL				m_bDrawChart;
@property (readwrite)			BOOL				m_bDrawSmitChart;
@property (readwrite)			BOOL				m_bIsFirst;
@property (retain, readwrite)	NSString			*m_strXCoordinateFormat;
@property (retain, readwrite)	NSString			*m_strYCoordinateFormat;
@property (retain, readwrite)	NSMutableArray		*m_aryForPhase;
@property (retain, readwrite)	NSMutableArray		*m_aryForMagnitude;
@property (readwrite)			NSUInteger			m_uiCancel;



/*!
 *	Draw the Coordinate accrord the Parameter. 
 *	@param			XCoordinateStartValue
 *					the Xcoordinate start value,type:(float)
 *	@param			XCoordinateEndValue
 *					the Xcoordinate end value,type:(float)
 *	@param			YCoordinateStartValue
 *					the Ycoordinate start value,type:(float)
 *	@param			YCoordinateEndValue
 *					the Ycoordinate end value,type:(float)
 *	@param			iCommentNumber
 *					the comment you wanna comment
 *	@return			draw the Coordinate accrord the Parameter
 */
- (void)DrawTheCoordinate:(float)XCoordinateStartValue 
			XcoordniteEnd:(float)XCoordinateEndValue 
	 YcoordnitestartValue:(float)YCoordinateStartValue 
	   YcoordniteEndValue:(float)YCoordinateEndValue 
			CommentNumber:(int)iCommentNumber;
/*!
 *	Draw the Chart accrord the Parameter. 
 *	@param			xFreqArray
 *					the Freq value,type:(NSNumber *)
 *	@param			yArray
 *					the Phase or Magnitude value  type:(NSNumber *) 
 *	@param			bPhase
 *					If YES.The yArray is Phase value,otherwise is Magnitude value
 *	@param			color
 *					Color of chart. 
 *	@param			uiCancel
 *					if NOCANCEL,dothing,Otherwise will discard last draw info
 *	@return			draw the chart accrord the Parameter
 */
- (void)DrawChartAccordValue:(NSMutableArray*)xFreqArray 
					  Yarray:(NSMutableArray *)yArray 
					 IsPhase:(BOOL)bPhase 
					   color:(NSColor*)color 
				   Operition:(NSUInteger)uiCancel;
/*!
 *	Draw the Smith accrord the Parameter. 
 *	@param			aryMangnitude
 *					the Magnitude value,type:(NSNumber *)
 *	@param			aryPhase
 *					the Phase value  type:(NSNumber *) 
 *	@param			index
 *					the index of you wanna draw
 *	@return			draw the Smith accrord the Parameter
 */
- (void)DrawSmithChartAccordValue:(NSMutableArray*)aryMangnitude 
					   Phasearray:(NSMutableArray *)aryPhase 
							Index:(int)index;
-(void)DrawCoordinate:(NSMutableDictionary *)dicForDrawCoordinate;
-(void)DrawSmithChart:(NSArray *)arrayForMagnitude 
				Phase:(NSArray *)arrayForPhase;
-(void)DrawThePICFromValueArray:(NSMutableArray *)xArray 
						 yArray:(NSMutableArray *)yArray 
					 lineWindth:(CGFloat) linewidth;
-(void)DrawOldChartFromInfo;
-(void)CancelSomeDrawOperation:(NSUInteger)opertion;



@end


