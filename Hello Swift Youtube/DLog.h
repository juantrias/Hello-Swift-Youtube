//
//  DLog.h
//  Hello Swift
//
//  Created by Juan on 14/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

/*
 Custom logs
 */
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif