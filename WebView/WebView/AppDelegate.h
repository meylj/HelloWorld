//
//  AppDelegate.h
//  WebView
//
//  Created by He xiaoyong on 4/17/13.
//  Copyright (c) 2013 Pegatron. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "NSStringCategory.h"

#define SETTINGFILEPATH			@"/QueryQCR.plist"
#define QUERY_INFO_FILEPATH		@"/vault/SNList"

#define	DOWNLOAD_TO_FILEPATH	@"/vault/PDCA_LOG"
#define RealFailCount	5


typedef enum
{
	downAllLogs		= 0,
	downFirstLog	= 1,
	downLastLog		= 2
}DownLogSetting;


@interface AppDelegate : NSObject <NSApplicationDelegate,NSOpenSavePanelDelegate>
{
    IBOutlet    WebView     *mainWebView;
    BOOL                    bLoadingFlag;
    int                     iCount;
    
    WebView						*m_hiddenWebView;
    // login 
    IBOutlet NSPanel            *panelLogin;    
    IBOutlet NSTextField        *txtUserName;
    IBOutlet NSTextField        *txtPassword;
    IBOutlet NSTextField        *labMessage;
    IBOutlet NSTextField		*labelNoticeLogin;
	IBOutlet NSTextField		*labelNoticeUsername;
	IBOutlet NSButton           *btnCheckRemember;
	
	NSMutableDictionary         *dicSettingFile;
	NSString                    *szQCRUrl;
    NSString                    *szDefaultURL;
    NSString                    *szPrifixURL;
    NSString                    *szUserName;
    NSString                    *szPassword;
	
	// auto detect
    NSString                    *szSettringPath;
    NSString                    *szSNFileList;
    NSString                    *szPass;
    NSString                    *szFail;
	NSString					*szRealFail;
	
	// Query and Download logs
	IBOutlet NSTextField		*txtSNFilePath;		///< the file's path of queried SN
    IBOutlet NSTextField        *txtLog_StationName;///< show the download station name.
    IBOutlet NSButton           *btnRun;			///< start to run
	IBOutlet NSButton			*btnSelect;			///< show the selected sn list files path.

	BOOL                        bDownloading;		///< if yes,
	NSString					*szCurrentQuerySN;	///< the current query sn.
	NSString					*szCurrentQueryStation;
	DownLogSetting				downLogSetting;		///< set the download logs. 0-->down all logs/1--->down first log/2--->down last log
    NSMutableArray              *muArySN;			///< SN need to download
    NSMutableArray              *muAryStation;		///< station names need to download
	NSMutableArray				*muAryLogSetting;	///< the setting of which log to download
    NSMutableDictionary         *dicMemoryURL;		///< memory some URL
	NSMutableArray				*aryLogsNeedDown;	///< store all logs' movetimes in webview
	NSMutableDictionary			*dicFailSNList;		///< when query or download fail, store the sn in this dictionary
	
	NSNotificationCenter		*nc;				///< notification center
}

@property (assign) IBOutlet NSWindow *window;

/*
 * 2013-07-01 added by Lucky
 * method		: GetSettingFile
 * description	: get the UserName,Password and URL from SETTINGFILEPATH(QueryQCR.plist) file.
 * key			:
 *              None
 */
- (BOOL)GetSettingFile;

/*
 * 2013-07-01 added by Lucky
 * method		: Login
 * description	: response to "Login" button's action, and login QCR with the UserName,Password and URL.
 * key			:
 *              None
 */
- (IBAction)Login:(id)sender;

/*
 * 2013-07-01 added by Lucky
 * method		: CheckRemember
 * description	: write the changed UserName and Password into the QueryQCR.plist
 * key			:
 *              None
 */
- (BOOL)CheckRemember;

/*
 * 2013-07-01 added by Lucky
 * method		: LoginQCR
 * description	: Login QCR with the UserName,Password and URL read from UI.
 * key			:
 *              None
 */
- (BOOL)LoginQCR;

/*
 * 2013-07-01 added by Lucky
 * method		: LoadWebURL
 * description	: load web of szURL.
 * key			:
 *              szURL	NSString ->the URL of the web to open.
 */
- (void)LoadWebURL:(NSString *)szURL;
- (void)ReloadWebOnFrameWithURL:(NSString *)szURL;

/*
 * 2013-07-01 added by Lucky
 * method		: ClickReloadWeb
 * description	: Auto click the button of web. Such as "Search","Enter"
 * key			:
 *              None
 */
- (BOOL)ClickReloadWeb:(DOMElement *)domButton;

/*
 * 2013-07-01 added by Lucky
 * method		: AutoDetect
 * description	:For auto detect folder:
 *	When folder have sn file list, then paser the file and remove the file, and downloading
 *	When folder have no file, continue detect.
 * key			:
 *              None
 */
- (void)AutoDetect;

