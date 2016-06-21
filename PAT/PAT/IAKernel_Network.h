#import "IAKernel.h"



#define IAKERNEL_NETWORK_TIMEOUT	5
#define IAKERNEL_NETWORK_PASS		@"0 SFC_OK"



/*!
 *	The old SW get DUT's area from a file, but it is unsafe and inconvenient. 
 *	So we query DUT's area from SFC. 
 *	@author	Izual Azurewrath
 *	@since	2011-12-26
 *			Creation. 
 */
@interface IAKernel (IAKernel_Network)



#pragma mark - Data Access 
/*!
 *	Query data from servlet with POST method. 
 *	@param		dictKeywords
 *				A dictionary that keywords are keys and end symbols are values. 
 *				If the values is empty, it means "\n". 
 *	@param		strURL
 *				Servlet URL with the parameter key. 
 *				http://172.28.144.98/N94Bobcat/N94SFC?p=
 *	@param		dictInfo
 *				Information send to server. 
 *	@param		error
 *				Error description if failed. 
 *	@return		A dictionary that keywords are keys and server response are values. 
 */
-(NSDictionary*)queryData:(NSDictionary*)dictKeywords 
				  fromURL:(NSString*)strURL 
				 withInfo:(NSDictionary*)dictInfo 
					error:(NSError**)error;
-(BOOL)QUERY_DATA:(NSDictionary*)dictProperties 
		  RESULT:(id*)idResult;



@end


