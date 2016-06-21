//
//  LogManager.m
//  Robot-Simul
//
//  Created by Havi on 13-12-25.
//
//

#import "LogManager.h"
#import "Optimization.h"
static NSString *g_szSyncUnitTestedLog = @"";
static NSString *g_szSyncRobotLog = @"";
static NSString *g_szSyncUnitLog = @"";
static NSString *g_szSyncResultLog = @"";
static NSString *g_szSyncConfigation = @"";
@implementation LogManager


@synthesize strDate;

+ (void)creatAndWriteUnitTestedCount:(NSString *)szInfo withPath:(NSString *)path;
{
    @synchronized(g_szSyncUnitTestedLog)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        NSString *szDirectory = [path stringByDeletingLastPathComponent];
        if (![fm fileExistsAtPath:szDirectory])
        {
            [fm createDirectoryAtPath:szDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if (!fileHandle)
        {
            [szInfo writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        else
        {
            NSArray *aryName = [szInfo componentsSeparatedByString:@","];
            NSString *strName = [aryName objectAtIndex:0];
		    NSString *strDate = [aryName objectAtIndex:3];//add for time;
            NSString *strFileInfo = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            NSRange rage = [strFileInfo rangeOfString:strName];
            NSArray *aryFileInfo = [strFileInfo componentsSeparatedByString:@"\n"];
            NSMutableArray *mutableAry = [NSMutableArray arrayWithArray:aryFileInfo];
            if (rage.location != NSNotFound)
            {
                for (int i=0 ;i<[aryFileInfo count];i++)
                {
                    NSString *unit=[aryFileInfo objectAtIndex:i];
                    NSRange range=[unit rangeOfString:strName];
                    if (range.location!=NSNotFound)
                    {
                        NSArray *ary1 = [unit componentsSeparatedByString:@","];
                        NSString * count = [ary1 objectAtIndex:2];
                        int num = [count intValue];
                        num++;
                        NSString *newStr = [NSString stringWithFormat:@"%@,%@,%@,%@",[ary1 objectAtIndex:0],[ary1 objectAtIndex:1],[NSNumber numberWithInt:num],strDate];
                        [mutableAry replaceObjectAtIndex:i  withObject:newStr];
                         break;
                    }
                   
                }
                NSString *strNew = [mutableAry componentsJoinedByString:@"\n"];
                [strNew writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
            }
            else{
            NSData *strData=[[NSData alloc]initWithBytes:(void *)[szInfo UTF8String] length:[szInfo length]];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:strData];
           // [strData release];
            [fileHandle closeFile];
                [strData release];
            }
        }
    }

}

+ (void)creatAndWriteRobotLog:(NSString *)strMsg
{
    @synchronized(g_szSyncRobotLog)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *strDate = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S.%F" timeZone:nil locale:nil];
        NSString *szDirectory = [RobotRunningLog stringByDeletingLastPathComponent];
        if (![fileManager fileExistsAtPath:szDirectory])
        {
            [fileManager createDirectoryAtPath:szDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }

        if (![fileManager fileExistsAtPath:RobotRunningLog])
        {
            if (![fileManager createFileAtPath:RobotRunningLog contents:nil attributes:nil])
            {
                NSRunAlertPanel(@"Error", @"Can not create log file", @"OK", nil, nil);
                NSLog(@"Can not create log file");
                return;
            }
        }
        NSFileHandle *filehandle = [NSFileHandle fileHandleForWritingAtPath:RobotRunningLog];
        NSString *strInfo = [NSString stringWithFormat:@"[%@]:%@\n",strDate,strMsg];

        if (nil == filehandle)
        {
            NSLog(@"can't get filehandle of file %@",RobotRunningLog);
            return;
        }
        @try
        {
            NSLog(@"%@",strInfo);
            NSData *data = [NSData dataWithBytes:[strInfo UTF8String] length:[strInfo length]];
            if (!data)
            {
                NSRunAlertPanel(@"Error", @"szInfo is not a UTF8String", @"OK", nil, nil);
                NSLog(@"szInfo is not a UTF8String");
                return;
            }
            [filehandle synchronizeFile];
            [filehandle seekToEndOfFile];
            [filehandle writeData:data];
            [filehandle closeFile];
        }
        @catch (NSException *exception)
        {
            NSLog(@"write log exception name :%@, description:%@",exception.name,exception.description);
            return;
        }
        @finally {
        }
    }
    
}

+ (void)creatAndWriteResultInfo:(NSString *)szInfo withPath:(NSString *)path
{
    @synchronized(g_szSyncResultLog)
    {
       // NSString *testResult=[NSString stringWithFormat:@"%@, ,%@\n",szWifiInfo,szTestInfo];
        NSFileHandle *fileHandle=[NSFileHandle fileHandleForWritingAtPath:path];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *szDirectory = [path stringByDeletingLastPathComponent];
        if (![fileManager fileExistsAtPath:szDirectory])
        {
            [fileManager createDirectoryAtPath:szDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if (!fileHandle) {
            NSError *error=nil;
            [szInfo writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"There is some error to write: %@",error);
            }
        }else{
            NSData *data=[[NSData alloc]initWithBytes:(void*)[szInfo UTF8String] length:[szInfo length]];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
            [fileHandle closeFile];
            [data release];
        }
    }
}

+ (void)WriteUnitLog:(NSString *)strMsg
{
    @synchronized(g_szSyncUnitLog)
    {
        static int i=0;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *strDate = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S.%F" timeZone:nil locale:nil];
        
        NSString *szDirectory = [StationRunningDetailLog stringByDeletingLastPathComponent];
        if (![fileManager fileExistsAtPath:szDirectory])
        {
            [fileManager createDirectoryAtPath:szDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if (![fileManager fileExistsAtPath:StationRunningDetailLog])
        {
            if (![fileManager createFileAtPath:StationRunningDetailLog contents:nil attributes:nil])
            {
                NSRunAlertPanel(@"Error", @"Can not create log file", @"OK", nil, nil);
                NSLog(@"Can not create log file");
                return;
            }
        }
//        NSLog(@"%@",strMsg);
        NSString *strInfo;
        NSFileHandle *filehandle = [NSFileHandle fileHandleForWritingAtPath:StationRunningDetailLog];
        if (i==0)
        {
            strInfo = [NSString stringWithFormat:@"%@\n",strMsg];
            i++;

        }
        else
            strInfo = [NSString stringWithFormat:@"[%@],%@\n",strDate,strMsg];

        if (nil == filehandle)
        {
            NSLog(@"can't get filehandle of file %@",StationRunningDetailLog);
            return;
        }
        @try
        {
            NSData *data = [NSData dataWithBytes:[strInfo UTF8String] length:[strInfo length]];
            if (!data)
            {
                NSRunAlertPanel(@"Error", @"szInfo is not a UTF8String", @"OK", nil, nil);
                NSLog(@"szInfo is not a UTF8String");
                return;
            }
            [filehandle synchronizeFile];
            [filehandle seekToEndOfFile];
            [filehandle writeData:data];
            [filehandle closeFile];
        }
        @catch (NSException *exception) {
            NSLog(@"write log exception name :%@, description:%@",exception.name,exception.description);
            return;
        }
        @finally {
        }

    }
}

//write the test configation log
+ (void)creatAndWriteTestConfiguration:(NSDictionary *)originalCoordinate withStaion:(NSArray *)station andPath:(NSString *)path
{
	@synchronized(g_szSyncConfigation)
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *szDirectory = [path stringByDeletingLastPathComponent];
		if (![fm fileExistsAtPath:szDirectory])
        {
            [fm createDirectoryAtPath:szDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }

		NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:kTestConfigurationLog];
		if (!fileHandle) {
			NSString *strInfo = [NSString stringWithFormat:@"Input(%@),,,,,,,,\nRobot_Coordinate(%@),,,,,,,,,\nPass_Coordinate(%@),,,,,,,,\nFail_Coordinate(%@),,,,,,,,\n,,,,,,,,\n",[[originalCoordinate objectForKey:kUntestAreaCoordinate]stringByReplacingOccurrencesOfString:@"," withString:@":"],[[originalCoordinate objectForKey:kRobotCoordinate]stringByReplacingOccurrencesOfString:@"," withString:@":"],[[originalCoordinate objectForKey:kPassAreaCoordinate]stringByReplacingOccurrencesOfString:@"," withString:@":"],[[originalCoordinate objectForKey:kFailAreaCoordinate]stringByReplacingOccurrencesOfString:@"," withString:@":"]];
			[strInfo writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
		}
	[fileHandle closeFile];
	NSMutableArray *aryCoordinateStation = [[[NSMutableArray alloc]init]autorelease];
	NSMutableArray *aryTestName = [[[NSMutableArray alloc]init]autorelease];
	for (int i=0; i<[station count]; i++) {
		NSDictionary *dicStation = [station objectAtIndex:i];
		NSArray *aryKeys = [dicStation allKeys];
		[aryTestName addObject:[aryKeys objectAtIndex:0]];
		NSDictionary *dicStationCoordinate = [dicStation objectForKey:[aryKeys objectAtIndex:0]];
		NSDictionary *dicSingleStationCoor = [dicStationCoordinate objectForKey:@"StationCoordinate"];
		[aryCoordinateStation addObject:dicSingleStationCoor];
	}
	
	int iMax = 0;
	int iMin = 99999999;
	for (NSDictionary *dic in aryCoordinateStation) {
		if ([[dic allKeys]count]>iMax) {
			iMax = (int)[[dic allKeys]count];
		}else if ([[dic allKeys]count]<iMin)
			iMin = (int)[[dic allKeys]count];
	}

//	NSLog(@"the max is %d and min is %d",iMax,iMin);
	for (int i=0; i<iMax; i++) {
		NSString *strInfo = [[NSString alloc]init] ;
		NSString *testName = @",";
		for (int j=0; j<[aryCoordinateStation count]; j++) {
			NSDictionary *dicStation = [aryCoordinateStation objectAtIndex:j];
			NSArray *aryKeys = [dicStation allKeys];
			if ([aryKeys count]>i) {

				NSString *strUnitCoordinate = [dicStation objectForKey:[aryKeys objectAtIndex:i]];
				NSString *strUnitName = [aryKeys objectAtIndex:i];
				NSArray *aryCoordinate = [strUnitCoordinate componentsSeparatedByString:@":"];
				strInfo = [strInfo stringByAppendingFormat:@",%@,%@,%@,%@,",strUnitName,[aryCoordinate objectAtIndex:0],[aryCoordinate objectAtIndex:1],[aryCoordinate objectAtIndex:2]];
				if (i==0) {
					//NSInteger k = 1;
					//NSString *string = [[aryKeys objectAtIndex:0] substringToIndex:k];
					testName = [testName stringByAppendingFormat:@"%@_Station,X,Y,Z,,",[aryTestName objectAtIndex:j]];
				}
			}else{
				strInfo = [strInfo stringByAppendingFormat:@",,,,,"];
			}
		}
		@try {
			
		
		NSString *strCoorInfo = [NSString stringWithFormat: @"%d,%@\n",i,strInfo];
		
		
		NSFileHandle *fileHandle1 = [NSFileHandle fileHandleForWritingAtPath:kTestConfigurationLog];
		if (fileHandle1) {
			NSData *data = [[NSData alloc]initWithBytes:(void *)[strCoorInfo UTF8String] length:[strCoorInfo length]];
//			[strInfo release];
			[fileHandle1 seekToEndOfFile];
			if (i==0) {
				NSString *strName = [NSString stringWithFormat:@"UnitNumber,%@\n",testName];
				NSData *data1 = [[NSData alloc]initWithBytes:(void *)[strName UTF8String] length:[strName length]];

				[fileHandle1 writeData:data1];
			}
			
			[fileHandle1 writeData:data];
		}
		//[fileHandle1 closeFile];
	}
	@catch (NSException *exception) {
		NSLog(@"the reason is %@",exception.reason);
	}
	@finally {
		
	}
	}



	}
}

//caculator the distance
+ (void) writeTheDistanceTableStart:(NSDictionary *)dicLine  andRow:(NSDictionary *)dicRow withPath:(NSString *)path
{
	static int i=1;
	NSString *strEmpty = [NSString stringWithFormat:@",,,,,,,\nTable %d,,\n",i];
	NSFileHandle *fileHandleEmpty = [NSFileHandle fileHandleForWritingAtPath:kTestConfigurationLog];
	if (fileHandleEmpty)
    {
		NSData *dataEmpry = [[NSData alloc]initWithBytes:(void *)[strEmpty UTF8String] length:[strEmpty length]];
		[fileHandleEmpty seekToEndOfFile];
		[fileHandleEmpty writeData:dataEmpry];
        [dataEmpry release];
		//[fileHandleEmpty closeFile];
	}

	NSUInteger count1 = [[dicLine allKeys]count];
	NSUInteger count2 = [[dicRow allKeys]count];
	id key1;
	id key2;
	NSEnumerator *enumerator1 = [dicLine keyEnumerator];
	for (int i=0; i<count1; i++)
    {
		key1 = [enumerator1 nextObject];
		
		NSString *lineCoordinate = [dicLine objectForKey:key1];
		NSArray *aryLine_X_Y_Z = [lineCoordinate componentsSeparatedByString:@":"];
		float line_X = [[aryLine_X_Y_Z objectAtIndex:0] floatValue];
		float line_Y = [[aryLine_X_Y_Z objectAtIndex:1] floatValue];
		float line_Z = [[aryLine_X_Y_Z objectAtIndex:2] floatValue];
		Station_Position startPositation = {line_X,line_Y,line_Z};
		//
		NSMutableArray *aryName = [[NSMutableArray alloc]init];
		NSMutableArray *aryDistance = [[NSMutableArray alloc]init];
		NSEnumerator *enumerator2 = [dicRow keyEnumerator];

		[aryName addObject:@","];
		[aryDistance addObject:key1];
		for (int j=0; j<count2; j++) {
			//NSString *strLine = [aryLine objectAtIndex:0];
			//row
			key2 = [enumerator2 nextObject];
			NSString *rowCoordinate = [dicRow objectForKey:key2];
			NSArray *aryRow_X_Y_Z = [rowCoordinate componentsSeparatedByString:@":"];
			float row_X = [[aryRow_X_Y_Z objectAtIndex:0] floatValue];
			float row_Y = [[aryRow_X_Y_Z objectAtIndex:1] floatValue];
			float row_Z = [[aryRow_X_Y_Z objectAtIndex:2] floatValue];
			Station_Position endPositation = {row_X,row_Y,row_Z};
			//caculator
			Optimization *station = [[[Optimization alloc]init]autorelease];
			float distance = [station GetTheDistance:startPositation toPoint:endPositation];
			if (i==0)
            {
				[aryName addObject:key2];
			}
			[aryDistance addObject:[NSNumber numberWithFloat:distance]];

		}
		if (i==0)
        {
			NSString *strInfo = @"";
			for (int i=0; i<[aryName count]; i++) {
				strInfo = [strInfo stringByAppendingString:[NSString stringWithFormat:@"%@,",[aryName objectAtIndex:i]]];
				if (i==[aryName count]-1) {
					strInfo = [strInfo stringByAppendingString:@"\n"];
				}
			}
			NSFileHandle *fileHandle3 = [NSFileHandle fileHandleForWritingAtPath:kTestConfigurationLog];
			if (fileHandle3) {
				NSData *data = [[NSData alloc]initWithBytes:(void *)[strInfo UTF8String] length:[strInfo length]];
				[fileHandle3 seekToEndOfFile];
				[fileHandle3 writeData:data];
				[fileHandle3 closeFile];
                [data release];

			}

			
		}

        NSString *strInfo = @",";
        for (int i=0; i<[aryDistance count]; i++) {
            strInfo = [strInfo stringByAppendingString:[NSString stringWithFormat:@"%@,",[aryDistance objectAtIndex:i]]];
            if (i==[aryDistance count]-1) {
                strInfo = [strInfo stringByAppendingString:@"\n"];
            }
        }
        NSFileHandle *fileHandle4 = [NSFileHandle fileHandleForWritingAtPath:kTestConfigurationLog];
        if (fileHandle4)
        {
            NSData *data = [[NSData alloc]initWithBytes:(void *)[strInfo UTF8String] length:[strInfo length]];
            [fileHandle4 seekToEndOfFile];
            [fileHandle4 writeData:data];
            [fileHandle4 closeFile];
            [data release];

        }
        [aryName release];
        [aryDistance release];

	}
	
	i++;
}
@end
