//
//  IAppDelegate.m
//  ICommunication
//
//  Created by chenchao on 13-11-29.
//  Copyright (c) 2013年 chenchao. All rights reserved.
//

#import "IAppDelegate.h"
#import "IModel.h"
@class IModel;
@implementation IAppDelegate
@synthesize cells = m_arrCells;
- (void)dealloc
{
    [m_strSendIP release];
    [m_arrCells release];
    [super dealloc];
}
- (id)init
{
    if (self = [super init])
    {
        m_strSendIP   = [[NSMutableString alloc]init];
        m_arrCells    = [[NSMutableArray alloc]init];
    }
    return self;
}
- (void)awakeFromNib
{
    [_window setTitle:@"ICommunication Tool"];
    [_window setMaxSize:NSMakeSize(600, 400)];
    [_window setMinSize:NSMakeSize(600, 400)];
    [m_iCollectionView setMaxItemSize:NSMakeSize(600, 60)];
    [m_iCollectionView setMinItemSize:NSMakeSize(600, 60)];
    [m_iCollectionView setBackgroundColors:[NSArray arrayWithObjects:[NSColor lightGrayColor],[NSColor clearColor],nil]];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}
- (void)WriteDebugMessage:(NSDictionary*)dicPara
{
    NSString    *strResult = [dicPara objectForKey:@"MSG"];
    IModel *objModel    = [[IModel alloc]init];
    NSString *szDate = [[NSDate date] descriptionWithCalendarFormat:@"%Y%m%d%H%M%S" timeZone:nil locale:nil];
    objModel.Msg = [NSString stringWithFormat:@"[%@]Read:%@",szDate,strResult];
    if ([m_arrCells count] == 5)
    {
        [self removeObjectFromCellsAtIndex:0];
    }
    [self insertObject:objModel inCellsAtIndex:[m_arrCells count]];
    [objModel release];
}

- (void)insertObject:(IModel *)object inCellsAtIndex:(NSUInteger)index
{
    [m_arrCells insertObject:object atIndex:index];
}

- (void)removeObjectFromCellsAtIndex:(NSUInteger)index
{
    [m_arrCells removeObjectAtIndex:index];
}

- (IBAction)btnListen:(id)sender
{
    m_iListenPort = [m_txtListenPort intValue];
    [NSThread detachNewThreadSelector:@selector(Listen) toTarget:self withObject:nil];
    [m_txtListenPort setEnabled:NO];
    [m_btnListen setEnabled:NO];
}

- (IBAction)btnSend:(id)sender
{
    NSString *strCommand = [m_txtSendMessage stringValue];
    [m_strSendIP setString:[m_txtSendIP stringValue]];
    m_iSendPort   = [m_txtSendPort intValue];
    
    [self btnConnectAct:strCommand];
}

- (void)Listen
{
    NSLog(@"Start Listen");
    struct  sockaddr_in servaddr;
    int n;
    char buff[4096];
    
    int m_iListenSocket = socket(AF_INET, SOCK_STREAM,0);
    
    if (m_iListenSocket == -1)
    {
        NSLog(@"create listen socket fail");
    }
    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(m_iListenPort);
    
    //reuse the port
    int reuse = true;
    if (setsockopt(m_iListenSocket, SOL_SOCKET, SO_REUSEPORT, (void *)&reuse,sizeof(int))!=0)
    {
        NSLog(@"Reuse Port Error");
        return ;
    }
    
    //bind to server port
    while (bind(m_iListenSocket, (struct sockaddr *)&servaddr, sizeof(servaddr)) == -1)
    {
        NSLog(@"bind to server fail, will bind again in 5 seconds");
        perror("bind server port fail:");
        sleep(5);
    }
    
    // listen on the socket
    if (listen(m_iListenSocket, 10) == -1)
    {
        NSLog(@"listen socket fail");
    }
    
    int serverSocket;
    while (1)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        if (( serverSocket = accept(m_iListenSocket, (struct sockaddr *)NULL, NULL) )== -1)
        {
            NSLog(@"accept socket error");
            close(serverSocket);
            serverSocket = -1;
            continue;
        }
        
        //receive message from server
        n = (int)recv(serverSocket, buff, 4096, 0);
        if (n > 0)
        {
            NSString *strMsg = [NSString stringWithUTF8String:buff];
            close(serverSocket);
            serverSocket = -1;
            NSLog(@"receive message -> %@, length-> %d",strMsg,n);
            [self performSelectorOnMainThread:@selector(WriteDebugMessage:) withObject:[NSDictionary dictionaryWithObject:strMsg forKey:@"MSG"] waitUntilDone:YES];
            memset(buff, 0, sizeof(buff));
        }
        else
        {
            close(serverSocket);
            serverSocket = -1;
        }
        [pool drain];
        usleep(1000);
    }
    NSLog(@"End Listen");
}

