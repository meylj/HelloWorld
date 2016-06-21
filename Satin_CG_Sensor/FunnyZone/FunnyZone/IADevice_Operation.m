//  IADevice_Operation.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "IADevice_Operation.h"

NSString *const   BNRRunColorChoicePanelNotification = @"RunColorChoose";
NSString* const BNRColorChoiceFinish  = @"BNRColorChoiceFinish";

@implementation TestProgress (IADevice_Operation)

//Start 2011.10.28 Add by Ming 
// Descripton:Set the UI's SN be the test item at csv file
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_ISN_FROM_UI:(NSDictionary*)dicContents
			   RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSArray	*arrSNs	= [dicContents objectForKey:@"SHOW_SN"];
    if (nil != arrSNs && [arrSNs count] > 0) 
    {
        [strReturnValue setString:@""];
        NSMutableString	*szShowSNs	= [[NSMutableString alloc] init];
        for (NSString *strSNKey in arrSNs) 
        {
            //NSString *strSNKey=[arrSNs objectAtIndex:i];
            NSString	*strSN	= [m_dicMemoryValues objectForKey:strSNKey];
            if(strSN && ![strSN isEqualToString:@""])
            {
                [szShowSNs appendString:[NSString stringWithFormat:
										 @"%@:%@;",
										 strSNKey, strSN]];
                [strReturnValue setString:[NSString stringWithString:szShowSNs]];
            }
            else
            {
                [strReturnValue setString:@""];
                break;
            }
        }
        [szShowSNs release];
        if ([strReturnValue isEqualToString:@""])
        {
            ATSDebug(@"can't get any SN");
            [strReturnValue setString:@"SN EMPTY"];
            return [NSNumber numberWithBool:NO];
        }
        else
            ATSDebug(@"scan sn %@",strReturnValue);
    }
    else
    {
        ATSDebug(@"The name of the array which defined in the script file is error , or can't find any value from the array ");
        [strReturnValue setString:@"SN EMPTY"];
        return [NSNumber numberWithBool:NO];
    }
	return [NSNumber numberWithBool:YES];
    
}
//End 2011.10.28 Add by Ming

 
//Start 2011.10.29 Add by Ming 
// Descripton: Show a message windows with your setting string
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      such as:
//          ABUTTONS:string(exp:PASS,FAIL)
//          MESSAGE:string(check photo if it have no wrong!)
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)MSGBOX_COMMAND:(NSDictionary*)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    ATSDebug(@"start RunAlterPanel");
	NSString	*szInputMSG		= [dicContents objectForKey:@"MESSAGE"];
    NSString	*szButtons	= [dicContents objectForKey:@"ABUTTONS"];
    NSString    *szTitle = [dicContents objectForKey:@"TITLE"];
	BOOL		bSelfDefine	= [[dicContents objectForKey:@"SELF_DEFINE"]
							   boolValue];
    BOOL		bShowSN		= [[dicContents objectForKey:@"SHOW_SN"]
							   boolValue];
    BOOL		bShowModal	= [[dicContents objectForKey:@"SHOW_MODAL"]
							   boolValue];
    m_bPanelThread	= YES;
    
    NSString *szMSG   =  @"";
    m_iPanelReturnValue = [self TransformKeyToValue:szInputMSG returnValue:&szMSG];
    
    if (szTitle == nil)
        szTitle = @"Attention!!!";
    if (bShowSN) 
    {
        SearchSerialPorts	*searchSPorts	= [[SearchSerialPorts alloc] init];
        NSMutableDictionary	*dicPort		= [[NSMutableDictionary alloc] init];
        NSString			*szBsdPath		= [[m_dicPorts objectForKey:kPD_Device_MOBILE]
											   objectAtIndex:kFZ_SerialInfo_SerialPort];
        [searchSPorts SearchPortsNumber:dicPort];
        NSString	*szNumber	= [dicPort valueForKey:szBsdPath];
        szMSG	= [NSString stringWithFormat:@"%@ KongCable SN:%@",szMSG,szNumber];
        [searchSPorts release];
        [dicPort release];
    }
    
    if (szMSG == nil || szButtons == nil)
	{
        ATSDebug(@"No Message or no button number!");
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = @"设定挡没有预设消息对话框的内容和按键的种类。(There are no Msg and Button No.)";
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
    }
	else
    {
        NSArray	*arrString	= [szButtons componentsSeparatedByString:@","];
        //the parameter is @" "
        if (bShowModal)
		{
            judgePanel	*m_judgePanel;
            m_judgePanel	= [judgePanel initJudgePanel];	
            [m_judgePanel showMoal:szMSG
					   ReturnValue:strReturnValue];
            ATSDebug(@"input value: %@", [[m_judgePanel m_InputData] stringValue]);
			ATSDebug(@"Final Return Value %@", strReturnValue);
            [m_judgePanel releaseJudgePanel];
            return [NSNumber numberWithBool:YES];
        }
        else if ([@" " isEqualToString:szButtons]) 
        {
            m_bPanelThread	= NO;
            if (bSelfDefine)
                [NSThread detachNewThreadSelector:@selector(start_selfPanel_Thread:)
										 toTarget:self
									   withObject:dicContents];
            else
            {
                NSAlert *alert = [[NSAlert alloc]init];
                alert.messageText = @"Attention!!!";
                alert.informativeText = szMSG;
                [alert layout];
                m_panel = [alert window];
                [alert release];
                ATSDebug(@"[NSThread detachNewThreadSelector:@selector(Start_AutoClose_Panel_Thread:) toTarget:self withObject:dicContents];");
                [NSThread detachNewThreadSelector:@selector(Start_Panel_Thread:) toTarget:self withObject:dicContents];
            }
        }
        //the parameter is one button name
        else
        { 
            if (1 == [arrString count])
            {
                if (bSelfDefine)
                    [NSThread detachNewThreadSelector:@selector(start_selfPanel_Thread:)
											 toTarget:self
										   withObject:dicContents];
                else
                {
                    ATSDebug(@"panel = NSGetAlertPanel(@WARNING, szMSG, @YES, @, @);");
                    [self performSelectorOnMainThread:@selector(ShowAlertPanel:)
										   withObject:[NSArray arrayWithObjects:szTitle,szMSG,szButtons,nil]
                                        waitUntilDone:YES];
                }
            }
            //two button name
            else if (2 <= [arrString count])
            {
                if (bSelfDefine)
                    [NSThread detachNewThreadSelector:@selector(start_selfPanel_Thread:)
											 toTarget:self
										   withObject:dicContents];
                else
                {
                    NSString	*szFirstButton	= [arrString objectAtIndex:0];
                    NSString	*szSecondButton	= [arrString objectAtIndex:1];
                    if (m_CGSN)	// Add by soshon,To Get CGSN
						szMSG	= [NSString stringWithFormat:
								   @"SN is %@!!!\n%@",
								   m_CGSN, szMSG];
                    [self performSelectorOnMainThread:@selector(ShowAlertPanel:)
                                           withObject:[NSArray arrayWithObjects:szTitle,szMSG,szFirstButton,szSecondButton,nil]
                                        waitUntilDone:YES];
                }
            }
        }
    }
	do
    {
		[NSThread sleepForTimeInterval:1];
		ATSDebug(@"Wait Panel......End %lu",m_iPanelReturnValue);
	}while (m_bPanelThread == YES);
	
    if(m_iPanelReturnValue == 1)
    [strReturnValue setString:@"Yes"];
	else
		[strReturnValue setString:@"No"];
	ATSDebug(@"panel return value: %lu",m_iPanelReturnValue);
    // For DWF station to choose which kind mobile to test
    BOOL bISNOResult =[[dicContents objectForKey:@"ISNORESULT"]boolValue];
    if(bISNOResult)
    {
        return [NSNumber numberWithBool:YES];
    }
    return [NSNumber numberWithBool:m_iPanelReturnValue];
    
}