/*
 * 2013-07-15 added by Lucky
 * method		: Start
 * description	: response to "Select" button's action, search the file of SN List.
 * key			:
 *              None
 */
- (IBAction)selectQueryFiles:(id)sender;

/*
 * 2013-07-01 added by Lucky
 * method		: Start
 * description	: response to "Run" button's action, start query and down logs by next SN. 
 * key			:
 *              None
 */
- (IBAction)Start:(id)sender;

/*
 * 2013-07-01 added by Lucky
 * method		: StartToTest
 * description	: Invokes "-(void)Test" method of the receiver on the main thread using the default mode,when receive the notification "BeginToRun".
 * key			:
 *              None
 */
- (void)StartToTest;

/*
 * 2013-07-01 added by Lucky
 * method		: Test
 * description	: Query the product infomation by SN,and down logs by station name from QCR.
 * key			:
 *                None
 */
- (void)Test;


/*
 * 2013-07-01 added by Lucky
 * method		: GetNowTimeStr
 * description	: Get the current date and time.
 * key			:
 *				None
 * return		: 
 *				NSString -> return the date and time in string format
 */
- (NSString *)GetNowTimeStr;

/*
 * 2013-07-01 added by Lucky
 * method		: AccessProductHistoryWeb
 * description	: Access product history web
 * key			:
 *				None
 * return		:
 *				BOOL ->Return YES, access product history web successfully. Otherwise, return NO.
 */
- (BOOL)AccessProductHistoryWeb;

/*
 * 2013-07-01 added by Lucky
 * method		: QueryBySN
 * description	: Search SN's production informations
 * key			:
 *				  szSN	NSString -> the SN to query.
 * return		:
 *				BOOL ->Return YES, query production information successfully. Otherwise, return NO.
 */
- (BOOL)QueryBySN;

/*
 * 2013-07-01 added by Lucky
 * method		: AccessProcessLogsWeb
 * description	: Access "View Process Logs" web and reset the web view attributes.
 * key			:
 *				  szSN	NSString -> the SN to query.
 * return		:
 *				BOOL ->Return YES, access "View Process Logs" web successfully. Otherwise, return NO.
 */
- (BOOL)AccessProcessLogsWeb;

/*
 * 2013-07-01 added by Lucky
 * method		: Batch_DownLoad_Logs_By_StaitonName
 * description	: Quey product history of SN, access "View Process Logs" web, and down logs by station name.
 * key			:
 *              szStaitonName NSString ->the station's name to download.
 * return		:
 *				BOOL ->Return YES,down logs sucessfully. Otherwise, return NO.
 */
- (BOOL)Batch_DownLoad_Logs_By_StaitonName:(NSString *)szStaitonName;

/*
 * 2013-07-01 added by Lucky
 * method		: DownloadLogsByStationName
 * description	: Collect the position in "View Process Logs" webview of the logs, we need to download, by station name.
 * key			:
 *              szStaitonName NSString ->the station's name to download.
 * return		:
 *				BOOL ->Return YES,down logs sucessfully. Otherwise, return NO.
 */
- (BOOL)DownloadLogsByStationName:(NSString *)szStationName;

/*
 * 2013-07-01 added by Lucky
 * method		: downLoadAllLogsOfStation
 * description	: Down logs, by scrolling the web view as the movement we collected.
 * key			:
 *              szStaitonName NSString ->the station's name to download.
 * return		:
 *				BOOL ->Return YES,down logs sucessfully. Otherwise, return NO.
 */
- (BOOL)downLoadAllLogsOfStation;

/*
 * 2013-07-01 added by Lucky
 * method		: whenDownloadFail
 * description	: recode the infomation of the query failed SN
 * key			:
 *				szInfo	NSString -> the infomation about query failed SN.
 */
- (void)whenDownloadFail:(NSString *)szInfo;

/*
 * 2013-07-01 added by Lucky
 * method		: whenDownloadPass
 * description	: recode the infomation of the query passed SN
 * key			:
 *				szInfo	NSString -> the infomation about query passed SN.
 */
- (void)whenDownloadPass:(NSString *)szInfo;


/*
 * 2013-07-01 added by Lucky
 * method		: MoveMouseToRun
 * description	: move the mouse to the press the "Run" button.
 * key			:
 *				None
 */
- (void)MoveMouseToRun;

/*
 * 2013-07-01 added by Lucky
 * method		: PressClick
 * description	: move the scoller view and press the right position of the web view to download logs.
 * key			:
 *				iMoveTimes	int -> the times to move the scoller view.
 */
- (void)PressClick:(int)iMoveTimes;

/*
 * 2013-07-01 added by Lucky
 * method		: scrollDown
 * description	: move the scoller view to the right position of the web view.
 * key			:
 *				iMoveTimes	int -> the times to move the scoller view.
 */
- (void)scrollDown:(int)iMoveTimes;



@end
