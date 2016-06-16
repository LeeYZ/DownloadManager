//
//  ZZConst.h
//  DownloadManager
//
//  Created by LeeYZ on 16/6/15.
//  Copyright © 2016年 LeeYZ. All rights reserved.
//

#ifndef ZZConst_h
#define ZZConst_h

#define kCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define EMPTY_STR @""
#define STR_ISNULL_OR_EMPTY(str)       (str == nil || [str isEqualToString:EMPTY_STR] || [str isEqual:[NSNull null]])

#endif /* ZZConst_h */
