//
//  ZZBaseDownloadModel.m
//  DownloadManager
//
//  Created by LeeYZ on 16/6/15.
//  Copyright © 2016年 LeeYZ. All rights reserved.
//

#import "ZZBaseDownloadModel.h"

#import "NSString+ZZString.h"

NSString * const ZeroSpeedString = @"0 b/s";

@interface ZZBaseDownloadModel ()
@property (nonatomic, strong) NSString *urlStr;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *saveFilePath;
@property (nonatomic, assign) DownloadStatus status;

@property (nonatomic, assign) long long totalExpectedToRead;
@property (nonatomic, assign) long long totalRead;
@property (nonatomic, assign) NSUInteger bytesRead;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) NSUInteger totalBytes;
@property (nonatomic, assign) long long byteSpeed;
@property (nonatomic, strong) NSDate *lastReadDate;

@property (nonatomic, strong) ZZDownloadRequest *request;
@end

@implementation ZZBaseDownloadModel

- (instancetype)initWithDownloadUrlStr:(NSString *)urlStr
                       andSaveFilePath:(NSString *)saveFilePath
                              fileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        self.urlStr = urlStr;
        self.fileName = fileName;
        self.saveFilePath = saveFilePath;
        self.status = DownloadStatusNormal;
    }
    return self;
}

#pragma mark - Property Method
- (NSString *)urlStr {
    return _urlStr;
}

- (NSString *)fileName {
    return _fileName;
}

- (NSString *)saveFilePath {
    return _saveFilePath;
}

- (DownloadStatus)status {
    return _status;
}

- (long long)totalExpectedToRead {
    return _totalExpectedToRead;
}

- (long long)totalRead {
    return _totalRead;
}

- (NSUInteger)bytesRead {
    return _bytesRead;
}

- (float)progress {
    return _progress;
}

- (NSString *)speed {
    NSString *speed = self.byteSpeed == 0 ? @"0 KB" : [NSByteCountFormatter stringFromByteCount:self.byteSpeed countStyle:NSByteCountFormatterCountStyleFile];
    return [NSString stringWithFormat:@"%@/s", speed];
}

- (NSDate *)lastReadDate {
    if (!_lastReadDate) {
        _lastReadDate = [NSDate date];
    }
    return _lastReadDate;
}

#pragma mark - Private Method
- (BOOL)checkUrlAndSavePathEmpty {
    BOOL isEmpty = NO;
    isEmpty = [self.urlStr isEmpty];
    isEmpty = isEmpty || [self.saveFilePath isEmpty];
    return isEmpty;
}

- (void)doDownload {
    __weak typeof(self) WS = self;
    self.request = [ZZDownloadRequest downloadFileWithURLString:self.urlStr
                                                   downloadPath:self.saveFilePath
                                                       fileName:self.fileName
                                                  progressBlock:^(float progress, NSUInteger bytesRead, unsigned long long totalRead, unsigned long long totalExpectedToRead) {
                                                      WS.totalBytes += bytesRead;
                                                      NSDate *currentDate = [NSDate date];
                                                      //时间差
                                                      double time = [currentDate timeIntervalSinceDate:WS.lastReadDate];
                                                      if (time >= 1) {
                                                          long long speed = WS.totalBytes * 1.0 / time;
                                                          WS.byteSpeed = speed;
                                                          WS.totalBytes = 0.0;
                                                          WS.lastReadDate = currentDate;
                                                      }
                                                      WS.progress = progress;
                                                      WS.bytesRead = bytesRead;
                                                      WS.totalRead = totalRead;
                                                      WS.totalExpectedToRead = totalExpectedToRead;
                                                      if (WS.progressBlock) {
                                                          WS.progressBlock(progress, bytesRead, totalRead, totalExpectedToRead);
                                                      }
                                                  }
                                                   successBlock:self.successBlock
                                                    cancelBlock:self.cancelBlock
                                                   failureBlock:self.failureBlock];
    if (self.request) {
        self.status = DownloadStatusDownloading;
    }
}

- (void)resetInfo {
    self.byteSpeed = 0;
}

#pragma mark - Public Method
- (void)start {
    if ([self checkUrlAndSavePathEmpty]) {
        self.status = DownloadStatusFailed;
        return;
    }
    if (self.status == DownloadStatusFinished || self.status == DownloadStatusDownloading) {
        return;
    }
    [self doDownload];
}

- (void)pause {
    if (self.status == DownloadStatusDownloading) {
        [self.request pauseDownload];
    }
    self.status = DownloadStatusPause;
    [self resetInfo];
}

- (void)cancel {
    self.status = DownloadStatusWait;
    if (self.request == nil) {
        return;
    }
    [self.request cancelDownload];
    [self resetInfo];
}

@end