-(void)ShowAlertPanel:(id)dicContect
{
    NSColor			*color	= [m_dicMemoryValues valueForKey:kPD_AMIOK_PanelColor];
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = [dicContect objectAtIndex:0];
    alert.informativeText = [dicContect objectAtIndex:1];
    if ([dicContect count] > 3)
    {
        [alert addButtonWithTitle:[dicContect objectAtIndex:2]];
        [alert addButtonWithTitle:[dicContect objectAtIndex:3]];
    }
    else
    if ([dicContect count] > 2)
    {
        [alert addButtonWithTitle:[dicContect objectAtIndex:2]];
    }
    else
    if ([dicContect count] < 2)
    {
        [alert release];
        return ;
    }
    if(color)
        [alert.window setBackgroundColor:color];
    if ([dicContect count] == 2)
    {
        ATSDebug(@"Panel beginModalSessionForWindow");
        NSArray * aryButtons = alert.buttons;
        for (NSInteger i = 0; i<[aryButtons count];i++)
            [[aryButtons objectAtIndex:i] setHidden:YES];
        [alert layout];
        m_session			= [NSApp beginModalSessionForWindow:[alert window]];
        m_iPanelReturnValue	= [NSApp runModalSession:m_session];
        [alert release];
    }
    else {
        m_iPanelReturnValue = [alert runModal];
        if (m_iPanelReturnValue == NSAlertFirstButtonReturn) {
            m_iPanelReturnValue = 1;
        }
        if (m_iPanelReturnValue == NSAlertSecondButtonReturn) {
            m_iPanelReturnValue = 0;
        }
        ATSDebug(@"Panel Click %lu",m_iPanelReturnValue);
        m_bPanelThread = NO;
        [alert release];
    }
}

//End 2011.10.29 Add by Ming

