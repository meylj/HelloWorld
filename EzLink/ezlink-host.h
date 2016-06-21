#ifndef _EZLINK_HOSTLIB_H
#define _EZLINK_HOSTLIB_H

#include <stdlib.h>
#include <stdint.h>

#define PROTOCOL_VERSION    "1.0"

/* Return code is the number of bytes sent/received, except when error - in that case, 
 * send the negative value of standard error codes. (like -ENOENT)  
 */
typedef struct {
    int (*TxData)(void *Context, void *Buf, uint32_t NumBytes);
    int (*RxData)(void *Context, void *Buf, uint32_t NumBytes, int32_t TimeOutInMs);
} EzLinkTransport_t;

/* Private structure, not relevant to consumer */
typedef struct {
    EzLinkTransport_t TransportMethods;
    uint8_t *RxBuf;
    uint32_t RxBufSize;
    void *TransportContext;
    uint32_t SeqNum;
} EzLink_t;

/* Serial packet types */
typedef enum {
    kEzLinkPktTypeStart,
    kEzLinkPktTypeData,
    kEzLinkPktTypeAck,
    kEzLinkPktTypeError
} EzLinkPktType;

#pragma pack(push, 1)

#define MULTICHARACTER_LITERAL(a,b,c,d)     (((a) << 24) | ((b) << 16) | ((c) << 8) | (d))
#define EZLINK_MAGIC_SIGNATURE              MULTICHARACTER_LITERAL('E', 'Z', 'L', 'K')
#define EZLINK_RESP_TIMEOUT_MS              400

typedef struct {
    int32_t ErrorCode;
    char ErrorString[];
} ErrorInfo_t;

typedef struct {
    uint32_t Magic;				// Should be set to ‘'BINM’
    uint8_t Type;				// Reflect by the EzLinkPktType above
    uint32_t Size;				// Size of data payload that follows
    uint32_t SeqNum;            // Monotonically increasing sequence number 
    uint16_t Checksum;			// 16-bit modular checksum
    uint8_t Data[]; 			// Data payload
} EzLinkPkt;
 
#pragma pack(pop)

/*-----------------------------------------------------------------------------------------------------------------
 * Function:        EzLink_Start
 * Description:     Responsible for starting up host mode with the DUT.
 *
 * Arguments:       
 *      BinInfo -               Pointer to a EzLink_t private structure that gets initialized by this method 
 *      TransportMethods        A set of TX/RX methods passed in by the caller that drives the transport part of this interface 
 *-----------------------------------------------------------------------------------------------------------------*/
extern "C"
{
int EzLink_Setup (
    EzLink_t		 	        *Info,
    EzLinkTransport_t	        *TransportMethods,
    void                        *TransportContext
    );
}

/*-----------------------------------------------------------------------------------------------------------------
 * Function:        EzLink_SendError
 * Description:     Sends an error down to the DUT (which will cause it to exist EzLink mode)
 *
 * Arguments:       
 *      BinInfo -               Pointer to a EzLink_t private structure
 *      ErrorCode               32-bit error contains
 *      ErrorString             (Optional) Error string
 *-----------------------------------------------------------------------------------------------------------------*/
extern "C"
{
int EzLink_SendError (
    EzLink_t                    *Info,
    int32_t                     ErrorCode,
    char                        *ErrorString
    );
}

/*-----------------------------------------------------------------------------------------------------------------
 * Function:        EzLink_SendData
 * Description:     Sends a request to the DUT and waits for an ACK back based on the timeout value provided
 *
 * Arguments:       
 *      BinInfo -               Pointer to a EzLink_t private structure
 *      RequestBuf              Pointer to a buffer that contains the send payload
 *      TimeoutInMs             Amount of time to wait for ACK - if < 0, wait indefinitely. Otherwise, wait for provided 
 *                              duration of time
 *      ErrorInfo               If the DUT signals an error, return the code through this argument (double-pointer that will 
 *                              get updated to point to a valid error structure. User should not free data)
 *-----------------------------------------------------------------------------------------------------------------*/
extern "C"
{
int EzLink_SendData (
    EzLink_t                    *Info,
    void                        *SendBuf,
    uint32_t                    NumSendBytes,
    int32_t                     TimeoutInMs,
    ErrorInfo_t                 **ErrorInfo
    );
}

/*-----------------------------------------------------------------------------------------------------------------
 * Function:        EzLink_RecvData
 * Description:     Wait for a request from the DUT and ACK it once it is received
 *
 * Arguments:       
 *      BinInfo -               Pointer to a EzLink_t private structure
 *      RecvBuf                 Double pointer toa  buffer that gets updated to point to the data sent by the DUT 
 *      NumRecvBytes            Number of bytes received 
 *      TimeoutInMs             Amount of time to wait for request - if < 0, wait indefinitely. Otherwise, wait for provided 
 *                              duration of time
 *      ErrorInfo               If the DUT signals an error, return the code through this argument (double-pointer that will 
 *                              get updated to point to a valid error structure. User should not free data)
 *-----------------------------------------------------------------------------------------------------------------*/
extern "C"
{
int EzLink_RecvData (
    EzLink_t                    *Info,
    void                        **RecvBuf,
    uint32_t                    *NumRecvBytes,
    int32_t                     TimeoutInMs,
    ErrorInfo_t                 **ErrorInfo
    );
}

/*-----------------------------------------------------------------------------------------------------------------
 * Function:        EzLink_Teardown 
 * Description:     Stops EzLink mode - no signal is sent down to the DUT in this call
 *
 * Arguments:       
 *      Info -               Pointer to a EzLink_t private structure that gets initialized by this method 
 *-----------------------------------------------------------------------------------------------------------------*/
extern "C"
{
int EzLink_Teardown (
    EzLink_t		 	        *Info
                     );}

#endif
