//
//  IADevice_Audio.m
//  FunnyZone
//
//  Created by Eagle on 10/31/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "IADevice_Audio.h"

@implementation TestProgress (IADevice_Audio)

// Get Audio Frenquecy From Fixture
// Param:
//          NSDictionary    *dicPara 
//      NSMutableString   *strReturnValue    : Return value

- (NSNumber *)GetAudioCardFFTResult:(NSDictionary *)dicPara ReturnValue:(NSMutableString *)strReturnValue
{
    Audio_FFT *audioFFT = [[Audio_FFT alloc] init];   //add for calculate frequency
    float        fLeftFreq,fRightFreq,fLeftScope,fRightScope;
	ATSDebug(@"Audio_FFT_Start");
	[audioFFT OutPutFFTResult:&fLeftFreq RFreq:&fRightFreq LScope:&fLeftScope RScope:&fRightScope];	
	ATSDebug(@"Audio_FFT__%f__%f__%f__%f",fLeftFreq,fRightFreq,fLeftScope,fRightScope);
    [strReturnValue setString: [NSString stringWithFormat:@"Audio_FFT__LF:(%f)__RF:(%f)__LS:(%f)__RS:(%f)",fLeftFreq,fRightFreq,fLeftScope,fRightScope]];
    [audioFFT release];
	return [NSNumber numberWithBool:YES];
}

@end
