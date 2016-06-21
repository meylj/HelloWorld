//
//  FakeAppDelegate.m
//  WebServerCenter
//
//  Created by Ken_Wu on 2014/3/22.
//  Copyright (c) 2014年 PEGATRON. All rights reserved.
//

#import "FakeAppDelegate.h"
#import "DataBase.h"

@implementation FakeAppDelegate
@synthesize state = _state;

#define HTTP_SERVER_PORT 8080
#define gh_station_path  @"/vault/data_collection/test_station_config/"
#define gh_station_info  @"gh_station_info.json"

- (id)init {
	if ((self = [super init]) != nil)
	{
		self.state = SERVER_STATE_IDLE;
		responseHandlers = [[NSMutableSet alloc] init];
		incomingRequests = CFDictionaryCreateMutable(kCFAllocatorDefault,0,
                                                     &kCFTypeDictionaryKeyCallBacks,
                                                     &kCFTypeDictionaryValueCallBacks);
        m_aryDataBase  = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
    [m_aryDataBase release];	m_aryDataBase		= nil;
    [responseHandlers release]; responseHandlers	= nil;
    CFRelease(incomingRequests);
    [super dealloc];
}

- (void)awakeFromNib {
    [self OnLoadPTypeList:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
}

#pragma mark- WebServerCenter
//
// start
//
// Creates the socket and starts listening for connections on it.
//

- (void)startMonitor_gh_station_info {
    FSEventStreamContext context;
    NSArray     *arrPathToWatch = @[[NSString stringWithFormat:@"%@%@",gh_station_path,gh_station_info]];
    context.info    = self;
    context.version = 0;
    context.retain  = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    
    m_streamObj = FSEventStreamCreate(NULL, fsEventsMonitorFileCallback, &context, (CFArrayRef)arrPathToWatch, kFSEventStreamEventIdSinceNow, (CFTimeInterval)1, kFSEventStreamCreateFlagUseCFTypes|kFSEventStreamCreateFlagFileEvents | kFSEventStreamEventFlagMustScanSubDirs);
    FSEventStreamScheduleWithRunLoop(m_streamObj, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    FSEventStreamStart(m_streamObj);
}

- (void)stopMonitor_gh_station_info {
    FSEventStreamStop(m_streamObj);
    FSEventStreamInvalidate(m_streamObj);
    FSEventStreamRelease(m_streamObj);
    m_streamObj = nil;
}

#define url_Pattern     @"\"SFC_URL\" : \"http://"
- (void)FindAndReplaceAt_gh_station_info {
    NSString    *szFileName = [NSString stringWithFormat:@"%@%@",gh_station_path,gh_station_info];
    NSString    *szFileData = [NSString stringWithContentsOfFile:szFileName encoding:NSUTF8StringEncoding error:nil];
    NSRange     nRange = [szFileData rangeOfString:[NSString stringWithFormat:@"%@127.0.0.1",url_Pattern]];
    if (nRange.location == NSNotFound) {
        NSArray     *aryData = [szFileData componentsSeparatedByString:@"\n"];
        for (NSString *szLine in aryData) {
            nRange = [szLine rangeOfString:url_Pattern];
            if (nRange.location != NSNotFound) {
                NSArray     *aryUrl = [szLine componentsSeparatedByString:@"/"];
                NSString    *szCmd = [NSString stringWithFormat:@"sed -i .bak 's/\\/%@/\\/127.0.0.1:%d/g' %@",
                                      aryUrl[2],HTTP_SERVER_PORT,szFileName];
                system([szCmd UTF8String]);
                NSLog(@"%@",szCmd);
                break;
            }
        }
    }
}

void fsEventsMonitorFileCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents,
                             void *eventPaths, const FSEventStreamEventFlags eventFlags[],
                             const FSEventStreamEventId eventIds[]) {
    FakeAppDelegate *App = (FakeAppDelegate*)clientCallBackInfo;
    for (NSInteger i1 = 0;i1 < numEvents;i1 ++)
    {
        FSEventStreamEventFlags flags = eventFlags[i1];
        
        if ((flags & kFSEventStreamEventFlagItemRenamed) || (flags & kFSEventStreamEventFlagItemModified)) {
            NSLog(@"kFSEventStreamEventFlagItemRenamed <=> kFSEventStreamEventFlagItemModified");
            [App FindAndReplaceAt_gh_station_info];
        }
        if (flags & kFSEventStreamEventFlagItemCreated)
        {
            if (flags & kFSEventStreamEventFlagItemIsFile)
            {
                NSLog(@"new create and it is a file");
            }
        }
        
        if (flags & kFSEventStreamEventFlagItemRemoved)
        {
            NSLog(@"removed");
        }
    }
}

- (void)start
{
	self.lastError = nil;
	self.state = SERVER_STATE_STARTING;
	socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM,
                            IPPROTO_TCP, 0, NULL, NULL);
	if (!socket)
	{
		[self errorWithName:@"Unable to create socket."];
		return;
	}
    
	int reuse = true;
	int fileDescriptor = CFSocketGetNative(socket);
	if (setsockopt(fileDescriptor, SOL_SOCKET, SO_REUSEADDR,
                   (void *)&reuse, sizeof(int)) != 0)
	{
		[self errorWithName:@"Unable to set socket options."];
		return;
	}
	
	struct sockaddr_in address;
	memset(&address, 0, sizeof(address));
	address.sin_len = sizeof(address);
	address.sin_family = AF_INET;
	address.sin_addr.s_addr = htonl(INADDR_ANY);
	address.sin_port = htons(HTTP_SERVER_PORT);
	CFDataRef addressData =
    CFDataCreate(NULL, (const UInt8 *)&address, sizeof(address));
	[(id)addressData autorelease];
	
	if (CFSocketSetAddress(socket, addressData) != kCFSocketSuccess)
	{
		[self errorWithName:@"Unable to bind socket to address."];
		return;
	}
    
	listeningHandle = [[NSFileHandle alloc]
                       initWithFileDescriptor:fileDescriptor
                       closeOnDealloc:YES];
    
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(receiveIncomingConnectionNotification:)
     name:NSFileHandleConnectionAcceptedNotification
     object:nil];
	[listeningHandle acceptConnectionInBackgroundAndNotify];
	
	self.state = SERVER_STATE_RUNNING;
}

