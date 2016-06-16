//
//  DownloadCell.m
//  DownloadManager
//
//  Created by LeeYZ on 16/6/15.
//  Copyright © 2016年 LeeYZ. All rights reserved.
//

#import "DownloadCell.h"

#import "DownloadModelItem.h"

@interface DownloadCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *downloadOptBtn;
@end

@implementation DownloadCell

#pragma mark - Lifycycle
- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Property Method
- (void)setDownloadModel:(DownloadModelItem *)downloadModel {
    _downloadModel = downloadModel;
    
    self.nameLabel.text = downloadModel.fileName;
    self.progressBar.progress = downloadModel.progress;
    [self setCellInfoWithStatus:downloadModel.status];
    
    __weak typeof(self) WS = self;
    downloadModel.progressBlock = ^(float progress, NSUInteger bytesRead, unsigned long long totalRead, unsigned long long totalExpectedToRead) {
        WS.progressBar.progress = progress;
        [WS setSpeedWithSpeedStr:WS.downloadModel.speed];
    };
    downloadModel.successBlock = ^(ZZDownloadRequest *request, id responseObject) {
        [WS setCellInfoWithStatus:DownloadStatusFinished];
        [WS setSpeedWithSpeedStr:ZeroSpeedString];
    };
    downloadModel.cancelBlock = ^(ZZDownloadRequest *request) {
        [WS setCellInfoWithStatus:DownloadStatusCancel];
        [WS setSpeedWithSpeedStr:ZeroSpeedString];
    };
    downloadModel.failureBlock = ^(ZZDownloadRequest *request, NSError *error) {
        [WS setCellInfoWithStatus:DownloadStatusFailed];
        [WS setSpeedWithSpeedStr:ZeroSpeedString];
    };
}

#pragma mark - Private Method
- (void)setCellInfoWithStatus:(DownloadStatus)status {
    NSString *introStr = @"下载";
    NSString *btnTitle = @"下载";
    switch (status) {
        case DownloadStatusNormal:
            break;
        case DownloadStatusWait:
            introStr = @"等待下载";
            btnTitle = @"等待";
            break;
        case DownloadStatusDownloading:
            introStr = @"正在下载...";
            btnTitle = @"暂停";
            break;
        case DownloadStatusPause:
            introStr = @"暂停下载";
            btnTitle = @"下载";
            break;
        case DownloadStatusCancel:
            introStr = @"取消下载";
            btnTitle = @"下载";
            break;
        case DownloadStatusFinished:
            introStr = @"下载完成";
            btnTitle = @"已完成";
            break;
        case DownloadStatusFailed:
            introStr = @"下载失败";
            btnTitle = @"重试";
            break;
    }
    self.infoLabel.text = introStr;
    [self.downloadOptBtn setTitle:btnTitle forState:UIControlStateNormal];
    self.speedLabel.text = self.downloadModel.speed;
}

- (void)setSpeedWithSpeedStr:(NSString *)speed {
    self.speedLabel.text = speed;
}

#pragma mark - Public Method
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *CellID = @"DownloadCellID";
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadCell" owner:nil options:nil] lastObject];
    } else {
        cell.downloadModel.progressBlock = nil;
        cell.downloadModel.successBlock = nil;
        cell.downloadModel.cancelBlock = nil;
        cell.downloadModel.failureBlock = nil;
    }
    return cell;
}

#pragma mark - Action
- (IBAction)OnDownloadOptBtnTap:(UIButton *)sender {
    switch (self.downloadModel.status) {
        case DownloadStatusNormal:
            case DownloadStatusPause:
            case DownloadStatusCancel:
            case DownloadStatusFailed:
            [self.downloadModel start];
            break;
        case DownloadStatusWait:
        case DownloadStatusDownloading:
            [self.downloadModel pause];
            break;
        case DownloadStatusFinished:
            break;
    }
    [self setCellInfoWithStatus:self.downloadModel.status];
}

@end