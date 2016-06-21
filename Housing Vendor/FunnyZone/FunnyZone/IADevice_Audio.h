//
//  IADevice_Audio.h
//  FunnyZone
//
//  Created by Eagle on 10/31/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "TestProgress.h"
#import "Audio_FFT/Audio_FFT.h"
@interface TestProgress (IADevice_Audio)

// Get Audio Frenquecy From Fixture
// Param:
//          NSDictionary    *dicPara 
//      NSMutableString   *strReturnValue    : Return value

- (NSNumber *)GetAudioCardFFTResult:(NSDictionary *)dicPara ReturnValue:(NSMutableString *)strReturnValue;

@end
