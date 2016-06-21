//
//  LoadingCAS140.m
//  FunnyZone
//
//  Created by 漢青 陳 on 13-7-26.
//  Copyright 2013年 PEGATRON. All rights reserved.
//

#import "LoadingCAS140.h"
#import <dlfcn.h>
#define CAS140_LIBRYRY_PATH "/usr/local/lib/libCAS4.4.2.0.dylib"
@implementation LoadingCAS140

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        lib_handle_CAS140 = dlopen(CAS140_LIBRYRY_PATH, RTLD_LOCAL|RTLD_LAZY);
        if (lib_handle_CAS140) {
            //
            if (NULL == (f_ip_casGetDeviceTypes = (_def_casGetDeviceTypes *)dlsym(lib_handle_CAS140, "casGetDeviceTypes")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetDeviceTypes");
            if (NULL == (f_ip_casGetDeviceTypeNameW = (_def_casGetDeviceTypeNameW *)dlsym(lib_handle_CAS140, "casGetDeviceTypeNameW")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetDeviceTypeNameW");
            if (NULL == (f_ip_casGetSerialNumber = (_def_casGetSerialNumber *)dlsym(lib_handle_CAS140, "casGetSerialNumber")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetSerialNumber");
            if (NULL == (f_ip_casCreateDeviceEx = (_def_casCreateDeviceEx *)dlsym(lib_handle_CAS140, "casCreateDeviceEx")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casCreateDeviceEx");
            if (NULL == (f_ip_casGetError = (_def_casGetError *)dlsym(lib_handle_CAS140, "casGetError")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetError");
            if (NULL == (f_ip_casInitialize = (_def_casInitialize *)dlsym(lib_handle_CAS140, "casInitialize")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casInitialize");
            if (NULL == (f_ip_casGetDeviceParameterStringW = (_def_casGetDeviceParameterStringW *)dlsym(lib_handle_CAS140, "casGetDeviceParameterStringW")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetDeviceParameterStringW");
            if (NULL == (f_ip_casGetDeviceTypeOptions = (_def_casGetDeviceTypeOptions *)dlsym(lib_handle_CAS140, "casGetDeviceTypeOptions")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetDeviceTypeOptions");
            if (NULL == (f_ip_casGetDeviceTypeOption = (_def_casGetDeviceTypeOption *)dlsym(lib_handle_CAS140, "casGetDeviceTypeOption")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetDeviceTypeOption");
            if (NULL == (f_ip_casGetDeviceTypeOptionName = (_def_casGetDeviceTypeOptionName *)dlsym(lib_handle_CAS140, "casGetDeviceTypeOptionName")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetDeviceTypeOptionName");
            if (NULL == (f_ip_casGetDeviceTypeOptionNameW = (_def_casGetDeviceTypeOptionNameW *)dlsym(lib_handle_CAS140, "casGetDeviceTypeOptionNameW")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetDeviceTypeOptionNameW");
            if (NULL == (f_ip_casSetDeviceParameterStringW = (_def_casSetDeviceParameterStringW *)dlsym(lib_handle_CAS140, "casSetDeviceParameterStringW")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casSetDeviceParameterStringW");
            if (NULL == (f_ip_casSetOptionsOnOff = (_def_casSetOptionsOnOff *)dlsym(lib_handle_CAS140, "casSetOptionsOnOff")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casSetOptionsOnOff");
            if (NULL == (f_ip_casGetMeasurementParameter = (_def_casGetMeasurementParameter *)dlsym(lib_handle_CAS140, "casGetMeasurementParameter")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetMeasurementParameter");
            if (NULL == (f_ip_casSetMeasurementParameter = (_def_casSetMeasurementParameter *)dlsym(lib_handle_CAS140, "casSetMeasurementParameter")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casSetMeasurementParameter");
            if (NULL == (f_ip_casMeasureDarkCurrent = (_def_casMeasureDarkCurrent *)dlsym(lib_handle_CAS140, "casMeasureDarkCurrent")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casMeasureDarkCurrent");
//            if (NULL == (f_ip_casGetShutter = (_def_casGetShutter *)dlsym(lib_handle_CAS140, "casGetShutter")))
//                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetShutter");
            if (NULL == (f_ip_casSetShutter = (_def_casSetShutter *)dlsym(lib_handle_CAS140, "casSetShutter")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casSetShutter");
            if (NULL == (f_ip_casSetDeviceParameter = (_def_casSetDeviceParameter *)dlsym(lib_handle_CAS140, "casSetDeviceParameter")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casSetDeviceParameter");
            if (NULL == (f_ip_casGetDeviceParameter = (_def_casGetDeviceParameter *)dlsym(lib_handle_CAS140, "casGetDeviceParameter")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetDeviceParameter");
            if (NULL == (f_ip_casColorMetric = (_def_casColorMetric *)dlsym(lib_handle_CAS140, "casColorMetric")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casColorMetric");
            if (NULL == (f_ip_casMeasure = (_def_casMeasure *)dlsym(lib_handle_CAS140, "casMeasure")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casMeasure");
            if (NULL == (f_ip_casPerformAction = (_def_casPerformAction *)dlsym(lib_handle_CAS140, "casPerformAction")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casPerformAction");
            if (NULL == (f_ip_casGetPhotInt = (_def_casGetPhotInt *)dlsym(lib_handle_CAS140, "casGetPhotInt")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetPhotInt");
            if (NULL == (f_ip_casGetRadInt = (_def_casGetRadInt *)dlsym(lib_handle_CAS140, "casGetRadInt")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetRadInt");
            if (NULL == (f_ip_casGetColorCoordinates = (_def_casGetColorCoordinates *)dlsym(lib_handle_CAS140, "casGetColorCoordinates")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetColorCoordinates");
//            if (NULL == (f_ip_casGetErrorMessageW = (_def_casGetErrorMessageW *)dlsym(lib_handle_CAS140, "casGetErrorMessageW")))
//                NSLog(@"[%s Line:%d] Unable to load api:[%s]",__FILE__,__LINE__,"casGetErrorMessageW");
            NSLog(@"[%s Line:%d] Success to load lib [%s]",__FILE__,__LINE__,CAS140_LIBRYRY_PATH);
        }
        else
        {
            NSLog(@"[%s Line:%d] Unable to load lib [%s]",__FILE__,__LINE__,CAS140_LIBRYRY_PATH);
        }
    }

    return self;
}

-(void)dealloc
{
    dlclose(lib_handle_CAS140);
    [super dealloc];
}
@end
