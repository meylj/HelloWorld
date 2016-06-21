//
//  CB_TestBase.m
//  FunnyZone
//
//  Created by Eagle on 9/8/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//



#import "CBTestBase.h"



static const char CONTROL_BIT_DYLIB[] = "/usr/local/lib/libCBAuth.dylib";



@implementation CB_LoadLibrary
- (id)init
{
    self = [super init];
    if (self) {
        lib = dlopen(CONTROL_BIT_DYLIB, RTLD_LAZY | RTLD_LOCAL);
        if (lib == NULL) {
            NSLog(@"unable to load %s: %s", CONTROL_BIT_DYLIB, dlerror());
        }
        else
        {
            f_CB_ControlBitsToCheck = dlsym(lib, "ControlBitsToCheck");
            if (!f_CB_ControlBitsToCheck)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_ControlBitsToCheck");
            f_CB_ControlBitsToClearOnPass = dlsym(lib, "ControlBitsToClearOnPass");
            if (!f_CB_ControlBitsToClearOnPass)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_ControlBitsToClearOnPass");
            
            f_CB_ControlBitsToClearOnFail = dlsym(lib, "ControlBitsToClearOnFail");
            if (!f_CB_ControlBitsToClearOnFail)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_ControlBitsToClearOnFail");
            f_CB_StationSetControlBit = dlsym(lib, "StationSetControlBit");
            if (!f_CB_StationSetControlBit)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_StationSetControlBit");
            
            f_CB_StationFailCountAllowed = dlsym(lib, "StationFailCountAllowed");
            if (!f_CB_StationFailCountAllowed)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_StationFailCountAllowed");
            
            f_CB_cbSNGetVersion = dlsym(lib, "cbSNGetVersion");
            if (!f_CB_cbSNGetVersion)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_cbSNGetVersion");
            
            f_CB_GetCountCBsToCheckSN = dlsym(lib, "GetCountCBsToCheckSN");
            if (!f_CB_GetCountCBsToCheckSN)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_GetCountCBsToCheckSN");
            
            f_CB_ControlBitsToCheckSN = dlsym(lib, "ControlBitsToCheckSN");
            if (!f_CB_ControlBitsToCheckSN)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_ControlBitsToCheckSN");
            
            f_CB_GetCountCBsToClearOnPassSN = dlsym(lib, "GetCountCBsToClearOnPassSN");
            if (!f_CB_GetCountCBsToClearOnPassSN)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_GetCountCBsToClearOnPassSN");
            
            f_CB_ControlBitsToClearOnPassSN = dlsym(lib, "ControlBitsToClearOnPassSN");
            if (!f_CB_ControlBitsToClearOnPassSN)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_ControlBitsToClearOnPassSN");
            
            f_CB_GetCountCBsToClearOnFailSN = dlsym(lib, "GetCountCBsToClearOnFailSN");
            if (!f_CB_GetCountCBsToClearOnFailSN)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_GetCountCBsToClearOnFailSN");
            
            f_CB_ControlBitsToClearOnFailSN = dlsym(lib, "ControlBitsToClearOnFailSN");
            if (!f_CB_ControlBitsToClearOnFailSN)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_ControlBitsToClearOnFailSN");
            
            f_CB_StationSetControlBitSN = dlsym(lib, "StationSetControlBitSN");
            if (!f_CB_StationSetControlBitSN)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_StationSetControlBitSN");
            
            f_CB_StationFailCountAllowedSN = dlsym(lib, "StationFailCountAllowedSN");
            if (!f_CB_StationFailCountAllowedSN)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_StationFailCountAllowedSN");
            
            f_CB_cbGetErrMsg = dlsym(lib, "cbGetErrMsg");
            if (!f_CB_cbGetErrMsg)
                NSLog(@"CB Framework : [%s] Unable to load function: %s\n", __FILE__, "f_CB_cbGetErrMsg");
        }
    }
    
    return self;
}

- (void)dealloc
{
    if(lib != NULL)
    {
        dlclose(lib);
        lib = NULL;
    }
    [super dealloc];
}
@end

@implementation CBTestBase

- (id)init
{
    self = [super init];
    if (self) {

    }
    
    return self;
}

