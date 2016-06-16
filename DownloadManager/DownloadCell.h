//
//  DownloadCell.h
//  DownloadManager
//
//  Created by LeeYZ on 16/6/15.
//  Copyright © 2016年 LeeYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownloadModelItem;

@interface DownloadCell : UITableViewCell
@property (nonatomic, strong) DownloadModelItem *downloadModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
