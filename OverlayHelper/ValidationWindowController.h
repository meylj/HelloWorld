//
//  ValidationWindowController.h
//  OverlayHelper
//
//  Created by allen on 30/10/2015.
//  Copyright © 2015 Lorky. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ValidationWindowController : NSWindowController
{
    BOOL m_bSetDefault;
    
}
    
@property (assign) IBOutlet NSTextField *NewOverlayVersion;
@property (assign) IBOutlet NSTextField *BaseOverlayVersion;
@property (assign) IBOutlet NSTextField *NewLiveVersion;
@property (assign) IBOutlet NSTextField *tfChangeNote;
@property (assign) IBOutlet NSTextField *tfRadarNumber;
@property (assign) IBOutlet NSTextField *tfTestCoverage;
@property (assign) IBOutlet NSTextField *tfLocalP4Number;
@property (assign) IBOutlet NSTextField *tfBaseLiveVersion;

@property (assign) IBOutlet NSTextField *tfValidateMethod;

@property (assign) IBOutlet NSButton *bSend;

@property (strong) NSMutableDictionary  * m_ValidationInfo;

- (IBAction)SendMail:(id)sender;

@end