//add remark by desikan 2012.4.19
// Descripton: thread function to pop up a panel witch is already define before the thread 
// 
// Param:
//      idThread: a dictionary include the message box info set in script file 
//          key:    ABUTTONS :set the title of the buttons on the panel，and help to define the count of button
//                  eg: ABUTTONS is "PASS,FAIL"  means we need 2 button and the title of these two button is "PASS" and "FAIL".
//                      ABUTTONS is "OK" means we need 1 button and it's title is "OK".
//                      if it is " ",the panel will have no button to close it. 
//                      so we need to call the function "CLOSE_MESSAGE_BOX:RETURN_VALUE:"to close it.
- (void)Start_Panel_Thread:(id)idThread
{
	NSAutoreleasePool	*pool	= [[NSAutoreleasePool alloc] init];
	ATSDebug(@"Start_Thread begin");
    
    NSString		*szButtons	= [idThread objectForKey:@"ABUTTONS"]; 
    if([@" " isEqualToString:szButtons])
    {
        m_session			= [NSApp beginModalSessionForWindow:m_panel];
        m_iPanelReturnValue	= (int)[NSApp runModalSession:m_session];
		NSColor			*color	= [m_dicMemoryValues valueForKey:kPD_AMIOK_PanelColor];
		if(color)
			[m_panel setBackgroundColor:color];
    }
    else
	{
//        m_iPanelReturnValue	= [NSApp runModalForWindow:m_panel];
        if (m_iPanelReturnValue==0 || m_iPanelReturnValue==1)
        {
            m_bPanelThread	= NO;
        
            [NSThread sleepForTimeInterval:1.0];
        }
    }
    ATSDebug(@"Start_Panel_Thread end");
	[pool drain];
}

// add remark by desikan 2012.4.19
// Descripton: thread function to pop up a panel with self define in function “- (void)beginSheetWithWindow:(NSWindow *)window panelContents:(NSDictionary *)dicPanelContents”
//      eg. for grounding   we may need to add some picture on the panel
// Param:
//      idThread: a dictionary include the message box info
- (void)start_selfPanel_Thread:(id)idThread
{
	NSAutoreleasePool	*pool	= [[NSAutoreleasePool alloc] init];
    judgePanel			*m_judgePanel;
	m_judgePanel		= [judgePanel initJudgePanel];	
    [m_judgePanel beginSheetWithWindow:nil
						 panelContents:idThread];
    m_iPanelReturnValue	= [m_judgePanel RUNJUDGEPANEL];
	m_bPanelThread		= NO;
	[pool drain];
}

//Start 2011.10.29 Add by Ming 
// Descripton: Close a message windows
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)CLOSE_MESSAGE_BOX:(NSDictionary*)dicContents
				 RETURN_VALUE:(NSMutableString*)strReturnValue
{
	[NSApp endModalSession:m_session];
	[NSApp endSheet:m_panel];
	[m_panel orderOut:self];
	if (m_panel != nil)
	{
		//NSReleaseAlertPanel(m_panel);
		m_panel	= nil;
	}
	return [NSNumber numberWithBool:YES];
}
//End 2011.10.29 Add by Ming

// torres 2011/11/30
// Descripton : Compare figure value in memory dictionary with the keys or deal with a array in memory dictionary with one key.
// Detail : if only one key in script file,default to be a array value,and make sure the object in array is a NSNumber,
//          bring a up-order to the array,and replace the undicsposed array with the seriation array,return the MAX or MIN.
//          else two or more keys,get each value from memory dictionary,and return the MAX or MIN.
// Param:
//      dicpare   --->  KEY         The keys of the value you memoried
//                                      FORMAT : KeyName /or/ KeyNameOne,keyNameTwo,.......
//                      TYPE        MAX/MIN(default MAX)
//      strReturnValue  ---> Return the max or min.
-(NSNumber *)COMPARE_WITH_KEY:(NSDictionary *)dicpara
				 RETURN_VALUE:(NSMutableString *)szReturnValue
{
    //Basic judge
    if (![dicpara isKindOfClass:[NSDictionary class]]
        || ![dicpara objectForKey:kFZ_Script_MemoryKey]
        || ![szReturnValue isKindOfClass:[NSString class]]) 
        return [NSNumber numberWithBool:NO];

    //do arithmetic with two values
    NSArray	*aryKeyNames	= [[dicpara objectForKey:kFZ_Script_MemoryKey]
							   componentsSeparatedByString:kFunnyZoneComma];
    double	fMax, fMin;
    if (1 == [aryKeyNames count])
	{
        //deal with array
        NSArray	*aryUndisposed	= [m_dicMemoryValues objectForKey:
								   [dicpara objectForKey:kFZ_Script_MemoryKey]];
        if (nil == aryUndisposed
			|| ![aryUndisposed isKindOfClass:[NSArray class]]
			|| 0 == [aryUndisposed count])
		{
            ATSDebug(@"COMPARE_WITH_KEY : Read value from memory dictionary fail[KEY:%@]!",
					 [dicpara objectForKey:kFZ_Script_MemoryKey]);
            return [NSNumber numberWithBool:NO];
        }
        
        //bring a up-order to the array
        NSArray	*arySeriation	= [m_mathLibrary BringOrderToArray:aryUndisposed];
        
        //replace the undicsposed array with the seriation one
        if (nil == arySeriation)
		{
            ATSDebug(@"COMPARE_WITH_KEY : BringOrderToArray Error!");
            return [NSNumber numberWithBool:NO];
        }
        [m_dicMemoryValues setObject:arySeriation
							  forKey:[dicpara objectForKey:kFZ_Script_MemoryKey]];
        
        ATSDebug(@"COMPARE_WITH_KEY : Bring a order to the undisposed array[KEY:%@]!",
				 [dicpara objectForKey:kFZ_Script_MemoryKey]);
        fMin	= [[arySeriation objectAtIndex:0] doubleValue];
        fMax	= [[arySeriation objectAtIndex:[arySeriation count] -1] doubleValue];
    }
    else
	{
        //deal with some single value
        fMin = fMax	= [[m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:0]] doubleValue];
        for (int i1=1 ; i1<[aryKeyNames count] ; i1++)
		{
            if (![m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:i1]])
			{
                ATSDebug(@"COMPARE_WITH_KEY : Read value from memory dictionary fail!");
                return [NSNumber numberWithBool:NO];
            }
            fMax	= MAX(fMax, [[m_dicMemoryValues objectForKey:
								  [aryKeyNames objectAtIndex:i1]] doubleValue]);
            fMin	= MIN(fMin, [[m_dicMemoryValues objectForKey:
								  [aryKeyNames objectAtIndex:i1]] doubleValue]);
        }
    }

    if ([[dicpara objectForKey:KIADeviceKey_TYPE]
		 isEqualToString:KIADeviceKey_COMPARE_MIN])
        [szReturnValue setString:[NSString stringWithFormat:@"%.5f", fMin]];
    else
        [szReturnValue setString:[NSString stringWithFormat:@"%.5f", fMax]];
    return [NSNumber numberWithBool:YES];
}

