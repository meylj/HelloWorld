//
//  Macros.h
//  CheckCableMapping
//
//  Created by Lorky on 7/16/13.
//  Copyright (c) 2013 Lorky. All rights reserved.
//

#ifndef CheckCableMapping_Macros_h
#define CheckCableMapping_Macros_h


/*!	Create an error object with given string format.
 *	Add error domain, the file name and line number where the error occurred. */
#define IAMakeError(error, ...) \
if(error)\
*error	= [NSError errorWithDomain:[NSString stringWithUTF8String:__FILE__]\
code:__LINE__\
userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:__VA_ARGS__]\
forKey:NSLocalizedDescriptionKey]]

/*!	Show error messages in console.
 *	Add the file name and line number where the error occurred. */
#define IAShowError(error) \
NSLog(@"Where: %s (%d)\nWhat: %@", \
__FILE__, __LINE__, [error localizedDescription])

/*!	Show something in console.
 *	Add the file name and line number where the error occurred. */
#define IAShowLog(...) \
NSLog(@"Where: %s (%d)\nWhat: %@", \
__FILE__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])


#endif
