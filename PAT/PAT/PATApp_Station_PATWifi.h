#import "PATApp.h"



/*!
 *	Special functions for PAT_Wifi station. 
 *	@author	Soshon Ran
 *	@since	2011-11-18
 *			Creation. 
 *	@since	2011-12-23
 *			Refactored by Izual Azurewrath. 
 */
@interface PATApp (PATApp_Station_PATWifi)



#pragma mark - Listen and Prepare 
-(void)listenNoteDiagramShouldBegin:(NSNotification*)note;

-(NSMutableDictionary *)GetTheDicpointFromArray:(NSArray *)arrLimit;

-(NSMutableDictionary *)ReadLimitFromConfigFile:(NSString *)filePath;



#pragma mark - Draw Diagram 
-(BOOL)drawDiagramsByMagnitude:(NSArray*)aryMagnitude 
					  andPhase:(NSArray*)aryPhase;



@end


