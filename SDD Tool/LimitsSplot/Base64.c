//
//  Base64.c
//  LimitsSplot
//
//  Created by User on 13-1-2.
//  Copyright (c) 2013年 User. All rights reserved.
//

#include <stdio.h>

typedef     int Base64Int;

Base64Int   Base64Encode( char *OrgString, char *Base64String, Base64Int OrgStringLen );
char        GetBase64Value(char ch);
Base64Int   Base64Decode( char *OrgString, char *Base64String,Base64Int Base64StringLen, int bForceDecode);


Base64Int   Base64Encode( char *OrgString, char *Base64String, Base64Int OrgStringLen )
{
	static char Base64Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	unsigned Base64StringLen = 0;
    
	while( OrgStringLen > 0 )
	{
		*Base64String ++ = Base64Encode[(OrgString[0] >> 2 ) & 0x3f];
        
        switch( OrgStringLen )
        {
            case 1:
                *Base64String ++ = Base64Encode[(OrgString[0] & 3) << 4 ];
                *Base64String ++ = '=';
                *Base64String ++ = '=';
                break;
            case 2:
                *Base64String ++ = Base64Encode[((OrgString[0] & 3) << 4) | (OrgString[1] >> 4)];
                *Base64String ++ = Base64Encode[((OrgString[1] & 0x0F) << 2) | (OrgString[2] >> 6)];
                *Base64String ++ = '=';
                break;
            default:
                *Base64String ++ = Base64Encode[((OrgString[0] & 3) << 4) | (OrgString[1] >> 4)];
                *Base64String ++ = Base64Encode[((OrgString[1] & 0xF) << 2) | (OrgString[2] >> 6)];
                *Base64String ++ = Base64Encode[OrgString[2] & 0x3F];
                break;
        }
        
		OrgString +=3;
		OrgStringLen -=3;
		Base64StringLen +=4;
	}
    
	*Base64String = 0;
	return Base64StringLen;
}


char    GetBase64Value(char ch)
{
	if ((ch >= 'A') && (ch <= 'Z'))   // A ~ Z
		return ch - 'A';
	if ((ch >= 'a') && (ch <= 'z'))   // a ~ z
		return ch - 'a' + 26;
	if ((ch >= '0') && (ch <= '9'))   // 0 ~ 9
		return ch - '0' + 52;
	switch (ch)
	{
		case '+':
			return 62;
		case '/':
			return 63;
		case '=':
			return 0;
		default:
			return 0;
	}
}

Base64Int   Base64Decode( char *OrgString, char *Base64String,Base64Int Base64StringLen,int bForceDecode)
{
    // safety protection
	if( Base64StringLen % 4 && !bForceDecode )
	{
		OrgString[0] = '\0';
		return -1;
	}
	char            Base64Encode[4];
	Base64Int       OrgStringLen=0;
    Base64Int       OrgStringLenEqualOffset=0;
    
    if ( Base64StringLen >=2 ) {
        if ( Base64String[Base64StringLen-1] == '=' ) {
            OrgStringLenEqualOffset++;
        }
        if ( Base64String[Base64StringLen-2] == '=' ) {
            OrgStringLenEqualOffset++;
        }
    }
    
	while( Base64StringLen > 3 )
	{
		Base64Encode[0] = GetBase64Value(Base64String[0]);
		Base64Encode[1] = GetBase64Value(Base64String[1]);
		Base64Encode[2] = GetBase64Value(Base64String[2]);
		Base64Encode[3] = GetBase64Value(Base64String[3]);
        
		*OrgString ++ = (Base64Encode[0] << 2) | (Base64Encode[1] >> 4);
		*OrgString ++ = (Base64Encode[1] << 4) | (Base64Encode[2] >> 2);
		*OrgString ++ = (Base64Encode[2] << 6) | (Base64Encode[3]);
        
		Base64String += 4;
		Base64StringLen -= 4;
		OrgStringLen += 3;
	}
    
	return OrgStringLen-OrgStringLenEqualOffset;
}