//
// stop
//
// Stops the server.
//
- (void)stop
{
	self.state = SERVER_STATE_STOPPING;
	[[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSFileHandleConnectionAcceptedNotification
     object:nil];
    
	[responseHandlers removeAllObjects];
    
	[listeningHandle closeFile];
	[listeningHandle release];
	listeningHandle = nil;
	
	for (NSFileHandle *incomingFileHandle in
         [[(NSDictionary *)incomingRequests copy] autorelease])
	{
		[self stopReceivingForFileHandle:incomingFileHandle close:YES];
	}
	
	if (socket)
	{
		CFSocketInvalidate(socket);
		CFRelease(socket);
		socket = nil;
	}
    
	self.state = SERVER_STATE_IDLE;
}

//
// receiveIncomingConnectionNotification:
//
// Receive the notification for a new incoming request. This method starts
// receiving data from the incoming request's file handle and creates a
// new CFHTTPMessageRef to store the incoming data..
//
// Parameters:
//    notification - the new connection notification
//
- (void)receiveIncomingConnectionNotification:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSFileHandle *incomingFileHandle = [userInfo objectForKey:NSFileHandleNotificationFileHandleItem];
    
    if(incomingFileHandle)
	{
		CFDictionaryAddValue(incomingRequests,incomingFileHandle,
                             [(id)CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE) autorelease]);
		
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveIncomingDataNotification:)
                                                     name:NSFileHandleDataAvailableNotification
                                                   object:incomingFileHandle];
        [incomingFileHandle waitForDataInBackgroundAndNotify];
    }
    
	[listeningHandle acceptConnectionInBackgroundAndNotify];
}

