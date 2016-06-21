#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include "serial.h"

static ssize_t _Serial_Read (
        int filedes, 
        void *buf, 
        size_t nbytes, 
        unsigned int timeout_ms
        )
{
    struct timeval tv;
    fd_set fds;
    int ret;

    tv.tv_sec = timeout_ms  / 1000;
    tv.tv_usec = (timeout_ms % 1000) * 1000;

    FD_ZERO(&fds);
    FD_SET(filedes, &fds);

    /* Use select to wait till a read descriptor is set */
    ret = select(filedes + 1, &fds, NULL, NULL, &tv);

    /* We got data - read as much as we can and return to the user */
    if (ret > 0) {
        ret = read(filedes, buf, nbytes);
        return ret;
    }
    else {
        return -ETIMEDOUT;
    }
}


int Serial_Open (
    char            *Port,
    int             *Fd,
    int             BaudRate
    )
{
    struct termios OldTio;
    struct termios NewTio;
    int SerialFd;
    int Ret;

    SerialFd = open(Port, O_RDWR | O_NOCTTY); 
    if (SerialFd < 0) {
        printf("Could not open serial port: %d\n", errno);
        return -1;
    }

    *Fd = SerialFd;

    /* Get old attributes */
    tcgetattr(SerialFd, &OldTio);
    bzero(&NewTio, sizeof(NewTio));
       
    /* Setup the serial port attributes */ 
    NewTio.c_cflag = CS8 | CREAD;
    NewTio.c_oflag = 0;
    NewTio.c_iflag = IGNPAR;
    NewTio.c_lflag = 0;
    NewTio.c_cc[VMIN] = 0;
    NewTio.c_cc[VTIME] = 0;

    /* Mac OS/X requires a special ioctl to set higher baud rates */
    if (BaudRate <= 115200) {
        if (cfsetospeed(&NewTio, BaudRate) < 0) {
            printf("Couldn't set speed!\n");
            return -1;
        }
    
        cfmakeraw(&NewTio);
        tcsetattr(SerialFd, TCSANOW, &NewTio);
        Ret = tcflush(SerialFd, TCIOFLUSH);
        if (Ret < 0) {
            printf("Couldn't flush serial port!\n");
            return Ret;
        }
    }
    else {
        tcsetattr(SerialFd, TCSANOW, &NewTio);
        
#ifndef IOSSIOSPEED
#define IOSSIOSPEED _IOW('T', 2, speed_t)
#endif
        Ret = ioctl(SerialFd, IOSSIOSPEED, &BaudRate);
        if (Ret < 0) {
            printf("Canot set speed!\n");
            return -1;
        }
    }

    /* This delay is needed to stabilize the serial port */
    usleep(50 * 1000);

    return 0;
}


int Serial_ReadBytes (
        void        *Context,
        void        *Buf, 
        uint32_t    NumBytes,
        int32_t     TimeOutInMs
        )
{
    int Ret;
    unsigned char *Ptr = (unsigned char *)Buf;
    unsigned int TotalBytes = 0;
    SerialContext_t *SerialContext = (SerialContext_t *)Context;

    while (NumBytes) {
        Ret = _Serial_Read(SerialContext->Fd, Ptr, NumBytes, TimeOutInMs);
        if (Ret < 0) {
            return Ret;
        }

        Ptr += Ret;
        NumBytes -= Ret;
        TotalBytes += Ret;
    }

    return 0;
}

void
PrintBytes (
        void        *Buf,
        uint32_t    NumBytes
        )
{
    int i;

    for (i = 0; i < NumBytes; i++) {
        printf("0x%02x ", ((uint8_t*)Buf)[i]);
        if ((i != 0) && (i % 8 == 0)) {
            printf("\n");
        }
    }
}

int Serial_WriteBytes (
        void        *Context,
        void        *Buf,
        uint32_t    NumBytes 
        )
{
    SerialContext_t *SerialContext = (SerialContext_t *)Context;
    if (!Context) {
        return -1;
    }

    //PrintBytes(Buf, NumBytes);
    return write(SerialContext->Fd, Buf, NumBytes);
}
