//
//  ASIKomodo.m
//  AE-Cake
//
//  Created by Scott on 15/3/9.
//  Copyright (c) 2015年 Yaya. All rights reserved.
//

#import "ASIKomodo.h"
#import "NSStringCategory.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation ASIKomodo

@synthesize KOMODO_GH_STID;
@synthesize KOMODO_IP;
@synthesize KOMODO_MAC;
@synthesize KOMODO_USERAGENT;
@synthesize KOMODO_AUID;
@synthesize KOMODO_URL;
@synthesize KOMODO_AV;
@synthesize PEGA_SITE;
@synthesize KOMODO_MONITORID;

- (id)init
{
    self = [super init];
	if (self) {
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

//check komodo is alive or not
- (BOOL)checkKomodoStatus
{
     NSURL *url = [NSURL URLWithString:KOMODO_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    [request startSynchronous];
    NSString *response = [request responseStatusMessage];
    int statusCode = [request responseStatusCode];
    ATSDebug(@"Request parameter is: URL=%@",url);

    if (statusCode >= 200 && statusCode <= 299) {
        return YES;
    }
    ATSDebug(@"Komodo response:%@ ",response);
    return NO;
}

//upload attachment file
- (bool)doUploadWithFile:(NSString *)filePath
                     Svc:(NSString *)svc
                  Result:(NSString *)r
{
    KOMODO_ATTACHMENT = filePath;
    if (svc!=nil) {
        KOMODO_SVC = svc;
    }
    if (r!=nil) {
        KOMODO_R = r;
    }
    //get file size
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long fileSize = [[fileManager attributesOfItemAtPath:filePath error:nil]fileSize];
    KOMODO_MESSAGE = [NSString stringWithFormat:@"%@(%llu)",[filePath lastPathComponent],fileSize];
    
    NSURL *url = [NSURL URLWithString:KOMODO_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObjectsAndKeys:KOMODO_USERAGENT,@"User-Agent", nil]];
    
    [request setPostValue:KOMODO_AUID      forKey:@"auid"];
    [request setPostValue:KOMODO_AV        forKey:@"av"];
    [request setPostValue:KOMODO_SVC       forKey:@"svc"];
    [request setPostValue:KOMODO_R         forKey:@"r"];
    [request setPostValue:KOMODO_GH_STID   forKey:@"gh_stid"];
    [request setFile:KOMODO_ATTACHMENT     forKey:@"attachment"];
    [request setPostValue:KOMODO_MESSAGE   forKey:@"m"];
    [request setPostValue:KOMODO_IP        forKey:@"ip"];
    [request setPostValue:KOMODO_MAC       forKey:@"mac"];
    ATSDebug(@"Request parameter is: URL=%@ & User_Agent=%@ & auid=%@ & av=%@ & svc=%@ & r=%@ & gh_stid=%@ attachment=%@ & m=%@ & ip=%@ & mac=%@",url,KOMODO_USERAGENT,KOMODO_AUID,KOMODO_AV,KOMODO_SVC,KOMODO_R,KOMODO_GH_STID,KOMODO_ATTACHMENT,KOMODO_MESSAGE,KOMODO_IP,KOMODO_MAC);
    [request startSynchronous];
    NSString *response = [request responseString];
    NSError *error = [request error];
    if (!error && [response contains:@"SUBMIT:OK"]) {
        KOMODO_DBID = [response subByRegex:@"MONITOR ID:(.*?)-" name:nil error:nil];
        KOMODO_MONITORID = [response subByRegex:@"-(.*?)\n" name:nil error:nil];
        ATSDebug(@"Upload response is:%@", response);
        return YES;
    }
    ATSDebug(@"Upload response is:%@", response);
    return NO;
}

//upload real time case
- (bool)doEventWithFile:(NSString *)csvmsg
                     Svc:(NSString *)svc
                  Result:(NSString *)r
{
    if (svc!=nil) {
          KOMODO_SVC = svc;
    }
    if (r!=nil) {
         KOMODO_R = r;
    }
    //get file size

    KOMODO_MESSAGE = [NSString stringWithString:csvmsg];
   
    NSURL *url = [NSURL URLWithString:KOMODO_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    //[request setRequestMethod:@"HEAD"];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObjectsAndKeys:KOMODO_USERAGENT,@"User-Agent", nil]];
    
    [request setPostValue:KOMODO_AUID      forKey:@"auid"];
    [request setPostValue:KOMODO_AV        forKey:@"av"];
    [request setPostValue:KOMODO_SVC       forKey:@"svc"];
    [request setPostValue:KOMODO_R         forKey:@"r"];
    [request setPostValue:KOMODO_GH_STID   forKey:@"gh_stid"];
    [request setPostValue:KOMODO_MESSAGE   forKey:@"m"];
    [request setPostValue:KOMODO_IP        forKey:@"ip"];
    [request setPostValue:KOMODO_MAC       forKey:@"mac"];
    ATSDebug(@"Request parameter is: URL=%@ & Method=post & User_Agent=%@ & auid=%@ & av=%@ & svc=%@ & r=%@ & gh_stid=%@ & m=%@ & ip=%@ & mac=%@",url,KOMODO_USERAGENT,KOMODO_AUID,KOMODO_AV,KOMODO_SVC,KOMODO_R,KOMODO_GH_STID,KOMODO_MESSAGE,KOMODO_IP,KOMODO_MAC);
    [request startSynchronous];
     NSString *response = [request responseString];
    NSError *error = [request error];
    if (!error & [response contains:@"SUBMIT:OK"]) {
        KOMODO_DBID = [response subByRegex:@"MONITOR ID:(.*?)-" name:nil error:nil];
        KOMODO_MONITORID = [response subByRegex:@"-(.*?)\n" name:nil error:nil];
        ATSDebug(@"Upload realtime message response:%@", response);
        return YES;
    }
    ATSDebug(@"Upload realtime message response:%@", response);
    return NO;
}

//Check flag of current station
- (BOOL)checkStationFlag
{
    NSURL *url = [NSURL URLWithString:KOMODO_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //[request setRequestMethod:@"HEAD"];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObjectsAndKeys:KOMODO_USERAGENT,@"User-Agent", nil]];
    
    [request setPostValue:@"getdata"           forKey:@"p"];
    [request setPostValue:KOMODO_AUID          forKey:@"auid"];
    [request setPostValue:KOMODO_AV            forKey:@"av"];
    [request setPostValue:@"9"                 forKey:@"dbid"];
    [request setPostValue:PEGA_SITE            forKey:@"site"];
    [request setPostValue:@"teststation"       forKey:@"reportlevel"];
    [request setPostValue:KOMODO_GH_STID       forKey:@"itemid"];
    [request setPostValue:@"databyteststation" forKey:@"reporttype"];
    [request setPostValue:@"flags"             forKey:@"getvalues"];
    [request setPostValue:@"FLAG"              forKey:@"servicename"];
    ATSDebug(@"Request parameter is: URL=%@ & User_Agent=%@ & p=getdata & auid=%@ & av=%@ & dbid=9 & site=%@ & reportlevel=teststation & itemid=%@ & reporttype=databyteststation & getvalues=flags & servicename=FLAG",url,KOMODO_USERAGENT,KOMODO_AUID,KOMODO_AV,PEGA_SITE,KOMODO_GH_STID);
    [request startSynchronous];
    NSString *response = [request responseString];
    NSError *error = [request error];
    if (!error) {
        if ([response contains:@"flagid"]) {
            ATSDebug(@"No falgid in response:%@", response);
            return NO;
        }
        ATSDebug(@"Check stationFlag response:%@", response);
        return YES;
    }
    ATSDebug(@"Check stationFlag response:%@", response);
    return NO;
}

//set flag
- (BOOL)setStationFlag
{
    NSURL *url = [NSURL URLWithString:KOMODO_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //[request setRequestMethod:@"HEAD"];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObjectsAndKeys:KOMODO_USERAGENT,@"User-Agent", nil]];
    
    [request setPostValue:@"dragonflag"        forKey:@"p"];
    [request setPostValue:KOMODO_AUID          forKey:@"auid"];
    [request setPostValue:KOMODO_AV            forKey:@"av"];
    [request setPostValue:@"5"                 forKey:@"dbid"];
    [request setPostValue:PEGA_SITE            forKey:@"site"];
    [request setPostValue:KOMODO_MONITORID     forKey:@"monitorid"];
    [request setPostValue:@"flag"              forKey:@"action"];
    [request setPostValue:@"Check Network"     forKey:@"message"];
    ATSDebug(@"Request parameter is: URL=%@ & User_Agent=%@ & p=dragonflag & auid=%@ & av=%@ & dbid=5 & site=%@ & monitorid=%@ & action=flag & message=Check Network",url,KOMODO_USERAGENT,KOMODO_AUID,KOMODO_AV,PEGA_SITE,KOMODO_MONITORID);
    [request startSynchronous];
    NSString *response = [request responseString];
    ATSDebug(@"Set stationFlag response:%@", response);
    NSError *error = [request error];
    if (!error)
    {
        if ([response contains:@"flagid"])
        {
            KOMODO_FLAGID = [response subByRegex:@" \"flagid\" : \"(.*?)\"" name:nil error:nil];
            return YES;
        }
        return NO;
    }
    ATSDebug(@"Set stationFlag response:%@", response);
    return NO;
}

//cancel flag
- (BOOL)cancelStationFlag
{
    NSURL *url = [NSURL URLWithString:KOMODO_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //[request setRequestMethod:@"HEAD"];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObjectsAndKeys:KOMODO_USERAGENT,@"User-Agent", nil]];
    
    [request setPostValue:@"dragonflag"        forKey:@"p"];
    [request setPostValue:KOMODO_AUID          forKey:@"auid"];
    [request setPostValue:KOMODO_AV            forKey:@"av"];
    [request setPostValue:@"5"                 forKey:@"dbid"];
    [request setPostValue:PEGA_SITE            forKey:@"site"];
    
    [request setPostValue:KOMODO_MONITORID     forKey:@"monitorid"];
    [request setPostValue:@"clear"              forKey:@"action"];
    [request setPostValue:KOMODO_FLAGID             forKey:@"flagid"];
    [request setPostValue:@"Network OK"     forKey:@"message"];
    ATSDebug(@"Request parameter is: URL=%@ & User_Agent=%@ & p=dragonflag & auid=%@ & av=%@ & dbid=5 & site=%@ & monitorid=%@ & action=clear & flagid=%@ message=Network OK",url,KOMODO_USERAGENT,KOMODO_AUID,KOMODO_AV,PEGA_SITE,KOMODO_MONITORID,KOMODO_FLAGID);
    [request startSynchronous];
    NSString *response = [request responseString];
    ATSDebug(@"Cancel stationFlag response:%@", response);
    NSError *error = [request error];
    if (!error)
    {
        if ([response contains:@"flagid"])
        {
            return YES;
        }
        return NO;
    }
    return NO;
}

//download attachment
-(BOOL)doDownloadFile:(NSString *)filePath
{
    NSURL *url = [NSURL URLWithString:KOMODO_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //[request setRequestMethod:@"HEAD"];
    [request setDownloadDestinationPath:filePath];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObjectsAndKeys:KOMODO_USERAGENT,@"User-Agent", nil]];
    
    [request setPostValue:@"getattachment"  forKey:@"p"];
    [request setPostValue:KOMODO_AUID       forKey:@"auid"];
    [request setPostValue:KOMODO_AV         forKey:@"av"];
    [request setPostValue:KOMODO_DBID       forKey:@"dbid"];
    [request setPostValue:KOMODO_MONITORID  forKey:@"monitorid"];
    
    [request startSynchronous];
    int statusCode = [request responseStatusCode];
    NSString *statusMessage = [request responseStatusMessage];
    if (statusCode == 200) {
        NSLog(@"Download file success, The status message is:%@",statusMessage);
        return YES;
    }
    NSLog(@"Download fail, The status message is:%@",statusMessage);
    return NO;
}

//only for test
- (void)doUploadTest
{
	NSString *szFilePath = @"/vault/Images/1234.csv.zip";
	//set request line
	NSURL *url = [NSURL URLWithString:@"http://17.239.230.122/komodo/index.cgi"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setRequestMethod:@"POST"];
	[request setRequestHeaders:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"komodo-agent/1.0",@"User-Agent", nil]];
	[request setPostValue:@"9-CREAM" forKey:@"svc"];
	[request setPostValue:@"51" forKey:@"r"];
	[request setPostValue:@"PGPD_F05-4F-FD_4_BBS" forKey:@"gh_stid"];
	[request setPostValue:@"PGPD-9895-PANT-9F83-PROJ-131" forKey:@"auid"];
	[request setPostValue:@"1.0" forKey:@"av"];
	[request setPostValue:@"10.18.194.78" forKey:@"ip"];
	[request setFile:szFilePath forKey:@"attachment"];
    [request setPostValue:@"123.csv.zip(3165)" forKey:@"m"];
	[request setPostValue:@"a8:20:66:29:d2:81" forKey:@"mac"];
	
	[request startSynchronous];
	NSError *error = [request error];
	if (!error) {
		NSString *response = [request responseString];
        NSString *strDBID = [response subByRegex:@"MONITOR ID:(.*?)-" name:nil error:nil];
		NSLog(@"%@",strDBID);
	}
}

- (void)doDownloadTest
{
	NSURL *url = [NSURL URLWithString:@"http://17.239.230.122/komodo/index.cgi"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	
	[request setDownloadDestinationPath:@"/vault/ImageDownload/Image.CSV"];
	[request setRequestHeaders:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"komodo-agent/1.0",@"User-Agent", nil]];
	[request setPostValue:@"getattachment" forKey:@"p"];
	[request setPostValue:@"PGPD-9895-PANT-9F83-PROJ-131" forKey:@"auid"];
	[request setPostValue:@"1.0" forKey:@"av"];
	[request setPostValue:@"5" forKey:@"dbid"];
	[request setPostValue:@"5028839" forKey:@"monitorid"];
	
	[request startSynchronous];
	int statusCode = [request responseStatusCode];
		NSString *statusMessage = [request responseStatusMessage];
	if (statusCode == 200) {
		NSLog(@"Download file success, The status message is:%@",statusMessage);
		return;
	}
	NSLog(@"Download fail, The status message is:%@",statusMessage);
	
}

- (void)doUploadTestHttp
{
    NSString *szFilePath = @"/vault/Images/1234.csv.zip";
    //set request line
    NSURL *url = [NSURL URLWithString:@"http://17.239.230.122/komodo/index.cgi"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"komodo-agent/1.0",@"User-Agent", nil]];
    [request setPostValue:@"9-CREAM" forKey:@"svc"];
    [request setPostValue:@"51" forKey:@"r"];
    [request setPostValue:@"PGPD_F05-4F-FD_4_BBS" forKey:@"gh_stid"];
    [request setPostValue:@"PGPD-9895-PANT-9F83-PROJ-131" forKey:@"auid"];
    [request setPostValue:@"1.0" forKey:@"av"];
    [request setPostValue:@"10.18.194.78" forKey:@"ip"];
    [request setFile:szFilePath forKey:@"attachment"];
    [request setPostValue:@"123.csv.zip(3165)" forKey:@"m"];
    [request setPostValue:@"a8:20:66:29:d2:81" forKey:@"mac"];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSString *strDBID = [response subByRegex:@"MONITOR ID:(.*?)-" name:nil error:nil];
        NSLog(@"%@",strDBID);
    }
}
@end
