//
//  IADevice_Operation.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.
//

#import "IADevice_Operation.h"


@implementation TestProgress (IADevice_Operation)
//for inform UI have window pop
//NSString * const BNRTestProgressPopWindow = @"TestProgressPopWindow";
//NSString * const BNRTestProgressQuitWindow = @"TestProgressQuitWindow";

//Start 2011.10.28 Add by Ming 
// Descripton:Set the UI's SN be the test item at csv file
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_ISN_FROM_UI:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSArray *arrSNs = [dicContents objectForKey:@"SHOW_SN"];
    if (nil != arrSNs && [arrSNs count] > 0) 
    {
        [strReturnValue setString:@""];
        NSMutableString *szShowSNs=[[NSMutableString alloc] init];
        for (NSString *strSNKey in arrSNs) 
        {
            //NSString *strSNKey=[arrSNs objectAtIndex:i];
            NSString *strSN=[m_dicMemoryValues objectForKey:strSNKey];
            if(strSN && ![strSN isEqualToString:@""])
            {
                [szShowSNs appendString:[NSString stringWithFormat:@"%@:%@;",strSNKey,strSN]];
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
        {
            ATSDebug(@"scan sn %@",strReturnValue);
        }
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
-(NSNumber*)MSGBOX_COMMAND:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    ATSDebug(@"start RunAlterPanel");
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:BNRTestProgressPopWindow object:self];
    
    
    
	NSString        *szMSG = [dicContents objectForKey:@"MESSAGE"];
    NSString        *szButtons = [dicContents objectForKey:@"ABUTTONS"];
	BOOL	 		bSelfDefine= [[dicContents objectForKey:@"SELF_DEFINE"] boolValue];
    BOOL            bShowSN = [[dicContents objectForKey:@"SHOW_SN"] boolValue];
    BOOL            bShowModal = [[dicContents objectForKey:@"SHOW_MODAL"] boolValue];
    m_bPanelThread=YES;
    
    if (bShowSN) 
    {
        SearchSerialPorts *searchSPorts = [[SearchSerialPorts alloc] init];
        NSMutableDictionary *dicPort    = [[NSMutableDictionary alloc] init];
        NSString    *szBsdPath  = [[m_dicPorts objectForKey:kPD_Device_MOBILE] objectAtIndex:kFZ_SerialInfo_SerialPort];
        [searchSPorts SearchPortsNumber:dicPort];
        NSString    *szNumber   = [dicPort valueForKey:szBsdPath];
        szMSG=[NSString stringWithFormat:@"%@ KongCable SN:%@",szMSG,szNumber];
        [searchSPorts release];
        [dicPort release];
    }
    
    if (szMSG == nil || szButtons == nil) {
        ATSDebug(@"No Message or no button number!");
        NSRunAlertPanel(@"警告(Warning)!", @"设定挡没有预设消息对话框的内容和按键的种类。(There are no Msg and Button No.)", @"确认（OK）", nil, nil);
    }
	else 
    {
        NSArray         *arrString = [szButtons componentsSeparatedByString:@","];
        //the parameter is @" "
        if (bShowModal) {
            judgePanel *m_judgePanel;
            m_judgePanel = [judgePanel initJudgePanel];	
            [m_judgePanel showMoal:szMSG ReturnValue:strReturnValue];
            ATSDebug(@"input value: %@",[[m_judgePanel m_InputData] stringValue]);
			ATSDebug(@"Final Return Value %@",strReturnValue);
            [m_judgePanel releaseJudgePanel];
            return [NSNumber numberWithBool:YES];
        }
        else
            
        //When no button, We will wait the response auto and auto dispear,or fail if no right response
        if ([@" " isEqualToString:szButtons]) 
        {
            m_bPanelThread= NO;
            if (bSelfDefine)
            {
                [NSThread detachNewThreadSelector:@selector(start_selfPanel_Thread:) toTarget:self withObject:dicContents];
            }
            else
            {
                ATSDebug(@"panel = NSGetAlertPanel(@WARNING, szMSG, @, @, @);\nszMSG=%@",szMSG);
                m_panel = NSGetAlertPanel(@"Attention!!!", szMSG, @"", @"", @"", nil);
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
                {
                    [NSThread detachNewThreadSelector:@selector(start_selfPanel_Thread:) toTarget:self withObject:dicContents];
                }
                else
                {
                    ATSDebug(@"panel = NSGetAlertPanel(@WARNING, szMSG, @YES, @, @);");
                    m_panel = NSGetAlertPanel(@"Attention!!!", szMSG, szButtons, @"", @"", nil);
                    ATSDebug(@"[NSThread detachNewThreadSelector:@selector(Start_Panel_Thread:) toTarget:self withObject:dicContents];");
                    [NSThread detachNewThreadSelector:@selector(Start_Panel_Thread:) toTarget:self withObject:dicContents];
                }
            }
            //two button name
            else if (2 <= [arrString count])
            {
                if (bSelfDefine)
                {
                    [NSThread detachNewThreadSelector:@selector(start_selfPanel_Thread:) toTarget:self withObject:dicContents];
                }
                else
                {
                    NSString *szFirstButton = [arrString objectAtIndex:0];
                    NSString *szSecondButton = [arrString objectAtIndex:1];
                    NSString *szTemp = [NSString string];
                    if (m_CGSN)
                    {
                        szTemp = [NSString stringWithFormat:@"SN is %@!!!\n",m_CGSN];
                        szMSG = [szTemp stringByAppendingString:szMSG];
                    }                                                      //Add by soshon,To Get CGSN
                    m_panel = NSGetAlertPanel(@"Attention!!!", szMSG, szFirstButton, szSecondButton, @"", nil);
                    [NSThread detachNewThreadSelector:@selector(Start_Panel_Thread:) toTarget:self withObject:dicContents];
                }
            }

        }
    }
	do
    {
		[NSThread sleepForTimeInterval:1];
		ATSDebug(@"Wait Panel......End %d",m_iPanelReturnValue);
        
	}while (m_bPanelThread == YES);
    
	ATSDebug(@"panel return value: %d",m_iPanelReturnValue);
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:BNRTestProgressQuitWindow object:self];
    //[strReturnValue setString:@"PASS to Open Message Box"];
	return [NSNumber numberWithBool:m_iPanelReturnValue];
    
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
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ATSDebug(@"Start_Thread begin");
    NSColor * color = [m_dicMemoryValues valueForKey:kPD_AMIOK_PanelColor];
    NSString        *szButtons = [idThread objectForKey:@"ABUTTONS"]; 
    if(color)
    {
        [m_panel setBackgroundColor:color];
    }
    if([@" " isEqualToString:szButtons])
    {
        m_session = [NSApp beginModalSessionForWindow:m_panel];
        m_iPanelReturnValue = [NSApp runModalSession:m_session];
    }
    else{ 
        m_iPanelReturnValue=[NSApp runModalForWindow:m_panel];
        if (m_iPanelReturnValue==0||m_iPanelReturnValue==1)
        {
            ATSDebug(@"Panel Click %d",m_iPanelReturnValue);
            [NSApp endSheet:m_panel];
            [m_panel orderOut:self];
            m_bPanelThread = NO;
            NSReleaseAlertPanel(m_panel);
        }
    }
    ATSDebug(@"Start_Panel_Thread end");
	[pool drain];
}
//marked by desikan  combine the two function "Start_Panel_Thread" and "Start_AutoClose_Panel_Thread"
//add remark by desikan 2012.4.19
//Descripton: thread function  pop up a panel have one or two button
//dont't neet to call the function "-(NSNumber*)CLOSE_MESSAGE_BOX:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue " to close the panel
// Param:
//      idThread: a dictionary include the message box info
//- (void)Start_Panel_Thread:(id)idThread
//{
//	ATSDebug(@"Start_Panel_Thread");
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    NSColor * color = [m_dicMemoryValues valueForKey:kPD_AMIOK_PanelColor];
//    if(color)
//    {
//        [m_panel setBackgroundColor:color];
//    }
//	ATSDebug(@"Start_Panel_Thread sheet begin");
//    
//    m_iPanelReturnValue=[NSApp runModalForWindow:m_panel];
//    if (m_iPanelReturnValue==0||m_iPanelReturnValue==1)
//    {
//        ATSDebug(@"Panel Click %d",m_iPanelReturnValue);
//        [NSApp endSheet:m_panel];
//        [m_panel orderOut:self];
//        m_bPanelThread = NO;
//        NSReleaseAlertPanel(m_panel);
//    }
//    [pool drain];
//}
// add remark by desikan 2012.4.19
// Descripton: thread function to pop up a panel with self define in function “- (void)beginSheetWithWindow:(NSWindow *)window panelContents:(NSDictionary *)dicPanelContents”
//      eg. for grounding   we may need to add some picture on the panel
// Param:
//      idThread: a dictionary include the message box info
- (void)start_selfPanel_Thread:(id)idThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    judgePanel *m_judgePanel;
	m_judgePanel = [judgePanel initJudgePanel];	
    [m_judgePanel beginSheetWithWindow:nil panelContents:idThread];
    m_iPanelReturnValue = [m_judgePanel RUNJUDGEPANEL];
	m_bPanelThread = NO;
	[pool drain];
}

