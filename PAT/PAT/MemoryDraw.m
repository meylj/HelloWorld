#import "MemoryDraw.h"



@implementation MemoryDraw



@synthesize Color			= m_color;
@synthesize XValues			= m_aryXValues;
@synthesize YValues			= m_aryYValues;
@synthesize LineWidth		= m_fLineWidth;
@synthesize Choice			= m_iChoice;
@synthesize Size			= m_size;
@synthesize Cancel			= m_uiCancel;



- (id)init
{
    self = [super init];
    if (self)
    {
        m_aryXValues	= [[NSMutableArray alloc] init];
        m_aryYValues	= [[NSMutableArray alloc] init];
        m_color			= [NSColor redColor];
        m_fLineWidth	= 1;
        m_iChoice		= 0;
        m_size			= NSMakeSize(0, 0);
        m_uiCancel		= NOCANCEL;
    }
    return self;
}



- (void)dealloc
{
    [m_aryXValues release];
    [m_aryYValues release];
    [super dealloc];
}



@end


