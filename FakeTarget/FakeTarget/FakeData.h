//
//  FTAppDelegate+FakeData.h
//  FakeTarget
//
//  Created by raniys on 4/1/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import "FTAppDelegate.h"
#import "YYControlPort.h"

@interface FTAppDelegate (FakeData)

//get serial port path
-(NSNumber *)getSerialPorts;

//open target
-(NSNumber *)openTarget:(NSString *)strTarget;

//close target
-(NSNumber *)closeTarget:(id)target;

//keeping receive meesage from port
-(void)readAndSendMessage:(NSString *)strTarget;

-(id)getValueFromXML:(id)inXml
			 mainKey:(NSString *)inMainKey, ...;

@end
