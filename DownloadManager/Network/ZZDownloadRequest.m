//
//  ZZDownloadRequest.m
//  VistaKTX
//
//  Created by LeeYZ on 16/1/8.
//  Copyright © 2016年 LeeYZ. All rights reserved.
//

#import "ZZDownloadRequest.h"

#import "ZZConst.h"

#import "AFNetworking.h"

static NSString *ZZDownloadErrorDomain = @"ZZDownloadErrorDomain";
NSString const *ZZDownloadErrorReasonKey = @"ZZDownloadErrorReasonKey";

static NSString *ZZOperationKey = @"operation";
static NSString *ZZPathKey = @"path";

@interface ZZDownloadRequest () {
    SuccessBlock    _successBlock;
    CancelBlock     _cancelBlock;
    FailureBlock    _failureBlock;
    ProgressBlock   _progressBlock;
    NSString        *_urlString;
    NSString        *_filePath;
}
@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@end

@implementation ZZDownloadRequest

#pragma mark - Lifycycle
- (instancetype)initWithUrlString:(NSString *)urlString
                     downloadPath:(NSString *)downloadPath
                         fileName:(NSString *)fileName
                    progressBlock:(ProgressBlock)progressBlock
                     successBlock:(SuccessBlock)successBlock
                      cancelBlock:(CancelBlock)cancelBlock
                     failureBlock:(FailureBlock)failureBlock {
    self = [super init];
    if (self) {
        _progressBlock  = progressBlock;
        _successBlock   = successBlock;
        _cancelBlock    = cancelBlock;
        _failureBlock   = failureBlock;
        _urlString      = urlString;
        
        [self doDownloadWithPath:downloadPath fileName:fileName];
    }
    return self;
}

#pragma mark - Property Method
- (NSMutableArray *)paths {
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}

- (NSString *)filePath {
    return [_filePath copy];
}

- (NSDictionary *)allReqHeaderFiledDict {
    return [_operation.request.allHTTPHeaderFields copy];
}

- (NSDictionary *)allRespHeaderFiledDict {
    return [_operation.response.allHeaderFields copy];
}

#pragma mark - Method
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

+ (ZZDownloadRequest *)downloadFileWithURLString:(NSString *)urlStirng
                                        fileName:(NSString *)fileName
                                   progressBlock:(ProgressBlock)progressBlock
                                    successBlock:(SuccessBlock)successBlock
                                     cancelBlock:(CancelBlock)cancelBlock
                                    failureBlock:(FailureBlock)failureBlock {
    return [self downloadFileWithURLString:urlStirng
                              downloadPath:nil
                                  fileName:fileName
                             progressBlock:progressBlock
                              successBlock:successBlock
                               cancelBlock:cancelBlock
                              failureBlock:failureBlock];
}

+ (instancetype)downloadFileWithURLString:(NSString *)urlStirng
                             downloadPath:(NSString *)downloadPath
                                 fileName:(NSString *)fileName
                            progressBlock:(ProgressBlock)progressBlock
                             successBlock:(SuccessBlock)successBlock
                              cancelBlock:(CancelBlock)cancelBlock
                             failureBlock:(FailureBlock)failureBlock {
    if (STR_ISNULL_OR_EMPTY(urlStirng)) {
        NSError *error = [NSError errorWithDomain:ZZDownloadErrorDomain code:-100 userInfo:@{ZZDownloadErrorReasonKey : @"下载地址不能为空"}];
        if (failureBlock) {
            failureBlock(nil,error);
        }
        return nil;
    }
    if (STR_ISNULL_OR_EMPTY(fileName)) {
        NSError *error = [NSError errorWithDomain:ZZDownloadErrorDomain code:-101 userInfo:@{ZZDownloadErrorReasonKey : @"文件名不能为空"}];
        if (failureBlock) {
            failureBlock(nil, error);
        }
        return nil;
    }
    return [[self alloc] initWithUrlString:urlStirng
                              downloadPath:downloadPath
                                  fileName:fileName
                             progressBlock:progressBlock
                              successBlock:successBlock
                               cancelBlock:cancelBlock
                              failureBlock:failureBlock];
}

- (void)doDownloadWithPath:(NSString *)downloadPath fileName:(NSString *)fileName {
    downloadPath = downloadPath ?: kCachePath;
    NSString *filePath = [downloadPath stringByAppendingPathComponent:fileName];
    _filePath = filePath;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    unsigned long long downloadedBytes = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //获取已下载的文件长度
        downloadedBytes = [self fileSizeForPath:filePath];
        //检查文件是否已经下载了一部分
        if (downloadedBytes > 0) {
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-",downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
        }
    }
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    //下载请求
    _operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //检查是否已经有该下载任务，如果有，释放掉...
    for (NSDictionary *dict in self.paths) {
        if ([filePath isEqualToString:dict[ZZPathKey]] && ![(AFHTTPRequestOperation *)dict[ZZOperationKey] isPaused]) {
            
        } else {
            [(AFHTTPRequestOperation *)dict[ZZOperationKey] cancel];
        }
    }
    NSDictionary *dictNew = @{ZZPathKey : fileName,
                              ZZOperationKey : _operation};
    [self.paths addObject:dictNew];
    //下载路径
    self.operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
    __block typeof(self) WS = self;
    //下载进度回调
    [self.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        //下载进度
        if (WS->_progressBlock) {
            long long downloadBytes = totalBytesRead + downloadedBytes;
            float progress = ((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
            WS->_progressBlock(progress, bytesRead, downloadBytes, totalBytesExpectedToRead);
        }
    }];
    
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (WS->_successBlock) {
            WS->_successBlock(WS, responseObject);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (WS->_failureBlock) {
            WS->_failureBlock(WS, error);
        }
    }];
    [self.operation start];
}

- (void)pauseDownload {
    [self.operation pause];
}

- (void)cancelDownload {
    [_operation cancel];
}

- (BOOL)isDownloading {
   return [_operation isExecuting];
}

- (BOOL)finished {
    return [_operation isFinished];
}

@end
