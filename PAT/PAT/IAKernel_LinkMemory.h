#import "IAKernel.h"



/*!
 *	@Author	Izual Azurewrath
 *	@Since	2011-12-05
 *			Creation. 
 */
@interface IAKernel (IAKernel_LinkMemory)



-(void)memory:(id)idObject 
	  withKey:(NSString*)strKey;

-(id)memoryForKey:(NSString*)strKey;

/*!	Translate memory. 
 *	@param	strSource
 *			An string with format like a comments. 
 *			All comments will be treat as memory keys. */
-(NSString*)translateMemory:(NSString*)strSource;

-(BOOL)SHOW_MEMORY:(NSDictionary*)dictProperties 
			RESULT:(id*)idResult;



@end


