//
//  NSString+ZZString.m
//  DownloadManager
//
//  Created by LeeYZ on 16/6/15.
//  Copyright © 2016年 LeeYZ. All rights reserved.
//

#import "NSString+ZZString.h"

@implementation NSString (ZZString)

- (BOOL)isEmpty {
    return !self || self.length == 0;
}

@end