// torres 2011/11/30
// Descripton : transform the value in memory dictionary with the key to ABS. torres 2011/11/7
//      KEY :  KeyName /or/ NULL
//          if has a key,read value from memory dictionary,else NULL key,deal with the m_szReturnValue. 
//      TYPE:   set the type,default int. 
-(NSNumber *)TRANSFER_DATA_ABS:(NSDictionary *)dicSubSetting
				  RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*szKey	= [dicSubSetting objectForKey:kFZ_Script_MemoryKey];
    
    //  transform data without key
    if (nil == szKey || [szKey isEqualToString:kFunnyZoneBlank])
    {
        if ([[dicSubSetting objectForKey:KIADeviceKey_TYPE]
			 isEqualToString:KIADeviceKey_TYPE_DOUBLE])
            [szReturnValue setString:[NSString stringWithFormat:
									  @"%.5f",fabs([szReturnValue doubleValue])]];
        else
            [szReturnValue setString:[NSString stringWithFormat:
									  @"%d",abs([szReturnValue intValue])]];
    }
    else
    {
        // if the value with key is not exist at memory value,return NO.
        if (nil == [m_dicMemoryValues objectForKey:szKey])
		{
            ATSDebug(@"TRANSFER_DATA_ABS : Read value from memory dictionary fail[KEY:%@]!",
					 szKey);
            return [NSNumber numberWithBool:NO];
        }
        NSString	*szValue	= [m_dicMemoryValues objectForKey:szKey];
        if ([[dicSubSetting objectForKey:KIADeviceKey_TYPE]
			 isEqualToString:KIADeviceKey_TYPE_DOUBLE])
            [szReturnValue setString:[NSString stringWithFormat:
									  @"%.5f",fabs([szValue doubleValue])]];
        else
            [szReturnValue setString:[NSString stringWithFormat:
									  @"%d",abs([szValue intValue])]];
    }
    return [NSNumber numberWithBool:YES];
}