- (void)dealloc
{

    [super dealloc];
}


//- (id)init
//{
//    self = [super init];
//    if (self)
//	{
//        lib = dlopen(CONTROL_BIT_DYLIB, RTLD_LAZY | RTLD_LOCAL);
//        if (lib == NULL)
//            NSLog(@"unable to load %s: %s", CONTROL_BIT_DYLIB, dlerror());
//        else
//        {
//#define LOAD_TestBase_CONTROLBIT_SYMBOL(x) \
//if ((x = dlsym(lib, #x)) == NULL) { NSLog(@"unable to load TestBaseControlBit symbol '%s': %s", #x, dlerror());}
//            
//            LOAD_TestBase_CONTROLBIT_SYMBOL(ControlBitsToCheck);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(ControlBitsToClearOnPass);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(ControlBitsToClearOnFail);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(StationFailCountAllowed);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(StationSetControlBit);
//            
//            /*new apis for the ccc-eee codes*/	
//            LOAD_TestBase_CONTROLBIT_SYMBOL(cbSNGetVersion);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(GetCountCBsToCheckSN);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(ControlBitsToCheckSN);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(GetCountCBsToClearOnPassSN);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(ControlBitsToClearOnPassSN);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(GetCountCBsToClearOnFailSN);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(ControlBitsToClearOnFailSN);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(StationSetControlBitSN);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(StationFailCountAllowedSN);
//            LOAD_TestBase_CONTROLBIT_SYMBOL(cbGetErrMsg);
//
//#undef LOAD_TestBase_CONTROLBIT_SYMBOL
//        }
//    }
//    
//    return self;
//}

-(BOOL)ControlBitsToCheck:(NSMutableArray *)aryStationIDsHex
			  stationName:(NSMutableArray *)aryStationNames
{
    size_t	size	= 0;
    bool	bReply	= false;
    
    bReply	= f_CB_ControlBitsToCheck(NULL,&size,NULL);
    
    if(bReply && size> 0 )
    {
        int		*array			= (int *)malloc(size * sizeof(int));
        char	**stationNames	= (char **)malloc(size*sizeof(char *));
        for(int i =0; i<size;i++)
            stationNames[i]	= (char *)malloc(256*sizeof(char));
        
        bReply	= f_CB_ControlBitsToCheck(array,&size,stationNames);
        
        if(bReply)
            for(int i=0; i<size;i++)
            {
                [aryStationIDsHex insertObject:[NSString stringWithFormat:@"0x%02x",array[i]]
									   atIndex:i];
                [aryStationNames insertObject:[NSString stringWithFormat:@"%s",stationNames[i]]
									  atIndex:i];
                printf("ControlBitsToCheck:%02x:%d == %s \n", array[i],array[i],stationNames[i]);
            }
        else
        {
            printf("ControlBitsToCheck:reply was not successful from second call fuction:ControlBitsToCheck.\n");
            printf("ControlBitsToCheck:IP_API_Reply contained an error : \n");
        }
        for(int i=0; i<size;i++)
            free(stationNames[i]);
        free(array);
        free(stationNames);
    }
    else
    {
        printf("ControlBitsToCheck:Size of stations to check : %zd .",size);
        printf("ControlBitsToCheck:reply was not true from first call fuction:ControlBitsToCheck., it might be off in the ghsi file.\n");        
    }
    
    printf("ControlBitsToCheck:Number of iterations %zd: ",size); 
    return bReply;
}

- (BOOL)ControlBitsToClearOnPass:(NSMutableArray *)aryStationIDsHex
{
    bool	bReply	= false;
    size_t	size	= 0;
    
    bReply	= f_CB_ControlBitsToClearOnPass(NULL,&size);
    
    if(bReply && size> 0 )
    {
        int	*array	= (int *)malloc(size * sizeof(int));
        bReply		= f_CB_ControlBitsToClearOnPass(array,&size);
        if(bReply)
            for(int i=0; i<size;i++)
            {
                [aryStationIDsHex insertObject:[NSString stringWithFormat:@"0x%02x",array[i]]
									   atIndex:i];
                printf("ControlBitsToClearOnPass:%02x:%d == ", array[i],array[i]);
            }
        else
            printf("ControlBitsToClearOnPass:reply was not true from second call fuction:ControlBitsToClearOnPass.\n");            
        free(array);        
    }
    else
    {
        printf("ControlBitsToClearOnPass:Size of stations to clear on pass : %zd .",size);
        printf("ControlBitsToClearOnPass:reply was not true from first call fuction:ControlBitsToClearOnPass.\n");        
    }
    
    printf("ControlBitsToClearOnPass:number of iterations: %zd .",size); 
    return bReply;
}

