//
//  eTraveler_Utils.h
//  eTraveler
//
//  Created by Erich on 10/12/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface eTraveler_Utils : NSObject

/*
 * dictionary serializers
 */
+(NSString *)serializeTob64:(NSDictionary *)value;
+(NSDictionary *)deSerializeFromb64:(NSString *)str;

@end
