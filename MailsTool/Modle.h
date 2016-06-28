//
//  Modle.h
//  MailsTool
//
//  Created by allen on 22/3/2016.
//  Copyright © 2016 allen. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface Modle : NSObject
{
    NSMutableDictionary * dicAttributeTitle;
    NSMutableDictionary * dicAttributeMainInfo;
    

}
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSMutableDictionary * dicContent;

+(Modle *)defaultModle;
-(instancetype)initWithDictionary:(NSDictionary *)dicContent atCategory:(NSString *)strCategory;


-(NSNumber *)formatData:(Modle *)ModleData intoFile:(NSString *)FilePath;
-(NSNumber *)setStrCategory :(NSString *)strCategory;


@end
