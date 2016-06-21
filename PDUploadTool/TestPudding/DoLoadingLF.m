//
//  DoLoadingLF.m
//  TestPudding
//
//  Created by Leehua on 5/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//  This file is created for loading library

#import "DoLoadingLF.h"
#import <dlfcn.h>

@implementation DoLoadingLF

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        //Load pudding
        lib_handle_IP = dlopen("/usr/local/lib/libInstantPudding.dylib", RTLD_LOCAL|RTLD_LAZY);
        if (!lib_handle_IP)
            NSLog(@"PuddingPDCA Framework : [%s] Unable to load library: %s\n", __FILE__, dlerror());
        else
        {
            f_IP_getVersion = dlsym(lib_handle_IP, "IP_getVersion");
            if (!f_IP_getVersion)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "f_IP_getVersion");
            else
                NSLog(@"PuddingPDCA Framework : [%s] InstantPudding library v%s", __FILE__, f_IP_getVersion());
            f_IP_UUTStart = dlsym(lib_handle_IP, "IP_UUTStart");
            if (!f_IP_UUTStart)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_UUTStart");
            f_IP_UUTCancel = dlsym(lib_handle_IP, "IP_UUTCancel");
            if (!f_IP_UUTCancel)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "f_IP_Cancel");
            f_IP_success = dlsym(lib_handle_IP, "IP_success");
            if (!f_IP_success)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_success");
            f_IP_reply_getError = dlsym(lib_handle_IP, "IP_reply_getError");
            if (!f_IP_reply_getError)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_reply_getError");
            f_IP_reply_destroy = dlsym(lib_handle_IP, "IP_reply_destroy");
            if (!f_IP_reply_destroy)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_reply_destroy");
            f_IP_addAttribute = dlsym(lib_handle_IP, "IP_addAttribute");
            if (!f_IP_addAttribute)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_addAttribute");
            f_IP_testSpec_create = dlsym(lib_handle_IP, "IP_testSpec_create");
            if (!f_IP_testSpec_create)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testSpec_create");
            f_IP_testSpec_setTestName = dlsym(lib_handle_IP, "IP_testSpec_setTestName");
            if (!f_IP_testSpec_setTestName)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testSpec_setTestName");
            f_IP_testSpec_setSubTestName = dlsym(lib_handle_IP, "IP_testSpec_setSubTestName");
            if (!f_IP_testSpec_setSubTestName)
                NSLog(@"PuddingPDCA Framework : PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testSpec_setSubTestName");
            f_IP_testSpec_setSubSubTestName = dlsym(lib_handle_IP, "IP_testSpec_setSubSubTestName");
            if (!f_IP_testSpec_setSubSubTestName)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testSpec_setSubSubTestName");
            f_IP_testSpec_setLimits = dlsym(lib_handle_IP, "IP_testSpec_setLimits");
            if (!f_IP_testSpec_setLimits)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testSpec_setLimits");
            f_IP_testSpec_setUnits = dlsym(lib_handle_IP, "IP_testSpec_setUnits");
            if (!f_IP_testSpec_setUnits)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testSpec_setUnits");
            f_IP_testSpec_setPriority = dlsym(lib_handle_IP, "IP_testSpec_setPriority");
            if (!f_IP_testSpec_setPriority)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testSpec_setPriority");
            f_IP_testResult_create = dlsym(lib_handle_IP, "IP_testResult_create");
            if (!f_IP_testResult_create)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testResult_create");
            f_IP_testResult_setResult = dlsym(lib_handle_IP, "IP_testResult_setResult");
            if (!f_IP_testResult_setResult)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testResult_setResult");
            f_IP_testResult_setMessage = dlsym(lib_handle_IP, "IP_testResult_setMessage");
            if (!f_IP_testResult_setMessage)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testResult_setMessage");
            f_IP_addResult = dlsym(lib_handle_IP, "IP_addResult");
            if (!f_IP_addResult)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_addResult");
            f_IP_testResult_destroy = dlsym(lib_handle_IP, "IP_testResult_destroy");
            if (!f_IP_testResult_destroy)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testResult_destroy");
            f_IP_addBlob = dlsym(lib_handle_IP, "IP_addBlob");
            if (!f_IP_addBlob)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_addBlob");
            f_IP_UUTDone = dlsym(lib_handle_IP, "IP_UUTDone");
            if (!f_IP_UUTDone)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_UUTDone");
            f_IP_UUTCommit = dlsym(lib_handle_IP, "IP_UUTCommit");
            if (!f_IP_UUTCommit)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_UUTCommit");
            f_IP_testSpec_destroy = dlsym(lib_handle_IP, "IP_testSpec_destroy"); 
            if (!f_IP_testSpec_destroy)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testSpec_destroy");
            f_IP_UID_destroy = dlsym(lib_handle_IP, "IP_UID_destroy"); 
            if (!f_IP_UID_destroy)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_UID_destroy");
            f_IP_testResult_setValue = dlsym(lib_handle_IP, "IP_testResult_setValue"); 
            if (!f_IP_testResult_setValue)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_testResult_setValue");
            f_IP_validateSerialNumber = dlsym(lib_handle_IP, "IP_validateSerialNumber");
            if (!f_IP_validateSerialNumber)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_validateSerialNumber");
            f_IP_amIOkay = dlsym(lib_handle_IP, "IP_amIOkay");
            if (!f_IP_amIOkay)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_amIOkay");
            f_IP_getGHStationInfo = dlsym(lib_handle_IP, "IP_getGHStationInfo");
            if (!f_IP_getGHStationInfo)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "IP_getGHStationInfo");		
            f_IP_setDUTPosition = dlsym(lib_handle_IP, "IP_setDUTPosition");
            if (!f_IP_setDUTPosition)
                NSLog(@"PuddingPDCA Framework : [%s] Unable to load function: %s\n", __FILE__, "f_IP_setDUTPosition");
        }

        NSString *strErrDesc = [NSString stringWithFormat:@"PuddingPDCA Framework : [%s] Unable to load InstantPudding library",__FILE__];
        NSAssert(lib_handle_IP,@"%@",strErrDesc);
    }    
    return self;
}

- (void)dealloc 
{
    if (!lib_handle_IP)
		dlclose(lib_handle_IP);
    [super dealloc];
}    

@end
