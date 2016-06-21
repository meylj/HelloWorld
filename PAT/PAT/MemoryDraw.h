#import <Foundation/Foundation.h>



enum 
{
    NOCANCEL,
    CANLIMITLINE,
    CANCELSMITH,
    CANCELNORMALCHART,
}CANCHOICE;



/*!
 *	@author	Soshon Ran
 *	@since	2011-12-06
 *			Creation. 
 */
@interface MemoryDraw : NSObject 
{
@private
    NSColor			*m_color;		//line Color Info(default is red)
    NSMutableArray  *m_aryXValues;	//X value
    NSMutableArray  *m_aryYValues;	//Y value
    CGFloat         m_fLineWidth;	//line winewindth(default is 1)
    NSUInteger      m_iChoice;		//your choice  0 is beeline(default),1 is curve,2 is oval.
    NSSize          m_size;			//if m_iChoice == 2,The width and height will must not nil;
    NSUInteger      m_uiCancel;		//if not NOCANCEL, It means that will cancel this object(self). 
										//(default is NOCANCEL)
}



@property (assign, readwrite)	NSColor         *Color;
@property (assign, readwrite)	NSMutableArray  *XValues;
@property (assign, readwrite)	NSMutableArray  *YValues;
@property (readwrite)			CGFloat			LineWidth;
@property (readwrite)			NSUInteger		Choice;
@property (readwrite)			NSUInteger		Cancel;
@property (readwrite)           NSSize          Size;



@end


