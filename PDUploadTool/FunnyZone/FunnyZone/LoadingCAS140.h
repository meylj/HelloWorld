//
//  LoadingCAS140.h
//  FunnyZone
//
//  Created by 漢青 陳 on 13-7-26.
//  Copyright 2013年 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef int _def_casGetDeviceTypes( void );
typedef char* _def_casGetSerialNumber( int ADevice, char* Dest, int ASize );;
typedef int _def_casCreateDeviceEx( int AInterfaceType, int AInterfaceOption );
typedef int _def_casGetError( int ADevice );
typedef int _def_casInitialize( int ADevice, int Perform );
typedef double _def_casGetDeviceParameter( int ADevice, int AWhat );
typedef int _def_casSetDeviceParameter( int ADevice, int AWhat, double AValue );
typedef int _def_casGetDeviceParameterStringW( int ADevice, int AWhat, unichar* ADest, int AMaxLen );
typedef int _def_casSetDeviceParameterStringW( int ADevice, int AWhat, unichar* AValue);
typedef unichar* _def_casGetDeviceTypeNameW( int AInterfaceType, unichar* Dest, int AMaxLen );
typedef int _def_casGetDeviceTypeOptions( int AInterfaceType );
typedef int _def_casGetDeviceTypeOption( int AInterfaceType, int AIndex );
typedef char* _def_casGetDeviceTypeOptionName( int AInterfaceType, int AOption, char* Dest, int AMaxLen );
typedef unichar* _def_casGetDeviceTypeOptionNameW( int AInterfaceType, int AOption, unichar* Dest, int AMaxLen );
typedef void _def_casSetOptionsOnOff( int ADevice, int AOptions, int AOnOff );
typedef double _def_casGetMeasurementParameter( int ADevice, int AWhat );
typedef int _def_casSetMeasurementParameter( int ADevice, int AWhat, double AValue );
typedef int _def_casMeasureDarkCurrent( int ADevice );
//typedef int _def_casGetShutter( int ADevice );
typedef void _def_casSetShutter( int ADevice, int OnOff );
typedef int _def_casColorMetric( int ADevice );
typedef int _def_casMeasure( int ADevice );
typedef int _def_casPerformAction( int ADevice, int AId );
typedef void _def_casGetPhotInt( int ADevice, double* APhotInt, char* AUnit, int AUnitMaxLen );
typedef void _def_casGetRadInt( int ADevice, double* ARadInt, char* AUnit, int AUnitMaxLen );
typedef void _def_casGetColorCoordinates( int ADevice, double* x, double* y, double* z, double* u, double* v, double* vv );
typedef unichar* _def_casGetErrorMessageW( int AError, unichar* Dest, int AMaxLen );;


_def_casGetDeviceTypes *f_ip_casGetDeviceTypes;
_def_casGetDeviceTypeNameW *f_ip_casGetDeviceTypeNameW;
_def_casGetSerialNumber *f_ip_casGetSerialNumber;
_def_casCreateDeviceEx *f_ip_casCreateDeviceEx;
_def_casGetError *f_ip_casGetError;
_def_casInitialize *f_ip_casInitialize;
_def_casGetDeviceParameter *f_ip_casGetDeviceParameter;
_def_casGetDeviceParameterStringW *f_ip_casGetDeviceParameterStringW;
_def_casSetDeviceParameterStringW *f_ip_casSetDeviceParameterStringW;
_def_casGetDeviceTypeOptions *f_ip_casGetDeviceTypeOptions;
_def_casGetDeviceTypeOption *f_ip_casGetDeviceTypeOption;
_def_casGetDeviceTypeOptionName *f_ip_casGetDeviceTypeOptionName;
_def_casGetDeviceTypeOptionNameW *f_ip_casGetDeviceTypeOptionNameW;
_def_casSetOptionsOnOff *f_ip_casSetOptionsOnOff;
_def_casGetMeasurementParameter *f_ip_casGetMeasurementParameter;
_def_casSetMeasurementParameter *f_ip_casSetMeasurementParameter;
_def_casMeasureDarkCurrent *f_ip_casMeasureDarkCurrent;
//_def_casGetShutter *f_ip_casGetShutter;
_def_casSetShutter *f_ip_casSetShutter;
_def_casSetDeviceParameter *f_ip_casSetDeviceParameter;
_def_casColorMetric *f_ip_casColorMetric;
_def_casMeasure *f_ip_casMeasure;
_def_casPerformAction *f_ip_casPerformAction;
_def_casGetPhotInt *f_ip_casGetPhotInt;
_def_casGetRadInt *f_ip_casGetRadInt;
_def_casGetColorCoordinates *f_ip_casGetColorCoordinates;
_def_casGetErrorMessageW *f_ip_casGetErrorMessageW;
@interface LoadingCAS140 : NSObject
{
    void        *lib_handle_CAS140;
}

@end
