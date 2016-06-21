#import <Foundation/Foundation.h>
#import "NSString_IA.h"
#import "NSImage_IA.h"
#import "IADevice.h"



#define IAKERNEL_AUTOSTART_INTERVAL	3
#define noteKernelDone				@"NoteKernelDone"
#define noteDiagramShouldBegin		@"DiagramShouldBegin"
typedef enum
{
	IAKERNEL_IDLE	= 0,
	IAKERNEL_BUSY	= 1,
	IAKERNEL_WAIT	= 2
} IAKERNEL_STATUS;
#ifdef DEBUG
#define DebugLog(...)	NSLog(__VA_ARGS__)
#else
#define DebugLog(...)	
#endif



/*!
 *	@brief	One kernel, one test. 
 *	@author	Izual Azurewrath
 *	@since	2011-11-30
 *			Creation. 
 */
@interface IAKernel : NSObject
{
	// Should be set up first before start test. 
	NSDictionary		*m_dictIndelibleMemory;	///< Won't be cleared. 
	NSMutableDictionary	*m_dictMemory;
	NSMutableDictionary	*m_dictDevices;
	NSString			*m_strLogPath;
	
	// Process after parse and sort. 
	NSMutableArray		*m_aryIOProcess;
	NSMutableArray		*m_aryCalProcess;
	NSMutableDictionary	*m_dictIOResult;
	NSMutableArray		*m_aryProcessed;
	
	// Kernel status. 
	NSThread			*m_threadCal;
	NSThread			*m_threadIO;
	IAKERNEL_STATUS		m_status;
	NSUInteger			tag;
	
	// Auto detect, start and break. 
	NSTimer				*m_timerAutoStart;
	BOOL				m_bFailBreak;
	BOOL				m_bAutoDeleteLogs;
}



/*!	@defgroup	IAKernel_Setup IAKernel_Setup
 *				Should be set up after allocate any kernel. */
///	@{
#pragma mark - Set Up 
-(BOOL)setUpCalProcess:(NSDictionary*)dictCalProcess;
-(BOOL)setUpIOProcess:(NSDictionary*)dictIOProcess;
@property (copy, readwrite)		NSDictionary	*IndelibleMemory;
-(BOOL)setUpDevice:(IADevice*)device 
		targetName:(NSString*)strName;
@property (retain, readonly)	NSString		*LogPath;
-(void)setLogPath:(NSString *)LogPath;
///	@}



#pragma mark - Clean For Next 
/*! You should call this function before start any test. */
-(void)clear;



#pragma mark - Main Process 
-(BOOL)startTest;
-(BOOL)autoStart;
/*!	Cancel test, kernel will simply set all test results to "Canceled. ". */
-(void)abortTest;
/*!	Post a notification to UI, tell it that kernel have finished test. */
-(void)sendNoteKernelDone:(BOOL)bFinalResult;



#pragma mark - Basic Informations 
@property (assign, readonly)	NSUInteger		Count;	///<	Test items count. 
/*!	Kernel status. 
 *	@see	IAKERNEL_STATUS */
@property (assign, readonly)	IAKERNEL_STATUS	Status;
@property (assign, readwrite)	NSUInteger		tag;
@property (assign, readwrite)	BOOL			AutoStart;
@property (assign, readwrite)	BOOL			FailBreak;
@property (assign, readwrite)	BOOL			AutoDeleteLogs;



@end



#pragma mark - Import Catagory 
#import "Bean_Result.h"
#import "IAKernel_LinkMemory.h"
#import "IAKernel_FlowControl.h"
#import "IAKernel_UI.h"
#import "IAKernel_Limits.h"
#import "IAKernel_LogRecord.h"
#import "IAKernel_Network.h"
#import "IAKernel_Station_PATWifi.h"