//Start 2011.10.29 Add by Ming 
// Descripton: Close a message windows
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)CLOSE_MESSAGE_BOX:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
	[NSApp endModalSession:m_session];
	[NSApp endSheet:m_panel];
	[m_panel orderOut:self];
	if (m_panel !=nil)
	{
		NSReleaseAlertPanel(m_panel);
		m_panel=nil;
	}
    //[strReturnValue setString:@"PASS to Close Message Box"];
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
-(NSNumber *)COMPARE_WITH_KEY:(NSDictionary *)dicpara RETURN_VALUE:(NSMutableString *)szReturnValue
{
    //Basic judge
    if (![dicpara isKindOfClass:[NSDictionary class]]
        || ![dicpara objectForKey:kFZ_Script_MemoryKey]
        || ![szReturnValue isKindOfClass:[NSString class]]) 
    {
        return [NSNumber numberWithBool:NO];
    }

    //do arithmetic with two values
    NSArray *aryKeyNames = [[dicpara objectForKey:kFZ_Script_MemoryKey] componentsSeparatedByString:kFunnyZoneComma];
    double fMax,fMin;
    if (1 == [aryKeyNames count]) {
        //deal with array
        NSArray *aryUndisposed = [m_dicMemoryValues objectForKey:[dicpara objectForKey:kFZ_Script_MemoryKey]];
        if (nil == aryUndisposed || ![aryUndisposed isKindOfClass:[NSArray class]] || 0 == [aryUndisposed count]) {
            ATSDebug(@"COMPARE_WITH_KEY : Read value from memory dictionary fail[KEY:%@]!",[dicpara objectForKey:kFZ_Script_MemoryKey]);
            return [NSNumber numberWithBool:NO];
        }
        
        //bring a up-order to the array
        NSArray *arySeriation = [m_mathLibrary BringOrderToArray:aryUndisposed];
        
        //replace the undicsposed array with the seriation one
        if (nil == arySeriation) {
            ATSDebug(@"COMPARE_WITH_KEY : BringOrderToArray Error!");
            return [NSNumber numberWithBool:NO];
        }
        [m_dicMemoryValues setObject:arySeriation forKey:[dicpara objectForKey:kFZ_Script_MemoryKey]];
        
        ATSDebug(@"COMPARE_WITH_KEY : Bring a order to the undisposed array[KEY:%@]!",[dicpara objectForKey:kFZ_Script_MemoryKey]);
        fMin = [[arySeriation objectAtIndex:0] doubleValue];
        fMax = [[arySeriation objectAtIndex:[arySeriation count] -1] doubleValue];
    }
    else {
        //deal with some single value
        fMin = fMax = [[m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:0]] doubleValue];
        for (int i1=1 ; i1<[aryKeyNames count] ; i1++){
            if (![m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:i1]]) {
                ATSDebug(@"COMPARE_WITH_KEY : Read value from memory dictionary fail!");
                return [NSNumber numberWithBool:NO];
            }
            fMax = MAX(fMax, [[m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:i1]] doubleValue]);
            fMin = MIN(fMin, [[m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:i1]] doubleValue]);
        }
    }

    if ([[dicpara objectForKey:KIADeviceKey_TYPE] isEqualToString:KIADeviceKey_COMPARE_MIN]) {
        [szReturnValue setString:[NSString stringWithFormat:@"%.5f",fMin]];
    } else {
        [szReturnValue setString:[NSString stringWithFormat:@"%.5f",fMax]];
    }
    return [NSNumber numberWithBool:YES];
}