- (void)btnConnectAct:(NSString*)MsgSend
{
    NSString    *szIP   = m_strSendIP;
    int         iPort   = m_iSendPort;
    if (!szIP || 7 > [szIP length] || 15 < [szIP length] || [[szIP componentsSeparatedByString:@"."] count] != 4)
    {
        NSLog(@"IP format fail");
        return ;
    }
    if ([MsgSend isEqualToString:@""] || [MsgSend isEqualToString:nil])
    {
        NSLog(@"MsgSend format fail");
        return;
    }
    int iSendSocket = -1;
    iSendSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (iSendSocket == -1)
    {
        NSLog(@"new socket Fail");
        return ;
    }
    // set reuse addr
    int reuse = true;
    if(setsockopt(iSendSocket,SOL_SOCKET,SO_REUSEADDR,(void *)&reuse,sizeof(int))!=0)
    {
        NSLog(@"setsockopt SO_REUSEADDR fail");
        close(iSendSocket);
        return ;
    }
    // set reuse port
    if (setsockopt(iSendSocket, SOL_SOCKET, SO_REUSEPORT, (void *)&reuse,sizeof(int))!=0)
    {
        NSLog(@"Reuse Port SO_REUSEPORT fail");
        close(iSendSocket);
        return ;
    }
    // Connect to IP
    struct sockaddr_in server_addr;
    socklen_t server_size = sizeof(server_addr);
    memset(&server_addr, 0, server_size);
    bzero(&server_addr, sizeof(struct sockaddr_in));
    server_addr.sin_family  = AF_INET;
    server_addr.sin_port = htons(m_iSendPort);
    server_addr.sin_addr.s_addr = inet_addr([szIP UTF8String]);
    
    if (connect(iSendSocket, (struct sockaddr*)&server_addr, server_size) == -1)
    {
        perror("connect error");
        NSLog(@"Can't connect to Robot [IP: %@, Port: 8888].", szIP);
		close(iSendSocket);
        return;
    }
    NSLog(@"connect to Robot [IP: %@, Port: %d] ok", szIP,iPort);
    @try
    {
        send(iSendSocket, [MsgSend UTF8String],[MsgSend length], 0);
        NSLog(@"Success send to robot: %@",MsgSend);
        
        IModel *objModel    = [[IModel alloc]init];
        NSString *szDate = [[NSDate date] descriptionWithCalendarFormat:@"%Y%m%d%H%M%S" timeZone:nil locale:nil];
        objModel.Msg = [NSString stringWithFormat:@"[%@]Send:%@",szDate,MsgSend];
        if ([m_arrCells count] == 5)
        {
            [self removeObjectFromCellsAtIndex:0];
        }

        [self insertObject:objModel inCellsAtIndex:[m_arrCells count]];
        [objModel release];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Write Data Fail\n");
        NSLog(@"%@: %@\n", exception.name, exception.reason);
    }
    @finally
    {
        close(iSendSocket);
    }
}

//- (NSString *)GetLocalIPOfNIC:(NSString*)NIC
//{
//    if (!NIC || [NIC isEqualToString:@""])
//    {
//        NIC = @"en0";
//    }
//
//    struct ifreq ifr;
//    struct sockaddr_in *sin;
//
//    int fd=-1;
//    fd = socket(PF_INET, SOCK_DGRAM, 0);
//    if (fd<0)
//    {
//        return nil;
//    }
//    memset(&ifr, 0x00, sizeof(ifr));
//    strcpy(ifr.ifr_name, [NIC UTF8String]);
//    ioctl(fd, SIOCGIFADDR, &ifr);
//    close(fd);
//    sin = (struct sockaddr_in *)&ifr.ifr_addr;
//
//    NSLog(@"local IP:%s",inet_ntoa(sin->sin_addr));
//
//    return [NSString stringWithCString:inet_ntoa(sin->sin_addr)
//                              encoding:NSUTF8StringEncoding];
//}
@end