// torres 2011/11/30
// Descripton : Calibration average of the memoried values with key,if only one key in script file,default to be a array value,
//              and make sure the object in array is a NSNumber,else two or more keys,get each value from memory dictionary.
// Parameter : 
//          NSDictionary    *dicPara 
//                  KEY     -> NSString*    :   the keys of the value you memoried
//                                              FORMAT : keyNmae /or/ keyNameOne,keyNameTwo,keyNameThree  ...
//                  ABS     ->  BOOL        :   the values that are caculated  will transfer to the absolute value
//          NSMutableString *szReturnValue  :   Return value
//              
//      Return:
//          Actions result  
-(NSNumber *)AVERAGE_WITH_KEYS:(NSDictionary *)dicPara
				  RETURN_VALUE:(NSMutableString *)szReturnValue
{     
    bool	bABS	= [[dicPara objectForKey:KIADeviceKey_ABS]
					   boolValue];//added by lucy
    //Basic judge
    if (![dicPara isKindOfClass:[NSDictionary class]]
        || ![[dicPara objectForKey:kFZ_Script_MemoryKey]
			 isKindOfClass:[NSString class]]
        || ![szReturnValue isKindOfClass:[NSString class]]) 
    {
        return [NSNumber numberWithBool:NO];
    }
    //get the average with the keys in the input parameter
    NSArray	*aryKeyNames	= [[dicPara objectForKey:kFZ_Script_MemoryKey]
							   componentsSeparatedByString:kFunnyZoneComma];
    double	nSum			= 0.0;
    if (1 == [aryKeyNames count])
	{
        NSArray	*aryValue	= [m_dicMemoryValues objectForKey:[dicPara objectForKey:kIADeviceKey]];
        if (nil == aryValue
			|| ![aryValue isKindOfClass:[NSArray class]]
			|| 0 == [aryValue count])
		{
            ATSDebug(@"AVERAGE_WITH_KEYS : Read value from memory dictionary fail[KEY:%@]!",
					 [dicPara objectForKey:kFZ_Script_MemoryKey]);
            return [NSNumber numberWithBool:NO];
        }
        double	average	= [m_mathLibrary GetAverageWithArray:aryValue
													NeedABS:bABS];
        if ([kFZ_99999_Value_Issue doubleValue] == average)
		{
            ATSDebug(@"-99999issue");
            ATSDebug(@"AVERAGE_WITH_KEYS : GetAverageWithArray return error!");
            return [NSNumber numberWithBool:NO];
        }
        [szReturnValue setString:[NSString stringWithFormat:@"%.5f",average]];
    }
    else
	{
        for (NSString *szKey in aryKeyNames)
        {   
            if(bABS)
			{
                if(nil != [m_dicMemoryValues objectForKey:szKey])
                    nSum	+= fabs([[m_dicMemoryValues objectForKey:szKey] doubleValue]);
                else
				{
                    ATSDebug(@"AVERAGE_WITH_KEYS : no value in dicMemoryValues with key[%@]",
							 szKey);
                    return [NSNumber numberWithBool:NO];
                }
                //added by lucy for current Dlog value 11.11.11
            }
            else
			{
                if (nil != [m_dicMemoryValues objectForKey:szKey])
                    nSum	+= [[m_dicMemoryValues objectForKey:szKey] doubleValue];
                else
				{
                    ATSDebug(@"AVERAGE_WITH_KEYS : no value in dicMemoryValues with key[%@]",
							 szKey);
                    return [NSNumber numberWithBool:NO];
                }
            }
        }
        [szReturnValue setString:[NSString stringWithFormat:
								  @"%.5f", nSum / [aryKeyNames count]]];
    }
    return [NSNumber numberWithBool:YES];
}

// torres 2011/11/30
// Get the complement value of the previous szReturnValue with bit number
//      Parameter:
//
//          NSDictionary    *dicPara        :   Setting
//              DATABITS    ->  NSString*   :   The bits of the value(8 or 16)
//          NSMutableString  *szReturnValue :   Return value
//
//      Return:
//          Action result
-(NSNumber *)GET_INT_COMPLEMENT_WITH_BIT:(NSDictionary *)dicPara
							 ReturnValue:(NSMutableString *)szReturnValue
{
    //Basic judge
    if (![dicPara isKindOfClass:[NSDictionary class]]
        || ![dicPara objectForKey:kIADevicePortDataBits]
        || ![szReturnValue isKindOfClass:[NSString class]]) 
        return [NSNumber numberWithBool:NO];
    if (![[dicPara objectForKey:kIADevicePortDataBits] intValue])
	{
        ATSDebug(@"GET_INT_COMPLEMENT_WITH_BIT : No int data in m_szReturnValue or not send bit number");
        return [NSNumber numberWithBool:NO];
    }
    [szReturnValue setString:[NSString stringWithFormat:@"%d",
                              [m_mathLibrary GetComplementOfInt:[szReturnValue intValue] 
													  BitNumber:[[dicPara objectForKey:
																  kIADevicePortDataBits]
																 intValue]]]];
    ATSDebug(@"GET_INT_COMPLEMENT_WITH_BIT : Calculate complement value:%@ with bits[%d]",
			 szReturnValue, [[dicPara objectForKey:kIADevicePortDataBits] intValue]);
    return [NSNumber numberWithBool:YES];
}