- (BOOL)ControlBitsToClearOnFail:(NSMutableArray *)aryStationIDsHex
{
    bool	bReply	= false;
    size_t	size	= 0;
    bReply	= f_CB_ControlBitsToClearOnFail(NULL,&size);
    
    if(bReply && size> 0 )
    {
        int	*array	= (int *)malloc(size * sizeof(int));
        bReply		= f_CB_ControlBitsToClearOnFail(array,&size);
        if(bReply && size> 0 )
            for(int i=0; i<size;i++)
            {
                [aryStationIDsHex insertObject:[NSString stringWithFormat:@"0x%02x",array[i]]
									   atIndex:i];
                printf("ControlBitsToClearOnFail:%02x:%d == ", array[i],array[i]);
            }            
        else
            printf("ControlBitsToClearOnFail:reply was not true from second call fuction:ControlBitsToClearOnFail.\n");
        free(array);        
    }
    else
    {
        printf("ControlBitsToClearOnFail:Size of stations to clear on fail : %zd .",size);
        printf("ControlBitsToClearOnFail:reply was not true from first call fuction:ControlBitsToClearOnFail.\n");         
    }
    printf("ControlBitsToClearOnFail:number of iterations: %zd .",size); 
    return bReply; 
}

- (BOOL)StationSetControlBit
{
    BOOL	bReply	= f_CB_StationSetControlBit();
	if (bReply)
		printf("Station go ahead and Set the control bit  \n");
	else
		printf("Station do not Set the control bit");
	return bReply;
}

- (int)getStationFailCountAllowed
{
    return f_CB_StationFailCountAllowed();
}

#pragma mark ----------new apis for the ccc-eee codes-----------

/*new apis for the ccc-eee codes*/	
- (int)GetCountCBsToCheckSN:(NSString *)szSerialNumber
{
    return f_CB_GetCountCBsToCheckSN([szSerialNumber UTF8String]);
}

-(int)ControlBitsToCheckSN:(NSString *)szSerialNumber
			 stationIDsHex:(NSMutableArray *)aryStationIDsHex
			   stationName:(NSMutableArray *)aryStationNames
{
    size_t	size	= 0;
    int		iReply	= -522;
    
    iReply	= f_CB_GetCountCBsToCheckSN([szSerialNumber UTF8String]);
    if (iReply >= 0)
        size	= iReply;
    
    if(size> 0)
    {
        int		*array			= (int *)malloc(size * sizeof(int));
        char	**stationNames	= (char **)malloc(size*sizeof(char *));
        for(int i =0; i<size;i++)
            stationNames[i]	= (char *)malloc(256*sizeof(char));
        
        iReply	= f_CB_ControlBitsToCheckSN([szSerialNumber UTF8String],
									   array,
									   &size,
									   stationNames);
        
        if(iReply > 0)
            for(int i=0; i<size;i++)
            {
                [aryStationIDsHex insertObject:[NSString stringWithFormat:@"0x%02x",array[i]]
									   atIndex:i];
                [aryStationNames insertObject:[NSString stringWithFormat:@"%s",stationNames[i]]
									  atIndex:i];
                printf("ControlBitsToCheck:%02x:%d == %s \n", array[i],array[i],stationNames[i]);
            }
        else
        {
            printf("ControlBitsToCheck:reply was not successful from second call fuction:ControlBitsToCheck.\n");
            printf("ControlBitsToCheck:IP_API_Reply contained an error : \n"); 
            
        }
        for(int i=0; i<size;i++)
            free(stationNames[i]);
        free(array);
        free(stationNames);
    }
    else
    {
        printf("ControlBitsToCheck:Size of stations to check : %zd .",size);
        printf("ControlBitsToCheck:reply was not true from first call fuction:ControlBitsToCheck., it might be off in the ghsi file.\n");        
    }
    
    printf("ControlBitsToCheck:Number of iterations %zd: ",size); 
    return iReply;
}

