//
//  ViewController.m
//  DownloadManager
//
//  Created by LeeYZ on 16/6/15.
//  Copyright © 2016年 LeeYZ. All rights reserved.
//

#import "ViewController.h"

#import "DownloadModelItem.h"

#import "DownloadCell.h"

#import "ZZConst.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *downloadModels;
@end

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDefault];
}

#pragma mark - Method
- (void)setDefault {
    self.downloadModels = [[NSMutableArray array] mutableCopy];
    
    NSString *url = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.6.dmg";
    for (int i = 0; i < 20 ; i++) {
        NSString *fileName = [NSString stringWithFormat:@"qq_%d.dmg",i];
        DownloadModelItem *downloadModel = [[DownloadModelItem alloc] initWithDownloadUrlStr:url andSaveFilePath:kCachePath fileName:fileName];
        [self.downloadModels addObject:downloadModel];
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadCell *cell = [DownloadCell cellWithTableView:tableView];
    cell.downloadModel = [self.downloadModels objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
