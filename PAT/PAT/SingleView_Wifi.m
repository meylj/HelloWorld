#import "SingleView_Wifi.h"



#define margin  17
#define HeightMargin 17



@implementation SingleView_Wifi



@synthesize	m_aryFreqForDraw;
@synthesize m_dictForDrawCoordinate;
@synthesize m_bDrawPhase;
@synthesize m_bDrawChart;
@synthesize m_bIsFirst;
@synthesize colorToDraw;
@synthesize m_strXCoordinateFormat;
@synthesize m_strYCoordinateFormat;
@synthesize m_aryForMagnitude;
@synthesize m_aryForPhase;
@synthesize m_bDrawSmitChart;
@synthesize m_uiCancel;


- (id)initWithFrame:(NSRect)frame
{
    self	= [super initWithFrame:frame];
    if (self) 
    {
        m_strXCoordinateFormat	= @"";
        m_strYCoordinateFormat	= @"";
        m_bIsFirst				= YES;
        m_bDrawPhase			= NO;
        colorToDraw				= [NSColor redColor];
        m_dictForDrawCoordinate	= [[NSMutableDictionary alloc] init];
        m_aryFreqForDraw		= [[NSMutableArray alloc] init];
        pointStart				= NSMakePoint(60, 60);
        m_aryForMagnitude       = [[NSMutableArray alloc] init];
        m_aryForPhase			= [[NSMutableArray alloc] init];
        
        m_aryStoreInfo			= [[NSMutableArray alloc] init];
        m_uiCancel				= NOCANCEL;
        [self setNeedsDisplay:YES];
    }
    return self;
}

