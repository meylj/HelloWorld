//
//  CommonDefine.h
//  MailsTool
//
//  Created by allen on 6/22/16.
//  Copyright © 2016 allen. All rights reserved.
//

#ifndef CommonDefine_h
#define CommonDefine_h

#define Str_AppleScript_Send                [NSString stringWithFormat:@"tell application \"Mail\" \ntell newMessage\ndelay 1\nsend\nend tell\nend tell\n"]

#define Str_AppleScript_Attachment          @"tell application \"Mail\"\ntell newMessage\ntry\nmake new attachment with properties {file name:theAttachmentFile} at after the last word of the last paragraph\nend try\nend tell\nend tell\n"






#endif /* CommonDefine_h */
