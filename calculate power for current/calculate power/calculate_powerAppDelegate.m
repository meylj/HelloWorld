//
//  calculate_powerAppDelegate.m
//  calculate power
//
//  Created by  on 12-4-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "calculate_powerAppDelegate.h"

@implementation calculate_powerAppDelegate

@synthesize window;


- (NSData *)ProductData:(NSArray *)firstString Second:(NSArray *)secString fIndex:(NSMutableArray*)arrIndexFirst sIndex:(NSMutableArray*)arrIndexSecond{
       NSMutableString *szString =[[[NSMutableString alloc]init] autorelease];
      float fValue;
    // each SN with power items
 
    [szString appendFormat:@"%@,",[firstString objectAtIndex:1]];
    int fInger = [arrIndexFirst count];
   // int sInger = [arrIndexSecond count];
   
        for (int i = 0; i<fInger;i++)
        {   
            NSNumber *iNumFirst = [arrIndexFirst objectAtIndex:i];
            NSString *itemNameFirst = [arryItemFirst objectAtIndex:[iNumFirst intValue] ];
           for (NSNumber * numberIndex in arrIndexSecond)
           {
               if ([[arryItemSecond objectAtIndex:[numberIndex floatValue]] isEqualTo:itemNameFirst])
               {
                
                   fValue = [[firstString objectAtIndex:[iNumFirst floatValue]]floatValue]-[[secString objectAtIndex:[numberIndex floatValue]]floatValue];
                   break;
                   
               }
           }
            [szString appendFormat:@"%f,",fValue];
             usleep(50);
        }
    
    
    [szString appendString:@"\n"];
    
    return [NSData dataWithBytes:(void *)[szString UTF8String] length:[szString length]];
}

- (NSString *)ReadFile:(NSString *)fileName{
    return [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
}

- (void)WriteToFileWithAry:(NSArray *)firstFile SecondFile:(NSArray *)secFile{
    NSInteger finger = [firstFile count];
    NSInteger singer = [secFile count];
    
    
    // csv format need input, but not only @"" 
   [@"" writeToFile:[NSString stringWithFormat:@"%@/Desktop/Current_%@_Value.csv", NSHomeDirectory(),[comBox stringValue]] atomically:YES encoding:NSUTF8StringEncoding error:Nil];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[NSString stringWithFormat:@"%@/Desktop/Current_%@_Value.csv", NSHomeDirectory(),[comBox stringValue]]];
    NSLog(@"3");
    arryItemFirst = [[firstFile objectAtIndex:1] componentsSeparatedByString:@","];
    arryItemSecond = [[secFile objectAtIndex:1] componentsSeparatedByString:@","];
    NSMutableArray *powerIndexFirst = [[NSMutableArray alloc]init];
    NSMutableArray *powerIndexSecond = [[NSMutableArray alloc] init];

    NSString *szSerial = @"SerialNumber,";
    NSData *pdata = [NSData dataWithBytes:(void *)[szSerial UTF8String] length:[szSerial length]];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:pdata];
    [fileHandle synchronizeFile];
    int k =0;
    for (NSString *szContent in arryItemFirst)
    {   NSRange range =[szContent rangeOfString:[comBox stringValue]];
        if (range.location !=NSNotFound && range.length >0)
        {
            [powerIndexFirst addObject:[NSNumber numberWithInt:k]];
            szContent = [NSString stringWithFormat:@"%@,",szContent];
            NSData *data = [NSData dataWithBytes:(void *)[szContent UTF8String] length:[szContent length]];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
            [fileHandle synchronizeFile];
         
            usleep(500);
        }
            
        k++;
    }
    int j =0;
    for(NSString *szContent in arryItemSecond)
    {
        NSRange range =[szContent rangeOfString:[comBox stringValue]];
        if (range.location !=NSNotFound && range.length >0)
        {
            [powerIndexSecond addObject:[NSNumber numberWithInt:j]];
        }
        
        j++;

    }

    NSString *szEnter =@"\n";
    NSData *data = [NSData dataWithBytes:(void *)[szEnter UTF8String] length:[szEnter length]];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle synchronizeFile];
    for (int i=7 ; i<finger ; i++) {
        
        NSArray *aryFirst = [[firstFile objectAtIndex:i] componentsSeparatedByString:@","];
        if ([aryFirst count] < 2)
        {
            break;   
        }
        NSString *szFirstSN = [aryFirst objectAtIndex:1] ;
        for (int j=7 ; j<singer ; j++) {
             NSLog(@"6");
            NSArray *arySecond = [[secFile objectAtIndex:j] componentsSeparatedByString:@","];
            
            if ([arySecond count]<2)
            {
                break;
            }
            NSString *szSecSN = [arySecond objectAtIndex:1];
            
            // find out the same SN in two files
            if ([szFirstSN isEqualToString:szSecSN]) {
                //NSLog(@"ID:%d SN post:%@  SN pre:%@",i-28,szFirstSN,szSecSN);   
                 //m++;
              
               //r[levelIndictor setIntValue:m];
                NSData *data = [self ProductData:aryFirst Second:arySecond fIndex:powerIndexFirst sIndex:powerIndexSecond];
               
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:data];
                [fileHandle synchronizeFile];
                //usleep(500);
                 break;
            }
            usleep(500);
        }  
    }
    [txtfield setStringValue:@"Completed!"];
    NSRunAlertPanel(@"OK", @"Finish!You can find log in desktop!", @"OK", nil, nil);
    [fileHandle closeFile];
    
    [powerIndexFirst release];
    [powerIndexSecond release];
}