//
// receiveIncomingDataNotification:
//
// Receive new data for an incoming connection.
//
// Once enough data is received to fully parse the HTTP headers,
// a HTTPResponseHandler will be spawned to generate a response.
//
// Parameters:
//    notification - data received notification
//
- (void)receiveIncomingDataNotification:(NSNotification *)notification
{
	NSFileHandle *incomingFileHandle = [notification object];
	NSData *data = [incomingFileHandle availableData];
	
	if ([data length] == 0)
	{
		[self stopReceivingForFileHandle:incomingFileHandle close:NO];
		return;
	}
    
	CFHTTPMessageRef incomingRequest = (CFHTTPMessageRef)CFDictionaryGetValue(incomingRequests,
                                                                              incomingFileHandle);
	
	if (!incomingRequest)
	{
		[self stopReceivingForFileHandle:incomingFileHandle close:YES];
		return;
	}
	
	if (!CFHTTPMessageAppendBytes(
                                  incomingRequest,
                                  [data bytes],
                                  [data length]))
	{
		[self stopReceivingForFileHandle:incomingFileHandle close:YES];
		return;
	}
	
	if(CFHTTPMessageIsHeaderComplete(incomingRequest))
	{
        NSDictionary *requestHeaderFields = [(NSDictionary *)CFHTTPMessageCopyAllHeaderFields(incomingRequest) autorelease];
        NSURL *requestURL	= [(NSURL *)CFHTTPMessageCopyRequestURL(incomingRequest) autorelease];
        NSString *method	= [(NSString *)CFHTTPMessageCopyRequestMethod(incomingRequest) autorelease];
        NSMutableString     *szShowResult = [[NSMutableString alloc] init];
		NSString * strData	= [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
        NSArray *aryUrlData = [method isEqualToString:@"GET"] ? [[requestURL absoluteString] componentsSeparatedByString:@"&"] : [strData componentsSeparatedByString:@"&"];
        BOOL    bFindSN = NO;
        NSLog(@"requestURL = %@,requestHeader = %@,method = %@",requestURL,requestHeaderFields,method);
		[self stopReceivingForFileHandle:incomingFileHandle close:NO];
        for (DataBase *parent in m_aryDataBase) {
			// I think here need to modify because the data source has been changed.
            NSString    *szSN = [NSString stringWithFormat:@"sn=%@",[parent DBValue]];
            NSInteger   index = [method isEqualToString:@"GET"] ? [aryUrlData indexOfObject:szSN] : [strData rangeOfString:szSN].location;
            if (index != NSNotFound) {
                bFindSN = YES;
                [szShowResult appendString:@"0 SFC OK"];
                for (NSString *szQueryData in aryUrlData) {
                    NSRange nRange = [szQueryData rangeOfString:@"p="];
                    BOOL bFindPType = NO;
                    if (nRange.location == NSNotFound)
                        continue;
                    for (DataBase *child in [parent children]) {
                        NSString *tmpStr = [NSString stringWithFormat:@"p=%@",[child DBKey]];
                        if ([tmpStr isEqualToString:szQueryData]) {
                            [szShowResult appendString:[NSString stringWithFormat:@"\n%@=%@\n",
                                                        [child DBKey],[child DBValue]]];
                            bFindPType = YES;
                            break;
                        }
                    }
                    if (!bFindPType)
                        [szShowResult setString:[NSString stringWithFormat:@"2 SFC_FATAL_ERROR ,%@ Can not get corresponding SFISTypes for this SN, please call EAI",[szQueryData substringFromIndex:nRange.location+nRange.length]]];
                }
                break;
            }
        }
        if (!bFindSN) {
            NSString *tmpSN = @"";
            for (NSString *szQueryData in aryUrlData) {
                NSRange   nRange = [szQueryData rangeOfString:@"sn="];
                if (nRange.location != NSNotFound)
                    tmpSN = [szQueryData substringFromIndex:nRange.location + nRange.length];
            }
            [szShowResult setString:[NSString stringWithFormat:@"3 SFC_DATA_FORMAT_ERR Invalid SN [%@]",tmpSN]];
        }
        CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
        CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Type", (CFStringRef)@"text/html");
        CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Connection", (CFStringRef)@"close");
        CFHTTPMessageSetBody(response,(CFDataRef)[[NSString stringWithFormat:@"%@",szShowResult]
                                                  dataUsingEncoding:NSUTF8StringEncoding]);
        CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);
        @try
        {
            [self performSelectorOnMainThread:@selector(UpdateUI_Message:)
                                   withObject:@{@"KEY":m_txtServerInfo,@"VALUE":[requestURL absoluteString]}
                                waitUntilDone:YES];
            [incomingFileHandle writeData:(NSData *)headerData];
            [self performSelectorOnMainThread:@selector(UpdateUI_Message:)
                                   withObject:@{@"KEY":m_txtClientInfo,@"VALUE":szShowResult}
                                waitUntilDone:YES];
        }
        @catch (NSException *exception)
        {
            // Ignore the exception, it normally just means the client
            // closed the connection from the other end.
        }
        @finally
        {
            CFRelease(headerData);
            CFRelease(response);
        }
        [szShowResult release];
		return;
	}
	[incomingFileHandle waitForDataInBackgroundAndNotify];
}

