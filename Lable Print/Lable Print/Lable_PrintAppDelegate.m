//
//  Lable_PrintAppDelegate.m
//  Lable Print
//
//  Created by user on 9/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Lable_PrintAppDelegate.h"

@implementation Lable_PrintAppDelegate

@synthesize window;
@synthesize txtBatterySNShow;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSString* strPath=@" ";
    PortLists=[AMSerialPortList portEnumerator];
    while(SerialPort=[PortLists nextObject]){
        strPath=[SerialPort bsdPath];
        if (NSNotFound != [strPath rangeOfString:@"DUT"].location) {
            PortChosen=[[AMSerialPort alloc]init:strPath 
                                        withName:strPath 
                                            type:(NSString *)CFSTR(kIOSerialBSDModemType)];
            [PortChosen open];
            [PortChosen setDataBits:8];
            [PortChosen setParity:0];
            [PortChosen setStopBits:1];
            [PortChosen setSpeed:115200];
            [PortChosen setReadTimeout:1];
            [PortChosen commitChanges];
            
        }
    }

    
}

-(IBAction)Print:(id)sender
{
    //[[NSUserDefaults standardUserDefaults] setValue:@"ftE2H9WJ" forKey:@"USB_NAME"];
    if ([PortChosen isOpen])
    {
        [PortChosen writeString:@"\r"
                  usingEncoding:NSUTF8StringEncoding 
                          error:NULL];
        NSString* strReceiveMessage;
        strReceiveMessage=[PortChosen readStringUsingEncoding:NSUTF8StringEncoding 
                                                        error:NULL];
        if(nil != strReceiveMessage && NSNotFound!=[strReceiveMessage rangeOfString:@":-)"].location)
        {
            [PortChosen writeString:[NSString stringWithFormat:@"device -k GasGauge --e read_pack_sn\r"] 
                      usingEncoding:NSUTF8StringEncoding 
                              error:NULL];
            NSString* strResults;
            strResults=[PortChosen readStringUsingEncoding:NSUTF8StringEncoding 
                                                            error:NULL];
            NSRange FirstRange;
            NSRange SecdRange;
            FirstRange=[strResults rangeOfString:@"PACK SN:"];
            strResults = [strResults substringFromIndex:(FirstRange.location!=NSNotFound)?FirstRange.location:0];
            SecdRange=[strResults rangeOfString:@"\n"];
            strResults = [strResults substringToIndex:(SecdRange.location!=NSNotFound)?SecdRange.location:0];
            strResults = [strResults stringByReplacingOccurrencesOfString:@"PACK SN:" withString:@""];
            strResults = [strResults stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            strResults = [strResults stringByReplacingOccurrencesOfString:@" " withString:@""];
            //[txtBatterySNShow setStringValue:strResults];
            [txtBatterySNShow setStringValue:[NSString stringWithFormat:@"%@",strResults]];
            //[txtSNLCDShow setStringValue:[NSString stringWithFormat:@"%@_LCD",strResults]];
            controlPrint    *printer = [[controlPrint alloc]init];
            [printer print: strResults];
            
            //[printer print:[NSString stringWithFormat:@"%@_LCD",strResults]];
            [printer release];
            

        }
     
    }
}

-(IBAction)Exit:(id)sender{
    [NSApp terminate:self];
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)dealloc {
    
    [SerialPort release];
    [PortChosen release];
    [super dealloc];
}


@end
