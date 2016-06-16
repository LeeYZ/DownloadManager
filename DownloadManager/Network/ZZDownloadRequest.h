//
//  ZZDownloadRequest.h
//  VistaKTX
//
//  Created by LeeYZ on 16/1/8.
//  Copyright © 2016年 LeeYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const *ZZDownloadErrorReasonKey;

@class ZZDownloadRequest;

typedef void(^ProgressBlock)(float progress, NSUInteger bytesRead, unsigned long long totalRead, unsigned long long totalExpectedToRead);
typedef void(^SuccessBlock)(ZZDownloadRequest *request, id responseObject);
typedef void(^CancelBlock)(ZZDownloadRequest *request);
typedef void(^FailureBlock)(ZZDownloadRequest *request, NSError *error);

@interface ZZDownloadRequest : NSObject
@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, copy, readonly) NSDictionary *allRespHeaderFiledDict;
@property (nonatomic, copy, readonly) NSDictionary *allReqHeaderFiledDict;

/**
 *  下载文件
 *
 *  @param URLStirng     文件链接
 *  @param fileName      文件名
 *  @param progressBlock 下载进度回调
 *  @param successBlock  下载成功回调
 *  @param failureBlock  下载失败回调
 *
 *  @return 下载任务
 */
+ (ZZDownloadRequest *)downloadFileWithURLString:(NSString *)urlStirng
                                        fileName:(NSString *)fileName
                                   progressBlock:(ProgressBlock)progressBlock
                                    successBlock:(SuccessBlock)successBlock
                                     cancelBlock:(CancelBlock)cancelBlock
                                    failureBlock:(FailureBlock)failureBlock;
/**
 *  下载文件
 *
 *  @param URLStirng     文件链接
 *  @param fileName      文件名
 *  @param downloadPath  下载位置(不带文件名)
 *  @param progressBlock 下载进度回调
 *  @param successBlock  下载成功回调
 *  @param failureBlock  下载失败回调
 *
 *  @return 下载任务
 */
+ (ZZDownloadRequest *)downloadFileWithURLString:(NSString *)urlStirng
                                    downloadPath:(NSString *)downloadPath
                                       fileName:(NSString *)fileName
                                   progressBlock:(ProgressBlock)progressBlock
                                    successBlock:(SuccessBlock)successBlock
                                     cancelBlock:(CancelBlock)cancelBlock
                                    failureBlock:(FailureBlock)failureBlock;

/**
 *  暂停下载文件
 *
 *  @param downloadRequest 下载任务
 */
- (void)pauseDownload;

/**
 *  获取文件大小
 *
 *  @param path 本地路径
 *
 *  @return 文件大小
 */
- (unsigned long long)fileSizeForPath:(NSString *)path;
- (void)cancelDownload;
- (BOOL)isDownloading;
- (BOOL)finished;
@end