// torres 2011/11/30
//  Do minus arithmetic with two values of keys,the frist value minus the second value
//      Parameter : 
//
//          NSDictionary    *dicPara 
//                  KEY     -> NSString*    :   the keys of the value you memoried
//                                              FORMAT : keyNameOne,keyNameTwo
//                  ABS     -> Boolean      :   if YES,return ABS value,else return normal
//          NSMutableString *szReturnValue  :   Return value
//              
//      Return:
//          Actions result  
- (NSNumber *)MINUS_WITH_KEYS:(NSDictionary *)dicPara
				 RETURN_VALUE:(NSMutableString *)szReturnValue
{
    //Basic judge
    if (![dicPara isKindOfClass:[NSDictionary class]]
        || ![dicPara objectForKey:kFZ_Script_MemoryKey]
        || ![szReturnValue isKindOfClass:[NSString class]]) 
        return [NSNumber numberWithBool:NO];
    
    //do minus arithmetic with two values
    NSArray	*aryKeyNames	= [[dicPara objectForKey:kFZ_Script_MemoryKey]
							   componentsSeparatedByString:kFunnyZoneComma];
    if (nil == [m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:0]]
		|| nil == [m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:1]])
	{
        ATSDebug(@"MINUS_WITH_KEYS : No decimal data with keys[%@]",
				 aryKeyNames);
        if ([[dicPara objectForKey:@"IgnoreKey"] boolValue])
            return [NSNumber numberWithBool:YES];
        else
            return [NSNumber numberWithBool:NO];
    }
    double	iMinus	= ([[m_dicMemoryValues objectForKey:
						 [aryKeyNames objectAtIndex:0]] doubleValue]
					   - [[m_dicMemoryValues objectForKey:
						   [aryKeyNames objectAtIndex:1]] doubleValue]);
    if ([[dicPara objectForKey:KIADeviceKey_ABS] boolValue])
	{
        [szReturnValue setString:[NSString stringWithFormat:
								  @"%.2f",fabs(iMinus)]];
        ATSDebug(@"MINUS_WITH_KEYS : Calculate minus value[%@] with ABS",
				 szReturnValue);
    }
    else
	{
        [szReturnValue setString:[NSString stringWithFormat:
								  @"%.2f",iMinus]];
        ATSDebug(@"MINUS_WITH_KEYS : Calculate minus value[%@] without ABS",
				 szReturnValue);
    }
    return [NSNumber numberWithBool:YES];
}

// add remark by desikan 2012.4.19
// Descripton : read retrun data when notification happen and encoding the data to string then append it
// Parameter : 
//          note: notification info , include the data get by the task
//         
- (void)ReadData:(NSNotification *)note
{
    NSData		*dataTemp	= [[note userInfo] objectForKey:
							   NSFileHandleNotificationDataItem];
    NSString	*szTemp		= [[NSString alloc] initWithData:dataTemp
											  encoding:NSASCIIStringEncoding];
    // old value append new value
    [m_muszValue appendString:[NSString stringWithString:szTemp]];
    [szTemp release];
}


// add remark by desikan 2012.4.19
// Descripton : deal with the data  get from the task and then memoried it as key "DataForRead" 
//      and set the ReadTimeOut to 21
// Parameter :  
//      pipeOutPut : include the date get by the task
// 
- (void)ReadDataToEnd:(NSPipe *) pipeOutput
{
    //add NSAutoreleasePool for avoiding memory leak by jingfu ran on 2012 05 10
    NSAutoreleasePool	*pool	= [[NSAutoreleasePool alloc] init];
    NSData				*data	= [[pipeOutput fileHandleForReading]
								   readDataToEndOfFile];
    NSString			*szTemp	= [[NSString alloc] initWithData:data
											   encoding:NSUTF8StringEncoding];
    [m_dicMemoryValues setObject:szTemp forKey:@"DataForRead"];
    [m_dicMemoryValues setObject:@"21" forKey:@"ReadTimeOut"];
    [szTemp release];
    [pool drain];
}

/*
 * Kyle 2012.02.10
 * abstract   : call a task for user system tool
 * parameters :
 *              szPath        ==> path of task
 *              args          ==> parameters of task
 *              EndString     ==> read data until find EndString
 *              iSeconds      ==> time out , unit is second
 *              szReturnValue ==> get string value
 */
