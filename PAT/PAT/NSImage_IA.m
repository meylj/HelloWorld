#import "NSImage_IA.h"



@implementation NSImage (NSImage_IA)



-(NSComparisonResult)compare:(NSImage*)aImage
{
	return [[self name] compare:[aImage name]];
}



@end


