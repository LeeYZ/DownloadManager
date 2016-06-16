//
//  ZZBaseDownloadModel.h
//  DownloadManager
//
//  Created by LeeYZ on 16/6/15.
//  Copyright © 2016年 LeeYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZZDownloadRequest.h"

typedef enum : NSUInteger {
    DownloadStatusNormal,
    DownloadStatusWait,
    DownloadStatusDownloading,
    DownloadStatusPause,
    DownloadStatusCancel,
    DownloadStatusFinished,
    DownloadStatusFailed
} DownloadStatus;

extern NSString * const ZeroSpeedString;

@interface ZZBaseDownloadModel : NSObject
@property (nonatomic, strong, readonly) NSString *urlStr;
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) NSString *saveFilePath;
@property (nonatomic, assign, readonly) DownloadStatus status;

@property (nonatomic, assign, readonly) long long totalExpectedToRead;
@property (nonatomic, assign, readonly) long long totalRead;
@property (nonatomic, assign, readonly) NSUInteger bytesRead;
@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, strong, readonly) NSString *speed;

@property (nonatomic, copy) ProgressBlock progressBlock;
@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) FailureBlock failureBlock;

- (instancetype)initWithDownloadUrlStr:(NSString *)urlStr
                       andSaveFilePath:(NSString *)saveFilePath
                              fileName:(NSString *)fileName;
- (void)start;
- (void)pause;
- (void)cancel;
@end