- (BOOL)CallTask:(NSString *)szPath
	   Parameter:(NSArray *)args
	   EndString:(NSString *)EndString
		 TimeOut:(NSNumber *)iSeconds
	 ReturnValue:(NSMutableString *)szReturnValue
{
    NSFileManager	*fMag	= [NSFileManager defaultManager];
    if (![fMag fileExistsAtPath:szPath]) 
    {
        ATSDebug(@"Can't find tool at path !");
        [szReturnValue setString:@""];
        return NO;
    }
    
    BOOL			bFlag			= YES;
    m_muszValue	= [[NSMutableString alloc] initWithString:@""];
    NSTask			*task			= [[NSTask alloc] init];
    NSPipe			*pipeOutput		= [[NSPipe alloc] init];
    NSFileHandle	*fHandleOutput	= [pipeOutput fileHandleForReading];
    
    [task setLaunchPath:szPath];
    [task setStandardOutput:pipeOutput];
    [task setArguments:args];
    
    [task launch];
    if (iSeconds) 
    {
        NSNotificationCenter	*nc	= [NSNotificationCenter defaultCenter];
        [nc addObserver:self
			   selector:@selector(ReadData:)
				   name:NSFileHandleReadCompletionNotification
				 object:fHandleOutput];
        [fHandleOutput readInBackgroundAndNotify];
    
        int			iTimeOut	= 0;
        NSRunLoop	*RunLoop	= [NSRunLoop currentRunLoop];
		// set wait 1 second every time
        NSDate		*dateTime	= [NSDate dateWithTimeIntervalSinceNow:1];
        while (iTimeOut < [iSeconds intValue])
		{	// repetition iSeconds seconds
            if (EndString
				&& [[NSString stringWithString:m_muszValue]
					ContainString:EndString])
                break;
            [RunLoop runUntilDate:dateTime];
            iTimeOut++;;
        }
    
        [szReturnValue setString:[NSString stringWithString:m_muszValue]];
    
        [nc removeObserver:self
					  name:NSFileHandleReadCompletionNotification
					object:fHandleOutput];
    }
    else
    {
        [m_dicMemoryValues setObject:@"0"
							  forKey:@"ReadTimeOut"];
        [m_dicMemoryValues setObject:@"No Data"
							  forKey:@"DataForRead"];
        [NSThread detachNewThreadSelector:@selector(ReadDataToEnd:)
								 toTarget:self
							   withObject:pipeOutput];
        while ([[m_dicMemoryValues objectForKey:@"ReadTimeOut"] intValue] < 15) 
        {
            int	iTemp	= [[m_dicMemoryValues objectForKey:@"ReadTimeOut"] intValue];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iTemp + 1]
								  forKey:@"ReadTimeOut"];
            sleep(1);
        }
        if ([[m_dicMemoryValues objectForKey:@"DataForRead"]
			 isEqualToString:@"No Data"])
            bFlag	= NO;
        
        [szReturnValue setString:[NSString stringWithString:
								  [m_dicMemoryValues objectForKey:@"DataForRead"]]];
    }
    [pipeOutput release];
    [task terminate];
    [task release];
    [m_muszValue release];
    
    return bFlag;
}

/**
 * Kyle 2012.02.13
 * method       : GetKongCableVersion:RETURN_VALUE:
 * abstract     : use astrisctl for get kong cable version
 *              dictSettings:   setting info in script file
 *              key:    Unit:  if the value of "bIS_1_to_N" in setting file is ture, get the key from script file to get the path of device
                        Path:     the task tool path
 *              szReturnValue:  the cable's version
 */
- (NSNumber *)GetKongCableVersion:(NSDictionary*)dictSettings
					 RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString	*szPortType				= [dictSettings objectForKey:kFZ_Script_DeviceTarget];
	NSString	*szBsdPath				= [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
    NSString			*szToolPath		= [dictSettings objectForKey:@"Path"];
    SearchSerialPorts	*searchSPorts	= [[SearchSerialPorts alloc] init];
    NSMutableDictionary	*muDic			= [[NSMutableDictionary alloc] init];
    [searchSPorts SearchPortsNumber:muDic];
    
    NSString	*szNumber	= [muDic valueForKey:szBsdPath];
    NSArray		*args		= [NSArray arrayWithObjects:
							   @"--host",
							   [NSString stringWithFormat:@"kong-%@",szNumber],
							   @"info", nil];
    [self CallTask:szToolPath
		 Parameter:args
		 EndString:nil
		   TimeOut:nil
	   ReturnValue:szReturnValue];
    
    [muDic release];
    [searchSPorts release];
    
    NSString	*szVersion	= [NSString stringWithString:szReturnValue];
    if ([szVersion ContainString:@"Firmware version:  "]
		&& [szVersion ContainString:@"Board serial #:"])
    {
        szVersion	= [[szVersion SubFrom:@"Firmware version:  "
								include:NO] SubTo:@"Board serial #:" include:NO];
        [szReturnValue setString:szVersion];
    }
    else
    {
        ATSDebug(@"return value error");
        [szReturnValue setString:@"Can't get kong cable version!"];
        return [NSNumber numberWithBool:NO];
    }
    
    return [NSNumber numberWithBool:YES];
}

// add notes by betty 2012/4/17
// use dfuit tool
//      Parameter:
//
//          NSDictionary    *dictSettings
//              ToolPath    ->  NSString*   :   path of dfuit
//              FilePath    ->  NSString*   :   path of RamDish_v1.dmg
//          NSMutableString  *szReturnValue :   Return value
//
//      Return:
//          Action result
- (NSNumber *)GetUSBStress:(NSDictionary*)dictSettings
			  RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString		*szToolPath		= [dictSettings objectForKey:@"ToolPath"];
    NSString		*szFilePath		= [dictSettings objectForKey:@"FilePath"];
    NSFileManager	*fileManager	= [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:szFilePath]) 
    {
        ATSDebug(@"Cant't find file at %@", szFilePath);
        return [NSNumber numberWithBool:NO];
    }
    
    NSArray	*args	= [NSArray arrayWithObjects:
					   @"-f",
					   szFilePath, nil];
    if (![self CallTask:szToolPath
			  Parameter:args
			  EndString:nil
				TimeOut:nil
			ReturnValue:szReturnValue])
        return [NSNumber numberWithBool:NO];
    
    return [NSNumber numberWithBool:YES];
}

