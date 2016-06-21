//
//  AppDelegate.h
//  CalculateJsonHash
//
//  Created by York_Xu on 6/29/15.
//  Copyright (c) 2015 York_Xu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSStringCategory.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

{
    IBOutlet NSButton           *m_btnChooseJsonFilePlace;
    IBOutlet NSTextField        *m_txtJsonFilePath;
    IBOutlet NSTextField        *m_txtCheckSum;
    NSMutableString             *m_strJsonFullPath;
    NSMutableString             *m_strNewCheckSum;
    NSMutableDictionary         *m_dicJsonData;
    NSString                    *urlString;
}

-(IBAction)Start:(id)sender;
-(IBAction)ChooseJsonFilePlace:(id)sender;
- (NSString *)CalculateCheckSum:(NSString *)szFilePath;
@end

