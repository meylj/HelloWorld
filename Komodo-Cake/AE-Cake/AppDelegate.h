//
//  AppDelegate.h
//  AE-Cake
//
//  Created by Yaya on 1/28/15.
//  Copyright (c) 2015 Yaya. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import  "ASIKomodo.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    
    IBOutlet NSWindow *window;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextView *outPutmessage;
    
    NSString     *m_strMoveFile;
    int           m_seconds;
	NSDictionary *m_dicSetting;
	ASIKomodo    *myASIKomodo;
    bool          m_bFinish;
}
-(id)init;

-(void)startMonitorFile:(NSString*)filePath;

- (void)startUpload:(NSDictionary *)dicPara;

- (NSArray *)parseDTCSVFile:(NSString *)filePath;

-(NSString*)CellContentsAtRow:(NSUInteger)row
                     AtColumn:(NSUInteger)column
                 FileContents:(NSArray *)aryContents;

-(NSArray*)listFile:(NSString*)strDicPath withFormat:(NSString*)fileFormat;

-(BOOL)moveFile:(NSString*)szOldPath NewPath:(NSString*)szNewPath;

void mycallback(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[]);

-(BOOL)removeFile:(NSString*)szPath;

- (BOOL) archiveFile:(NSString*)srcfile destZipFile:(NSString*)zipfile;

@end

