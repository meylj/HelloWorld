//
//  AppDelegate.h
//  ToolForModifyTestallFile
//
//  Created by Linda8_Yang on 9/22/16.
//  Copyright © 2016 Linda8_Yang. All rights reserved.
//

#import "NewTestallFormat.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSString *m_strStationName;
    NewTestallFormat *objNewTestall;
}

@property (nonatomic,retain) IBOutlet NSTextField *testallFilePath;
@property (nonatomic,retain) IBOutlet NSTextField *JsonFilePath;

- (IBAction)loadTestallFile:(id)sender;
- (IBAction)loadJsonFile:(id)sender;
- (IBAction)toGenerateNewTestallFileWithNewFormat:(id)sender;
- (IBAction)toCheckTheNewTestallFile:(id)sender;
- (IBAction)ExitApp:(id)sender;
@end