//
// stopReceivingForFileHandle:close:
//
// If a file handle is accumulating the header for a new connection, this
// method will close the handle, stop listening to it and release the
// accumulated memory.
//
// Parameters:
//    incomingFileHandle - the file handle for the incoming request
//    closeFileHandle - if YES, the file handle will be closed, if no it is
//		assumed that an HTTPResponseHandler will close it when done.
//
- (void)stopReceivingForFileHandle:(NSFileHandle *)incomingFileHandle
                             close:(BOOL)closeFileHandle
{
	if (closeFileHandle)
	{
		[incomingFileHandle closeFile];
	}
	
	[[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSFileHandleDataAvailableNotification
     object:incomingFileHandle];
	CFDictionaryRemoveValue(incomingRequests, incomingFileHandle);
}

- (void)setLastError:(NSError *)anError
{
	[anError retain];
	[_lastError release];
	_lastError = anError;
	
	if (_lastError == nil)
	{
		return;
	}
	
	[self stop];
	
	self.state = SERVER_STATE_IDLE;
	NSLog(@"HTTPServer error: %@", self.lastError);
}

//
// errorWithName:
//
// Stops the server and sets the last error to "errorName", localized using the
// HTTPServerErrors.strings file (if present).
//
// Parameters:
//    errorName - the description used for the error
//
- (void)errorWithName:(NSString *)errorName
{
	self.lastError = [NSError
                      errorWithDomain:@"HTTPServerError"
                      code:0
                      userInfo:
                      [NSDictionary dictionaryWithObject:
                       NSLocalizedStringFromTable(
                                                  errorName,
                                                  @"",
                                                  @"HTTPServerErrors")
                                                  forKey:NSLocalizedDescriptionKey]];
}

//
// setState:
//
// Changes the server state and posts a notification (if the state changes).
//
// Parameters:
//    newState - the new state for the server
//
- (void)setState:(HTTPServerState)newState
{
	if (_state == newState)
	{
		return;
	}
    
	_state = newState;
	
	[[NSNotificationCenter defaultCenter]
     postNotificationName:HTTPServerNotificationStateChanged
     object:self];
}

- (HTTPServerState)getState {
    return _state;
}

#pragma mark - Delegate NSOutlineViewDataSource
// How many children does this outline view item has?
-(NSInteger)outlineView:(NSOutlineView *)outlineView
 numberOfChildrenOfItem:(id)item
{
	if (item == nil)
        return [m_aryDataBase count];
    if ([item isKindOfClass:[DataBase class]])
	{
        return [item countOfChildren];
    }
    return 0;
}

// Who are children of this outline view item?
- (id)outlineView:(NSOutlineView *)outlineView
			child:(NSInteger)index
		   ofItem:(id)item
{
	if (item == nil)
        return [m_aryDataBase objectAtIndex:index];
    else
		if ([item isKindOfClass:[DataBase class]]) {
			return [item ObjectAtIndex:index];
		}
    return nil;
}
// Can this outline view item has any child?
- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
	if (item == nil)
        return [m_aryDataBase count] > 0;
    if ([item isKindOfClass:[DataBase class]])
        return [item isExpandable];
    return NO;
}
-(id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
		  byItem:(id)item
{
	NSString * strIdentifier = [tableColumn identifier];
	if ([strIdentifier isEqualToString:@"KEY"])
	{
		return [(DataBase *)item DBKey];
	}
	else if ([strIdentifier isEqualToString:@"VALUE"])
		return [(DataBase *)item DBValue];
	return @"";
}

- (void)outlineView:(NSOutlineView *)outlineView
	 setObjectValue:(id)object
	 forTableColumn:(NSTableColumn *)tableColumn
			 byItem:(id)item
{
	NSString * strIdentifier = [tableColumn identifier];
	if ([strIdentifier isEqualToString:@"KEY"])
		[(DataBase *)item setDBKey:object];
	else if ([strIdentifier isEqualToString:@"VALUE"])
		[(DataBase *)item setDBValue:object];
}
#pragma mark - Actioins
-(void)UpdateUI_Message : (NSDictionary *) pDict
{
    id      objKey = [pDict objectForKey:@"KEY"];
    id      value = [pDict objectForKey:@"VALUE"];
    if ([objKey isKindOfClass:[NSOutlineView class]])
        [objKey reloadData];
    if ([objKey isKindOfClass:[NSTextView class]])
	{
        if (value)
		{
            NSString    *tmpStr = [NSString stringWithFormat:@"%@\n",value];
            [[[objKey textStorage] mutableString] insertString:tmpStr atIndex:0];
        }
        else
            [objKey setString:@""];
    }
	
}

- (IBAction)OnSwitchStatus:(id)sender {
    switch ([m_ServerStatus selectedSegment]) {
        case 0:
            [self FindAndReplaceAt_gh_station_info];
            [self start];
			// Clear text field while segment start.
			@try
			{
				[self performSelectorOnMainThread:@selector(UpdateUI_Message:)
									   withObject:@{@"KEY":m_txtServerInfo}
									waitUntilDone:YES];
				[self performSelectorOnMainThread:@selector(UpdateUI_Message:)
									   withObject:@{@"KEY":m_txtClientInfo}
									waitUntilDone:YES];
			}
			@catch (NSException *exception)
			{
				// Ignore the exception, it normally just means the client
				// closed the connection from the other end.
			}

            [self startMonitor_gh_station_info];
            break;
        default: {
            NSString *szFullName = [NSString stringWithFormat:@"%@%@",gh_station_path,gh_station_info];
            NSString *szRename = [NSString stringWithFormat:@"rm %@;mv %@.bak %@",szFullName,szFullName,szFullName];
            [self stopMonitor_gh_station_info];
            system([szRename UTF8String]);
            [self stop];
            break;
        }
    }
}

- (IBAction)ExpandAndCollapseItem:(id)sender
{
	NSButton * button = (NSButton *)sender;
	if (button.state == NSOnState)
	{
		for (DataBase *aData in m_aryDataBase)
			[m_OvDUT_Info expandItem:aData expandChildren:YES];
	}
	else // Off state
	{
		for (DataBase *aData in m_aryDataBase)
			[m_OvDUT_Info collapseItem:aData collapseChildren:YES];
	}
}

- (IBAction)AddItem:(id)sender
{
	NSInteger iSelectedRow = [m_OvDUT_Info selectedRow];
	if (iSelectedRow < 0)
		iSelectedRow = 0;
	DataBase * item = [m_OvDUT_Info itemAtRow:iSelectedRow];
	BOOL isExpandable = [item isExpandable];
	if (!isExpandable && item) // Children
	{
		// Get Parents first
		DataBase * aChildren = [[DataBase alloc] init];
		DataBase * parent = [m_OvDUT_Info parentForItem:item];
		NSUInteger index = [m_aryDataBase indexOfObject:parent];
		NSUInteger indexChild = [parent indexOfChildrenItem:item];
		[parent insertChildren:aChildren atIndex:indexChild];
		[m_aryDataBase replaceObjectAtIndex:index withObject:parent];
		[aChildren release];
	}
	else // Parent
	{
		DataBase * parent = [[DataBase alloc] init];
		DataBase * aChild = [[DataBase alloc] init];
		[parent setDBKey:@"SN"];
		[parent setDBValue:@"Undefined SN"];
		[parent addAChildren:aChild];
		[m_aryDataBase insertObject:parent atIndex:iSelectedRow];
		[aChild release]; aChild = nil;
		[parent release]; parent = nil;
	}
	[self performSelectorOnMainThread:@selector(UpdateUI_Message:) withObject:@{@"KEY": m_OvDUT_Info} waitUntilDone:YES];
}

- (IBAction)RemoveItem:(id)sender
{
	if ([m_aryDataBase count] == 0)
	{
		NSBeep();
		return;
	}

	NSInteger iSelectedRow = [m_OvDUT_Info selectedRow];
	if (iSelectedRow < 0)
		iSelectedRow = 0;
	DataBase * item = [m_OvDUT_Info itemAtRow:iSelectedRow];
	BOOL isExpandable = [item isExpandable];
	if (!isExpandable) // Children
	{
		// Get Parents first
		DataBase * parent = [m_OvDUT_Info parentForItem:item];
		NSUInteger index = [m_aryDataBase indexOfObject:parent];
		[parent removeChild:item];
		if ([parent countOfChildren])
			[m_aryDataBase replaceObjectAtIndex:index withObject:parent];
		else
			[m_aryDataBase removeObject:parent];
	}
	else // Parent
	{
		[m_aryDataBase removeObject:item];
	}
	[self performSelectorOnMainThread:@selector(UpdateUI_Message:) withObject:@{@"KEY": m_OvDUT_Info} waitUntilDone:YES];
}

- (IBAction)OnSavePTypeList:(id)sender
{
    NSString *InfoFileName = [[NSBundle mainBundle] pathForResource:@"PType" ofType:@"plist"];
	NSMutableDictionary * dictDataSource = [[NSMutableDictionary alloc] init];
	for (DataBase * aData in m_aryDataBase)
	{
		NSMutableDictionary * dictChild = [[NSMutableDictionary alloc] init];
		NSString * strKey = aData.DBValue;
		for (DataBase *aChild in [aData children])
		{
			[dictChild setObject:aChild.DBValue forKey:aChild.DBKey];
		}
		[dictDataSource setObject:dictChild forKey:strKey];
		[dictChild release]; dictChild = nil;
	}
    [dictDataSource writeToFile:InfoFileName atomically:YES];
	[dictDataSource release]; dictDataSource = nil;
}

- (IBAction)OnLoadPTypeList:(id)sender
{
    NSString *InfoFileName = [[NSBundle mainBundle] pathForResource:@"PType" ofType:@"plist"];
	[m_aryDataBase release]; m_aryDataBase = nil;
	m_aryDataBase = [[NSMutableArray alloc] init];
	NSDictionary *dictDataBase = [[NSDictionary alloc] initWithContentsOfFile:InfoFileName];
	for (NSString * idSerialNumber in [dictDataBase allKeys])
	{
		DataBase * allData = [[DataBase alloc] init];
		
		NSDictionary * dictKeyValue = [dictDataBase objectForKey:idSerialNumber];
		for (NSString * strKey in [dictKeyValue allKeys])
		{
			DataBase * aData = [[DataBase alloc] init];
			aData.DBKey = strKey;
			aData.DBValue = [dictKeyValue objectForKey:strKey];
			[allData addAChildren:aData];
			[aData release]; aData = nil;
		}
		allData.DBKey = @"SN";
		allData.DBValue = idSerialNumber;
		
		[m_aryDataBase addObject:allData];
		[allData release];
	}
	[dictDataBase release]; dictDataBase = nil;
	
    [self performSelectorOnMainThread:@selector(UpdateUI_Message:) withObject:@{@"KEY": m_OvDUT_Info} waitUntilDone:YES];
}
@end
