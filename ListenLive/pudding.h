//
//  pudding.h
//  ListenLive
//
//  Created by raniys on 3/31/15.
//  Copyright (c) 2015 raniys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pudding : NSObject

//get stationINfo
- (NSDictionary *)loadDataFromJsonFile:(NSString *)path;
@end