// add notes by betty 2012/4/17
//  Do divid arithmetic with two values of keys,the dividend value divide the Divisor value
//      Parameter : 
//
//          NSDictionary    *dicPara 
//                  Divisor -> NSString*    :   the key of the value you memoried for divisor
//                  Dividend-> NSString*    :   the key of the value you memoried for dividend
//          NSMutableString *szReturnValue  :   Return value
//              
//      Return:
//          Actions result
- (NSNumber *)CalculateCurrent:(NSDictionary*)dictSettings
				  RETURN_VALUE:(NSMutableString*)szReturnValue
{
    if (!szReturnValue
		|| ![m_dicMemoryValues objectForKey:[dictSettings objectForKey:@"Dividend"]]
		|| ![dictSettings objectForKey:@"Divisor"]
		|| (0 == [[m_dicMemoryValues objectForKey:
				   [dictSettings objectForKey:@"Dividend"]] floatValue]))
    {
        [szReturnValue setString:kFZ_99999_Value_Issue];
        return [NSNumber numberWithBool:NO];
    }
    float	fdividend	= [[m_dicMemoryValues objectForKey:
							[dictSettings objectForKey:@"Dividend"]] floatValue];
    float	fdivisor	= [[dictSettings objectForKey:@"Divisor"] floatValue];
    float	fquotient	= fdividend/fdivisor;
    [szReturnValue setString:[NSString stringWithFormat:@"%f",fquotient]];
    return [NSNumber numberWithBool:YES];
    
}

// Ken 2012/05/26
//  Call Application
//      Parameter : 
//          NSDictionary    *dicSettings
//                  TARGET  -> NSString*    :   the Application path
//          NSMutableString *szReturnValue  :   Return value
//
- (NSNumber *)LAUNCH_APP:(NSDictionary*)dicSettings
			RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString	*szApp	= [dicSettings valueForKey:@"TARGET"];
    NSWorkspace	*App	= [NSWorkspace sharedWorkspace];
    return [NSNumber numberWithBool:[App launchApplication:szApp]];
}

- (void)ColorChooseFinish: (NSNotification* )noti
{
    m_bFinishChoose  = YES;
}

- (void)Thread_Choice
{
    NSAutoreleasePool       *pool   = [[NSAutoreleasePool    alloc]init];
    NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(ColorChooseFinish:)
               name:BNRColorChoiceFinish
             object:nil];
    [nc     postNotificationName:BNRRunColorChoicePanelNotification
                          object:self
                        userInfo:nil];
    [pool    drain];
    
}

// Open a window to chose unit color
- (NSNumber *)MSG_SINGLECHOICE:(NSDictionary   *)dicPara
                  RETURN_VALUE:(NSMutableString*)szReturnValue
{
    m_bFinishChoose     = NO;
    [NSThread   detachNewThreadSelector:@selector(Thread_Choice) toTarget:self withObject:nil];
    return [NSNumber    numberWithBool:YES];
}

- (NSNumber *)WAIT_HERE:(NSDictionary   *)dicPara
           RETURN_VALUE:(NSMutableString*)szReturnValue
{
    do
	{
        usleep(10000);
        NSLog(@"+++++Good");
    } while (!m_bFinishChoose);
    
    NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
    [nc  removeObserver:self name:BNRColorChoiceFinish object:nil];
    
    return [NSNumber    numberWithBool:YES];
}

// Matching test flow
-(NSNumber*)MATCHING_RESULT_TESTFLOW:(NSDictionary*)dicPara
                        RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSArray *arrTestFlow    = m_bSubTest_PASS_FAIL? [dicPara objectForKey:@"PASS"]:[dicPara objectForKey:@"FAIL"];
    
    BOOL    bRet    = YES;
    for (int i = 0; i < [arrTestFlow count]; i++)
    {
        NSDictionary    *dicSubItem = [arrTestFlow objectAtIndex:i];
        NSArray        *arrSubItemNames = [dicSubItem allKeys];
        
        //Check script format
        if ([arrSubItemNames count] != 1)
        {
            [szReturnValue setString:@"The script format error"];
            return [NSNumber numberWithBool:NO];
        }
        
        //Selector test function follow the script test sequence
        NSString        *strSubItemName = [arrSubItemNames objectAtIndex:0];
        NSDictionary    *dicSubItemPara = [dicSubItem objectForKey:strSubItemName];
        SEL selectorFunction    = NSSelectorFromString(strSubItemName);
        if ([self respondsToSelector:selectorFunction])
        {
            bRet &= [[self performSelector:selectorFunction withObject:dicSubItemPara withObject:szReturnValue] boolValue];
        }
        else
        {
            [szReturnValue setString:@"Can't found the selector function"];
            return [NSNumber numberWithBool:NO];
        }
        
//        //It immediately return result once a function test fail. It will skip others untest items
//        if (!bRet)
//        {
//            return [NSNumber numberWithBool:NO];
//        }
        
    }
	return [NSNumber numberWithBool:bRet];
}
@end




