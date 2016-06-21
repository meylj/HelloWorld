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
#include "ezlink-host.h"
#include "serial.h"

#include <fstream>
#include <iostream>

using namespace std;


#define RETURN_ON_ERROR(Status)             \
{                                      \
    int _UNIQUE_VAR = (Status);        \
    if (_UNIQUE_VAR < 0)        \
    {                                  \
        return _UNIQUE_VAR;            \
    }                                  \
}


#define DIAGS_CMD_TIMEOUT_MS 1000

int main(int Argc, char *Argv[]) {
    EzLinkTransport_t Methods;
    SerialContext_t SerialContext;
    EzLink_t EzLinkInfo;
    ErrorInfo_t *ErrorInfo;
    int Status;
    int i;
    uint8_t *RxBuf;
    uint32_t RxBufSize;
    
    char ReadBuf[2050];
    Methods.TxData = Serial_WriteBytes;
    Methods.RxData = Serial_ReadBytes;
    
    Status = Serial_Open(Argv[1], &SerialContext.Fd, 115200);
    
    if (Status < 0) {
        printf("1.Serial_Open():Status < 0\n");
        return -1;
    }
    else
    {    
        printf("1.Serial_Open():Successs!\n");
    }
    
    //char *arg = "tristar --provision";
    string aa= Argv[2];
    string cmd = "\n" + aa + "\r\n";
    write(SerialContext.Fd, cmd.c_str(), cmd.length());
    printf("cmd.c_str = %s and cmd.length = %ld\n", cmd.c_str(), cmd.length());
    read(SerialContext.Fd,ReadBuf,2050);
    //printf(ReadBuf);
    
    /* 1. Setup the Ezlink with diags */
    Status = EzLink_Setup(&EzLinkInfo, &Methods, &SerialContext);
    if (Status < 0)
    {
        printf("2.EzLink_Setup():Status < 0\n");
        return Status;
    }
    else
    {
        printf("2.EzLink_Setup():Successs!\n");
    }
    
    /* Phase 1 - Receive the provisioning request from diags */
    Status = EzLink_RecvData(&EzLinkInfo, (void **)&RxBuf, &RxBufSize, 2000, &ErrorInfo);
    if (Status < 0)
    {
        printf("3.EzLink_RecvData():Status < 0\n");
        return Status;
    }
    else
    {
        printf("3.EzLink_RecvData():Successs!\n");
    }
    
    printf("RxBuf = Received %u bytes = %s\n", RxBufSize, RxBuf);
    
    char tx_buf[5000]; tx_buf[0]='\0';
    
    
    strcat(tx_buf, "python /vault/JMET.py");
	strcat(tx_buf, " '");
    strcat(tx_buf, (char *)RxBuf);
    strcat(tx_buf, "'\0");
    
    printf("$$$$$$$$$$$$$$$$$$$$\n %s\n\n", tx_buf);
    FILE *fp=popen(tx_buf, "r");
    
    if(fp == NULL)
    {
        printf("Fail to CALL python");
    }
    
    char buf[5000];
    fgets(buf, sizeof(buf), fp);
    printf("buf = B02 %s ####\n", buf);
    pclose(fp);
    
        /* Phase 2 - Send the provisioning info from JMET to diags */
    Status = EzLink_SendData(&EzLinkInfo, buf, sizeof(buf), 1000, &ErrorInfo);
    if(Status != 0) // we should chck the status_code be 0  ???
    {
        printf("4.EzLink_SendData():Status < 0\n");
        return Status;
    }
    else
    {
        printf("4.EzLink_SendData():Successs!\n");
    }
    
//    }
    
    // Zero out the tx_buf, so I can see what Diags is handing up.
    for (i = 0; i < RxBufSize; i++) {
        RxBuf[i] = 0;
    }
    
    /* Phase 3 - Get the provioning response back from diags */
    Status = EzLink_RecvData(&EzLinkInfo, (void **)&RxBuf, &RxBufSize, 2000, &ErrorInfo);
    if (Status < 0)
    {
        printf("5.EzLink_RecvData():Status < 0\n");
        return Status;
    }
    else
    {
        printf("5.EzLink_RecvData():Successs!\n");
    }
    
    tx_buf[0]='\0';
	
	strcat(tx_buf, "python /vault/JMET.py");
//    strcat(tx_buf, "/vault/JMET.py");
	strcat(tx_buf, " '");
    strcat(tx_buf, (char *)RxBuf);
    strcat(tx_buf, "'\0");
    
    printf("$$$$$$$$$$$$$$$$$$$$\n %s\n\n", tx_buf);
    
    FILE *fp1=popen(tx_buf, "r");
    
    if(fp1 == NULL)
    {
        printf("Fail to CALL python");
    }
    
//    char buf1[2048];
	char buf1[5000];
    fgets(buf1, sizeof(buf1), fp1);
    
    printf("Received %u bytes\n", RxBufSize);
    return 0;
}
