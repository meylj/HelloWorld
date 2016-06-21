#ifndef _SERIAL_H
#define _SERIAL_H

#include <stdint.h>

typedef struct {
    int Fd;
} SerialContext_t;

    int Serial_Open (
    char            *Port,
    int             *Fd,
    int             BaudRate
    );


int Serial_ReadBytes (
        void        *Context,
        void        *Buf, 
        uint32_t    NumBytes,
        int32_t     TimeOutInMs
        );

int Serial_WriteBytes (
        void        *Context,
        void        *Buf,
        uint32_t    NumBytes 
        );

#endif

