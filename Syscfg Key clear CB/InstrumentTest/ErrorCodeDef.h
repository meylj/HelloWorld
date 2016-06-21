/*
 *  ErrorCodeDef.h
 *  InstrumentTest
 *
 *  Created by 吳 枝霖 on 2009/4/20.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#define		kSuccessCode					0
#define		kNoInitDevice					1
#define		kGPIB_Error						2
#define		kFuncParamterError				3
#define		kPPS_Command_Error				10
#define		kPPS_NumericOutRange			11
#define		kPPS_NumericOverLength			12
#define		kPPS_Command_Sequence_Error		13
#define		kPPS_SetVoltageFail				14
#define		k34970_FetchTimeOut				15
// ======================= Instrument Name ====================
#define		kUnknownDevice					0
#define		kMotechPPS_1201					1
#define		kAgilentPPS_66321				2
// ======================= Resistance Range ===================
#define		kAutoRange						0
#define		k100ohm							100
#define		k1Kohm							1000
#define		k10Kohm							10000
#define		k100Kohm						100000
#define		k1Mohm							1000000
#define		k10Mohm							10000000
#define		k100Mohm						100000000