- (int)GetCountCBsToClearOnPassSN:(NSString *)szSerialNumber
{
    return f_CB_GetCountCBsToClearOnPassSN([szSerialNumber UTF8String]);
}

-(int)ControlBitsToClearOnPassSN:(NSString *)szSerialNumber
				   stationIDsHex:(NSMutableArray *)aryStationIDsHex
{
    int		iReply	= -522;
    size_t	size	= 0;
    
    iReply	= f_CB_GetCountCBsToClearOnPassSN([szSerialNumber UTF8String]);
    if (iReply >= 0)
        size	= iReply;
    
    if(size> 0)
    {
        int	*array	= (int *)malloc(size * sizeof(int));
        iReply		= f_CB_ControlBitsToClearOnPassSN([szSerialNumber UTF8String],
												 array,
												 &size);
        if(iReply > 0)
            for(int i=0; i<size;i++)
            {
                [aryStationIDsHex insertObject:[NSString stringWithFormat:@"0x%02x",array[i]] atIndex:i];
                printf("ControlBitsToClearOnPass:%02x:%d == ", array[i],array[i]);
            }
        else
            printf("ControlBitsToClearOnPass:reply was not true from second call fuction:ControlBitsToClearOnPass.\n");
        free(array);        
    }
    else
    {
        printf("ControlBitsToClearOnPass:Size of stations to clear on pass : %zd .",size);
        printf("ControlBitsToClearOnPass:reply was not true from first call fuction:ControlBitsToClearOnPass.\n");        
    }
    
    printf("ControlBitsToClearOnPass:number of iterations: %zd .",size); 
    return iReply;

}

- (int)GetCountCBsToClearOnFailSN:(NSString *)szSerialNumber
{
    return f_CB_GetCountCBsToClearOnFailSN([szSerialNumber UTF8String]);
}

-(int)ControlBitsToClearOnFailSN:(NSString *)szSerialNumber
				   stationIDsHex:(NSMutableArray *)aryStationIDsHex
{
    int		iReply	= -522;
    size_t	size	= 0;
    
    iReply	= f_CB_GetCountCBsToClearOnFailSN([szSerialNumber UTF8String]);
    if (iReply >= 0)
        size	= iReply;
    
    if(size> 0)
    {
        int	*array	= (int *)malloc(size * sizeof(int));
        iReply		= f_CB_ControlBitsToClearOnFailSN([szSerialNumber UTF8String],array,&size);
        if(iReply > 0 )
            for(int i=0; i<size;i++)
            {
                [aryStationIDsHex insertObject:[NSString stringWithFormat:@"0x%02x",array[i]] atIndex:i];
                printf("ControlBitsToClearOnFail:%02x:%d == ", array[i],array[i]);
            }
        else
            printf("ControlBitsToClearOnFail:reply was not true from second call fuction:ControlBitsToClearOnFail.\n"); 
        free(array);        
    }
    else
    {
        printf("ControlBitsToClearOnFail:Size of stations to clear on fail : %zd .",size);
        printf("ControlBitsToClearOnFail:reply was not true from first call fuction:ControlBitsToClearOnFail.\n");         
    }
    printf("ControlBitsToClearOnFail:number of iterations: %zd .",size); 
    return iReply; 

}

- (int)StationSetControlBitSN:(NSString *)szSerialNumber
{
    return f_CB_StationSetControlBitSN([szSerialNumber UTF8String]);
}

- (int)StationFailCountAllowedSN:(NSString *)szSerialNumber
{
    return f_CB_StationFailCountAllowedSN([szSerialNumber UTF8String]);
}

- (NSString *)cbSNGetVersion
{
    return [NSString stringWithFormat:@"%s", f_CB_cbSNGetVersion()];
}

- (NSString *)cbGetErrMsg:(int) errNum;
{
    return [NSString stringWithFormat:@"%s", f_CB_cbGetErrMsg(errNum)];
}

@end




