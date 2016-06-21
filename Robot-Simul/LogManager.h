//
//  LogManager.h
//  Robot-Simul
//
//  Created by Havi on 13-12-25.
//
//

#import <Foundation/Foundation.h>
#import "normaldefine.h"
#import "StationCline.h"
@class Optimization;
@interface LogManager : NSObject
{

    NSString *strDate;
}
@property (nonatomic,assign) NSString *strDate;

+ (void)creatAndWriteUnitTestedCount:(NSString *)szInfo withPath:(NSString *)path;

+ (void)creatAndWriteRobotLog:(NSString *)strMsg;

+ (void)creatAndWriteResultInfo:(NSString *)szInfo  withPath:(NSString *)path;

+ (void)WriteUnitLog:(NSString *)strMsg;

+ (void)creatAndWriteTestConfiguration:(NSDictionary *)originalCoordinate withStaion:(NSArray *)station andPath:(NSString *)path;

+ (void) writeTheDistanceTableStart:(NSDictionary *)dicLine  andRow:(NSDictionary *)dicRow withPath:(NSString *)path;


@end
