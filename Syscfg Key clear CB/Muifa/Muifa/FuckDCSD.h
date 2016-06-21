#import <Foundation/Foundation.h>



#define kFuckDCSDAddedOSDUTNote		@"kFuckDCSDAddedOSDUTNote"
#define kFuckDCSDRemovedOSDUTNote	@"kFuckDCSDRemovedOSDUTNote"
#define kFuckDCSDOSDUTKey			@"kFuckDCSDOSDUTKey"
#define kFuckDCSDDUTVID				0x05ac
#define kFuckDCSDDUTPID				0x12a8



@interface FuckDCSD : NSObject
{
	
}
+(id)sharedFuckDCSD;
+(NSString*)findLocationID:(NSString*)strBSDPath;
@end




