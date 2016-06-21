//
//  ASIKomodo.h
//  AE-Cake
//
//  Created by Scott on 15/3/9.
//  Copyright (c) 2015年 Yaya. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ASIKomodo : NSObject
{
    NSString *KOMODO_USERAGENT;         //user agent   "komodo-agent/1.0"
    NSString *KOMODO_URL; 		        //url          "http://17.239.230.122/komodo/index.cgi?"
    NSString *KOMODO_SVC; 				//svc          "9-CREAM"
    NSString *KOMODO_AUID;		        //auid         "PGPD-9895-PANT-9F83-PROJ-131";
    NSString *KOMODO_AV;				//av            "1.0"
    
    NSString *REQUEST_METHOD;           //method        "post"
    NSString *PEGA_SITE; 		        //PGPD
    
    NSString *KOMODO_P; 				//p
    NSString *KOMODO_GET_ATTACHMENT;	//getattachment
    NSString *KOMODO_DBID;			    //dbid
    NSString *KOMODO_MONITORID;		    //monitorid
    NSString *KOMODO_FLAGID;		    //flagid
    
    NSString *KOMODO_ATTACHMENT;		//attachment
    NSString *KOMODO_MESSAGE;		    //m

    NSString *KOMODO_GH_STID; 			//gh_stid
   
    NSString *KOMODO_R;				    //r
    NSString *KOMODO_IP; 				//ip
    NSString *KOMODO_MAC; 				//mac
    
}

@property (copy) NSString *KOMODO_GH_STID;
@property (copy) NSString *KOMODO_IP;
@property (copy) NSString *KOMODO_MAC;
@property (copy) NSString *KOMODO_URL;
@property (copy) NSString *KOMODO_USERAGENT;
@property (copy) NSString *KOMODO_AUID;
@property (copy) NSString *KOMODO_AV;
@property (copy) NSString *PEGA_SITE;
@property (copy) NSString *KOMODO_MONITORID;

//upload attachment
- (bool)doUploadWithFile:(NSString *)filePath
                     Svc:(NSString *)svc
                  Result:(NSString *)r;
//upload to downtime server
- (bool)doEventWithFile:(NSString *)csvmsg
                    Svc:(NSString *)svc
                 Result:(NSString *)r;
//download attachment
-(BOOL)doDownloadFile:(NSString *)filePath;
//check komodo is alive or not
- (BOOL)checkKomodoStatus;
//check flag
- (BOOL)checkStationFlag;
//set flag
- (BOOL)setStationFlag;
//cancelflag
- (BOOL)cancelStationFlag;

//only for test
- (void)doUploadTest;
- (void)doDownloadTest;

@end