-(IBAction)btnStart:(id)sender
{
    [txtfield setStringValue:@"Starting......"];
    NSArray *aryPreData = [[self ReadFile:m_szPathPreBurn] componentsSeparatedByString:@"\n"];
    NSArray *aryPostData = [[self ReadFile:m_szPathPostBurn] componentsSeparatedByString:@"\n"];
    [self WriteToFileWithAry:aryPreData SecondFile:aryPostData];  
}


-(IBAction)btnExit:(id)sender
{
    
    if (NSRunAlertPanel(@"Alert!",@"Are you sure to exit?", @"Yes", @"No", nil)==NSAlertDefaultReturn)
    {
        [NSApp terminate:self];
    }
}
-(void)awakeFromNib{
    [btnStart setEnabled:NO];
}
-(id)init
{
    self = [super init];
    if(self)
    {
    m_szPathPostBurn = [[NSMutableString alloc]init];
    m_szPathPreBurn= [[NSMutableString alloc]init];
      
    }
    return self;
}
-(void)dealloc
{
    [m_szPathPreBurn release];
    [m_szPathPostBurn release];
}

-(IBAction)choosePathForPre:(id)sender
{
    [self choosePath:m_szPathPreBurn];
    [txtShowPathPre setStringValue:m_szPathPreBurn];
   
}
-(IBAction)choosePathForPost:(id)sender
{
    [self choosePath:m_szPathPostBurn];
    //[m_szPathPostBurn retain];
    [txtShowPathPost setStringValue:m_szPathPostBurn];
}

-(void)choosePath:(NSMutableString *)m_path
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    //[openPanel setCanChooseFiles:<#(BOOL)#>];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setTitle:@"CHOOSE LOG PATH"];
    [openPanel setPrompt:@"OK"];
    [openPanel setDirectoryURL:[NSURL URLWithString:@"/vault/"]];
    
    if ([openPanel runModalForTypes:[NSArray arrayWithObject:@"csv"]] == NSOKButton)
	{
        NSArray *arrFileChose = [openPanel filenames];
        if ([arrFileChose count]==1)
        {
             //NSLog(@"8");
            [m_path setString:[arrFileChose objectAtIndex:0]];
            [btnStart setEnabled:YES];
           
        }
        else
        {
            NSRunAlertPanel(@"Warning", @"Error Choose, Please choose again!", @"OK", nil, nil);
            [btnStart setEnabled:NO];
            return;
        }
        
        
    }
 
}


@end