// torres 2011/11/30
// Descripton : transform the value in memory dictionary with the key to ABS. torres 2011/11/7
//      KEY :  KeyName /or/ NULL
//          if has a key,read value from memory dictionary,else NULL key,deal with the m_szReturnValue. 
//      TYPE:   set the type,default int. 
-(NSNumber *)TRANSFER_DATA_ABS:(NSDictionary *)dicSubSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szKey = [dicSubSetting objectForKey:kFZ_Script_MemoryKey];
    
    //  transform data without key
    if (nil == szKey || [szKey isEqualToString:kFunnyZoneBlank])
    {
        if ([[dicSubSetting objectForKey:KIADeviceKey_TYPE] isEqualToString:KIADeviceKey_TYPE_DOUBLE])
        {
            [szReturnValue setString:[NSString stringWithFormat:@"%.5f",fabs([szReturnValue doubleValue])]];
        }
        else
        {
            [szReturnValue setString:[NSString stringWithFormat:@"%d",abs([szReturnValue intValue])]];
        }
    }
    else
    {
        // if the value with key is not exist at memory value,return NO.
        if (nil == [m_dicMemoryValues objectForKey:szKey]){
            ATSDebug(@"TRANSFER_DATA_ABS : Read value from memory dictionary fail[KEY:%@]!",szKey);
            return [NSNumber numberWithBool:NO];
        }
        NSString *szValue = [m_dicMemoryValues objectForKey:szKey];
        if ([[dicSubSetting objectForKey:KIADeviceKey_TYPE] isEqualToString:KIADeviceKey_TYPE_DOUBLE])
        {
            [szReturnValue setString:[NSString stringWithFormat:@"%.5f",fabs([szValue doubleValue])]];
        }
        else
        {
            [szReturnValue setString:[NSString stringWithFormat:@"%d",abs([szValue intValue])]];
        }
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
-(NSNumber *)AVERAGE_WITH_KEYS:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue
{     
    bool bABS = [[dicPara objectForKey:KIADeviceKey_ABS] boolValue];//added by lucy 
    //Basic judge
    if (![dicPara isKindOfClass:[NSDictionary class]]
        || ![[dicPara objectForKey:kFZ_Script_MemoryKey] isKindOfClass:[NSString class]] 
        || ![szReturnValue isKindOfClass:[NSString class]]) 
    {
        return [NSNumber numberWithBool:NO];
    }
    //get the average with the keys in the input parameter
    NSArray *aryKeyNames = [[dicPara objectForKey:kFZ_Script_MemoryKey] componentsSeparatedByString:kFunnyZoneComma];
    double nSum = 0.0;
    if (1 == [aryKeyNames count]) {
        NSArray *aryValue = [m_dicMemoryValues objectForKey:[dicPara objectForKey:kIADeviceKey]];
        if (nil == aryValue || ![aryValue isKindOfClass:[NSArray class]] || 0 == [aryValue count]) {
            ATSDebug(@"AVERAGE_WITH_KEYS : Read value from memory dictionary fail[KEY:%@]!",[dicPara objectForKey:kFZ_Script_MemoryKey]);
            return [NSNumber numberWithBool:NO];
        }
        double average = [m_mathLibrary GetAverageWithArray:aryValue NeedABS:bABS];
        if ([kFZ_99999_Value_Issue doubleValue] == average) {
            ATSDebug(@"-99999issue");
            ATSDebug(@"AVERAGE_WITH_KEYS : GetAverageWithArray return error!");
            return [NSNumber numberWithBool:NO];
        }
        [szReturnValue setString:[NSString stringWithFormat:@"%.5f",average]];
    }
    else {
        for (NSString *szKey in aryKeyNames)
        {   
            if(bABS){
                if(nil != [m_dicMemoryValues objectForKey:szKey]){
                    nSum +=fabs([[m_dicMemoryValues objectForKey:szKey] doubleValue]);
                }
                else{
                    ATSDebug(@"AVERAGE_WITH_KEYS : no value in dicMemoryValues with key[%@]",szKey);
                    return [NSNumber numberWithBool:NO];
                }
                //added by lucy for current Dlog value 11.11.11
            }
            else{
                if (nil != [m_dicMemoryValues objectForKey:szKey]){
                    nSum += [[m_dicMemoryValues objectForKey:szKey] doubleValue];
                }
                else{
                    ATSDebug(@"AVERAGE_WITH_KEYS : no value in dicMemoryValues with key[%@]",szKey);
                    return [NSNumber numberWithBool:NO];
                }
            }
        }
        [szReturnValue setString:[NSString stringWithFormat:@"%.5f",nSum/[aryKeyNames count]]];
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
-(NSNumber *)GET_INT_COMPLEMENT_WITH_BIT:(NSDictionary *)dicPara ReturnValue:(NSMutableString *)szReturnValue
{
    //Basic judge
    if (![dicPara isKindOfClass:[NSDictionary class]]
        || ![dicPara objectForKey:kIADevicePortDataBits]
        || ![szReturnValue isKindOfClass:[NSString class]]) 
    {
        return [NSNumber numberWithBool:NO];
    }
    if (![[dicPara objectForKey:kIADevicePortDataBits] intValue]) {
        ATSDebug(@"GET_INT_COMPLEMENT_WITH_BIT : No int data in m_szReturnValue or not send bit number");
        return [NSNumber numberWithBool:NO];
    }
    [szReturnValue setString:[NSString stringWithFormat:@"%d",
                              [m_mathLibrary GetComplementOfInt:[szReturnValue intValue] 
                                                    BitNumber:[[dicPara objectForKey:kIADevicePortDataBits] intValue]]]];
    ATSDebug(@"GET_INT_COMPLEMENT_WITH_BIT : Calculate complement value:%@ with bits[%d]",szReturnValue,[[dicPara objectForKey:kIADevicePortDataBits] intValue]);
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
- (NSNumber *)MINUS_WITH_KEYS:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue
{
    //Basic judge
    if (![dicPara isKindOfClass:[NSDictionary class]]
        || ![dicPara objectForKey:kFZ_Script_MemoryKey]
        || ![szReturnValue isKindOfClass:[NSString class]]) 
    {
        return [NSNumber numberWithBool:NO];
    }
    
    //do minus arithmetic with two values
    NSArray *aryKeyNames = [[dicPara objectForKey:kFZ_Script_MemoryKey] componentsSeparatedByString:kFunnyZoneComma];
    if (nil == [m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:0]] || nil == [m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:1]]) {
        ATSDebug(@"MINUS_WITH_KEYS : No decimal data with keys[%@]",aryKeyNames);
        if ([[dicPara objectForKey:@"IgnoreKey"]boolValue]) {
            return [NSNumber numberWithBool:YES];
        }
        else
            return [NSNumber numberWithBool:NO];
    }
    double iMinus = [[m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:0]] doubleValue] - [[m_dicMemoryValues objectForKey:[aryKeyNames objectAtIndex:1]] doubleValue];
    if ([[dicPara objectForKey:KIADeviceKey_ABS] boolValue]) {
        [szReturnValue setString:[NSString stringWithFormat:@"%.2f",fabs(iMinus)]];
        ATSDebug(@"MINUS_WITH_KEYS : Calculate minus value[%@] with ABS",szReturnValue);
    }
    else{
        [szReturnValue setString:[NSString stringWithFormat:@"%.2f",iMinus]];
        ATSDebug(@"MINUS_WITH_KEYS : Calculate minus value[%@] without ABS",szReturnValue);
    }
    return [NSNumber numberWithBool:YES];
}

/*
 * Kyle 2010.12.13
 * method  : ScientificToDouble:RETURN_VALUE:
 * abstract:
 * key     :
 *
 */

// add remark by desikan 2012.4.19
// Descripton : Change one number from scientfic to normal
// Parameter : 
//          NSDictionary    *dicPara   :None
//          NSMutableString *szReturnValue  :   result of the conversion
//              eg.   change  1.2E3  to 1200
//      Return:
//          Actions result 
//  marked by desikan 2012.4.27  combine with "ChangeScientificToNormal:RETURN_VALUE:"
//- (NSNumber *)ScientificToDouble:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
//{
//    if (nil == szReturnValue || (![szReturnValue isKindOfClass:[NSMutableString class]])) 
//    {
//        ATSDebug(@"szReturnValue is error!");
//        return [NSNumber numberWithBool:NO];
//    }
//    // Split source to 2 parts
//    NSArray *arraySource    = [[NSString stringWithString:szReturnValue] componentsSeparatedByString:@"E"];
//    double  dN              = 0;
//    int     iE              = 0;
//    if((arraySource == NULL)
//       || ([arraySource count] != 2))
//        return [NSNumber numberWithBool:NO];
//    
//    // Scan int from 2 parts
//    NSScanner *scanner      = [NSScanner scannerWithString:[arraySource objectAtIndex:0]];
//    [scanner scanDouble:&dN];
//    scanner = [NSScanner scannerWithString:[arraySource objectAtIndex:1]];
//    [scanner scanInt:&iE];
//    
//    // power and multiplication
//    double  dResult         = dN * pow(10, iE);
//    [szReturnValue setString:[NSString stringWithFormat:@"%lf",dResult]];
//    return [NSNumber numberWithBool:YES];
//}

/*
 * Kyle 2012.02.10
 * abstract   : read retrun data when notification happen
 * parameters :
 */
// add remark by desikan 2012.4.19
// Descripton : read retrun data when notification happen and encoding the data to string then append it
// Parameter : 
//          note: notification info , include the data get by the task
//         
- (void)ReadData:(NSNotification *)note
{
    NSData * dataTemp = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *szTemp  = [[NSString alloc] initWithData:dataTemp encoding:NSASCIIStringEncoding];
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
    NSAutoreleasePool   *pool = [[NSAutoreleasePool alloc] init];
    NSData *data = [[pipeOutput fileHandleForReading] readDataToEndOfFile];
    NSString *szTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
- (BOOL)CallTask:(NSString *)szPath Parameter:(NSArray *)args EndString:(NSString *)EndString TimeOut:(NSNumber *)iSeconds ReturnValue:(NSMutableString *)szReturnValue
{
    NSFileManager *fMag   = [NSFileManager defaultManager];
    if (![fMag fileExistsAtPath:szPath]) 
    {
        ATSDebug(@"Can't find tool at path !");
        [szReturnValue setString:@""];
        return NO;
    }
    
    BOOL bFlag            = YES;
    m_muszValue           = [[NSMutableString alloc] initWithString:@""];
    NSTask *task          = [[NSTask alloc] init];
    NSPipe *pipeOutput    = [[NSPipe alloc] init];
    NSFileHandle *fHandleOutput = [pipeOutput fileHandleForReading];
    
    // set tool path
    [task setLaunchPath:szPath];
    [task setStandardOutput:pipeOutput];
    // set parameters
    [task setArguments:args];
    // execute tool with parameters
    [task launch];
    
    // receive message by time(iSeconds)
    if (iSeconds) 
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(ReadData:) name:NSFileHandleReadCompletionNotification object:fHandleOutput];
        [fHandleOutput readInBackgroundAndNotify];
    
        int iTimeOut       = 0;
        NSRunLoop *RunLoop = [NSRunLoop currentRunLoop];
        NSDate *dateTime   = [NSDate dateWithTimeIntervalSinceNow:1]; // set wait 1 second every time
        while (iTimeOut < [iSeconds intValue]) {                                 // repetition iSeconds seconds
            if (EndString && [[NSString stringWithString:m_muszValue] ContainString:EndString]) 
            {
                break;
            }
            [RunLoop runUntilDate:dateTime];
            iTimeOut++;;
        }
    
        [szReturnValue setString:[NSString stringWithString:m_muszValue]];
    
        [nc removeObserver:self name:NSFileHandleReadCompletionNotification object:fHandleOutput];
    }
    // receive message for 15 times
    else
    {
        [m_dicMemoryValues setObject:@"0" forKey:@"ReadTimeOut"];
        [m_dicMemoryValues setObject:@"No Data" forKey:@"DataForRead"];
        [NSThread detachNewThreadSelector:@selector(ReadDataToEnd:) toTarget:self withObject:pipeOutput];
        while ([[m_dicMemoryValues objectForKey:@"ReadTimeOut"] intValue] < 15) 
        {
            int iTemp = [[m_dicMemoryValues objectForKey:@"ReadTimeOut"] intValue];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iTemp + 1] forKey:@"ReadTimeOut"];
            sleep(1);
        }
        if ([[m_dicMemoryValues objectForKey:@"DataForRead"] isEqualToString:@"No Data"])
        {
            bFlag = NO;
        }
        
        [szReturnValue setString:[NSString stringWithString:[m_dicMemoryValues objectForKey:@"DataForRead"]]];
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
- (NSNumber *)GetKongCableVersion:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString    *szPortType     = [dictSettings objectForKey:kFZ_Script_DeviceTarget];
	bool bIs_1_to_N	=	[[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_IS_1_to_N] boolValue];
	NSString    *szBsdPath;
	if(bIs_1_to_N)
	{
        NSString *szUnit = [dictSettings objectForKey:@"Unit"];
		szBsdPath      = [[[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort] objectForKey:szUnit];
	}
	else
	{
       szBsdPath       = [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
	}
    NSString    *szToolPath         = [dictSettings objectForKey:@"Path"];
    SearchSerialPorts *searchSPorts = [[SearchSerialPorts alloc] init];
    NSMutableDictionary *muDic      = [[NSMutableDictionary alloc] init];
    [searchSPorts SearchPortsNumber:muDic];
    
    NSString    *szNumber           = [muDic valueForKey:szBsdPath];
    NSArray     *args               = [NSArray arrayWithObjects:@"--host",[NSString stringWithFormat:@"kong-%@",szNumber],@"info", nil];
    [self CallTask:szToolPath Parameter:args EndString:nil TimeOut:nil ReturnValue:szReturnValue];
    
    [muDic release];
    [searchSPorts release];
    
    NSString    *szVersion          = [NSString stringWithString:szReturnValue];
    if ([szVersion ContainString:@"Firmware version:  "] && [szVersion ContainString:@"Board serial #:"]) 
    {
        szVersion = [[szVersion SubFrom:@"Firmware version:  " include:NO] SubTo:@"Board serial #:" include:NO];
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
- (NSNumber *)GetUSBStress:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString *szToolPath       = [dictSettings objectForKey:@"ToolPath"];
    NSString *szFilePath       = [dictSettings objectForKey:@"FilePath"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:szFilePath]) 
    {
        ATSDebug(@"Cant't find file at %@",szFilePath);
        return [NSNumber numberWithBool:NO];
    }
    
    NSArray *args = [NSArray arrayWithObjects:@"-f",szFilePath, nil];
    if (![self CallTask:szToolPath Parameter:args EndString:nil TimeOut:nil ReturnValue:szReturnValue])
    {
        return [NSNumber numberWithBool:NO];
    }
    
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

- (NSNumber *)CalculateCurrent:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)szReturnValue
{
    if (!szReturnValue || ![m_dicMemoryValues objectForKey:[dictSettings objectForKey:@"Dividend"]] || ![dictSettings objectForKey:@"Divisor"] || (0 == [[m_dicMemoryValues objectForKey:[dictSettings objectForKey:@"Dividend"]] floatValue])) 
    {
        [szReturnValue setString:kFZ_99999_Value_Issue];
        return [NSNumber numberWithBool:NO];
    }
    float fdividend = [[m_dicMemoryValues objectForKey:[dictSettings objectForKey:@"Dividend"]] floatValue];
    float fdivisor = [[dictSettings objectForKey:@"Divisor"] floatValue];
    float fquotient = fdividend/fdivisor;
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
- (NSNumber *)LAUNCH_APP:(NSDictionary*)dicSettings RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString *szApp = [dicSettings valueForKey:@"TARGET"];
    NSWorkspace *App = [NSWorkspace sharedWorkspace];
    return [NSNumber numberWithBool:[App launchApplication:szApp]];
}

@end