- (void)dealloc
{
    [m_aryForMagnitude release];
    [m_aryForPhase release];
    [m_dictForDrawCoordinate release];
    [m_aryFreqForDraw release];
    [m_aryStoreInfo release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    
    //if m_bIsFirst is YES,will draw coordinate
    if (m_bIsFirst) 
    {
        [[NSColor whiteColor] set];
		[NSBezierPath fillRect:bounds];
         m_bIsFirst = NO;
		[self DrawCoordinate:m_dictForDrawCoordinate];
    }
	
    //if NOCANCEL, do nothing.Otherwise will cancel the object whose m_uiCancel is m_uiCancel
    [self CancelSomeDrawOperation:m_uiCancel];
    
    //if m_bDrawChart is YES will invoke method DrawThePICFromValueArray:yArray:lineWindth
    if (m_bDrawChart) 
    {
        if (!m_bDrawPhase) 
            [self DrawThePICFromValueArray:m_aryFreqForDraw 
									yArray:m_aryForMagnitude 
								lineWindth:1]; 
        else
            [self DrawThePICFromValueArray:m_aryFreqForDraw 
									yArray:m_aryForPhase 
								lineWindth:1];
        m_bDrawChart = NO;
    }
	
	//if m_bDrawChart is YES will invoke method DrawSmitChart:Phase
    if (m_bDrawSmitChart) 
    {
        m_bDrawSmitChart = NO;
        [self DrawSmithChart:m_aryForMagnitude 
					   Phase:m_aryForPhase];
        
    }
    [self DrawOldChartFromInfo];
	
}

/*!
 *	Draw the Coordinate accrord the Parameter
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
			CommentNumber:(int)iCommentNumber
{
	[m_dictForDrawCoordinate removeAllObjects];
	[m_dictForDrawCoordinate setObject:[NSNumber numberWithFloat:XCoordinateStartValue] 
								forKey:@"XSTARTNUMBER"];
	[m_dictForDrawCoordinate setObject:[NSNumber numberWithFloat:XCoordinateEndValue] 
								forKey:@"XENDNUMBER"];
	[m_dictForDrawCoordinate setObject:[NSNumber numberWithFloat:YCoordinateStartValue] 
								forKey:@"YSTARTNUMBER"];
	[m_dictForDrawCoordinate setObject:[NSNumber numberWithFloat:YCoordinateEndValue] 
								forKey:@"YENDNUMBER"];
	[m_dictForDrawCoordinate setObject:[NSNumber numberWithFloat:iCommentNumber] 
								forKey:@"COMMENTNUMBER"];
	m_bIsFirst	= YES;
	[self display];
}

/*!
 *	Draw the Chart accrord the Parameter
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
				   Operition:(NSUInteger)uiCancel
{
    [self setM_uiCancel:uiCancel];
    [self setColorToDraw:color];
    [m_aryFreqForDraw removeAllObjects];
    [m_aryFreqForDraw addObjectsFromArray:xFreqArray];
    
    if (bPhase)
    {
        [m_aryForPhase removeAllObjects];
        [m_aryForPhase addObjectsFromArray:yArray];
    }
	else
    {
        [m_aryForMagnitude removeAllObjects];
        [m_aryForMagnitude addObjectsFromArray:yArray];
    }
	
	[self setM_bDrawPhase:bPhase];
	[self setM_bDrawChart:YES];
	[self display];
}

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
							Index:(int)index
{
    [self setM_uiCancel:CANCELSMITH];
    [self setColorToDraw:[NSColor greenColor]];
    [m_aryForMagnitude removeAllObjects];
    [m_aryForPhase removeAllObjects];
    [m_aryForMagnitude addObjectsFromArray:aryMangnitude];
    [m_aryForPhase addObjectsFromArray:aryPhase];
    [self setM_bDrawSmitChart:YES];
    [self display];
}

-(void)DrawCoordinate:(NSMutableDictionary *)dicForDrawCoordinate
{
    //strore the info about the NSBezierPath;
    MemoryDraw	*newMemory	= [[MemoryDraw alloc] init];
    if ([[dicForDrawCoordinate allKeys] count] == 0) 
    {
		[newMemory release];	
        newMemory	= nil;
        return;
    }
    NSPoint	orignPoint	= pointStart;
    float	XEndValue	= [[dicForDrawCoordinate valueForKey:@"XENDNUMBER"] floatValue];
    float	XstartValue	= [[dicForDrawCoordinate valueForKey:@"XSTARTNUMBER"] floatValue];
    float	YEndValue	= [[dicForDrawCoordinate valueForKey:@"YENDNUMBER"] floatValue];
    float	YstartValue	= [[dicForDrawCoordinate valueForKey:@"YSTARTNUMBER"] floatValue];
    int		commentNumber	= [[dicForDrawCoordinate valueForKey:@"COMMENTNUMBER"] intValue];
	
    NSBezierPath	*path1	= [NSBezierPath bezierPath];
    [path1 setLineWidth:1];
    [[NSColor blackColor] set];
    [path1 moveToPoint:orignPoint];
    NSRect	bounds	= [self bounds];
    CGFloat	height	= bounds.size.height;
    CGFloat	width	= bounds.size.width;
    
    newMemory.LineWidth	= 1;
    newMemory.Color	= [NSColor blackColor];
    [newMemory.XValues addObject:[NSNumber numberWithFloat:orignPoint.x]];
    [newMemory.YValues addObject:[NSNumber numberWithFloat:orignPoint.y]];
    
    //NSPoint    point;
    float	XiTotalDistance		= XEndValue - XstartValue;
    float	XiInteverDistance	= XiTotalDistance/commentNumber;
    
    float	YiTotalDistance		= YEndValue - YstartValue;
    float	YiInteverDistance	= YiTotalDistance/commentNumber;
    
    //X coordinate
    
    [path1 lineToPoint:NSMakePoint(width-margin,orignPoint.y)];
    
    [newMemory.XValues addObject:[NSNumber numberWithFloat:width-margin]];
    [newMemory.YValues addObject:[NSNumber numberWithFloat:orignPoint.y]];
    
	[path1 stroke];
	[path1 moveToPoint:orignPoint];
	[path1 setLineWidth:1];
	float	originValue	= XstartValue;
	float	xValue		= orignPoint.x;
    
    
    for (int i = 0; i < 3; i++) 
    {
        NSTextField	*textFillCoordValue;
        NSString	*strTempX	= @"";
        NSString	*strTempY	= @"";
        
        switch (i) 
		{
            case 0:
                textFillCoordValue = [[NSTextField alloc] initWithFrame:NSMakeRect(orignPoint.x-53, orignPoint.y-20, 80, 15)];
                if (XstartValue > 2)
                    strTempX = [NSString stringWithFormat:@"%0.0f",XstartValue];
                else
                    strTempX = [NSString stringWithFormat:@"%0.1f",XstartValue];
                if (YstartValue > 2)
                    strTempY = [NSString stringWithFormat:@"%0.0f",YstartValue];
                else
                    strTempY = [NSString stringWithFormat:@"%0.1f",YstartValue];
                break;
            case 1:
                textFillCoordValue = [[NSTextField alloc] initWithFrame:NSMakeRect(orignPoint.x+width-margin-100, orignPoint.y-30, 50, 15)];
                strTempX = [NSString stringWithString:m_strYCoordinateFormat];
                
                break;
            case 2:
                textFillCoordValue = [[NSTextField alloc] initWithFrame:NSMakeRect(orignPoint.x, orignPoint.y+height-HeightMargin-55, 100, 15)];
                strTempX = [NSString stringWithString:m_strXCoordinateFormat];
                break;
            default:
                break;
        }
        
        [textFillCoordValue setAlignment:NSLeftTextAlignment];
        [textFillCoordValue setBezeled:NO];
        [textFillCoordValue setBordered:NO];
        [textFillCoordValue setBackgroundColor:[NSColor whiteColor]];
        [textFillCoordValue setEditable:NO];
        [textFillCoordValue setTextColor:[NSColor blackColor]];
        
        if ([strTempY isNotEqualTo:@""]) 
            strTempX = [NSString  stringWithFormat:@"(%@,%@)",strTempX,strTempY];
        [textFillCoordValue setStringValue:strTempX];
        
        [self addSubview:textFillCoordValue];
        [textFillCoordValue release];
    }
	
	for (int i = 0; i < commentNumber; i++) 
	{
		originValue			+= XiInteverDistance;
		widthOfCoordinate	=  width-orignPoint.x-margin;
		xValue				+= widthOfCoordinate/commentNumber;
		NSTextField	*textFillCoordValue	= [[NSTextField alloc] initWithFrame:NSMakeRect(xValue-10, orignPoint.y-18, 40, 17)];
		[textFillCoordValue setAlignment:NSJustifiedTextAlignment];
        [textFillCoordValue setEditable:NO];
		[path1 moveToPoint:NSMakePoint(xValue, orignPoint.y)];
		[path1 lineToPoint:NSMakePoint(xValue, height-HeightMargin)];
		
		//store info 
		MemoryDraw  *newnewMemory = [[MemoryDraw alloc] init];
		newnewMemory.Color	= [NSColor grayColor];
		newnewMemory.LineWidth	= 1;
		[newnewMemory.XValues addObject:[NSNumber numberWithFloat:xValue]];
		[newnewMemory.YValues addObject:[NSNumber numberWithFloat:orignPoint.y]];
		[newnewMemory.XValues addObject:[NSNumber numberWithFloat:xValue]];
		[newnewMemory.YValues addObject:[NSNumber numberWithFloat:height-HeightMargin]];
		[m_aryStoreInfo addObject:newnewMemory];
		[newnewMemory release];
		
		[textFillCoordValue setBezeled:NO];
		[textFillCoordValue setBordered:NO];
		[textFillCoordValue setBackgroundColor:[NSColor whiteColor]];
        [textFillCoordValue setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];
		if (originValue >= 2) 
			[textFillCoordValue setStringValue:[NSString stringWithFormat:@"%0.0f",originValue]];
		else
			[textFillCoordValue setStringValue:[NSString stringWithFormat:@"%0.1f",originValue]];
        

		[self addSubview:textFillCoordValue];
		[textFillCoordValue release];
	}
	[[NSColor blackColor] set];
	[path1 stroke];
    
	//Y coordinate
	[path1 moveToPoint:orignPoint];
	[path1 lineToPoint:NSMakePoint(orignPoint.x,height-HeightMargin)];
	
	//store draw info
	[newMemory.XValues addObject:[NSNumber numberWithFloat:orignPoint.x]];
	[newMemory.YValues addObject:[NSNumber numberWithFloat:orignPoint.y]];
	[newMemory.XValues addObject:[NSNumber numberWithFloat:orignPoint.x]];
	[newMemory.YValues addObject:[NSNumber numberWithFloat:height-HeightMargin]];
	[[NSColor grayColor] set];
	[path1 stroke];
	
	
	[path1 moveToPoint:orignPoint];
	[path1 setLineWidth:1];
	originValue = YstartValue;
	float  yValue = orignPoint.y;
	for (int i = 0; i < commentNumber; i++) 
	{
		originValue += YiInteverDistance; 
		heightOfCoordinate = height-orignPoint.y-HeightMargin;
		yValue += heightOfCoordinate/commentNumber;
		NSTextField  *textFillCoordValue = [[NSTextField alloc] initWithFrame:NSMakeRect(orignPoint.x-42,yValue-10,30, 15)];
		[textFillCoordValue setAlignment:NSRightTextAlignment];
        [textFillCoordValue setEditable:NO];
		
		[path1 moveToPoint:NSMakePoint(orignPoint.x, yValue)];
		[path1 lineToPoint:NSMakePoint(width-margin,yValue)];
		
		
		//store info
		MemoryDraw  *newnewMemory = [[MemoryDraw alloc] init];
		newnewMemory.Color	= [NSColor grayColor];
		newnewMemory.LineWidth	= 1;
		[newnewMemory.XValues addObject:[NSNumber numberWithFloat:orignPoint.x]];
		[newnewMemory.YValues addObject:[NSNumber numberWithFloat:yValue]];
		[newnewMemory.XValues addObject:[NSNumber numberWithFloat:width-margin]];
		[newnewMemory.YValues addObject:[NSNumber numberWithFloat:yValue]];
		[m_aryStoreInfo addObject:newnewMemory];
		[newnewMemory release];
		
		
		[textFillCoordValue setBezeled:NO];
		[textFillCoordValue setBordered:NO];
		[textFillCoordValue setBackgroundColor:[NSColor whiteColor]];
		[textFillCoordValue setTextColor:[NSColor blackColor]];
		[textFillCoordValue setStringValue:[NSString stringWithFormat:@"%0.2f",originValue]];
		[self addSubview:textFillCoordValue];
		[textFillCoordValue release];
	}
	
	
	[path1 stroke];
    
    //if smith chart coodinate,will draw two ovals and one beeline
    if (XiTotalDistance == YiTotalDistance) 
    {
        NSBezierPath *pathTemp = [NSBezierPath bezierPath];
        [pathTemp moveToPoint:NSMakePoint(pointStart.x, pointStart.y+heightOfCoordinate/2)];
        [pathTemp setLineWidth:2];
        [[NSColor blackColor] set];
        [pathTemp lineToPoint:NSMakePoint(pointStart.x+widthOfCoordinate, pointStart.y+heightOfCoordinate/2)];
        [pathTemp stroke];
        [pathTemp closePath];
        
        //store draw info 
        MemoryDraw *newmemoryforOvalFirst = [[MemoryDraw alloc] init];
        newmemoryforOvalFirst.Color	= [NSColor blackColor];
        newmemoryforOvalFirst.LineWidth	= 2;
        [newmemoryforOvalFirst.XValues addObject:[NSNumber numberWithFloat:pointStart.x]];
        [newmemoryforOvalFirst.YValues addObject:[NSNumber numberWithFloat:pointStart.y+heightOfCoordinate/2]];
        [newmemoryforOvalFirst.XValues addObject:[NSNumber numberWithFloat:pointStart.x+widthOfCoordinate]];
        [newmemoryforOvalFirst.YValues addObject:[NSNumber numberWithFloat:pointStart.y+heightOfCoordinate/2]];
        [m_aryStoreInfo addObject:newmemoryforOvalFirst];
        [newmemoryforOvalFirst release];
        
        //store info
        MemoryDraw *newmemoryforOval = [[MemoryDraw alloc] init];
        newmemoryforOval.Color	= [NSColor blackColor];
        newmemoryforOval.LineWidth	= 2;
        newmemoryforOval.Choice	= 2;
        newmemoryforOval.Size	= NSMakeSize(widthOfCoordinate, heightOfCoordinate);
        [newmemoryforOval.XValues addObject:[NSNumber numberWithFloat:pointStart.x]];
        [newmemoryforOval.YValues addObject:[NSNumber numberWithFloat:pointStart.y]];
        [m_aryStoreInfo addObject:newmemoryforOval];
        [newmemoryforOval release];
        
        MemoryDraw *newmemoryforOvalSecond = [[MemoryDraw alloc] init];
        newmemoryforOvalSecond.Color	= [NSColor blackColor];
        newmemoryforOvalSecond.LineWidth	= 2;
        newmemoryforOvalSecond.Choice	= 2;
        newmemoryforOvalSecond.Size	= NSMakeSize(widthOfCoordinate/2, heightOfCoordinate/2);
        [newmemoryforOvalSecond.XValues addObject:[NSNumber numberWithFloat:pointStart.x+widthOfCoordinate/2]];
        [newmemoryforOvalSecond.YValues addObject:[NSNumber numberWithFloat:pointStart.y+heightOfCoordinate/4]];
        [m_aryStoreInfo addObject:newmemoryforOvalSecond];
        [newmemoryforOvalSecond release];
        
        //draw oval 
        path1 = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(pointStart.x, 
																  pointStart.y, 
																  widthOfCoordinate, 
																  heightOfCoordinate)];
        [path1 setLineWidth:2];
        [[NSColor blackColor] set];
        [path1 stroke];
        
        //draw oval 
        path1 = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(pointStart.x+widthOfCoordinate/2, 
																  pointStart.y+heightOfCoordinate/4, 
																  widthOfCoordinate/2, 
																  heightOfCoordinate/2)];
        [path1 setLineWidth:2];
        [[NSColor blackColor] set];
        [path1 stroke];
        
    }
	
    [m_aryStoreInfo addObject:newMemory];
    xRate = widthOfCoordinate/XiTotalDistance;
    yRate = heightOfCoordinate/YiTotalDistance;
    [path1 closePath];
	[newMemory release];	newMemory	= nil;
}



/*!
 *	Draw the chart accord xArray and yArray. 
 *	@param			xArray
 *					The xArray Value(For PAT,It is Freq)
 *	@param			yArray
 *					The yArray Value(For PAT,It is Magnitude or Phase)
 *	@param			linewidth
 *					Line width. 
 *	@return			draw the chart accrord the Parameter
 */
-(void)DrawThePICFromValueArray:(NSMutableArray *)xArray 
						 yArray:(NSMutableArray *)yArray 
					 lineWindth:(CGFloat) linewidth
{
    MemoryDraw      *newMemory = [[MemoryDraw alloc] init];
    newMemory.Color	= colorToDraw;
    newMemory.LineWidth	= linewidth;
    if ([xArray count] <= 30) 
        newMemory.Cancel	= CANLIMITLINE;
    else
        newMemory.Cancel	= CANCELNORMALCHART;
	
    NSBezierPath	*pathtemp	= [NSBezierPath bezierPath];
    [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
    [pathtemp setLineWidth:linewidth];
    [colorToDraw set];
    NSPoint	point;
    NSPoint	SecondPoint	= pointStart;
	if (![xArray count] || ![yArray count]) 
    {
        [newMemory release];
        return;
    }
		
    point.y	= pointStart.y+[[yArray objectAtIndex:0] floatValue]*yRate;
    point.x	= [[xArray objectAtIndex:0] floatValue]*xRate-pointStart.x-margin/6;
    [newMemory.XValues addObject:[NSNumber numberWithFloat:point.x]];
    [newMemory.YValues addObject:[NSNumber numberWithFloat:point.y]];
	
    [pathtemp moveToPoint:point];
    NSUInteger	uicount	= (([xArray count] <= [yArray count]) 
						   ? [xArray count] 
						   : [yArray count]);
    for (int i = 1; i < uicount; i++) 
    {
        //get the real coordinate
        SecondPoint.y	= pointStart.y+[[yArray objectAtIndex:i] floatValue]*yRate;
        SecondPoint.x	= [[xArray objectAtIndex:i] floatValue]*xRate-pointStart.x-margin/6;
        [pathtemp lineToPoint:SecondPoint];
        point = SecondPoint;
        [pathtemp moveToPoint:point];
        
        //store draw info
        [newMemory.XValues addObject:[NSNumber numberWithFloat:SecondPoint.x]];
        [newMemory.YValues addObject:[NSNumber numberWithFloat:SecondPoint.y]];
    }
	
    [pathtemp stroke];
    [pathtemp closePath];
    
    [m_aryStoreInfo addObject:newMemory];
    [newMemory release];
}


/*!
 *	Draw the Smith accrord the Parameter
 *	@param	arrayForMagnitude
 *			the Magnitude value,type:(NSNumber *)
 *	@param	arrayForPhase
 *			the Phase value  type:(NSNumber *) 
 *	@return	draw the Smith accord the Parameter
 */
-(void)DrawSmithChart:(NSArray *)arrayForMagnitude 
				Phase:(NSArray *)arrayForPhase
{
    MemoryDraw		*newMemoryDraw	= [[MemoryDraw alloc] init];
    newMemoryDraw.Choice	= 1;
    newMemoryDraw.LineWidth	= 2;
    newMemoryDraw.Color	= colorToDraw;
    newMemoryDraw.Cancel	= CANCELSMITH;
    
    NSPoint  MyOriginalpoint;
    MyOriginalpoint.x = pointStart.x+widthOfCoordinate/2;
    MyOriginalpoint.y = pointStart.y+heightOfCoordinate/2;
    NSPoint  pSecondPoint = NSMakePoint(0, 0);
    NSBezierPath    *pathTemp = [NSBezierPath bezierPath];
    double			dMagnitude = 0.0;
    double			dPhase = 0.0;
    double			xValue = 0.0;
    double			yValue = 0.0;
	
    NSPoint arrayForDraw[[arrayForMagnitude count]];
    NSUInteger	uiCount	= (([arrayForPhase count] <= [arrayForMagnitude count]) 
						   ? [arrayForPhase count] 
						   : [arrayForMagnitude count]);
    
    [pathTemp setLineWidth:1];
    [colorToDraw set];
	
    for (int i = 0; i < uiCount; i++) 
    {
        dMagnitude = [[arrayForMagnitude objectAtIndex:i] floatValue];
        dPhase  = [[arrayForPhase objectAtIndex:i] floatValue];
        int choice = -1;
        //magnituede
        if (dPhase>=0 && dPhase <90) 
            choice = 0;
        else if (dPhase>=90 && dPhase <180)
            choice = 1;
        else if (dPhase>=180 && dPhase <270)
            choice = 2;
        else if (dPhase>=270 && dPhase < 360)
            choice = 3;
        
        switch (choice) 
        {
            case 0:
                dPhase = dPhase*pi/180;
                xValue = dMagnitude *cos(dPhase);
                yValue = dMagnitude *sin(dPhase);
                break;
            case 1:
                dPhase = (180-dPhase)*pi/180;
                xValue = -dMagnitude *cos(dPhase);
                yValue = dMagnitude *sin(dPhase);
                break;
            case 2:
                dPhase = (dPhase-180)*pi/180;
                xValue = -dMagnitude *cos(dPhase);
                yValue = -dMagnitude *sin(dPhase);
                break;
            case 3:
                dPhase = (dPhase-270)*pi/180;
                xValue = dMagnitude *sin(dPhase);
                yValue = -dMagnitude *cos(dPhase);
                break;
            default:
                break;
        }
        
        //get real coordinate
        pSecondPoint.x	= MyOriginalpoint.x + (float)xValue*xRate;
        pSecondPoint.y	= MyOriginalpoint.y + (float)yValue*yRate;
        arrayForDraw[i] = pSecondPoint;
        
        //store info
        [newMemoryDraw.XValues addObject:[NSNumber numberWithFloat:pSecondPoint.x]];
        [newMemoryDraw.YValues addObject:[NSNumber numberWithFloat:pSecondPoint.y]];
        
        if (0 == i)
            [pathTemp moveToPoint:pSecondPoint];
        [pathTemp setLineJoinStyle:NSRoundLineJoinStyle];
        [pathTemp setLineCapStyle:NSRoundLineCapStyle];
        // draw smith line!
        [pathTemp lineToPoint:pSecondPoint];
        [pathTemp moveToPoint:pSecondPoint];
        
    }
	
    [pathTemp stroke];
    [pathTemp closePath];
    [m_aryStoreInfo addObject:newMemoryDraw];
    [newMemoryDraw release];
}

/*!
 *	Draw the old chart
 *	@return	draw the old chart
 */
-(void)DrawOldChartFromInfo
{
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:[self bounds]];
    
    MemoryDraw      *newMemoryDraw;
    NSMutableArray  *xArray;
    NSMutableArray  *yArray;
    NSPoint         firstPoint;
    NSPoint         secondPoint;
    for (int i = 0; i < [m_aryStoreInfo count]; i++) 
    {
        NSBezierPath	*bezierpath	= [NSBezierPath bezierPath];
        newMemoryDraw	= [m_aryStoreInfo objectAtIndex:i];
        [bezierpath setLineWidth:newMemoryDraw.LineWidth];
        xArray			= newMemoryDraw.XValues;
        yArray			= newMemoryDraw.YValues;
        firstPoint.x	= [[xArray objectAtIndex:0] floatValue];
        firstPoint.y	= [[yArray objectAtIndex:0] floatValue];
        
        switch (newMemoryDraw.Choice) 
        {
            case 1:
                [bezierpath setLineJoinStyle:NSRoundLineJoinStyle];
                [bezierpath setLineCapStyle:NSRoundLineCapStyle];
                break;
            case 2:
                bezierpath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(firstPoint.x, 
																			   firstPoint.y, 
																			   newMemoryDraw.Size.width, 
																			   newMemoryDraw.Size.height)];
                [bezierpath setLineWidth:newMemoryDraw.LineWidth];
                [[newMemoryDraw Color] set];
                [bezierpath stroke];
                [bezierpath closePath];
                continue;
                break;
            default:
                break;
        }
        
        if (([xArray count] == [yArray count]) && [xArray count]) 
        {
            firstPoint.x = [[xArray objectAtIndex:0] floatValue];
            firstPoint.y = [[yArray objectAtIndex:0] floatValue];
            [bezierpath moveToPoint:firstPoint];
            for (int jcount = 1; jcount < [xArray count]; jcount++) 
            {
                secondPoint.x = [[xArray objectAtIndex:jcount] floatValue];
                secondPoint.y = [[yArray objectAtIndex:jcount] floatValue];
                [bezierpath lineToPoint:secondPoint];
                firstPoint = secondPoint;
                [bezierpath moveToPoint:firstPoint];
            }
        }
        [[newMemoryDraw Color] set];
        [bezierpath closePath];
        [bezierpath stroke];
    }
}



-(void)CancelSomeDrawOperation:(NSUInteger)opertion
{
    if (opertion == NOCANCEL) 
        return;
    else
        for (int i = 0; i < [m_aryStoreInfo count]; i++)
            if (opertion == [[m_aryStoreInfo objectAtIndex:i] Cancel]) 
                [m_aryStoreInfo removeObjectAtIndex:i];
    return;
}



@end


